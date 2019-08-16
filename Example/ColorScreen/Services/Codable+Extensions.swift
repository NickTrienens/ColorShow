//
//  Codable+Extensions.swift
//  MealTime
//
//  Created by Nick Trienens on 9/26/2018.
//  Copyright © 2018 GeckoGalleries. All rights reserved.
//

import Foundation

extension String {
    func decode<T: Decodable>() throws -> T {
        guard let data = self.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "could not make data"))
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    func decode<T: Decodable>() throws -> [T] {
        guard let data = self.data(using: .utf8) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "could not make data"))
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([T].self, from: data)
    }
}

extension Array where Element: Decodable {}

extension Dictionary {
    func asJSONString() throws -> String {
        return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted).toString()
    }
}

extension Data {
    struct StringConversion: Error {}

    func decode<T: Decodable>() throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: self)
    }

    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }

    func toString() throws -> String {
        if let ret = String(data: self, encoding: .utf8) {
            return ret
        }
        throw StringConversion()
    }
}

extension Encodable {
    func asString() throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self)
        if let val = String(data: data, encoding: .utf8) {
            return val
        }
        throw EncodingError.invalidValue("", EncodingError.Context(codingPath: [], debugDescription: ""))
    }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self)

        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            return json
        } else {
            throw EncodingError.invalidValue("", EncodingError.Context(codingPath: [], debugDescription: ""))
        }
    }
}

// Convenience around usage of dictionaries representing JSON objects.
extension Dictionary {
    /// Functions similarly to `NSDictionary's` valueForKeyPath.
    ///
    /// - parameter keyPath: The keypath of the value.
    ///
    /// - returns: The value at the given keypath is one exists.
    ///    If no key exists at the specified keypath, nil is returned.
    func value<T>(at keyPath: String) -> T? {
        var keys = keyPath.components(separatedBy: ".")
        if keys.count > 0, let key = keys[0] as? Key {
            if keys.count == 1 {
                return self[key] as? T
            } else if let dict = self[key] as? [Key: Any] {
                _ = keys.remove(at: 0)
                return dict.value(at: keys.joined(separator: "."))
            }
        }
        return nil
    }

    /// Print a `Dictionary` as a JSON-formatted string to assist in debugging.
    ///
    /// - Returns: A stringified representation of the `Dictionary`.
    /// - Throws: A `JSONSerialization` exception if the dictionary is not serializable.
    func prettyPrinted() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        return String(data: data, encoding: .utf8) ?? ""
    }
}
