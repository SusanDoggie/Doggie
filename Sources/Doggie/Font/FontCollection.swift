//
//  FontCollection.swift
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

public struct FontCollection : SetAlgebra, Hashable, Collection, ExpressibleByArrayLiteral {
    
    private var fonts: Set<_ElementWrapper>
    
    private init(fonts: Set<_ElementWrapper>) {
        self.fonts = fonts
    }
    
    public init() {
        self.fonts = []
    }
    
    public init(arrayLiteral elements: Font ...) {
        self.fonts = Set(elements.map(_ElementWrapper.init))
    }
    
    public init(_ elements: Font ...) {
        self.fonts = Set(elements.map(_ElementWrapper.init))
    }
    
    public init<S : Sequence>(_ components: S) where S.Element == Font {
        self.fonts = Set(components.map(_ElementWrapper.init))
    }
}

extension FontCollection {
    
    fileprivate struct _ElementWrapper : Hashable {
        
        let font: Font
        
        init(font: Font) {
            self.font = font.with(size: 0)
        }
        
        var hashValue: Int {
            return font.fontName.hashValue
        }
        
        static func ==(lhs: _ElementWrapper, rhs: _ElementWrapper) -> Bool {
            return lhs.font.fontName == rhs.font.fontName
        }
    }
}

extension FontCollection {
    
    public struct Index : Comparable {
        
        fileprivate let base: Set<_ElementWrapper>.Index
        
        public static func ==(lhs: Index, rhs: Index) -> Bool {
            return lhs.base == rhs.base
        }
        
        public static func <(lhs: Index, rhs: Index) -> Bool {
            return lhs.base < rhs.base
        }
    }
    
    public struct Iterator : IteratorProtocol {
        
        fileprivate var base: SetIterator<_ElementWrapper>
        
        public mutating func next() -> Font? {
            return base.next()?.font
        }
    }
    
    public var startIndex: Index {
        return Index(base: fonts.startIndex)
    }
    
    public var endIndex: Index {
        return Index(base: fonts.endIndex)
    }
    
    public var count: Int {
        return fonts.count
    }
    
    public var isEmpty: Bool {
        return fonts.isEmpty
    }
    
    public subscript(position: Index) -> Font {
        return fonts[position.base].font
    }
    
    public func index(after i: Index) -> Index {
        return Index(base: fonts.index(after: i.base))
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(base: fonts.makeIterator())
    }
}

extension FontCollection {
    
    public var hashValue: Int {
        return fonts.hashValue
    }
    
    public static func ==(lhs: FontCollection, rhs: FontCollection) -> Bool {
        return lhs.fonts == rhs.fonts
    }
}

extension FontCollection {
    
    public var familyNames: Set<String> {
        return Set(fonts.flatMap { $0.font.familyName })
    }
}

extension FontCollection {
    
    public func contains(_ member: Font) -> Bool {
        return fonts.contains(_ElementWrapper(font: member))
    }
    
    public func filter(_ isIncluded: (Font) throws -> Bool) rethrows -> FontCollection {
        return FontCollection(fonts: try fonts.filter { try isIncluded($0.font) })
    }
    
    public func union(_ other: FontCollection) -> FontCollection {
        return FontCollection(fonts: fonts.union(other.fonts))
    }
    
    public func intersection(_ other: FontCollection) -> FontCollection {
        return FontCollection(fonts: fonts.intersection(other.fonts))
    }
    
    public func symmetricDifference(_ other: FontCollection) -> FontCollection {
        return FontCollection(fonts: fonts.symmetricDifference(other.fonts))
    }
    
    public mutating func insert(_ newMember: Font) -> (inserted: Bool, memberAfterInsert: Font) {
        let result = fonts.insert(_ElementWrapper(font: newMember))
        return (result.0, result.1.font)
    }
    
    public mutating func remove(_ member: Font) -> Font? {
        return fonts.remove(_ElementWrapper(font: member))?.font
    }
    
    public mutating func update(with newMember: Font) -> Font? {
        return fonts.update(with: _ElementWrapper(font: newMember))?.font
    }
    
    public mutating func formUnion(_ other: FontCollection) {
        fonts.formUnion(other.fonts)
    }
    
    public mutating func formIntersection(_ other: FontCollection) {
        fonts.formIntersection(other.fonts)
    }
    
    public mutating func formSymmetricDifference(_ other: FontCollection) {
        fonts.formSymmetricDifference(other.fonts)
    }
}

extension FontCollection : CustomStringConvertible {
    
    public var description: String {
        return "FontCollection(count: \(fonts.count))"
    }
}

protocol FontCollectionBase {
    
    var faces: [FontFaceBase] { get }
}

extension FontCollection {
    
    public enum Error : Swift.Error {
        
        case UnknownFormat
        case InvalidFormat(String)
        case Unsupported(String)
        case DecoderError(String)
    }
    
    public init(data: Data) throws {
        
        let decoders: [FontDecoder.Type] = [
            TTCDecoder.self,
            OpenTypeDecoder.self,
            WOFFDecoder.self,
            ]
        
        for Decoder in decoders {
            if let decoder = try Decoder.init(data: data) {
                self.init(decoder.faces.flatMap(Font.init))
                return
            }
        }
        
        throw Error.UnknownFormat
    }
}
