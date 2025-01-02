//
//  NSItemProvider.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

#if canImport(ObjectiveC)

public protocol NSItemProviderDecoder {
    
    static var readableTypeIdentifiersForItemProvider: [String] { get }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self
}

public protocol NSItemProviderEncoder {
    
    static var writableTypeIdentifiersForItemProvider: [String] { get }
    
    var writableTypeIdentifiersForItemProvider: [String] { get }
    
    static func itemProviderVisibilityForRepresentation(withTypeIdentifier typeIdentifier: String) -> NSItemProviderRepresentationVisibility
    
    func itemProviderVisibilityForRepresentation(withTypeIdentifier typeIdentifier: String) -> NSItemProviderRepresentationVisibility
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress?
}

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

private final class _ItemProvider<Item>: NSObject, NSItemProviderReading, NSItemProviderWriting {
    
    let item: Item
    
    init(item: Item) {
        self.item = item
    }
    
    static var readableTypeIdentifiersForItemProvider: [String] {
        guard let Decoder = Item.self as? NSItemProviderDecoder.Type else { fatalError() }
        return Decoder.readableTypeIdentifiersForItemProvider
    }
    
    static var writableTypeIdentifiersForItemProvider: [String] {
        guard let Encoder = Item.self as? NSItemProviderEncoder.Type else { fatalError() }
        return Encoder.writableTypeIdentifiersForItemProvider
    }
    
    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        guard let Decoder = Item.self as? NSItemProviderDecoder.Type else { fatalError() }
        return try Self(item: Decoder.object(withItemProviderData: data, typeIdentifier: typeIdentifier) as! Item)
    }
    
    var writableTypeIdentifiersForItemProvider: [String] {
        guard let encoder = item as? NSItemProviderEncoder else { fatalError() }
        return encoder.writableTypeIdentifiersForItemProvider
    }
    
    static func itemProviderVisibilityForRepresentation(withTypeIdentifier typeIdentifier: String) -> NSItemProviderRepresentationVisibility {
        guard let Encoder = Item.self as? NSItemProviderEncoder.Type else { fatalError() }
        return Encoder.itemProviderVisibilityForRepresentation(withTypeIdentifier: typeIdentifier)
    }
    
    func itemProviderVisibilityForRepresentation(withTypeIdentifier typeIdentifier: String) -> NSItemProviderRepresentationVisibility {
        guard let encoder = item as? NSItemProviderEncoder else { fatalError() }
        return encoder.itemProviderVisibilityForRepresentation(withTypeIdentifier: typeIdentifier)
    }
    
    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        guard let encoder = item as? NSItemProviderEncoder else { fatalError() }
        return encoder.loadData(withTypeIdentifier: typeIdentifier, forItemProviderCompletionHandler: completionHandler)
    }
}

extension NSItemProvider {
    
    public convenience init<Encoder: NSItemProviderEncoder>(object: Encoder) {
        self.init(object: _ItemProvider(item: object))
    }
}

extension NSItemProvider {
    
    public func canLoadObject<Decoder: NSItemProviderDecoder>(ofType aType: Decoder.Type) -> Bool {
        return self.canLoadObject(ofClass: _ItemProvider<Decoder>.self)
    }
    
    @discardableResult
    public func loadObject<Decoder: NSItemProviderDecoder>(ofType aType: Decoder.Type, completionHandler: @escaping (Decoder?, Error?) -> Void) -> Progress {
        return self.loadObject(ofClass: _ItemProvider<Decoder>.self) { completionHandler($0.flatMap { $0 as? _ItemProvider<Decoder> }.map { $0.item }, $1) }
    }
}

extension NSItemProviderEncoder {
    
    fileprivate var itemProvider: NSItemProvider {
        return NSItemProvider(object: self)
    }
}

#endif

#if os(iOS) || targetEnvironment(macCatalyst)

import UIKit

extension UIDragItem {
    
    public convenience init(object: NSItemProviderWriting) {
        self.init(itemProvider: NSItemProvider(object: object))
        self.localObject = object
    }
    
    public convenience init<Encoder: NSItemProviderEncoder>(object: Encoder) {
        self.init(itemProvider: NSItemProvider(object: object))
        self.localObject = object
    }
}

extension UIDragDropSession {
    
    public func canLoadObjects<Decoder: NSItemProviderDecoder>(ofType aType: Decoder.Type) -> Bool {
        return self.canLoadObjects(ofClass: _ItemProvider<Decoder>.self)
    }
}

extension UIDropSession {
    
    @discardableResult
    public func loadObjects<Decoder: NSItemProviderDecoder>(ofType aType: Decoder.Type, completion: @escaping ([Decoder]) -> Void) -> Progress {
        return self.loadObjects(ofClass: _ItemProvider<Decoder>.self) { completion($0.lazy.compactMap { $0 as? _ItemProvider<Decoder> }.map { $0.item }) }
    }
}

extension UIPasteboard {
    
    public func setObjects(_ objects: [NSItemProviderEncoder], localOnly: Bool = false, expirationDate: Date? = nil) {
        self.setItemProviders(objects.map { $0.itemProvider }, localOnly: localOnly, expirationDate: expirationDate)
    }
}

extension UIPasteConfiguration {
    
    public convenience init<Decoder: NSItemProviderDecoder>(forAccepting aType: Decoder.Type) {
        self.init(forAccepting: _ItemProvider<Decoder>.self)
    }
    
    public func addTypeIdentifiers<Decoder: NSItemProviderDecoder>(forAccepting aType: Decoder.Type) {
        self.addTypeIdentifiers(forAccepting: _ItemProvider<Decoder>.self)
    }
}

#endif
