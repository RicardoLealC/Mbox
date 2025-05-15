//
//  Item.swift
//  MusicBoxd
//
//  Created by Ricardo Leal on 14/05/25.
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
