//
//  WeakDictionary.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@_fixed_layout
public struct WeakDictionary<Key: AnyObject, Value> {
    
    @usableFromInline
    var base: [ObjectIdentifier: ValueContainer] {
        didSet {
            base = base.filter { $0.value.key != nil }
        }
    }
    
    @inlinable
    public init() {
        self.base = [:]
    }
    
    @inlinable
    public subscript(key: Key) -> Value? {
        get {
            guard let element = base[ObjectIdentifier(key)], element.key === key else { return nil }
            return element.value
        }
        set {
            base[ObjectIdentifier(key)] = newValue.map { ValueContainer(key: key, value: $0) }
        }
    }
    
    @inlinable
    public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            return self[key] ?? defaultValue()
        }
        set {
            self[key] = newValue
        }
    }
}

extension WeakDictionary {
    
    @usableFromInline
    struct ValueContainer {
        
        @usableFromInline
        weak var key: Key?
        
        @usableFromInline
        let value: Value
        
        @inlinable
        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
    }
}
