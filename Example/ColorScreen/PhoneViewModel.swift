//
//  PhoneViewModel.swift
//  ColorScreen_Example
//
//  Created by Nicholas Trienens on 5/29/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class PhoneViewModel: ColorViewModel {
    let brightness = BehaviorRelay<Float>(value: 0.5)

    func bindings(wakeTap: ControlEvent<Void>,
                  sleepTap: ControlEvent<Void>, brightessChanged: ControlProperty<Float>) -> Output {
        brightessChanged
            .withLatestFrom(state) { ($0, $1) }
            .map {
                var state = $1
                state.backLight = Double($0)
                FirebaseStore.shared.setPair(state)
                    .subscribe()
                    .disposed(by: self.disposeBag)

                return $0
            }
            .bind(to: brightness)
            .disposed(by: disposeBag)

        sleepTap
            .subscribe(onNext: { _ in
                FirebaseStore.shared.setPair(DeviceState(pair: self.group, color: "#ff0000", mode: "sleep", backLight: Double(self.brightness.value)))
                    .subscribe()
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

        wakeTap.subscribe(
            onNext: { _ in

                FirebaseStore.shared.setPair(DeviceState(pair: self.group, color: "#0000FF", mode: "wake", backLight: Double(self.brightness.value)))
                    .subscribe()
                    .disposed(by: self.disposeBag)
            }
        )
        .disposed(by: disposeBag)

//        brightness
//            .withLatestFrom(FirebaseStore.shared.state(group).filterNil()) { ($0, $1) }
//            .subscribe(onNext: { value, state in
//                var newState = state
//                newState.backLight = Double(value)
//                FirebaseStore.shared.setPair(newState)
//                    .subscribe()
//                    .disposed(by: self.disposeBag)
//            })
//            .disposed(by: disposeBag)

        return bindings()
    }
}
