-- 홋카이도 여행 수첩 · 공유 저장소 설정
-- Supabase 대시보드 → SQL Editor → New query 에 전체를 붙여넣고 Run.
-- ① 아래 '여기에-여행-암호' 를 두 사람만 아는 암호로 바꾸세요(8자 이상 추천).
-- 여러 번 실행해도 괜찮아요. 암호를 바꾸고 싶으면 ① 줄만 바꿔서 다시 실행하세요.

-- ① 여행 암호 --------------------------------------------------------------
create table if not exists public.trip_secret (
  id int primary key default 1 check (id = 1),
  code text not null
);
alter table public.trip_secret enable row level security;   -- 정책 없음 = 앱에서 읽을 수 없음
insert into public.trip_secret (id, code) values (1, '여기에-여행-암호')
  on conflict (id) do update set code = excluded.code;

-- ② 여행 멤버 ---------------------------------------------------------------
create table if not exists public.members (
  uid uuid primary key,
  name text,
  joined_at timestamptz not null default now()
);
alter table public.members enable row level security;

create or replace function public.is_member() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.members where uid = auth.uid())
$$;

create or replace function public.join_trip(p_code text, p_name text) returns boolean
language plpgsql security definer set search_path = public as $$
begin
  if auth.uid() is null then return false; end if;
  if not exists (select 1 from public.trip_secret where code = p_code) then return false; end if;
  insert into public.members (uid, name) values (auth.uid(), left(coalesce(p_name, ''), 30))
    on conflict (uid) do update set name = excluded.name;
  return true;
end $$;

revoke all on function public.join_trip(text, text) from public, anon;
grant execute on function public.join_trip(text, text) to authenticated;
grant execute on function public.is_member() to authenticated;

drop policy if exists "members read" on public.members;
create policy "members read" on public.members for select to authenticated using (public.is_member());

-- ③ 데이터 테이블 -------------------------------------------------------------
create table if not exists public.items (          -- 일정 추가·수정·숨김
  id text primary key,
  day int not null,
  data jsonb not null default '{}',
  deleted boolean not null default false,
  updated_by text,
  updated_at timestamptz not null default now()
);
create table if not exists public.kv (             -- 다녀옴 체크, 날짜, 항공편 등
  key text primary key,
  value jsonb,
  updated_by text,
  updated_at timestamptz not null default now()
);
create table if not exists public.photos (         -- 사진 정보(파일은 Storage)
  id text primary key,
  day int,
  spot text,
  caption text,
  path text not null,
  taken_at bigint,
  created_at bigint,
  by_name text
);
alter table public.items  enable row level security;
alter table public.kv     enable row level security;
alter table public.photos enable row level security;

drop policy if exists "trip items"  on public.items;
drop policy if exists "trip kv"     on public.kv;
drop policy if exists "trip photos" on public.photos;
create policy "trip items"  on public.items  for all to authenticated using (public.is_member()) with check (public.is_member());
create policy "trip kv"     on public.kv     for all to authenticated using (public.is_member()) with check (public.is_member());
create policy "trip photos" on public.photos for all to authenticated using (public.is_member()) with check (public.is_member());

-- ④ 사진 파일 저장소(비공개 버킷) ----------------------------------------------
insert into storage.buckets (id, name, public) values ('photos', 'photos', false)
  on conflict (id) do nothing;

drop policy if exists "trip photo files read"   on storage.objects;
drop policy if exists "trip photo files write"  on storage.objects;
drop policy if exists "trip photo files delete" on storage.objects;
create policy "trip photo files read"   on storage.objects for select to authenticated using (bucket_id = 'photos' and public.is_member());
create policy "trip photo files write"  on storage.objects for insert to authenticated with check (bucket_id = 'photos' and public.is_member());
create policy "trip photo files delete" on storage.objects for delete to authenticated using (bucket_id = 'photos' and public.is_member());

-- ⑤ 실시간 반영 -------------------------------------------------------------
do $$
begin
  begin alter publication supabase_realtime add table public.items;  exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.kv;     exception when duplicate_object then null; end;
  begin alter publication supabase_realtime add table public.photos; exception when duplicate_object then null; end;
end $$;
