//
//  FirebaseStore.swift
//  ColorScreen_Example
//
//  Created by Nicholas Trienens on 5/25/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Firebase
import Foundation
import RxFirebaseDatabase
import RxSwift

class FirebaseStore {
    let disposeBag = DisposeBag()
    static let shared = FirebaseStore()

    func addPair(_ pair: String) -> Completable {
        guard !pair.isEmpty else { fatalError() }

        return Completable.create(subscribe: { completable in
            let state = DeviceState(pair: pair)
            do {
                try Database.database().reference().ref
                    .child("pairs")
                    .child(state.pair)
                    .rx
                    .setValue(state.asDictionary())
                    .subscribe(onNext: { _ in
                        completable(.completed)
                    })
                    .disposed(by: self.disposeBag)

                return Disposables.create {}
            } catch {
                completable(.error(error))
                return Disposables.create {}
            }
        })
    }

    func setPair(_ state: DeviceState) -> Completable {
        guard !state.pair.isEmpty else {
            DLog("Pair was empty")
            return Completable.never()
        }

        return Completable.create(subscribe: { completable in
            do {
                try Database.database().reference().ref
                    .child("pairs")
                    .child(state.pair)
                    .rx
                    .setValue(state.asDictionary())
                    .subscribe(onNext: { _ in
                        completable(.completed)
                    })
                    .disposed(by: self.disposeBag)

                return Disposables.create {}
            } catch {
                completable(.error(error))
                return Disposables.create {}
            }
        })
    }

    func state(_ pair: String) -> Observable<DeviceState?> {
        guard !pair.isEmpty else { fatalError() }

        return Database.database().reference().ref
            .child("pairs")
            .child(pair)
            .rx
            .observeEvent(.value)
            .map { snapshot -> DeviceState? in
                do {
                    if let dict = snapshot.value as? [String: Any] {
                        let str = try dict.asJSONString()
                        if let game: DeviceState = try str.decode() {
                            return game
                        }
                    }
                } catch {
                    DLog(error)
                }
                return nil
            }
    }

    func enableDiscovery(_ device: DiscoverableDevice) -> Completable {
        fatalError()
        return Completable.create(subscribe: { completable in
            do {
                try Database.database().reference().ref
                    .child("discovery")
                    .child(device.uuid)
                    .rx
                    .setValue(device.asDictionary())
                    .subscribe(onNext: { _ in
                        completable(.completed)
                    })
                    .disposed(by: self.disposeBag)

                return Disposables.create {}
            } catch {
                completable(.error(error))
                return Disposables.create {}
            }
        })
    }

    func createAndMonitorDiscovery(_ device: DiscoverableDevice) -> Observable<String> {
        fatalError()
        let monitor = PublishSubject<String>()

        enableDiscovery(device)
            .subscribe(onCompleted: {
                Database.database().reference().ref
                    .child("discovery")
                    .child(device.uuid)
                    .rx
                    .observeEvent(.value)
                    .map { snapshot -> String? in
                        do {
                            if let dict = snapshot.value as? [String: Any] {
                                let str = try dict.asJSONString()
                                if let game: DiscoverableDevice = try str.decode() {
                                    return game.match
                                }
                            }
                        } catch {
                            DLog(error)
                        }
                        return nil
                    }
                    .filterNil()
                    .bind(to: monitor)
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

        return monitor
    }

    func fetchDiscoverableDevices() -> Observable<[DiscoverableDevice]> {
        return Database.database().reference().ref
            .child("discovery")
            .rx
            .observeEvent(.value)
            .map { snapshot -> [DiscoverableDevice] in
                do {
                    if let dict = snapshot.value as? [String: [String: Any]] {
                        return try dict.values.map {
                            let device: DiscoverableDevice = try $0.asJSONString().decode()
                            return device
                        }
                    }
                } catch {
                    DLog(error)
                }
                return []
            }
    }
}

struct FirebaseServiceError: Error {
    let localizedDescription: String

    init(file: String = #file, line: Int = #line) {
        localizedDescription = " error: \(file) - \(line)"
    }

    init(_ localizedDescription: String) {
        self.localizedDescription = localizedDescription
    }
}
