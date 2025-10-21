//
//  Created by 김채우 on 10/17/25.
//

import Cocoa
import CoreGraphics
import ApplicationServices
import Accessibility

class KeyboardMouseController {
    
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
        
        
        print("모니터링 시작 대기 중")
        // ... (이벤트 탭 생성 및 CFRunLoop에 추가하는 코드)
    }
    
    // 2. 키보드 이벤트 발생 시 호출될 콜백 함수 (static으로 선언)
    static func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
        // 키보드 입력을 확인하고 마우스 이벤트로 변환하는 로직 구현
        
        // return nil; // 이벤트를 시스템에 전달하지 않고 막을 때
        return Unmanaged.passRetained(event) // 이벤트를 시스템으로 전달할 때
    }
    
    func startEventTap() {
        // CGEventTapCreate 로직 구현
    }
}
