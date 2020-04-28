//
//  AttributedString.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

@frozen
public struct AttributedString<Attribute: Equatable>: Equatable {
    
    @usableFromInline
    var _string: String
    
    @usableFromInline
    var _attributes: [_Attribute]
    
    @inlinable
    public init<S: StringProtocol>(_ string: S, attribute: Attribute) {
        self._string = String(string)
        self._attributes = [_Attribute(index: 0, attribute: attribute)]
    }
    
    @inlinable
    init<S: StringProtocol>(string: S, attributes: [_Attribute]) {
        self._string = String(string)
        self._attributes = attributes
    }
}

extension AttributedString {
    
    @frozen
    @usableFromInline
    struct _Attribute: Equatable {
        
        @usableFromInline
        var index: Int
        
        @usableFromInline
        var attribute: Attribute
        
        @inlinable
        init(index: Int, attribute: Attribute) {
            self.index = index
            self.attribute = attribute
        }
    }
}

extension AttributedString {
    
    @frozen
    public struct AttributeCollection: Equatable {
        
        @usableFromInline
        var _string: String
        
        @usableFromInline
        var _attributes: [_Attribute]
        
        @inlinable
        init(string: String, attributes: [_Attribute]) {
            self._string = String(string)
            self._attributes = attributes
        }
    }
    
    @inlinable
    public var attributes: AttributeCollection {
        return AttributeCollection(string: _string, attributes: _attributes)
    }
}

extension AttributedString.AttributeCollection: RandomAccessCollection {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    public var startIndex: Int {
        return _attributes.startIndex
    }
    public var endIndex: Int {
        return _attributes.endIndex
    }
    
    public subscript(position: Int) -> (attribute: Attribute, range: Range<Int>) {
        let attribute = _attributes[position]
        let upperBound = position + 1 == _attributes.endIndex ? _string.count : _attributes[position + 1].index
        return (attribute.attribute, attribute.index..<upperBound)
    }
}

extension AttributedString._Attribute: Hashable where Attribute: Hashable {
    
}

extension AttributedString: Hashable where Attribute: Hashable {
    
}

extension AttributedString.AttributeCollection: Hashable where Attribute: Hashable {
    
}

extension AttributedString {
    
    @inlinable
    public var string: String {
        return _string
    }
    
    @inlinable
    public var count: Int {
        return _string.count
    }
    
    @inlinable
    public var isEmpty: Bool {
        return _string.isEmpty
    }
}

extension AttributedString {
    
    @inlinable
    public func attributedSubstring(from range: Range<Int>) -> AttributedString {
        
        precondition(range.clamped(to: 0..<_string.count) == range, "Index out of range.")
        
        let startIndex = _string.index(_string.startIndex, offsetBy: range.lowerBound)
        let endIndex = _string.index(_string.startIndex, offsetBy: range.upperBound)
        
        let substring = _string[startIndex..<endIndex]
        
        var attributes: [_Attribute] = []
        
        let start_attribute = _attributes.lazy.filter { $0.index <= range.lowerBound }.max { $0.index }?.attribute
        if let start_attribute = start_attribute {
            attributes.append(_Attribute(index: 0, attribute: start_attribute))
        }
        
        attributes.append(contentsOf: _attributes.lazy.compactMap { $0.index != range.lowerBound && range ~= $0.index ? _Attribute(index: $0.index - range.lowerBound, attribute: $0.attribute) : nil })
        
        return AttributedString(string: substring, attributes: attributes)
    }
}

extension AttributedString {
    
    @inlinable
    mutating func _fix_attributes() {
        
        if _string.isEmpty {
            
            self._attributes = [self._attributes[0]]
            
        } else {
            
            let attributes = self._attributes.filter { $0.index < _string.count }
            self._attributes = []
            
            for attribute in attributes where attribute != self._attributes.last {
                if attribute.index == self._attributes.last?.index {
                    self._attributes.removeLast()
                }
                self._attributes.append(attribute)
            }
        }
    }
}

extension AttributedString {
    
    @inlinable
    public mutating func append(_ other: String) {
        _string.append(contentsOf: other)
    }
    
    @inlinable
    public mutating func append(_ other: AttributedString) {
        
        let old_length = _string.count
        
        _string.append(contentsOf: other._string)
        _attributes.append(contentsOf: other._attributes.map { _Attribute(index: $0.index + old_length, attribute: $0.attribute) })
        
        self._fix_attributes()
    }
}

extension AttributedString {
    
    @inlinable
    public mutating func setAttribute(_ attribute: Attribute) {
        self._attributes = [_Attribute(index: 0, attribute: attribute)]
    }
    
    @inlinable
    public mutating func setAttribute<T>(_ value: T, for keyPath: WritableKeyPath<Attribute, T>) {
        
        for i in 0..<self._attributes.count {
            self._attributes[i].attribute[keyPath: keyPath] = value
        }
        
        self._fix_attributes()
    }
    
    @inlinable
    public mutating func setAttribute(_ attribute: Attribute, in range: Range<Int>) {
        
        precondition(range.clamped(to: 0..<_string.count) == range, "Index out of range.")
        
        if _string.isEmpty {
            
            self._attributes = [_Attribute(index: 0, attribute: attribute)]
            
        } else {
            
            let attributes = self._attributes
            
            self._attributes = attributes.filter { $0.index < range.lowerBound }
            self._attributes.append(_Attribute(index: range.lowerBound, attribute: attribute))
            
            let attributes_in_range = attributes.lazy.filter { $0.index != range.lowerBound && range ~= $0.index }
            if let attribute = attributes_in_range.max(by: { $0.index })?.attribute {
                self._attributes.append(_Attribute(index: range.upperBound, attribute: attribute))
            }
            
            self._attributes.append(contentsOf: attributes.lazy.filter { $0.index > range.upperBound })
            
            self._fix_attributes()
        }
    }
    
    @inlinable
    public mutating func setAttribute<T>(_ value: T, for keyPath: WritableKeyPath<Attribute, T>, in range: Range<Int>) {
        
        precondition(range.clamped(to: 0..<_string.count) == range, "Index out of range.")
        
        if _string.isEmpty {
            
            var attribute = self._attributes[0]
            attribute.attribute[keyPath: keyPath] = value
            self._attributes = [attribute]
            
        } else {
            
            let attributes = self._attributes
            
            self._attributes = attributes.filter { $0.index <= range.lowerBound }
            
            if self._attributes[self._attributes.count - 1].index == range.lowerBound {
                
                self._attributes[self._attributes.count - 1].attribute[keyPath: keyPath] = value
                
            } else {
                
                var attribute = self._attributes[self._attributes.count - 1].attribute
                attribute[keyPath: keyPath] = value
                self._attributes.append(_Attribute(index: range.lowerBound, attribute: attribute))
            }
            
            let attributes_in_range = attributes.lazy.filter { $0.index != range.lowerBound && range ~= $0.index }
            
            for var attribute in attributes_in_range {
                attribute.attribute[keyPath: keyPath] = value
                self._attributes.append(attribute)
            }
            
            if var attribute = attributes_in_range.max(by: { $0.index }) {
                attribute.attribute[keyPath: keyPath] = value
                self._attributes.append(_Attribute(index: range.upperBound, attribute: attribute.attribute))
            }
            
            self._attributes.append(contentsOf: attributes.lazy.filter { $0.index > range.upperBound })
            
            self._fix_attributes()
        }
    }
}

extension AttributedString {
    
    @inlinable
    public func replacingCharacters(in range: Range<Int>, with replacement: String) -> AttributedString {
        
        precondition(range.clamped(to: 0..<_string.count) == range, "Index out of range.")
        
        var result = self.attributedSubstring(from: 0..<range.lowerBound)
        result.append(replacement)
        result.append(self.attributedSubstring(from: range.upperBound..<_string.count))
        return result
    }
    
    @inlinable
    public func replacingCharacters(in range: Range<Int>, with replacement: AttributedString) -> AttributedString {
        
        precondition(range.clamped(to: 0..<_string.count) == range, "Index out of range.")
        
        var result = self.attributedSubstring(from: 0..<range.lowerBound)
        result.append(replacement)
        result.append(self.attributedSubstring(from: range.upperBound..<_string.count))
        return result
    }
}