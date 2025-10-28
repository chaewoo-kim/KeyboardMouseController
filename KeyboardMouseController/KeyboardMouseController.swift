//
//  Created by 김채우 on 10/17/25.
//  Edited by 김채우 on 10/21/25.
//

import Cocoa
import CoreGraphics
import Combine
import ApplicationServices
import Accessibility

enum KeyAction: Int {
    case moveUp = 91
    case moveDown = 87
    case moveLeft = 86
    case moveRight = 88
    
    case leftClick = 89
    case rightClick = 92
    
    case scrollToggle = 69
}

// 2. 키보드 이벤트 발생 시 호출될 콜백 함수 (static으로 선언)
// 4가지 방향의 키의 활성 상태를 바꾸는 역할
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
        // refcon을 사용해 keyboardmousecontroller에 접근
        guard let refcon = refcon else {
            return Unmanaged.passRetained(event)
        }
        let controller = Unmanaged<KeyboardMouseController>.fromOpaque(refcon).takeUnretainedValue()
        
        // 키보드 이벤트만을 처리
        guard type == .keyDown || type == .keyUp else {
            return Unmanaged.passRetained(event)
        }
        
        // 해당 키의 고유번호인 keyCode 받아오기
        let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
        // 이벤트 타입이 'keyDown'이면 isPressed는 true, 'keyUp'이면 false
        let isPressed = (type == .keyDown)
    
        guard let action = KeyAction(rawValue: keyCode) else {
            print("정의되지 않은 키 : \(keyCode)")
            return Unmanaged.passRetained(event)
        }
            
        // 콘솔에 어떤 키가 눌렸는지 떼 졌는지와 해당 키 코드 출력
        print("Key event: \(type), keyCode: \(keyCode)")
            
        // 마우스 포인터 움직이는 로직 여기다가 구현
        // 기본적으로 할당되는 단축키는 숫자 패드
        // 상: 8, 하: 5, 좌: 4, 우: 6, 스크롤: +, 드래그: Enter, 좌클릭: 7, 우클릭: 9
        // 사용할 keyCode
            // 상: 91, 하: 87, 좌: 86, 우: 88, 스크롤: 69, 드래그: 76, 좌클릭: 89, 우클릭: 92
        // 0. 현재 마우스 포인터의 위치 가져와서 저장해야 함
        // 가져올 때는 NSEvent로 값을 가져와야 함. CGEvent는 키보드 이벤트이기 때문에 마우스 커서의 현재 위치를 가져올 수 없음
        // NSEvent와 CGEvent는 좌표(0,0) 시작점이 좌상단, 좌하단으로 다르기 때문에 값을 옮길 때 고려해야 함\
        // 0.1 현재 마우스 포인터 위치. 기준 좌상단(0,0)
        
        // 시간 비례로 마우스 포인터 이동 속도 조절
        // 상하좌우 이동 현황을 Boolean으로 선언
        // 키 코드가 들어왔을 때 해당 방향을 true로 변경
        // 1초에 일정 횟수 Boolean 값을 검사해 true면 마우스 포인터 이동
        
        // 1. switch 문으로 해당 코드가 어떤 값인지 확인
        // 2. 코드에 따라 작업 실행
        // 2-1. 상/하/좌/우: 해당 방향으로 마우스 포인터 이동
        switch action {
        case .moveLeft, .moveRight, .moveUp, .moveDown:
            controller.handleMovement(keyCode: keyCode, isPressed: isPressed)
        case .leftClick:
            if (type == .keyDown) {
                print("좌클릭")
                controller.performLeftClick(isPressed: isPressed)
            }
        case .rightClick:
            if (type == .keyDown) {
                print("우클릭")
                controller.performRightClick(isPressed: isPressed)
            }
        case .scrollToggle:
            controller.performScrolling(isPressed: isPressed)
            break
        }
        
        // 이벤트를 시스템에 전달하지 않고 막을 때, 즉 해당 keyCode가 앱에서 원하는 값일 때
        return nil;
    }


class KeyboardMouseController: ObservableObject {
    
    @Published var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                DispatchQueue.main.async {
                    // 권한 확인 여부
                    let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
                    
                    // 권한 확인 변수에
                    if AXIsProcessTrustedWithOptions(options) {
                        self.startMonitoring()
                    } else {
                        print("접근성 권한 없음")
                        self.isEnabled = false
                    }
                }
            } else {
                self.stopEventTap()
            }
        }
    }
    
    // 이벤트 탭 참조를 저장하는 변수
    // 재시동, 삭제 등에 사용
    private var eventTap: CFMachPort?
    
    // 마우스 위치 주기적으로 업데이트하는 Timer 객체
    private var movementTimer: Timer?
    
    // 마우스 포인터 가속 속도
    @Published var baseSpeed: CGFloat = 100.0
    @Published var maxSpeed: CGFloat = 1200.0
    @Published var acceleration: CGFloat = 2000.0
    
    // 현재 마우스 포인터 속도
    private var currentSpeed: CGFloat = 100.0
    
    // 현재 이동 방향 상태 저장하는 변수들
    // handleEvent 함수가 이 값들을 변경
    // updateMousePosition 함수가 이 값들을 읽음
    var isMovingUp = false
    var isMovingDown = false
    var isMovingRight = false
    var isMovingLeft = false
    
    var isLeftClick = false
    var isRightClick = false
//    var isDrag = false
    var isScroll = false
    
    var scrollSpeed: Int32 = 10
    
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
                // 마우스 이동 타이머
                self.startStateTimer()
            }
        }
        
        
        print("모니터링 시작")
        // ... (이벤트 탭 생성 및 CFRunLoop에 추가하는 코드)
    }
    
    // 탭 비활성화
    func stopEventTap() {
        // 1. 타이머 무효화해 더 이상 실행되지 않게 함
        movementTimer?.invalidate()
        movementTimer = nil // 메모리에서 해제
        
        // 2. 이벤트 탭 비활성화, 시스템에서 제거
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            eventTap = nil // 메모리에서 해제
        }
        
        print("이벤트 감지를 중지했습니다.")
    }
    
    //3. 이벤트 감지하는 탭 생성
    func startEventTap() {
        // CGEventTapCreate 로직 구현
        
        // 1. 감시할 이벤트 종류 정의: 상수
        let eventMask = (1 << CGEventType.keyDown.rawValue) |   // keyDown 일 때 그 키의 고유값을 비트연산 해서 고유값 생성
                        (1 << CGEventType.keyUp.rawValue) // keyUp일 때 그 키의 고유값을 비트연산 해서 고유값 생성
        
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
    
    func handleMovement(keyCode: Int, isPressed: Bool) {
        // 마우스 포인터 이동에 대한 로직
        switch keyCode {
        case 91: // 숫자패드 8
            print("위로 이동")
            isMovingUp = isPressed
        case 87: // 숫자패드 5
            print("아래로 이동")
            isMovingDown = isPressed
        case 86:
            print("좌로 이동")
            isMovingLeft = isPressed
        case 88:
            print("우로 이동")
            isMovingRight = isPressed
        default:
            print("필요한 값 아님")
        }
    }
    
    func performLeftClick(isPressed: Bool) {
        // 좌클릭 실행
        
        isLeftClick = isPressed
        
        // 전역 좌표를 가져와 바로 사용
        guard let event = CGEvent(source: nil) else { return }
        let position = event.location
        
        // 마우스 왼쪽 버튼 다운 이벤트 생성
        let mouseDownEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseDown,
            mouseCursorPosition: position,
            mouseButton: .left
        )
        
        // 마우스 왼쪽 버튼 업 이벤트 생성
        let mouseUpEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseUp,
            mouseCursorPosition: position,
            mouseButton: .left
        )
        
        // 생성된 이벤트를 시스템에 게시(post)하여 실행
        mouseDownEvent?.post(tap: .cgSessionEventTap)
        mouseUpEvent?.post(tap: .cgSessionEventTap)
    }
    
    func performRightClick(isPressed: Bool) {
        // 우클릭 실행
        
        guard let event = CGEvent(source: nil) else { return }
        let position = event.location
        
        isRightClick = isPressed
        
        // 마우스 오른쪽 버튼 다운 이벤트 생성
        let mouseDownEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: .rightMouseDown,
            mouseCursorPosition: position,
            mouseButton: .right
        )
        
        // 마우스 오른쪽 버튼 업 이벤트 생성
        let mouseUpEvent = CGEvent(
            mouseEventSource: nil,
            mouseType: .rightMouseUp,
            mouseCursorPosition: position,
            mouseButton: .right
        )
        
        // 생성된 이벤트를 시스템에 게시(post)하여 실행
        mouseDownEvent?.post(tap: .cgSessionEventTap)
        mouseUpEvent?.post(tap: .cgSessionEventTap)
    }
    
    func performScrolling(isPressed: Bool) {
        // 스크롤 기능 구현
        // 스크롤 키와 위 키 또는 아래 키가 같이 눌리면 스크롤 기능
        isScroll = isPressed
        print("스크롤 상태: ", isPressed)
    }
    
    // 메인 업데이트 함수
    @objc private func updateControllerState(interval: TimeInterval) {
        if isScroll {
            handleScroll()
            return
        }
        
        // 스크롤이 아닌 경우 포인터 이동 처리 수행
        handlePointerMovement(interval: interval)
    }
    
    private func handleScroll() {
        var scrollDelta: Int32 = 0
        
        if isMovingUp == true {
            scrollDelta = +scrollSpeed
        } else if isMovingDown == true {
            scrollDelta = -scrollSpeed
        }
        
        if scrollDelta != 0 {
            // 스크롤 이벤트 생성
            let scrollEvent = CGEvent(
                scrollWheelEvent2Source: nil,
                units: .pixel,  // .pixel 또는 .line
                wheelCount: 1,  // 1: 수직 스크롤, 2: 수직+수평
                wheel1: scrollDelta,    // 수직 스크롤 델타
                wheel2: 0,  // 수평 스크롤 델타
                wheel3: 0
            )
            
            // 스크롤 이벤트 시스템에 개시
            scrollEvent?.post(tap: .cgSessionEventTap)
            print("스크롤 이벤트 발생")
        }
    }
    
    private func handlePointerMovement(interval: TimeInterval) {
        // 방향 키 눌려있는지 확인
        let isMoving = isMovingUp || isMovingDown || isMovingLeft || isMovingRight
        
        // 방향 키 눌려져 있다면 속도 계산 후 반영
        if isMoving {
            currentSpeed = min(maxSpeed, currentSpeed + acceleration * CGFloat(interval))
        } else {
            currentSpeed = baseSpeed
        }
        
        // 방향 벡터 계산
        // 현재 눌린 키의 상태를 바탕으로 이동 방향 결정
        var dx: CGFloat = 0 // x축 방향
        var dy: CGFloat = 0 // y축 방향
        
        if isMovingUp { dy -= 1 }
        if isMovingDown { dy += 1 }
        if isMovingRight { dx += 1 }
        if isMovingLeft { dx -= 1 }
        
        // 움직임이 없으면 계산 줄이기 위해 즉시 종료
        if dx == 0 && dy == 0 {
            return
        }
        
        // 대각선 이동 속도 보정
        if dx != 0 && dy != 0 {
            let magnitude = sqrt(dx*dx + dy*dy) // 벡터의 크기 계산
            dx /= magnitude // x, y 요소로 나누어 길이가 1인 단위 벡터 생성
            dy /= magnitude
        }
        
        // 이번 프레임에서 이동할 거리 계산
        let distance = currentSpeed * CGFloat(interval)
        
        guard let event = CGEvent(source: nil) else { return }
        var newPosition = event.location
        
        // 최종 목표 위치 계산
        newPosition.x += dx * distance
        newPosition.y += dy * distance
        
        // 최종 마우스 포인터 이동
        CGWarpMouseCursorPosition(newPosition)
        print(newPosition)
    }
    
    private func startStateTimer() {
        // 간격은 1초에 60번 (60프레임)
        let timerInterval = 1.0 / 60.0
        
        let newTimer = Timer(timeInterval: timerInterval, repeats: true) { [weak self] _ in
            self?.updateControllerState(interval: timerInterval)
        }
        
        RunLoop.main.add(newTimer, forMode: .default)
        
        movementTimer = newTimer
        
        print("마우스 이동 타이머 시작")
    }
}
