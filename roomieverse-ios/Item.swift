//
//  Item.swift
//  roomieverse-ios
//
//  Created by An Tran on 2/18/26.
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
