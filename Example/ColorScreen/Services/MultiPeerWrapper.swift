//
//  MultiPeerWrapper.swift
//  PeletonPlayer
//
//  Created by Nicholas Trienens on 9/21/18.
//  Copyright © 2018 Nicholas Trienens. All rights reserved.
//

import Foundation
import MultiPeer
import RxCocoa
import RxSwift

extension UserDefaults {
    private struct Key {
        static let deviceId = "deviceIdKey"
        static let lastGroup = "lastGroupKey"
    }

    public static var lastGroup: String? {
        get { return standard.value(forKey: Key.lastGroup) as? String }
        set { standard.set(newValue, forKey: Key.lastGroup) }
    }

    public static var deviceId: String {
        get {
            if let deviceId = standard.value(forKey: Key.deviceId) as? String, deviceId.count == 36 {
                return deviceId
            } else {
                let deviceId = UUID().uuidString
                standard.set(deviceId, forKey: Key.deviceId)
                return deviceId
            }
        }
        set { standard.set(newValue, forKey: Key.deviceId) }
    }
}

class LocalCommunicator {
    let connectivity = MultiPeer()
    let incomingMessage = PublishSubject<Packet>()
    let connections = PublishSubject<[String]>()
    init() {}

    func invite(as device: String) {
        connectivity.initialize(serviceType: "demo-app", deviceName: device)
        connectivity.delegate = self
        connectivity.startInviting()
    }

    func accept(as device: String) {
        connectivity.initialize(serviceType: "demo-app", deviceName: device)
        connectivity.delegate = self
        connectivity.startAccepting()
    }

    func stopSearching() {
        connectivity.stopSearching()
    }

    func sendStatus(playlist: String, currentTrackId: String, playPosition: Double, isPlaying: Bool) {
        if let stringVal = try? Packet(playlistID: playlist, trackID: currentTrackId, playPosition: playPosition, isPlaying: isPlaying).asString(), let data = stringVal.data(using: .utf8) {
            // DLog(stringVal)
            connectivity.send(data: data, type: DataType.message.rawValue)
        }
    }
}

extension LocalCommunicator: MultiPeerDelegate {
    func multiPeer(didReceiveData data: Data, ofType type: UInt32) {
        switch type {
        case DataType.message.rawValue:
            // DLog(data.toString() ?? "")
            guard let message: Packet = try! data.decode() else { return }
            incomingMessage.onNext(message)

        default:
            break
        }
    }

    func multiPeer(connectedDevicesChanged devices: [String]) {
        // DLog("Connected devices changed: \(devices)")
        connections.onNext(devices)
    }
}

enum DataType: UInt32 {
    case message = 1
    case warning = 2
}

struct Packet: Codable {
    let sentAt: Date
    let playlistID: String
    let trackID: String
    let playPosition: Double
    let isPlaying: Bool

    init(playlistID: String, trackID: String, playPosition: Double, isPlaying: Bool) {
        sentAt = Date()
        self.playlistID = playlistID
        self.trackID = trackID
        self.playPosition = playPosition
        self.isPlaying = isPlaying
    }
}
