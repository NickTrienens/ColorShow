//
//  AudioPlayer.swift
//  ColorScreen_Example
//
//  Created by Nicholas Trienens on 8/13/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import SwiftySound

class AudioPlayer {
    enum Sounds: String, CaseIterable {
        case cat
        case owl
        case elephant
        case goat
        case pig

        var file: URL? {
            return Bundle.main.url(forResource: rawValue, withExtension: ".mp3")
        }
    }

    func play(_ sound: Sounds) {
        let url = sound.file!
        print(url)
        Sound.play(url: url)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            Sound.stop(for: url)
        }
    }
}
