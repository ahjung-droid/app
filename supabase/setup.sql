-- 홋카이도 여행 수첩 · 공유 저장소 설정 (일정 수정·메모·체크 공유용)
-- Supabase → SQL Editor → New query 에 전체를 붙여넣고 Run.
-- ★ 딱 한 군데: 아래 '여기에-여행-암호' 를 두 사람만 아는 암호로 바꾸세요.
-- 여러 번 실행해도 괜찮아요. 암호를 바꾸고 싶으면 그 줄만 바꿔서 다시 실행하세요.

-- 여행 암호 (앱에서 직접 읽을 수 없고, 아래 함수만 확인해요)
create table if not exists public.trip_secret (
  id int primary key default 1 check (id = 1),
  code text not null
);
alter table public.trip_secret enable row level security;
insert into public.trip_secret (id, code) values (1, '여기에-여행-암호')
  on conflict (id) do update set code = excluded.code;

-- 일정 추가·수정·숨김
create table if not exists public.items (
  id text primary key,
  day int not null,
  data jsonb not null default '{}',
  deleted boolean not null default false,
  updated_by text,
  updated_at timestamptz not null default now()
);
-- 다녀옴 체크, 여행 날짜, 항공편, 공유 앨범 링크 등
create table if not exists public.kv (
  key text primary key,
  value jsonb,
  updated_by text,
  updated_at timestamptz not null default now()
);
-- 테이블은 잠가 두고(정책 없음), 아래 함수로만 읽고 써요
alter table public.items enable row level security;
alter table public.kv    enable row level security;

create or replace function public.trip_check(p_code text) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.trip_secret where code = p_code)
$$;

create or replace function public.trip_load(p_code text) returns jsonb
language plpgsql stable security definer set search_path = public as $$
begin
  if not public.trip_check(p_code) then raise exception 'bad_code'; end if;
  return jsonb_build_object(
    'items', coalesce((select jsonb_agg(jsonb_build_object('id', id, 'day', day, 'data', data, 'deleted', deleted, 'updated_by', updated_by)) from public.items), '[]'::jsonb),
    'kv',    coalesce((select jsonb_agg(jsonb_build_object('key', key, 'value', value)) from public.kv), '[]'::jsonb)
  );
end $$;

create or replace function public.trip_save_item(p_code text, p_id text, p_day int, p_data jsonb, p_deleted boolean, p_by text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not public.trip_check(p_code) then raise exception 'bad_code'; end if;
  insert into public.items (id, day, data, deleted, updated_by, updated_at)
    values (left(p_id, 80), p_day, coalesce(p_data, '{}'::jsonb), coalesce(p_deleted, false), left(p_by, 30), now())
    on conflict (id) do update set day = excluded.day, data = excluded.data, deleted = excluded.deleted,
      updated_by = excluded.updated_by, updated_at = now();
end $$;

create or replace function public.trip_delete_item(p_code text, p_id text) returns void
language plpgsql security definer set search_path = public as $$
begin
  if not public.trip_check(p_code) then raise exception 'bad_code'; end if;
  delete from public.items where id = p_id;
end $$;

create or replace function public.trip_set_kv(p_code text, p_rows jsonb) returns void
language plpgsql security definer set search_path = public as $$
declare r jsonb;
begin
  if not public.trip_check(p_code) then raise exception 'bad_code'; end if;
  for r in select * from jsonb_array_elements(coalesce(p_rows, '[]'::jsonb)) loop
    insert into public.kv (key, value, updated_by, updated_at)
      values (left(r->>'key', 120), r->'value', left(r->>'by', 30), now())
      on conflict (key) do update set value = excluded.value, updated_by = excluded.updated_by, updated_at = now();
  end loop;
end $$;

revoke all on function public.trip_check(text) from public;
revoke all on function public.trip_load(text) from public;
revoke all on function public.trip_save_item(text, text, int, jsonb, boolean, text) from public;
revoke all on function public.trip_delete_item(text, text) from public;
revoke all on function public.trip_set_kv(text, jsonb) from public;
grant execute on function public.trip_check(text) to anon, authenticated;
grant execute on function public.trip_load(text) to anon, authenticated;
grant execute on function public.trip_save_item(text, text, int, jsonb, boolean, text) to anon, authenticated;
grant execute on function public.trip_delete_item(text, text) to anon, authenticated;
grant execute on function public.trip_set_kv(text, jsonb) to anon, authenticated;
