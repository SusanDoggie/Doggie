//
//  FontCollection.swift
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
public struct FontCollection: SetAlgebra, Hashable, Collection, ExpressibleByArrayLiteral {
    
    @usableFromInline
    var fonts: Set<Font>
    
    @inlinable
    init(fonts: Set<Font>) {
        self.fonts = fonts
    }
    
    @inlinable
    public init() {
        self.fonts = []
    }
    
    @inlinable
    public init(arrayLiteral elements: Font ...) {
        self.fonts = Set(elements.map { $0.with(size: 0, features: [:]) })
    }
    
    @inlinable
    public init<S: Sequence>(_ components: S) where S.Element == Font {
        self.fonts = Set(components.map { $0.with(size: 0, features: [:]) })
    }
}

extension FontCollection {
    
    @frozen
    public struct Index: Comparable, Hashable {
        
        @usableFromInline
        let base: Set<Font>.Index
        
        @inlinable
        init(base: Set<Font>.Index) {
            self.base = base
        }
        
        @inlinable
        public static func <(lhs: Index, rhs: Index) -> Bool {
            return lhs.base < rhs.base
        }
    }
    
    @frozen
    public struct Iterator: IteratorProtocol {
        
        @usableFromInline
        var base: SetIterator<Font>
        
        @inlinable
        init(base: SetIterator<Font>) {
            self.base = base
        }
        
        @inlinable
        public mutating func next() -> Font? {
            return base.next()
        }
    }
    
    @inlinable
    public var startIndex: Index {
        return Index(base: fonts.startIndex)
    }
    
    @inlinable
    public var endIndex: Index {
        return Index(base: fonts.endIndex)
    }
    
    @inlinable
    public var count: Int {
        return fonts.count
    }
    
    @inlinable
    public var isEmpty: Bool {
        return fonts.isEmpty
    }
    
    @inlinable
    public subscript(position: Index) -> Font {
        return fonts[position.base]
    }
    
    @inlinable
    public func index(after i: Index) -> Index {
        return Index(base: fonts.index(after: i.base))
    }
    
    @inlinable
    public func makeIterator() -> Iterator {
        return Iterator(base: fonts.makeIterator())
    }
}

extension FontCollection {
    
    @inlinable
    public var familyNames: Set<String> {
        return Set(fonts.compactMap { $0.familyName })
    }
}

extension FontCollection {
    
    @inlinable
    public func contains(_ member: Font) -> Bool {
        return fonts.contains(member.with(size: 0, features: [:]))
    }
    
    @inlinable
    public func filter(_ isIncluded: (Font) throws -> Bool) rethrows -> FontCollection {
        return FontCollection(fonts: try fonts.filter { try isIncluded($0) })
    }
    
    @inlinable
    public func union(_ other: FontCollection) -> FontCollection {
        return FontCollection(fonts: fonts.union(other.fonts))
    }
    
    @inlinable
    public func intersection(_ other: FontCollection) -> FontCollection {
        return FontCollection(fonts: fonts.intersection(other.fonts))
    }
    
    @inlinable
    public func symmetricDifference(_ other: FontCollection) -> FontCollection {
        return FontCollection(fonts: fonts.symmetricDifference(other.fonts))
    }
    
    @inlinable
    public func subtracting(_ other: FontCollection) -> FontCollection {
        return FontCollection(fonts: fonts.subtracting(other.fonts))
    }
    
    @inlinable
    @discardableResult
    public mutating func insert(_ newMember: Font) -> (inserted: Bool, memberAfterInsert: Font) {
        return fonts.insert(newMember.with(size: 0, features: [:]))
    }
    
    @inlinable
    @discardableResult
    public mutating func remove(_ member: Font) -> Font? {
        return fonts.remove(member.with(size: 0, features: [:]))
    }
    
    @inlinable
    @discardableResult
    public mutating func update(with newMember: Font) -> Font? {
        return fonts.update(with: newMember.with(size: 0, features: [:]))
    }
    
    @inlinable
    public mutating func formUnion(_ other: FontCollection) {
        fonts.formUnion(other.fonts)
    }
    
    @inlinable
    public mutating func formIntersection(_ other: FontCollection) {
        fonts.formIntersection(other.fonts)
    }
    
    @inlinable
    public mutating func formSymmetricDifference(_ other: FontCollection) {
        fonts.formSymmetricDifference(other.fonts)
    }
    
    @inlinable
    public mutating func subtract(_ other: FontCollection) {
        fonts.subtract(other.fonts)
    }
    
    @inlinable
    public func isSubset(of other: FontCollection) -> Bool {
        return fonts.isSubset(of: other.fonts)
    }
    
    @inlinable
    public func isDisjoint(with other: FontCollection) -> Bool {
        return fonts.isDisjoint(with: other.fonts)
    }
    
    @inlinable
    public func isSuperset(of other: FontCollection) -> Bool {
        return fonts.isSuperset(of: other.fonts)
    }
    
}

extension FontCollection: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return "FontCollection(count: \(fonts.count))"
    }
}

protocol FontCollectionBase {
    
    var faces: [FontFaceBase] { get }
}

extension FontCollection {
    
    public enum Error: Swift.Error {
        
        case UnknownFormat
        case InvalidFormat(String)
        case Unsupported(String)
        case DecoderError(String)
    }
    
    public init(data: Data) throws {
        
        let decoders: [FontDecoder.Type] = [
            TTCDecoder.self,
            WOFFDecoder.self,
            OpenTypeDecoder.self,
            ]
        
        for Decoder in decoders {
            if let decoder = try Decoder.init(data: data) {
                self.init(decoder.faces.compactMap(Font.init))
                return
            }
        }
        
        throw Error.UnknownFormat
    }
    
    public init(contentsOf url: URL, options: Data.ReadingOptions = []) throws {
        try self.init(data: Data(contentsOf: url, options: options))
    }
    
    public init(contentsOfFile path: String, options: Data.ReadingOptions = []) throws {
        try self.init(data: Data(contentsOf: URL(fileURLWithPath: path), options: options))
    }
}

extension FontCollection {
    
    public init<S: Sequence>(urls: S) where S.Element == URL {
        
        self.init()
        
        let fonts = FileManager.default.fileUrls(urls).parallelMap { try? FontCollection(contentsOf: $0, options: .alwaysMapped) }
        
        for _fonts in fonts {
            if let _fonts = _fonts {
                self.formUnion(_fonts)
            }
        }
    }
    
    public init(url: URL) {
        self.init(urls: CollectionOfOne(url))
    }
}

