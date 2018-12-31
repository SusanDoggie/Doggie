//
//  SDXMLString.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

extension SDXMLDocument {
    
    public func xml(prettyPrinted: Bool = false) -> String {
        var result = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
        self._xml(prettyPrinted: prettyPrinted, &result)
        return result
    }
    
    public func data(prettyPrinted: Bool = false) -> Data {
        let xml = self.xml(prettyPrinted: prettyPrinted)
        return xml.data(using: .utf8) ?? Data()
    }
    
    private func _xml(prettyPrinted: Bool, _ output: inout String) {
        for element in self {
            element._xml(prettyPrinted ? "\n" : "", prefixMap: [:], &output)
        }
    }
}

extension SDXMLDocument : CustomStringConvertible {
    
    public var description: String {
        return xml()
    }
}

extension SDXMLElement : CustomStringConvertible {
    
    public var description: String {
        var result = ""
        self._xml("", prefixMap: [:], &result)
        return result
    }
}

extension SDXMLElement {
    
    fileprivate func _xml(_ indent: String, prefixMap: [String: Substring], _ output: inout String) {
        
        switch kind {
        case .node:
            
            var prefixMap = prefixMap
            
            for (key, value) in self._attributes.filter({ $0.key.attribute.hasPrefix("xmlns:") }) {
                let substr = key.attribute.dropFirst(6)
                if !substr.isEmpty && !substr.contains(":") {
                    prefixMap[value] = substr
                }
            }
            
            let name = prefixMap[self._namespace].map { "\($0):\(self._name)" } ?? self._name
            let attributes = self._attributes.map { attribute, value in " \(prefixMap[attribute.namespace].map { "\($0):\(attribute.attribute)" } ?? attribute.attribute)=\"\(value)\"" }.joined()
            
            if self.count == 0 {
                "\(indent)<\(name)\(attributes) />".write(to: &output)
            } else {
                "\(indent)<\(name)\(attributes)>".write(to: &output)
                var flag = false
                for element in self._elements {
                    flag = element.isNode || flag
                    element._xml(indent == "" ? indent : "\(indent)  ", prefixMap: prefixMap, &output)
                }
                if flag {
                    "\(indent)</\(name)>".write(to: &output)
                } else {
                    "</\(name)>".write(to: &output)
                }
            }
            
        case .characters: _string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).write(to: &output)
        case .comment: "\(indent)<!--\(_string)-->".write(to: &output)
        case .CDATA: "\(indent)<![CDATA[\(_string)]]>".write(to: &output)
        }
    }
}

