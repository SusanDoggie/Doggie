//
//  ObjectiveC.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if canImport(ObjectiveC)

import ObjectiveC

@inlinable
@discardableResult
public func synchronized<R>(object: AnyObject, block: () throws -> R) rethrows -> R {
    objc_sync_enter(object)
    defer { objc_sync_exit(object) }
    return try block()
}

private class _ValueBindingTableValue {
    
    let observer: NSKeyValueObservation
    
    init(observer: NSKeyValueObservation) {
        self.observer = observer
    }
    
    deinit {
        observer.invalidate()
    }
}

extension WeakDictionary where Key == AnyObject, Value == [AnyKeyPath: _ValueBindingTableValue] {
    
    fileprivate subscript(target: AnyObject, keyPath: AnyKeyPath) -> _ValueBindingTableValue? {
        get {
            return self[target]?[keyPath]
        }
        set {
            self[target, default: [:]][keyPath] = newValue
        }
    }
}

private var NSObjectValueBindingKey = "NSObjectValueBindingKey"

extension NSObjectProtocol where Self: NSObject {
    
    private var _observers: WeakDictionary<AnyObject, [AnyKeyPath: _ValueBindingTableValue]> {
        get {
            return objc_getAssociatedObject(self, &NSObjectValueBindingKey) as? WeakDictionary ?? WeakDictionary()
        }
        set {
            objc_setAssociatedObject(self, &NSObjectValueBindingKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public func bindValue<Value, Target: AnyObject>(_ sourceKeyPath: KeyPath<Self, Value>,
                                                    to target: Target,
                                                    at targetKeyPath: ReferenceWritableKeyPath<Target, Value>)
    {
        let observer = observe(sourceKeyPath, options: [.initial, .new]) { [weak target] (_, change) in
            guard let newValue = change.newValue else { return }
            target?[keyPath: targetKeyPath] = newValue
        }
        
        synchronized(object: self) { _observers[target, targetKeyPath] = _ValueBindingTableValue(observer: observer) }
    }
}

#endif

