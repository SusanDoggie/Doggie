//
//  CoreText.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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

#if canImport(CoreGraphics) && canImport(CoreText)

extension CTFramesetter {
    
    public var typesetter: CTTypesetter {
        return CTFramesetterGetTypesetter(self)
    }
    
    public func createFrame(_ path: CGPath,
                            _ stringRange: CFRange = CFRange(),
                            _ frameAttributes: CFDictionary? = nil) -> CTFrame {
        return CTFramesetterCreateFrame(self, stringRange, path, frameAttributes)
    }
    
    public func suggestFrameSize(_ constraints: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                                 _ stringRange: CFRange = CFRange(),
                                 _ frameAttributes: CFDictionary? = nil,
                                 _ fitRange: UnsafeMutablePointer<CFRange>? = nil) -> CGSize {
        return CTFramesetterSuggestFrameSizeWithConstraints(self, stringRange, frameAttributes, constraints, fitRange)
    }
}

extension CTFrame {
    
    public var stringRange: CFRange {
        return CTFrameGetStringRange(self)
    }
    
    public var visibleStringRange: CFRange {
        return CTFrameGetVisibleStringRange(self)
    }
    
    public var path: CGPath {
        return CTFrameGetPath(self)
    }
    
    public var attributes: CFDictionary? {
        return CTFrameGetFrameAttributes(self)
    }
    
    public var lines: [CTLine] {
        return CTFrameGetLines(self) as? [CTLine] ?? []
    }
}

extension CTLine {
    
    public func truncatedLine(_ width: Double, _ truncationType: CTLineTruncationType, _ truncationToken: CTLine?) -> CTLine? {
        return CTLineCreateTruncatedLine(self, width, truncationType, truncationToken)
    }
    
    public func justifiedLine(_ justificationFactor: CGFloat, _ justificationWidth: Double) -> CTLine? {
        return CTLineCreateJustifiedLine(self, justificationFactor, justificationWidth)
    }
    
    public var glyphCount: Int {
        return CTLineGetGlyphCount(self)
    }
    
    public var glyphRuns: [CTRun] {
        return CTLineGetGlyphRuns(self) as? [CTRun] ?? []
    }
    
    public var stringRange: CFRange {
        return CTLineGetStringRange(self)
    }
    
    public func penOffsetForFlush(_ flushFactor: CGFloat, _ flushWidth: Double) -> Double {
        return CTLineGetPenOffsetForFlush(self, flushFactor, flushWidth)
    }
    
    public func imageBounds(_ context: CGContext?) -> CGRect {
        return CTLineGetImageBounds(self, context)
    }
    
    public func typographicBounds(_ ascent: UnsafeMutablePointer<CGFloat>?,
                                  _ descent: UnsafeMutablePointer<CGFloat>?,
                                  _ leading: UnsafeMutablePointer<CGFloat>?) -> Double {
        return CTLineGetTypographicBounds(self, ascent, descent, leading)
    }
    
    public var trailingWhitespaceWidth: Double {
        return CTLineGetTrailingWhitespaceWidth(self)
    }
    
    public func stringIndexForPosition(_ position: CGPoint) -> CFIndex {
        return CTLineGetStringIndexForPosition(self, position)
    }
    
    public func offsetForStringIndex(_ charIndex: CFIndex, _ secondaryOffset: UnsafeMutablePointer<CGFloat>?) -> CGFloat {
        return CTLineGetOffsetForStringIndex(self, charIndex, secondaryOffset)
    }
}

extension CTRun {
    
    public var glyphCount: Int {
        return CTRunGetGlyphCount(self)
    }
    
    public var attributes: CFDictionary {
        return CTRunGetAttributes(self)
    }
    
    public var status: CTRunStatus {
        return CTRunGetStatus(self)
    }
    
    public var glyphs: [CGGlyph] {
        let count = glyphCount
        return Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            guard let buffer = buffer.baseAddress else { return }
            CTRunGetGlyphs(self, CFRange(), buffer)
            initializedCount = count
        }
    }
    
    public var positions: [CGPoint] {
        let count = glyphCount
        return Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            guard let buffer = buffer.baseAddress else { return }
            CTRunGetPositions(self, CFRange(), buffer)
            initializedCount = count
        }
    }
    
    public var advances: [CGSize] {
        let count = glyphCount
        return Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            guard let buffer = buffer.baseAddress else { return }
            CTRunGetAdvances(self, CFRange(), buffer)
            initializedCount = count
        }
    }
    
    public var stringIndices: [CFIndex] {
        let count = glyphCount
        return Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            guard let buffer = buffer.baseAddress else { return }
            CTRunGetStringIndices(self, CFRange(), buffer)
            initializedCount = count
        }
    }
    
    public var stringRange: CFRange {
        return CTRunGetStringRange(self)
    }
    
    public func typographicBounds(_ range: CFRange = CFRange(),
                                  _ ascent: UnsafeMutablePointer<CGFloat>?,
                                  _ descent: UnsafeMutablePointer<CGFloat>?,
                                  _ leading: UnsafeMutablePointer<CGFloat>?) -> Double {
        return CTRunGetTypographicBounds(self, range, ascent, descent, leading)
    }
    
    public func imageBounds(_ context: CGContext?, _ range: CFRange = CFRange()) -> CGRect {
        return CTRunGetImageBounds(self, context, range)
    }
    
    public var textMatrix: CGAffineTransform {
        return CTRunGetTextMatrix(self)
    }
}

extension CGContext {
    
    public func draw(_ string: CFAttributedString, in path: CGPath) {
        let framesetter = CTFramesetterCreateWithAttributedString(string)
        let frame = framesetter.createFrame(path)
        self.draw(frame)
    }
    
    public func draw(_ frame: CTFrame) {
        CTFrameDraw(frame, self)
    }
    
    public func draw(_ line: CTLine) {
        CTLineDraw(line, self)
    }
    
    public func draw(_ run: CTRun, _ range: CFRange = CFRange()) {
        CTRunDraw(run, self, range)
    }
}

#endif
