//
//  DiscoverableDevices.swift
//  ColorScreen_Example
//
//  Created by Nicholas Trienens on 5/29/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

struct DiscoverableDevice: Codable {
    var uuid: String = UserDefaults.deviceId
    var claimed: Bool = false
    var match: String?
    var lasUpdate: Date = Date()
}
