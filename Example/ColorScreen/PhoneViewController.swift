//
//  ViewController.swift
//  ColorScreen
//
//  Created by Nick Trienens on 05/25/2019.
//  Copyright (c) 2019 Nick Trienens. All rights reserved.
//

import ColorSlider
import DynamicColor
import RxCocoa
import RxSwift
import SnapKit
import SwiftyButton
import UIKit

class PhoneViewController: ViewController {
    let sleepButton = FlatButton()
    let wakeButton = FlatButton()

    let colorSlider = ColorSlider(orientation: .horizontal, previewSide: .top)
    let brightnessSlider = UISlider()

    let viewModel = PhoneViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        subscriptions()
        addElements()

//        let gestureTap = UITapGestureRecognizer(target: self, action: #selector(tap))
//        view.addGestureRecognizer(gestureTap)
    }

    func addElements() {
        let originalColor = DynamicColor(hexString: "#c0392b")
        let desaturatedColor = originalColor.desaturated()
        view.backgroundColor = desaturatedColor

        sleepButton.color = UIColor.red.desaturated()
        sleepButton.setTitle("sleep", for: [])
        sleepButton.highlightedColor = UIColor.blue
        sleepButton.cornerRadius = 5
        view.addSubview(sleepButton)
        sleepButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(10)
            make.width.equalTo(100)
            make.height.equalTo(45)
        }

        wakeButton.color = UIColor.blue.desaturated()
        wakeButton.highlightedColor = UIColor.blue.adjustedAlpha(amount: 0.5)
        wakeButton.cornerRadius = 5
        wakeButton.setTitle("wake", for: [])
        view.addSubview(wakeButton)
        wakeButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
            make.width.equalTo(100)
            make.height.equalTo(45)
        }

        view.addSubview(colorSlider)
        colorSlider.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(40)
            make.trailing.leading.equalToSuperview().inset(30)
            make.height.equalTo(50)
        }

        view.addSubview(brightnessSlider)
        brightnessSlider.snp.makeConstraints { make in
            make.bottom.equalTo(colorSlider.snp.top).offset(-70)
            make.trailing.leading.equalToSuperview().inset(10)
        }
        brightnessSlider.setValue(0.6, animated: true)
    }

    func subscriptions() {
        let bindables = viewModel.bindings(wakeTap: wakeButton.rx.tap, sleepTap: sleepButton.rx.tap, brightessChanged: brightnessSlider.rx.value)

        bindables.state
            .subscribe(onNext: { state in
                DLog(CGFloat(state.backLight))
                let color = UIColor(hexString: state.color).darkened(amount: 0.25 - CGFloat(state.backLight) / 4)
                self.view.backgroundColor = color
                self.brightnessSlider.value = Float(state.backLight)
            })
            .disposed(by: disposeBag)
    }

    @objc func tap() {
        viewModel.group = ""
        UserDefaults.lastGroup = nil
        viewModel.searchNearby()
    }
}
