//
//  JsonConvertible.swift
//
//  The MIT License
//  Copyright (c) 2021 The Oddmen Technology Limited. All rights reserved.
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

public protocol JsonConvertible {
    
    func toJson() -> Json
}

extension Json: JsonConvertible {
    
    @inlinable
    public func toJson() -> Json {
        return self
    }
}

extension Optional: JsonConvertible where Wrapped: JsonConvertible {
    
    @inlinable
    public func toJson() -> Json {
        return self?.toJson() ?? nil
    }
}

extension Bool: JsonConvertible {
    
    @inlinable
    public func toJson() -> Json {
        return Json(self)
    }
}

extension SignedInteger where Self: FixedWidthInteger {
    
    @inlinable
    public func toJson() -> Json {
        return Json(self)
    }
}

extension UnsignedInteger where Self: FixedWidthInteger {
    
    @inlinable
    public func toJson() -> Json {
        return Json(self)
    }
}

extension UInt: JsonConvertible { }
extension UInt8: JsonConvertible { }
extension UInt16: JsonConvertible { }
extension UInt32: JsonConvertible { }
extension UInt64: JsonConvertible { }
extension Int: JsonConvertible { }
extension Int8: JsonConvertible { }
extension Int16: JsonConvertible { }
extension Int32: JsonConvertible { }
extension Int64: JsonConvertible { }

extension BinaryFloatingPoint {
    
    @inlinable
    public func toJson() -> Json {
        return Json(self)
    }
}

#if swift(>=5.3) && !os(macOS) && !targetEnvironment(macCatalyst)

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
extension Float16: JsonConvertible { }

#endif

extension float16: JsonConvertible { }
extension Float: JsonConvertible { }
extension Double: JsonConvertible { }

extension Decimal: JsonConvertible {
    
    @inlinable
    public func toJson() -> Json {
        return Json(self)
    }
}

extension StringProtocol {
    
    @inlinable
    public func toJson() -> Json {
        return Json(String(self))
    }
}

extension String: JsonConvertible {
    
    @inlinable
    public func toJson() -> Json {
        return Json(self)
    }
}

extension Substring: JsonConvertible { }

extension Array: JsonConvertible where Element: JsonConvertible {
    
    @inlinable
    public func toJson() -> Json {
        return Json(self)
    }
}

extension Dictionary: JsonConvertible where Key == String, Value: JsonConvertible {
    
    @inlinable
    public func toJson() -> Json {
        return Json(self)
    }
}

extension OrderedDictionary: JsonConvertible where Key == String, Value: JsonConvertible {
    
    @inlinable
    public func toJson() -> Json {
        return Json(self)
    }
}
