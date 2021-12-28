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
        return self?.toJson() ?? .null
    }
}

extension Bool: JsonConvertible {
    
    @inlinable
    public func toJson() -> Json {
        return .boolean(self)
    }
}

extension SignedInteger where Self: FixedWidthInteger {
    
    @inlinable
    public func toJson() -> Json {
        return .number(Json.Number(self))
    }
}

extension UnsignedInteger where Self: FixedWidthInteger {
    
    @inlinable
    public func toJson() -> Json {
        return .number(Json.Number(self))
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
        return .number(Json.Number(self))
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
        return .number(.decimal(self))
    }
}

extension StringProtocol {
    
    @inlinable
    public func toJson() -> Json {
        return .string(String(self))
    }
}

extension String: JsonConvertible {
    
    @inlinable
    public func toJson() -> Json {
        return .string(self)
    }
}

extension Substring: JsonConvertible { }

extension Array: JsonConvertible where Element: JsonConvertible {
    
    @inlinable
    public func toJson() -> Json {
        return .array(self.map { $0.toJson() })
    }
}

extension Dictionary: JsonConvertible where Key == String, Value: JsonConvertible {
    
    @inlinable
    public func toJson() -> Json {
        return .dictionary(self.mapValues { $0.toJson() })
    }
}

extension OrderedDictionary: JsonConvertible where Key == String, Value: JsonConvertible {
    
    @inlinable
    public func toJson() -> Json {
        return .dictionary(Dictionary(self.mapValues { $0.toJson() }))
    }
}
