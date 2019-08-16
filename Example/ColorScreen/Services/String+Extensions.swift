//
//  String+Extensions.swift
//  MealTime
//
//  Created by Nick Trienens on 9/26/2018.
//  Copyright © 2018 GeckoGalleries. All rights reserved.
//

import Foundation

extension String {
    func contains(needle: String, options: CompareOptions = []) -> Bool {
        return range(of: needle, options: options) != nil
    }

    func startsWith(needle: String, options: CompareOptions = []) -> Bool {
        if let loc = self.range(of: needle, options: options), loc.lowerBound == self.startIndex {
            return true
        }
        return false
    }

    func limited(_ max: Int) -> String {
        if count > max {
            return String(prefix(upTo: index(startIndex, offsetBy: max)))
        }
        return self
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = capitalizingFirstLetter()
    }

    func digits() -> String {
        let invalidCharacters = CharacterSet.decimalDigits.inverted

        return components(separatedBy: invalidCharacters)
            .joined(separator: "")
    }
}

public func DLog(_ message: Any, filename: String = #file, function: String = #function, line: Int = #line) {
    let formatter = DateFormatter()
    formatter.dateFormat = "h:mm:ss.SSS"
    let timeString = formatter.string(from: Date())
    if let index = filename.range(of: "/", options: .backwards, range: nil, locale: nil)?.lowerBound {
        let finalIndex = filename.index(index, offsetBy: 1)
        let filename = filename[finalIndex...]
        let output = "\(filename) \(function)[\(line)]@\(timeString): \(message)"
        print(output)
    } else {
        let output = "\(function)[\(line)]@\(timeString): \(message)"
        print(output)
    }
}

public func delay(_ time: Float, block: @escaping (() -> Void)) {
    let delayTimeout = Int64(time * Float(NSEC_PER_SEC))
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(delayTimeout) / Double(NSEC_PER_SEC)) { () -> Void in
        block()
    }
}
