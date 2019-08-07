//
//  SVGEffect.swift
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

public struct SVGEffect: ExpressibleByDictionaryLiteral {
    
    private var elements: [UUID: SVGEffectElement]
    
    public var output: SVGEffectElement?
    
    public init() {
        self.elements = [:]
        self.output = nil
    }
    
    public init(elements: [UUID: SVGEffectElement], output: SVGEffectElement?) {
        self.elements = elements
        self.output = output
    }
    
    public init(dictionaryLiteral elements: (UUID, SVGEffectElement)...) {
        self.elements = Dictionary(uniqueKeysWithValues: elements)
    }
    
    public subscript(_ key: UUID) -> SVGEffectElement? {
        get {
            return elements[key]
        }
        set {
            elements[key] = newValue
        }
    }
    
    public var keys: Dictionary<UUID, SVGEffectElement>.Keys {
        return elements.keys
    }
    
    public var values: Dictionary<UUID, SVGEffectElement>.Values {
        return elements.values
    }
}

extension SVGEffect {
    
    public enum Source : Hashable {
        
        case source
        case sourceAlpha
        case reference(UUID)
        
        public init(_ uuid: UUID) {
            self = .reference(uuid)
        }
    }
}

public protocol SVGEffectElement {
    
    var region: Rect? { get set }
    
    var sources: [SVGEffect.Source] { get }
    
    func visibleBound(_ sources: [SVGEffect.Source: Rect]) -> Rect?
}

extension SVGEffect {
    
    public func simplify() -> SVGEffect {
        var table: [UUID: SVGEffectElement] = [:]
        self.enumerate { id, filter in table[id] = filter }
        return SVGEffect(elements: table, output: output)
    }
}

extension SVGEffect {
    
    public func visibleBound(_ bound: Rect) -> Rect {
        return self.apply(bound) { $1.region ?? $1.visibleBound($2) ?? bound } ?? bound
    }
}

extension SVGEffect {
    
    public func apply<S>(_ source: S, _ sourceAlpha: (S) -> S = { $0 }, _ body: (UUID?, SVGEffectElement, [SVGEffect.Source: S]) throws -> S?) rethrows -> S? {
        
        var table: [UUID: S] = [:]
        var source_alpha: S?
        
        try self.enumerate { uuid, filter in
            table[uuid] = try body(uuid, filter, Dictionary(filter.sources.compactMap { key in
                switch key {
                case .source: return (key, source)
                case .sourceAlpha:
                    source_alpha = source_alpha ?? sourceAlpha(source)
                    return (key, source_alpha!)
                case let .reference(id): return table[id].map { (key, $0) }
                }
            }, uniquingKeysWith: { first, _ in first }))
        }
        
        return try self.output.flatMap { try body(nil, $0, Dictionary($0.sources.compactMap { key in
            switch key {
            case .source: return (key, source)
            case .sourceAlpha:
                source_alpha = source_alpha ?? sourceAlpha(source)
                return (key, source_alpha!)
            case let .reference(id): return table[id].map { (key, $0) }
            }
        }, uniquingKeysWith: { first, _ in first })) }
    }
}

extension SVGEffectElement {
    
    fileprivate func enumerate(_ checked: inout Set<UUID>, _ elements: [UUID: SVGEffectElement], _ body: (UUID, SVGEffectElement) throws -> Void) rethrows -> Void {
        
        try self.sources.forEach {
            
            guard case let .reference(uuid) = $0 else { return }
            guard !checked.contains(uuid) else { return }
            guard let filter = elements[uuid] else { return }
            
            var _elements = elements
            _elements[uuid] = nil
            
            checked.insert(uuid)
            
            try filter.enumerate(&checked, _elements, body)
            try body(uuid, filter)
        }
    }
}

extension SVGEffect {
    
    public func enumerate(_ body: (UUID, SVGEffectElement) throws -> Void) rethrows -> Void {
        var checked: Set<UUID> = []
        try self.output?.enumerate(&checked, elements, body)
    }
}
