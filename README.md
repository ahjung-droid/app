# 北海道 여행 수첩

삿포로 · 오타루 · 비에이 3박 4일(2026.10.23~10.26) 여행 앱. `index.html` 하나로 동작합니다.

- **旅 일정**: TW263 / LJ204 항공편 기준 일차별 타임라인. 장소마다 가는 법·예상 비용·지도/길찾기, 참고 사진과 설명·후기·공식 사이트 링크. **일정 추가·수정·숨기기**와 공유 메모
- **食 맛집**: 식사·맥주, 간식·디저트 목록과 가게별 지도·정보·후기 링크
- **写 추억**: 일차·장소별 사진 업로드와 앨범(누가 올렸는지 표시)
- **宿 정보**: 숙소, 항공편, 엔화 계산기, 교통 요금, 일본어 표현, 긴급 연락처

## 동행과 함께 쓰기 (공유 모드)

일정 수정, 다녀옴 체크, 사진이 두 사람 휴대폰에 실시간으로 공유됩니다. 무료 Supabase를 저장소로 쓰고, 앱은 GitHub Pages로 엽니다.

1. **Supabase 프로젝트 만들기**: [supabase.com](https://supabase.com) 가입 → New project. 지역은 Northeast Asia(Seoul 또는 Tokyo), DB 비밀번호는 아무거나(앱에서는 안 씀).
2. **익명 로그인 켜기**: Authentication → Sign In / Providers → *Allow anonymous sign-ins* 켜고 저장.
3. **저장소 만들기**: SQL Editor → New query에 [`supabase/setup.sql`](supabase/setup.sql) 전체를 붙여넣고, 맨 위 `'여기에-여행-암호'`를 두 사람만 아는 암호로 바꾼 뒤 Run.
4. **연결 정보 넣기**: Project Settings → API Keys에서 *Project URL*과 *anon public*(또는 *publishable*) 키를 복사해 [`config.js`](config.js)에 넣기. 둘 다 공개돼도 되는 값이에요. 여행 암호는 여기에 넣지 마세요.
5. **GitHub Pages 켜기**: 저장소 Settings → Pages → Source: *Deploy from a branch*, Branch: `claude/hokkaido-trip-itinerary-app-6b35x3` / `(root)` → Save. 1~2분 뒤 https://ahjung-droid.github.io/app/ 에서 열려요.
6. **휴대폰에서 열기**: 두 사람 모두 위 주소를 열고 이름과 여행 암호를 입력 → 공유 메뉴에서 *홈 화면에 추가*.

참고
- 무료 플랜 저장 용량은 1GB예요. 사진은 긴 변 2048px로 줄여 저장해서 약 2,000장까지 들어가요.
- 무료 프로젝트는 1주일 넘게 사용이 없으면 일시정지돼요. 대시보드에서 *Restore*를 누르면 데이터 그대로 다시 켜져요. 여행 직전에 한 번 열어두세요.
- 여행 암호를 바꾸려면 `setup.sql`의 암호 줄만 바꿔 다시 실행하세요. 이미 들어온 기기는 그대로 유지돼요.
- `config.js`가 비어 있으면 이 기기 브라우저에만 저장하는 모드로 동작해요.
