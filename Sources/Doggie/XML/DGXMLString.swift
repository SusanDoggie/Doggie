//
//  DGXMLString.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

extension DGXMLDocument {
    
    public func xmlString(prettyPrinted: Bool = false) -> String {
        var result = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        self._xml(prettyPrinted: prettyPrinted, &result)
        return result
    }
    
    public func xmlData(prettyPrinted: Bool = false) -> Data {
        let xml = self.xmlString(prettyPrinted: prettyPrinted)
        return xml.data(using: .utf8) ?? Data()
    }
    
    private func _xml(prettyPrinted: Bool, _ output: inout String) {
        for element in self {
            element._xml(prettyPrinted ? "\n" : "", prefixMap: [:], &output)
        }
    }
}

extension DGXMLDocument : CustomStringConvertible {
    
    public var description: String {
        return xmlString()
    }
}

extension DGXMLElement {
    
    fileprivate func _xml(_ terminator: String, prefixMap: [String: String], _ output: inout String) {
        
        switch kind {
        case let .node(_name, namespace):
            
            var prefixMap = prefixMap
            
            for (key, value) in attributes.filter({ $0.key.hasPrefix("xmlns:") }) {
                let substr = String(key.dropFirst(6)).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if !substr.isEmpty && !substr.contains(":") {
                    prefixMap[value] = substr
                }
            }
            
            let name = namespace.flatMap { prefixMap[$0].map { "\($0):\(_name)" } } ?? _name
            
            if attributes.count == 0 {
                if self.count == 0 {
                    "\(terminator)<\(name) />".write(to: &output)
                } else {
                    "\(terminator)<\(name)>".write(to: &output)
                    for element in self {
                        element._xml(terminator == "" ? terminator : "\(terminator)  ", prefixMap: prefixMap, &output)
                    }
                    "\(terminator)</\(name)>".write(to: &output)
                }
            } else {
                let attributes = self.attributes.map { "\($0)=\"\($1)\"" }.joined(separator: " ")
                if self.count == 0 {
                    "\(terminator)<\(name) \(attributes) />".write(to: &output)
                } else {
                    "\(terminator)<\(name) \(attributes)>".write(to: &output)
                    for element in self {
                        element._xml(terminator == "" ? terminator : "\(terminator)  ", prefixMap: prefixMap, &output)
                    }
                    "\(terminator)</\(name)>".write(to: &output)
                }
            }
            
        case let .characters(value): value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).write(to: &output)
        case let .comment(value): "\(terminator)<!--\(value)-->".write(to: &output)
        case let .CDATA(value): "\(terminator)<![CDATA[\(value)]]>".write(to: &output)
        }
        
    }
    
}
