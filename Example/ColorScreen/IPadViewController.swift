//
//  ViewController.swift
//  ColorScreen
//
//  Created by Nick Trienens on 05/25/2019.
//  Copyright (c) 2019 Nick Trienens. All rights reserved.
//

import DynamicColor
import RxSwift
import UIKit

class PadViewController: ViewController {
    let viewModel = ColorViewModel()
    let player = AudioPlayer()
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isIdleTimerDisabled = true
        let originalColor = DynamicColor(hexString: "#c0392b")
        let desaturatedColor = originalColor.desaturated()
        view.backgroundColor = desaturatedColor

        let gestureTap = UITapGestureRecognizer(target: self, action: #selector(tap))
        view.addGestureRecognizer(gestureTap)

        let output = viewModel.bindings()
        output
            .state
            .subscribe(onNext: { state in
                self.view.backgroundColor = UIColor(hexString: state.color)
                UIScreen.main.brightness = CGFloat(state.backLight)

                self.player.play(AudioPlayer.Sounds.allCases.randomElement()!)

            })
            .disposed(by: disposeBag)
    }

    @objc func tap() {
        // viewModel.group = ""
        // UserDefaults.lastGroup = nil
        viewModel.searchNearby()
    }
}
