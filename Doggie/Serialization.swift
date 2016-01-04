//
//  Serialization.swift
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

public func SDPropertyListWithData(data: NSData) throws -> AnyObject {
    return try NSPropertyListSerialization.propertyListWithData(data, options: NSPropertyListMutabilityOptions.MutableContainersAndLeaves, format: nil)
}
public func SDPropertyListWithStream(stream: NSInputStream) throws -> AnyObject {
    return try NSPropertyListSerialization.propertyListWithStream(stream, options: NSPropertyListMutabilityOptions.MutableContainersAndLeaves, format: nil)
}
public func SDPropertyListSerializationBinary(data: AnyObject) throws -> NSData {
    return try NSPropertyListSerialization.dataWithPropertyList(data, format: .BinaryFormat_v1_0, options: 0)
}
public func SDPropertyListSerialization(data: AnyObject) throws -> String {
    return String(data: try NSPropertyListSerialization.dataWithPropertyList(data, format: .XMLFormat_v1_0, options: 0), encoding: NSUTF8StringEncoding)!
}
public func SDPropertyListSerialization(data: AnyObject, toStream stream: NSOutputStream) throws -> Int {
    var error: NSError? = nil
    let count = NSPropertyListSerialization.writePropertyList(data, toStream: stream, format: .XMLFormat_v1_0, options: 0, error: &error)
    if error != nil {
        throw error!
    }
    return count
}
public func SDJSONWithData(data: NSData) throws -> AnyObject {
    return try NSJSONSerialization.JSONObjectWithData(data, options: [.MutableContainers, .MutableLeaves])
}
public func SDJSONWithStream(stream: NSInputStream) throws -> AnyObject {
    return try NSJSONSerialization.JSONObjectWithStream(stream, options: [.MutableContainers, .MutableLeaves])
}
public func SDJSONSerialization(data: AnyObject) throws -> String {
    if NSJSONSerialization.isValidJSONObject(data) {
        return String(data: try NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted), encoding: NSUTF8StringEncoding)!
    }
    throw NSError(domain: __FUNCTION__, code: 1, userInfo: ["Message": "Invalid JSON Object"])
}
public func SDJSONSerialization(data: AnyObject, toStream stream: NSOutputStream) throws -> Int {
    if NSJSONSerialization.isValidJSONObject(data) {
        var error: NSError? = nil
        let count = NSJSONSerialization.writeJSONObject(data, toStream: stream, options: .PrettyPrinted, error: &error)
        if error != nil {
            throw error!
        }
        return count
    }
    print("Error in \(__FUNCTION__): Invalid JSON Object")
    return 0
}

extension NSArray {
    
    public var plist: String? {
        return try? SDPropertyListSerialization(self)
    }
    
    public var json: String? {
        return try? SDJSONSerialization(self)
    }
}
extension NSDictionary {
    
    public var plist: String? {
        return try? SDPropertyListSerialization(self)
    }
    
    public var json: String? {
        return try? SDJSONSerialization(self)
    }
}
