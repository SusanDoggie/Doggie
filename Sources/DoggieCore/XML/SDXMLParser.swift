//
//  SDXMLParser.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

extension SDXMLDocument {
    
    public enum Error: Swift.Error {
        
        case unknown
        case parser(String)
    }
    
    public init(xml string: String) throws {
        try self.init(data: string._utf8_data)
    }
    
    public init(data: Data) throws {
        let parser = SDXMLParser(data: data)
        guard parser.parse() else { throw parser.parserError.map { Error.parser($0.localizedDescription) } ?? Error.unknown }
        self = parser.document
    }
    
    public init(contentsOf url: URL, options: Data.ReadingOptions = []) throws {
        try self.init(data: Data(contentsOf: url, options: options))
    }
    
    public init(contentsOfFile path: String, options: Data.ReadingOptions = []) throws {
        try self.init(data: Data(contentsOf: URL(fileURLWithPath: path), options: options))
    }
}

final class SDXMLParser: XMLParser, XMLParserDelegate {
    
    var document = SDXMLDocument()
    var stack: [(SDXMLElement, [String: String])] = []
    var namespaces: [String: String] = [:]
    
    override init(data: Data) {
        super.init(data: data)
        self.delegate = self
        self.shouldProcessNamespaces = true
        self.shouldReportNamespacePrefixes = true
    }
    
    func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
        namespaces[prefix] = namespaceURI
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        
        var attributeDict = attributeDict
        
        for (prefix, uri) in namespaces {
            attributeDict[prefix == "" ? "xmlns" : "xmlns:\(prefix)"] = uri
        }
        
        var attributes: [SDXMLAttribute: String] = [:]
        
        for (_attribute, value) in attributeDict {
            
            let prefix: String
            let attribute: String
            var namespace: String?
            
            let split = _attribute.split(separator: ":")
            
            if split.count == 2 && split[0] != "xmlns" {
                prefix = String(split[0])
                attribute = String(split[1])
            } else {
                prefix = ""
                attribute = _attribute
            }
            
            if let _namespace = namespaces.first(where: { $0.key == prefix })?.value {
                namespace = _namespace
            } else {
                for (_, namespaces) in stack.reversed() {
                    if let _namespace = namespaces.first(where: { $0.key == prefix })?.value {
                        namespace = _namespace
                        break
                    }
                }
            }
            
            if let namespace = namespace {
                attributes[SDXMLAttribute(attribute: attribute, namespace: namespace)] = value
            } else {
                attributes[SDXMLAttribute(attribute: _attribute)] = value
            }
        }
        
        stack.append((SDXMLElement(name: elementName, namespace: namespaceURI ?? "", attributes: attributes), namespaces))
        namespaces = [:]
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let last = stack.popLast() {
            if stack.isEmpty {
                document.append(last.0)
            } else {
                stack.mutableLast.0.append(last.0)
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let string = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if string != "" {
            if stack.isEmpty {
                document.append(SDXMLElement(characters: string))
            } else {
                stack.mutableLast.0.append(SDXMLElement(characters: string))
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundComment comment: String) {
        if stack.isEmpty {
            document.append(SDXMLElement(comment: comment))
        } else {
            stack.mutableLast.0.append(SDXMLElement(comment: comment))
        }
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if stack.isEmpty {
            document.append(SDXMLElement(CDATA: String(data: CDATABlock, encoding: .utf8) ?? ""))
        } else {
            stack.mutableLast.0.append(SDXMLElement(CDATA: String(data: CDATABlock, encoding: .utf8) ?? ""))
        }
    }
}
