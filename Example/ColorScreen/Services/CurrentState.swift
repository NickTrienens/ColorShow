//
//  CurrentState.swift
//  ColorScreen_Example
//
//  Created by Nicholas Trienens on 5/25/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

struct DeviceState: Codable, Equatable {
    var color: String {
        didSet {
            lastUpdated = Date()
        }
    }

    let pair: String
    var mode: String
    var lastUpdated: Date
    var volume: Double {
        didSet {
            lastUpdated = Date()
        }
    }

    var track: String {
        didSet {
            lastUpdated = Date()
        }
    }

    var playing: Bool {
        didSet {
            lastUpdated = Date()
        }
    }

    var backLight: Double {
        didSet {
            lastUpdated = Date()
        }
    }

    init(pair: String, color: String = "#333333", mode: String = "red", backLight: Double = 1) {
        self.pair = pair
        self.color = color
        self.mode = mode
        self.backLight = backLight
        lastUpdated = Date()
        volume = 0
        playing = false
        track = "rain"
    }
}
