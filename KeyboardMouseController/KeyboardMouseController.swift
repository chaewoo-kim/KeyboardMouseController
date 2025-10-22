//
//  Created by 김채우 on 10/17/25.
//  Edited by 김채우 on 10/21/25.
//

import Cocoa
import CoreGraphics
import ApplicationServices
import Accessibility

// 2. 키보드 이벤트 발생 시 호출될 콜백 함수 (static으로 선언)
func handleEvent(
    proxy: CGEventTapProxy, // 이벤트가 발생하는 이벤트 탭(Event Tap) 자체를 나타내는 불투명한 포인터. 이벤트 시스템에서 내부적으로 사용됩니다.
    type: CGEventType, // 발생한 이벤트의 유형을 나타내는 열거형(Enum). ex) 마우스 다운, 스크롤 등
    event: CGEvent, // 발생한 이벤트의 모든 세부 정보를 담고 있는 객체. 이벤트 위치, 키 코드, 마우스 버튼 상태 등의 정보
    refcon: UnsafeMutableRawPointer? // Reference Context. 이벤트 탭을 설정할 때 개발자가 임의로 전달한 데이터 받음
    // -> 보통 static 함수에서 객체의 인스턴스 상태에 접근하기 위해 해당 객체의 self 포인터를 전달받는데 사용
) -> Unmanaged<CGEvent>? { // 이벤트 처리가 끝난 후 시스테멩 다시 전달할 CGEvent 객체를 반환해야 함
    // Unmanaged<T>: Swift의 ARC(Automatic Reference Counting) 관리 대상이 아닌 수동 메모리 관리를 위핸 래퍼(Wrapper)
    //   C 기반 Core Graphics 함수와 상호작용할 때 메모리 누수를 막기 위해 사용
    // ?: nil을 반환할 수 있음을 의미. nil을 반환하면 이벤트를 소비해 가로채거나 차단하는 효과 낼 수 있음
    
    
    // 키보드 입력을 확인하고 마우스 이벤트로 변환하는 로직 구현
    // 이벤트 유형이 키가 눌린 것인지 떼어진 것인지 확인
    if type == .keyDown { // 이후에 keyDown일 때와 keyUp일 때를 분류해서 로직 짜야 함
        
        // 해당 키의 고유번호인 keyCode 받아오기
        let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
            
        // 콘솔에 어떤 키가 눌렸는지 떼 졌는지와 해당 키 코드 출력
        print("Key event: \(type), keyCode: \(keyCode)")
            
        // 마우스 포인터 움직이는 로직 여기다가 구현
        // 기본적으로 할당되는 단축키는 숫자 패드
        // 상: 8, 하: 5, 좌: 4, 우: 6, 스크롤: +, 드래그: Enter
        // 사용할 keyCode
            // 상: 91, 하: 87, 좌: 86, 우: 88, 스크롤: 69, 드래그: 76
        // 0. 현재 마우스 포인터의 위치 가져와서 저장해야 함
        // 가져올 때는 NSEvent로 값을 가져와야 함. CGEvent는 키보드 이벤트이기 때문에 마우스 커서의 현재 위치를 가져올 수 없음
        // NSEvent와 CGEvent는 좌표(0,0) 시작점이 좌상단, 좌하단으로 다르기 때문에 값을 옮길 때 고려해야 함\
        // 0.1 현재 마우스 포인터 위치. 기준 좌상단(0,0)
        let nsPosition = NSEvent.mouseLocation
        
        // 0.2 현재 화면 높이 가져와 Core Graphics 좌표계로 변환
        // 현재 화면
        guard let mainScreen = NSScreen.main else {
            return Unmanaged.passRetained(event) // 메인 화면 못 가져오면 이벤트 통과
        }
        // 현재 화면의 높이
        let screenHeight = mainScreen.frame.height
        
        // 현재 마우스 포인터 위치를 NSEvent 기준에서 CGEvent 기준으로 변경해 저장
        var cgPosition = CGPoint(
            x: nsPosition.x,
            y: screenHeight-nsPosition.y
        )
        print("현재 위치: ", cgPosition)
        
        // 일단 설정한 마우스 속도. 나중에 시간 비례로 고쳐야 함
        let moveAmount: CGFloat = 20.0 // 20px씩 이동
        
        // 시간 비례로 마우스 포인터 이동 속도 조절
        // 상하좌우 이동 현황을 Boolean으로 선언
        // 키 코드가 들어왔을 때 해당 방향을 true로 변경
        // 1초에 일정 횟수 Boolean 값을 검사해 true면 마우스 포인터 이동
        
        // 1. switch 문으로 해당 코드가 어떤 값인지 확인
        // 2. 코드에 따라 작업 실행
        // 2-1. 상/하/좌/우: 해당 방향으로 마우스 포인터 이동 -> 일단 이것만 구현해보자
        switch keyCode {
        case 91: // 숫자패드 8
            print("위로 이동")
            cgPosition.y -= moveAmount
        case 87: // 숫자패드 5
            print("아래로 이동")
            cgPosition.y += moveAmount
        case 86:
            print("좌로 이동")
            cgPosition.x -= moveAmount
        case 88:
            print("우로 이동")
            cgPosition.x += moveAmount
        default:
            print("필요한 값 아님")
            return Unmanaged.passRetained(event)
        }
        
        // 수정된 좌표 기준으로 마우스 포인터 위치 재설정
        CGWarpMouseCursorPosition(cgPosition)
        print("재설정 위치: ", cgPosition)
        
        // 2-2. 상하/좌우: 마우스 포인터 이동 정지
            // 2-2-3. 하나의 키가 들어와 있는 도중에 다른 키가 눌렸을 때 어떻게 반응하는지 확인해 봐야 함
        // 2-3. 상+좌우/하+좌우: 해당 대각 방향으로 마우스 포인터 이동. 정방향 이동보다 속도가 루트 2배 빨라야 할듯
        
        
        // 이벤트를 시스템에 전달하지 않고 막을 때, 즉 해당 keyCode가 앱에서 원하는 값일 때
        return nil;
    }
    // 입력 키의 타입이 keyUp일 때
    if type == .keyUp {}
    
    print("다른 키의 이벤트 통과")
    return Unmanaged.passRetained(event) // 이벤트를 시스템으로 전달할 때
}


class KeyboardMouseController {
    
    // 이벤트 탭 참조를 저장하는 변수
    // 재시동, 삭제 등에 사용
    private var eventTap: CFMachPort?
    
    // 1. 시스템 이벤트 탭을 시작하는 함수
    func startMonitoring() {
        // CGEventTapCreate 로직 필요
        // 해당 로직은 시스템 권한(Accessibility)에 의존
        print("함수 실행됨")
        
        DispatchQueue.main.async {
            // 권한 확인 여부
            let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
            
            print(options)
            
            // 권한 확인 변수에
            let isTrusted = AXIsProcessTrustedWithOptions(options)
            print("isTrusted: ", isTrusted)
            
            // 권한 확인
            if !isTrusted {
                print("접근성 권한이 필요합니다. 설정에서 앱을 허용해 주세요")
                
                // 권한 요청 UI 출력 -> 해결
                
                // 모니터링 중단, 사용자가 설정 변경 후 앱을 재시작해야 기능 활성화됨
                return
            } else {
                print("접근 권한 있음")
                
                // 이벤트 탭 확인
                self.startEventTap()
            }
        }
        
        
        print("모니터링 시작")
        // ... (이벤트 탭 생성 및 CFRunLoop에 추가하는 코드)
    }
    
    //3. 이벤트 감지하는 탭 생성
    func startEventTap() {
        // CGEventTapCreate 로직 구현
        
        // 1. 감시할 이벤트 종류 정의: 상수
        let eventMask = (1 << CGEventType.keyDown.rawValue) |   // keyDown 일 때 그 키의 고유값을 비트연산 해서 고유값 생성
                        (1 << CGEventType.keyUp.rawValue) | // keyUp일 때 그 키의 고유값을 비트연산 해서 고유값 생성
                        (1 << CGEventType.flagsChanged.rawValue) // flagsChanged일 때(shift 같은 수정 키) 그 키의 고유값을 비트연산 해서 고유값 생성
        
        // 2. 콜백 함수에 클래스 인스턴스 전달 준비
        // handleEvent는 static이기 때문에 인스턴스를 가리키는 주소값인 self를 보내줘야 함
        let refcon = Unmanaged.passUnretained(self).toOpaque();
        
        // 3. 이벤트 감시자 생성
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: handleEvent,
            userInfo: refcon
        ) else {
            print("Failed to create event tap")
            return
        }
        
        // 생성된 탭을 인스턴스 변수에 저장
        self.eventTap = tap
        
        // 4. RunLoop에 감시자 추가
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        
        // 5. 감시자 활성화
        CGEvent.tapEnable(tap: tap, enable: true)
        
        print("Event Tap started successfully")
        
    }
}
