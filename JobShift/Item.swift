//
//  Item.swift
//  JobShift
//
//  Created by 川上真 on 2023/12/10.
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
