//
//  Item.swift
//  KeyboardMouseController
//
//  Created by 김채우 on 10/16/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
