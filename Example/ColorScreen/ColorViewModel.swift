//
//  ColorViewModel.swift
//  ColorScreen_Example
//
//  Created by Nicholas Trienens on 5/29/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import DeviceKit
import Foundation

import RxCocoa
import RxRelay
import RxSwift

class ColorViewModel {
    struct Output {
        let state: Observable<DeviceState>
    }

    var disposeBag = DisposeBag()
    private let peers = LocalCommunicator()

    let beaons = Beacons()
    let discovery = DiscoverableDevice()
    let state = ReplaySubject<DeviceState>.create(bufferSize: 1)
    var group = "mine" // 9D3D900A-58F7-4BF5-ABBF-B90E56CF8B25=EA942A5C-D21C-4674-A2F9-7E588DBB2E47"

    func bindings() -> Output {
        if group.isEmpty {
            FirebaseStore.shared.addPair("mine")
                .subscribe(
                    onCompleted: {
                        FirebaseStore.shared.state(self.group)
                            .distinctUntilChanged()
                            .catchError { _ -> Observable<DeviceState?> in
                                //                    self.group = ""
                                //                    UserDefaults.lastGroup = nil
                                self.searchNearby()
                                return Observable.just(nil)
                            }
                            .filterNil()
                            .bind(to: self.state)
                            .disposed(by: self.disposeBag)
                    }
                ).disposed(by: disposeBag)
        } else {
            FirebaseStore.shared.state(group)
                .distinctUntilChanged()
                .debug()
                .catchError { _ -> Observable<DeviceState?> in
//                    self.group = ""
//                    UserDefaults.lastGroup = nil
                    self.searchNearby()
                    return Observable.just(nil)
                }
                .filterNil()
                .bind(to: state)
                .disposed(by: disposeBag)
        }

        return Output(state: state.asObservable())
    }

    func stopSearch() {}

    func searchNearby() {
        if Device.current.isOneOf([Device.iPadMini4, Device.iPadMini5, Device.iPadMini3]) {
            group = discovery.uuid

            peers.invite(as: discovery.uuid)
            peers.connections
                .subscribe(onNext: {
                    var devices = $0
                    devices.append(self.discovery.uuid)
                    if !devices.isEmpty {
                        UserDefaults.lastGroup = self.group
                        self.peers.sendStatus(playlist: self.group, currentTrackId: "1", playPosition: 10, isPlaying: true)
                    }
                })
                .disposed(by: disposeBag)

            FirebaseStore.shared.state(group)
                .distinctUntilChanged()
                .catchErrorJustReturn(nil)
                .filterNil()
                .bind(to: state)
                .disposed(by: disposeBag)

        } else {
            peers.accept(as: discovery.uuid)
        }

        peers.incomingMessage
            .subscribe(onNext: { packet in
                DLog(packet)
                self.group = packet.playlistID
                FirebaseStore.shared.state(packet.playlistID)
                    .distinctUntilChanged()
                    .catchErrorJustReturn(nil)
                    .filterNil()
                    .bind(to: self.state)
                    .disposed(by: self.disposeBag)

            })
            .disposed(by: disposeBag)
    }
}
