//
//  ViewController.swift
//  ColorScreen
//
//  Created by Nick Trienens on 05/25/2019.
//  Copyright (c) 2019 Nick Trienens. All rights reserved.
//

import DynamicColor
import RxSwift
import SnapKit
import SwiftyButton
import UIKit

class ViewController: UIViewController {
    var disposeBag = DisposeBag()
}

// MARK: - filter and unwrap -

/// A type for describing Optionals, and thereby injecting their type into generic extensions.
public protocol OptionalType {
    associatedtype Boxed
    var asOptional: Boxed? { get }
}

/// Conformance to OptionalType.
extension Optional: OptionalType {
    public var asOptional: Wrapped? { return self }
}

extension ObservableType where Element: OptionalType {
    /// Advance an unwrapped Element if it is non-nil. In other words, convert an Observable<T?> to an Observable<T>.
    ///
    /// Drawn with little revision from http://stackoverflow.com/a/36788483
    ///
    /// - Returns: An `Observable` with an unwrapped Element.
    public func filterNil() -> Observable<Element.Boxed> {
        return filter { $0.asOptional != nil }
            .map { $0.asOptional! }
    }
}
