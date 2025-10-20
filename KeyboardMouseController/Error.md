# Error List

## 2025.10.20
### init 함수 사용
문제
- init 함수 내에서의 KeyboardMouseController 호출 시 타이밍의 문제
- 접근성을 허가해 달라는 창이 뜨지 않음
원인
- startMonitoring() 함수가 메인보다 일찍 실행되었기 때문
해결
- DispatchQueue.main.async로 startMonitoring()이 비동기적으로 동작하도록 함으로써 해결
### AXRequestProcessTrusted() 호출 안 됨
문제
- 시스템이 찾을 수 없음
원인
- 해당 함수는 존재하지 않는 것으로 확인됨
- 왜 Gemini가 자꾸 존재한다고 하는지는 모르겠음
해결
- AXIsProcessTrustedWithOptions 함수 사용
### AXIsProcessTrustedWithOptions 함수가 작동하지 않음
문제
- 손쉬운 사용 권한이 없을 시 해당 프롬프트를 띄워야 하는데 띄우지 않음
원인
- 정확한 파악은 어렵지만 아마 app sandbox 때문이었을 것이라고 생각됨
해결
- 해결이라고 하기엔 애매하고 시도해 본 것들
1. App Sandbox 설정 변경
- 아예 App Sandbox를 삭제
2. tccutil 권한 초기화
- tccutil reset 명령어를 통해 권한 데이터베이스 초기화
