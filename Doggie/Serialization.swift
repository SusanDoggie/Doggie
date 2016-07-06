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

public func SDPropertyListWithData(data: Data) throws -> AnyObject {
    return try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil)
}
public func SDPropertyListWithStream(stream: InputStream) throws -> AnyObject {
    return try PropertyListSerialization.propertyList(with: stream, options: .mutableContainersAndLeaves, format: nil)
}
public func SDPropertyListSerializationBinary(data: AnyObject) throws -> Data {
    return try PropertyListSerialization.data(fromPropertyList: data, format: .binary, options: 0)
}
public func SDPropertyListSerialization(object: AnyObject) throws -> String {
    return String(data: try PropertyListSerialization.data(fromPropertyList: object, format: .xml, options: 0), encoding: String.Encoding.utf8)!
}
public func SDPropertyListSerialization(object: AnyObject, toStream stream: NSOutputStream) throws -> Int {
    var error: NSError? = nil
    let count = PropertyListSerialization.writePropertyList(object, to: stream, format: .xml, options: 0, error: &error)
    if error != nil {
        throw error!
    }
    return count
}
public func SDJSONWithData(data: Data) throws -> AnyObject {
    return try JSONSerialization.jsonObject(with: data, options: [.mutableContainers, .mutableLeaves])
}
public func SDJSONWithStream(stream: InputStream) throws -> AnyObject {
    return try JSONSerialization.jsonObject(with: stream, options: [.mutableContainers, .mutableLeaves])
}
public func SDJSONSerialization(object: AnyObject) throws -> String {
    if JSONSerialization.isValidJSONObject(object) {
        return String(data: try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted), encoding: String.Encoding.utf8)!
    }
    throw NSError(domain: #function, code: 1, userInfo: ["Message": "Invalid JSON Object"])
}
public func SDJSONSerialization(object: AnyObject, toStream stream: NSOutputStream) throws -> Int {
    if JSONSerialization.isValidJSONObject(object) {
        var error: NSError? = nil
        let count = JSONSerialization.writeJSONObject(object, to: stream, options: .prettyPrinted, error: &error)
        if error != nil {
            throw error!
        }
        return count
    }
    print("Error in \(#function): Invalid JSON Object")
    return 0
}

extension NSArray {
    
    public var plist: String? {
        return try? SDPropertyListSerialization(object: self)
    }
    
    public var json: String? {
        return try? SDJSONSerialization(object: self)
    }
}
extension NSDictionary {
    
    public var plist: String? {
        return try? SDPropertyListSerialization(object: self)
    }
    
    public var json: String? {
        return try? SDJSONSerialization(object: self)
    }
}
