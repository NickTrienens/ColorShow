//
//  ibeacon.swift
//  ColorScreen_Example
//
//  Created by Nicholas Trienens on 8/14/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import CoreBluetooth
import CoreLocation
import Foundation
import iBeaconManager
import RxBluetoothKit
import RxSwift

struct AccelValue: Codable {
    let x: Float
    let y: Float
    let z: Float

    init(_ data: Data) throws {
        self = try JSONDecoder().decode(AccelValue.self, from: data)
    }
}

extension Characteristic: CustomDebugStringConvertible {
    public var debugDescription: String {
        if let data = value, let value = try? AccelValue(data) {
            return "Characteristic: \(uuid) - \(value)"
        }
        return "Characteristic: \(uuid)"
    }
}

// subclass BeaconManagerDelegate
class Beacons: BeaconManagerDelegate {
    var beaconManager: BeaconManager
    private let centralManager = CentralManager(queue: .main)
    let disposeBag = DisposeBag()
    init() {
        // create a Beacon object
        let beacon = Beacon(uuid: "8ec76ea3-6668-48da-9866-75be8bc86f4d", major: 0, minor: 0, identifier: "example beacon")

        // initialize the BeaconManager class by passing in your Beacon object
        beaconManager = BeaconManager(beacon: beacon)

        // start monitoring for beacon activity
        beaconManager.startMonitoring()

        startBLE()
    }

    func startBLE() {
        let service = CBUUID(string: "19B10000-E8F2-537E-4F6C-D104768A1214")

        print("start monitoring")

        centralManager.observeState()
            .startWith(centralManager.state)
            .debug()
            .filter { $0 == BluetoothState.poweredOn }
            .timeout(.seconds(3), scheduler: MainScheduler.asyncInstance)
            .take(1)
            .flatMap { _ in
                self.centralManager
                    .scanForPeripherals(withServices: [service])
                    .timeout(.seconds(3), scheduler: MainScheduler.asyncInstance)
            }
            .take(1)
            .flatMap { scannedPeripheral in
                scannedPeripheral.peripheral.establishConnection().debug()
            }
            .flatMap { $0.discoverServices(nil) }
            .flatMap { services -> Observable<[Characteristic]> in
                print("\(services)")
                guard let s = services.first else { throw BluetoothError.bluetoothInUnknownState }
                return s.discoverCharacteristics([]).asObservable().debug()
            }
            .flatMap { characteristicO -> Observable<Characteristic> in
                guard let characteristic = characteristicO.first else { throw BluetoothError.bluetoothInUnknownState }
                print(characteristic)
                return characteristic.observeValueUpdateAndSetNotification()
            }
            .retry()
            .subscribe(
                onNext: { characteristic in
                    print("connected \(characteristic)")
                },
                onError: {
                    print($0)
                }
            )
            .disposed(by: disposeBag)
    }

    // add protocol methods
    func beaconManager(sender _: BeaconManager, isInBeaconRange _: CLRegion) {
        print("inside beacon range")
    }

    func beaconManager(sender _: BeaconManager, isNotInBeaconRange _: CLRegion) {
        print("not inside beacon range")
    }

    func beaconManager(sender _: BeaconManager, searchingInRegion _: CLRegion) {
        print("searching for beacon")
    }

    func beaconManager(sender _: BeaconManager, enteredBeaconRegion _: CLRegion) {
        print("entered beacon region")
    }

    func beaconManager(sender _: BeaconManager, exitedBeaconRegion _: CLRegion) {
        print("exited beacon region")
    }

    func beaconManager(sender _: BeaconManager, monitoringRegionFailed _: CLRegion, withError _: Error) {
        print("monitoring for beacon failed")
    }
}
