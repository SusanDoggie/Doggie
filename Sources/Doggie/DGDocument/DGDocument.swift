//
//  DGDocument.swift
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

public struct DGDocument {
    
    fileprivate let rootId: Int
    public let table: [Int: Value]
    
    public init(root: Int, table: [Int: Value]) {
        self.rootId = root
        self.table = DGDocument.trim(root: root, table: table)
    }
}

extension DGDocument {
    
    fileprivate static func trim(root: Int, table: [Int: Value]) -> [Int: Value] {
        var result: [Int: Value] = [:]
        if table[root] != nil {
            var checking = [root]
            while let id = checking.popLast() {
                if let item = table[id] {
                    switch item {
                    case .indirect: break
                    case let .array(array):
                        result[id] = table[id]
                        checking.append(contentsOf: array.flatMap { $0.identifier.flatMap { result[$0] == nil ? $0 : nil } })
                    case let .dictionary(dictionary):
                        result[id] = table[id]
                        checking.append(contentsOf: dictionary.flatMap { $1.identifier.flatMap { result[$0] == nil ? $0 : nil } })
                    default:
                        result[id] = table[id]
                    }
                }
            }
        }
        return result
    }
}

extension DGDocument {
    
    public struct View {
        
        fileprivate var table: [Int: Value] = [:]
        
        public let identifier: Int?
        public let value: DGDocument.Value
    }
    
    public var root: DGDocument.View? {
        return table[rootId].map { DGDocument.View(table: table, identifier: rootId, value: $0) }
    }
}

extension DGDocument.View {
    
    public var count: Int {
        return self.value.count
    }
    
    public subscript(index: Int) -> DGDocument.View {
        let value = self.value[index]
        switch value {
        case let .indirect(identifier): return table[identifier].map { DGDocument.View(table: table, identifier: identifier, value: $0) } ?? DGDocument.View(table: table, identifier: identifier, value: nil)
        default: return DGDocument.View(table: table, identifier: nil, value: value)
        }
    }
    
    public var keys: LazyMapCollection<[String: DGDocument.Value], String> {
        return self.value.keys
    }
    
    public subscript(key: String) -> DGDocument.View {
        let value = self.value[key]
        switch value {
        case let .indirect(identifier): return table[identifier].map { DGDocument.View(table: table, identifier: identifier, value: $0) } ?? DGDocument.View(table: table, identifier: identifier, value: nil)
        default: return DGDocument.View(table: table, identifier: nil, value: value)
        }
    }
}
