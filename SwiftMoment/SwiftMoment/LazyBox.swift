//
//  LazyBox.swift
//
//  Created by Ole Begemann on 17.12.15.
//  Copyright © 2016 Ole Begemann. All rights reserved.
//

import Foundation

internal enum LazyValue<T> {
    case NotYetComputed(() -> T)
    case Computed(T)
}


/// Adapted to Swift 3 from
/// https://oleb.net/blog/2015/12/lazy-properties-in-structs-swift/
internal final class LazyBox<T> {
    init(computation: @escaping () -> T) {
        _value = .NotYetComputed(computation)
    }

    private var _value: LazyValue<T>

    /// All reads and writes of `_value` must happen on this queue.
    private let queue = DispatchQueue(label: "LazyBox._value")

    var value: T {
        var returnValue: T? = nil
        queue.sync {
            switch self._value {
            case .NotYetComputed(let computation):
                let result = computation()
                self._value = .Computed(result)
                returnValue = result
            case .Computed(let result):
                returnValue = result
            }
        }
        assert(returnValue != nil)
        return returnValue!
    }
}
