# KeyboardMouseController
> 키보드로 마우스를 제어하는 애플리케이션

# 팀원 소개

----

# 목차
1. 개요
2. 프로젝트 주요 기능
3. 기술 스택
4. 요구사항 명세서
5. 사용자 유스케이스
6. API 명세서
7. 테스트 명세서
8. 트러블 슈팅
----

# 1. 개요
> 본 프로젝트는 키보드의 숫자 패드를 마우스 대신 사용하도록 한다. 마우스 포인터의 상하좌우 이동, 드래그, 스크롤 등의 기능이 있다. 번거롭게 키보드에서 손을 떼 마우스를 조작하는 경우를 없앤다.

## 1-1. 문제 정의
 키보드를 많이 사용하고 컴퓨터에 능숙한 사람들은 대부분 단축키를 적극적으로 활용한다. 하지만 단축키를 아무리 잘 사용한다고 하더라도 마우스를 사용해 조작하는 것이 더 빠른 경우가 있다. 
 
 이 때 마우스를 사용하는 것은 더 편하기 때문이 아니라 더 빠르기 때문이다. 키보드에서 손을 떼고 마우스로 손을 이동시키는 번거로움을 감수하는 것이다. 이러한 불필요한 동작을 줄이기 위해 해당 어플리케이션을 고안하게 되었다. 
## 1-2. 유사 서비스
### 1-2-1. Window
<img width="885" height="593" alt="windows_keyboardmouse" src="https://github.com/user-attachments/assets/1b860c2b-3a96-4154-bfb3-4c279d8eb677" />

- 주요 기능
  - 마우스 포인터 이동
  - 마우스 버튼 클릭

### 1-2-2. macOS
<img width="800" height="359" alt="macOS_keyboardmouse" src="https://github.com/user-attachments/assets/42e5b386-deba-41f4-b5d1-7321cb8bf34c" />

- 주요 기능
  - 마우스 포인터 이동
  - 마우스 버튼 클릭

----

# 2. 프로젝트 주요 기능
## 2-1. 단축키 설정
- 마우스 컨트롤 상태 ON/OFF 키 설정
- 좌클릭, 우클릭, 스크롤, 드래그 키 설정
  - 좌클릭: 숫자 패드 7번, 우클릭: 숫자 패드 9번, 스크롤: 숫자 패드 +, 드래그: 숫자 패드 Enter
- 마우스 포인터 상하좌우 이동 단축키 설정
  - 상: 숫자 패드 8번, 하: 숫자 패드 5번, 좌: 숫자 패드 4번, 우: 숫자 패드 6번
## 2-2. 앱 설정
- 제어 센터에서 가리기/보이기 설정
- 앱 사용/사용중지 설정
- 손쉬운 사용 권한 설정
## 2-3. 마우스 설정
- 마우스 포인터 이동 속도 설정
## 2-4. 마우스 조작
- 좌클릭, 우클릭, 스크롤, 드래그
- 마우스 포인터 이동
----

# 3. 기술 스택
## Language
![Swift](https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white)
## IDE
![Xcode](https://img.shields.io/badge/Xcode-1572B6?style=for-the-badge&logo=xcode&logoColor=white)

----

# 4. 요구사항 명세서
[요구사항 명세서.pdf](https://github.com/user-attachments/files/23012182/default.pdf)

----

# 5. 사용자 유스케이스
<img width="721" height="1041" alt="사용자 유스케이스 drawio" src="https://github.com/user-attachments/assets/6241a977-f8b0-4a84-a962-097f832b6a99" />

----

# 6. API 명세서

----

# 7. 테스트 명세서

----

# 8. 트러블 슈팅

