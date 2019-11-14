//
//  NSItemProvider.swift
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

#if canImport(ObjectiveC)

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public protocol NSItemProviderEncoder {
    
    static var writableTypeIdentifiersForItemProvider: [String] { get }
    
    var writableTypeIdentifiersForItemProvider: [String] { get }
    
    static func itemProviderVisibilityForRepresentation(withTypeIdentifier typeIdentifier: String) -> NSItemProviderRepresentationVisibility
    
    func itemProviderVisibilityForRepresentation(withTypeIdentifier typeIdentifier: String) -> NSItemProviderRepresentationVisibility
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress?
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension NSItemProviderEncoder {
    
    public var writableTypeIdentifiersForItemProvider: [String] {
        return Self.writableTypeIdentifiersForItemProvider
    }
    
    public static func itemProviderVisibilityForRepresentation(withTypeIdentifier typeIdentifier: String) -> NSItemProviderRepresentationVisibility {
        return .all
    }
    
    public func itemProviderVisibilityForRepresentation(withTypeIdentifier typeIdentifier: String) -> NSItemProviderRepresentationVisibility {
        return Self.itemProviderVisibilityForRepresentation(withTypeIdentifier: typeIdentifier)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
final class _WritingWrapper<Encoder: NSItemProviderEncoder> : NSObject, NSItemProviderWriting {
    
    let encoder: Encoder
    
    init(encoder: Encoder) {
        self.encoder = encoder
    }
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        return Encoder.writableTypeIdentifiersForItemProvider
    }
    
    var writableTypeIdentifiersForItemProvider: [String] {
        return encoder.writableTypeIdentifiersForItemProvider
    }
    
    static func itemProviderVisibilityForRepresentation(withTypeIdentifier typeIdentifier: String) -> NSItemProviderRepresentationVisibility {
        return Encoder.itemProviderVisibilityForRepresentation(withTypeIdentifier: typeIdentifier)
    }
    
    func itemProviderVisibilityForRepresentation(withTypeIdentifier typeIdentifier: String) -> NSItemProviderRepresentationVisibility {
        return encoder.itemProviderVisibilityForRepresentation(withTypeIdentifier: typeIdentifier)
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        return encoder.loadData(withTypeIdentifier: typeIdentifier, forItemProviderCompletionHandler: completionHandler)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension NSItemProvider {
    
    public convenience init<Encoder: NSItemProviderEncoder>(object: Encoder) {
        self.init(object: _WritingWrapper(encoder: object))
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
public protocol NSItemProviderDecoder {
    
    static var readableTypeIdentifiersForItemProvider: [String] { get }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self
}

class _ItemProviderReadingImp: NSObject, NSItemProviderReading {
    
    class var readableTypeIdentifiersForItemProvider: [String] { return [] }
    
    required init(itemProviderData data: Data, typeIdentifier: String) throws { }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return try Self(itemProviderData: data, typeIdentifier: typeIdentifier)
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
final class _ReadingWrapper<Decoder: NSItemProviderDecoder> : _ItemProviderReadingImp {
    
    let decoder: Decoder
    
    required init(itemProviderData data: Data, typeIdentifier: String) throws {
        self.decoder = try Decoder.object(withItemProviderData: data, typeIdentifier: typeIdentifier)
        try super.init(itemProviderData: data, typeIdentifier: typeIdentifier)
    }
    
    override class var readableTypeIdentifiersForItemProvider: [String] {
        return Decoder.readableTypeIdentifiersForItemProvider
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
extension NSItemProvider {
    
    public func canLoadObject<Decoder: NSItemProviderDecoder>(ofType aType: Decoder.Type) -> Bool {
        return self.canLoadObject(ofClass: _ReadingWrapper<Decoder>.self)
    }
    
    @discardableResult
    public func loadObject<Decoder: NSItemProviderDecoder>(ofType aType: Decoder.Type, completionHandler: @escaping (Decoder?, Error?) -> Void) -> Progress {
        return self.loadObject(ofClass: _ReadingWrapper<Decoder>.self) { completionHandler($0.flatMap { $0 as? _ReadingWrapper<Decoder> }.map { $0.decoder }, $1) }
    }
}

#endif

#if os(iOS)

@available(iOS 11.0, *)
extension UIDragDropSession {
    
    public func canLoadObjects<Decoder: NSItemProviderDecoder>(ofType aType: Decoder.Type) -> Bool {
        return self.canLoadObjects(ofClass: _ReadingWrapper<Decoder>.self)
    }
}

@available(iOS 11.0, *)
extension UIDropSession {
    
    @discardableResult
    public func loadObjects<Decoder: NSItemProviderDecoder>(ofType aType: Decoder.Type, completion: @escaping ([Decoder]) -> Void) -> Progress {
        return self.loadObjects(ofClass: _ReadingWrapper<Decoder>.self) { completion($0.lazy.compactMap { $0 as? _ReadingWrapper<Decoder> }.map { $0.decoder }) }
    }
}

@available(iOS 11.0, *)
extension UIPasteboard {
    
    public func setObjects<Encoder: NSItemProviderEncoder>(_ objects: [Encoder], localOnly: Bool, expirationDate: Date?) {
        self.setItemProviders(objects.map { NSItemProvider(object: $0) }, localOnly: localOnly, expirationDate: expirationDate)
    }
}

@available(iOS 11.0, *)
extension UIPasteConfiguration {
    
    public convenience init<Decoder: NSItemProviderDecoder>(forAccepting aType: Decoder.Type) {
        self.init(forAccepting: _ReadingWrapper<Decoder>.self)
    }
    
    public func addTypeIdentifiers<Decoder: NSItemProviderDecoder>(forAccepting aType: Decoder.Type) {
        self.addTypeIdentifiers(forAccepting: _ReadingWrapper<Decoder>.self)
    }
}

#endif
