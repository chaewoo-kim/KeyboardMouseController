//
//  KeyboardMouseControllerApp.swift
//  KeyboardMouseController
//
//  Created by 김채우 on 10/16/25.
//

import SwiftUI

// KeyboardMouseController 객체를 외부에 선언
// 앱이 살아있는 동안 메모리에 유지
let keyboardController = KeyboardMouseController()

@main
struct KeyboardMouseControllerApp: App {

    var body: some Scene {
        
        WindowGroup {
//            ContentView() -> 설정 창은 나중에 구현할 것이기 때문에 지금을 필요 없음
            
            Text("Keyboard Control Running in Background")
                .frame(width: 200, height: 100)
                .onAppear {
                    keyboardController.startMonitoring()
                }
        }
    }
}
