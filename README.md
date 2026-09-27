# 北海道 여행 수첩

삿포로 · 오타루 · 비에이 3박 4일(2026.10.23~10.26) 여행 앱. `index.html` 하나로 동작합니다.

- **旅 일정**: TW263 / LJ204 항공편 기준 일차별 타임라인. 장소마다 가는 법·예상 비용·지도/길찾기, 참고 사진과 설명·후기·공식 사이트 링크. **일정 추가·수정·숨기기**와 공유 메모
- **食 맛집**: 식사·맥주, 간식·디저트 목록과 가게별 지도·정보·후기 링크
- **写 추억**: 일차·장소별 사진 업로드와 앨범(누가 올렸는지 표시)
- **宿 정보**: 숙소, 항공편, 엔화 계산기, 교통 요금, 일본어 표현, 긴급 연락처

## 동행과 함께 쓰기 (공유 모드)

일정 추가·수정·숨기기, 메모, 다녀옴 체크, 공유 앨범 링크가 두 사람 휴대폰에 똑같이 보여요(20초마다 자동 동기화). 사진은 구글 포토 공유 앨범에 모으고, 공유 데이터는 무료 Supabase에 저장합니다.

1. **Supabase 프로젝트 만들기**: [supabase.com](https://supabase.com) → *Start your project* → *Continue with GitHub* → *New project* (이름 아무거나, DB 비밀번호는 *Generate*, 지역 Seoul/Tokyo) → 1~2분 대기.
2. **SQL 붙여넣기**: 왼쪽 *SQL Editor* → *New query* → [`supabase/setup.sql`](supabase/setup.sql) 전체 붙여넣기 → `'여기에-여행-암호'`만 두 사람만 아는 암호로 바꾸기 → *Run*. 아래에 *Success*가 나오면 끝.
3. **연결 정보 2개 전달**: 톱니바퀴(*Project Settings*) → *Data API*의 **Project URL**, *API Keys*의 **publishable**(또는 Legacy 탭의 **anon public**) 키를 복사해 [`config.js`](config.js)에 넣기. `secret`/`service_role` 키는 넣지 마세요.

그다음 두 사람 모두 https://ahjung-droid.github.io/app/ 을 열고 이름과 여행 암호를 한 번 입력하면 돼요.

참고
- 여행 암호는 코드가 아니라 Supabase 안에만 있고, 서버 함수가 확인해요. 암호 없이는 데이터를 읽거나 쓸 수 없어요.
- 암호를 바꾸려면 `setup.sql`의 암호 줄만 바꿔 다시 실행하세요. 앱이 새 암호를 물어봐요.
- 무료 프로젝트는 1주일 넘게 사용이 없으면 일시정지돼요. 대시보드에서 *Restore*를 누르면 데이터 그대로 다시 켜져요. 여행 직전에 한 번 열어두세요.
- `config.js`가 비어 있으면 이 기기 브라우저에만 저장하는 모드로 동작해요.
