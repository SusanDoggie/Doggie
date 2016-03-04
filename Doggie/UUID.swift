//
//  UUID.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

import Foundation

public struct UUID {
    public var byte0, byte1, byte2, byte3: UInt8
    public var byte4, byte5: UInt8
    public var byte6, byte7: UInt8
    public var byte8, byte9: UInt8
    public var byte10, byte11, byte12, byte13, byte14, byte15: UInt8
}

extension UUID {
    
    public static var zero : UUID {
        return UUID(byte0: 0, byte1: 0, byte2: 0, byte3: 0, byte4: 0, byte5: 0, byte6: 0, byte7: 0, byte8: 0, byte9: 0, byte10: 0, byte11: 0, byte12: 0, byte13: 0, byte14: 0, byte15: 0)
    }
}

extension UUID {
    
    public var uuid: NSUUID {
        get {
            return NSUUID(UUIDBytes: [byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7, byte8, byte9, byte10, byte11, byte12, byte13, byte14, byte15])
        }
        set {
            withUnsafeMutablePointer(&self) { newValue.getUUIDBytes(UnsafeMutablePointer($0)) }
        }
    }
    
    public var cfuuid: CFUUID {
        get {
            return CFUUIDCreateWithBytes(nil, byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7, byte8, byte9, byte10, byte11, byte12, byte13, byte14, byte15)
        }
        set {
            let _cfuuid = CFUUIDGetUUIDBytes(newValue)
            byte0 = _cfuuid.byte0
            byte1 = _cfuuid.byte1
            byte2 = _cfuuid.byte2
            byte3 = _cfuuid.byte3
            byte4 = _cfuuid.byte4
            byte5 = _cfuuid.byte5
            byte6 = _cfuuid.byte6
            byte7 = _cfuuid.byte7
            byte8 = _cfuuid.byte8
            byte9 = _cfuuid.byte9
            byte10 = _cfuuid.byte10
            byte11 = _cfuuid.byte11
            byte12 = _cfuuid.byte12
            byte13 = _cfuuid.byte13
            byte14 = _cfuuid.byte14
            byte15 = _cfuuid.byte15
        }
    }
    
    public var string: String {
        return uuid.UUIDString
    }
    
    public init() {
        self.init(uuid: NSUUID())
    }
    
    public init(uuid: NSUUID) {
        byte0 = 0
        byte1 = 0
        byte2 = 0
        byte3 = 0
        byte4 = 0
        byte5 = 0
        byte6 = 0
        byte7 = 0
        byte8 = 0
        byte9 = 0
        byte10 = 0
        byte11 = 0
        byte12 = 0
        byte13 = 0
        byte14 = 0
        byte15 = 0
        withUnsafeMutablePointer(&self) { uuid.getUUIDBytes(UnsafeMutablePointer($0)) }
    }
    public init(cfuuid: CFUUID) {
        self.init(CFUUIDBytes: CFUUIDGetUUIDBytes(cfuuid))
    }
    public init(CFUUIDBytes _cfuuid: CFUUIDBytes) {
        byte0 = _cfuuid.byte0
        byte1 = _cfuuid.byte1
        byte2 = _cfuuid.byte2
        byte3 = _cfuuid.byte3
        byte4 = _cfuuid.byte4
        byte5 = _cfuuid.byte5
        byte6 = _cfuuid.byte6
        byte7 = _cfuuid.byte7
        byte8 = _cfuuid.byte8
        byte9 = _cfuuid.byte9
        byte10 = _cfuuid.byte10
        byte11 = _cfuuid.byte11
        byte12 = _cfuuid.byte12
        byte13 = _cfuuid.byte13
        byte14 = _cfuuid.byte14
        byte15 = _cfuuid.byte15
    }
    public init!(uuid: String) {
        if let _uuid = NSUUID(UUIDString: uuid) {
            self.init(uuid: _uuid)
        } else {
            return nil
        }
    }
}

extension UUID: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return self.string
    }
    public var debugDescription: String {
        return self.string
    }
}

extension UUID: Hashable, Comparable {
    
    public var hashValue: Int {
        return hash_combine(0, byte0, byte1, byte2, byte3, byte4, byte5, byte6, byte7, byte8, byte9, byte10, byte11, byte12, byte13, byte14, byte15)
    }
}

public func ==(lhs: UUID, rhs: UUID) -> Bool {
    return lhs.byte0 == rhs.byte0
        && lhs.byte1 == rhs.byte1
        && lhs.byte2 == rhs.byte2
        && lhs.byte3 == rhs.byte3
        && lhs.byte4 == rhs.byte4
        && lhs.byte5 == rhs.byte5
        && lhs.byte6 == rhs.byte6
        && lhs.byte7 == rhs.byte7
        && lhs.byte8 == rhs.byte8
        && lhs.byte9 == rhs.byte9
        && lhs.byte10 == rhs.byte10
        && lhs.byte11 == rhs.byte11
        && lhs.byte12 == rhs.byte12
        && lhs.byte13 == rhs.byte13
        && lhs.byte14 == rhs.byte14
        && lhs.byte15 == rhs.byte15
}

public func <(lhs: UUID, rhs: UUID) -> Bool {
    
    if lhs.byte0 < rhs.byte0 {
        return true
    } else if lhs.byte0 != rhs.byte0 {
        return false
    }
    
    if lhs.byte1 < rhs.byte1 {
        return true
    } else if lhs.byte1 != rhs.byte1 {
        return false
    }
    
    if lhs.byte2 < rhs.byte2 {
        return true
    } else if lhs.byte2 != rhs.byte2 {
        return false
    }
    
    if lhs.byte3 < rhs.byte3 {
        return true
    } else if lhs.byte3 != rhs.byte3 {
        return false
    }
    
    if lhs.byte4 < rhs.byte4 {
        return true
    } else if lhs.byte4 != rhs.byte4 {
        return false
    }
    
    if lhs.byte5 < rhs.byte5 {
        return true
    } else if lhs.byte5 != rhs.byte5 {
        return false
    }
    
    if lhs.byte6 < rhs.byte6 {
        return true
    } else if lhs.byte6 != rhs.byte6 {
        return false
    }
    
    if lhs.byte7 < rhs.byte7 {
        return true
    } else if lhs.byte7 != rhs.byte7 {
        return false
    }
    
    if lhs.byte8 < rhs.byte8 {
        return true
    } else if lhs.byte8 != rhs.byte8 {
        return false
    }
    
    if lhs.byte9 < rhs.byte9 {
        return true
    } else if lhs.byte9 != rhs.byte9 {
        return false
    }
    
    if lhs.byte10 < rhs.byte10 {
        return true
    } else if lhs.byte10 != rhs.byte10 {
        return false
    }
    
    if lhs.byte11 < rhs.byte11 {
        return true
    } else if lhs.byte11 != rhs.byte11 {
        return false
    }
    
    if lhs.byte12 < rhs.byte12 {
        return true
    } else if lhs.byte12 != rhs.byte12 {
        return false
    }
    
    if lhs.byte13 < rhs.byte13 {
        return true
    } else if lhs.byte13 != rhs.byte13 {
        return false
    }
    
    if lhs.byte14 < rhs.byte14 {
        return true
    } else if lhs.byte14 != rhs.byte14 {
        return false
    }
    
    if lhs.byte15 < rhs.byte15 {
        return true
    }
    
    return false
}
