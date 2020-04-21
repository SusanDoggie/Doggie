//
//  CoreText.swift
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

#if canImport(CoreGraphics) && canImport(CoreText)

extension CTFramesetter {
    
    open var typesetter: CTTypesetter {
        return CTFramesetterGetTypesetter(self)
    }
    
    open func createFrame(_ path: CGPath,
                            _ stringRange: CFRange = CFRange(),
                            _ frameAttributes: CFDictionary? = nil) -> CTFrame {
        return CTFramesetterCreateFrame(self, stringRange, path, frameAttributes)
    }
    
    open func suggestFrameSize(_ constraints: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude),
                                 _ stringRange: CFRange = CFRange(),
                                 _ frameAttributes: CFDictionary? = nil,
                                 _ fitRange: UnsafeMutablePointer<CFRange>? = nil) -> CGSize {
        return CTFramesetterSuggestFrameSizeWithConstraints(self, stringRange, frameAttributes, constraints, fitRange)
    }
}

extension CTFrame {
    
    open var stringRange: CFRange {
        return CTFrameGetStringRange(self)
    }
    
    open var visibleStringRange: CFRange {
        return CTFrameGetVisibleStringRange(self)
    }
    
    open var path: CGPath {
        return CTFrameGetPath(self)
    }
    
    open var attributes: CFDictionary? {
        return CTFrameGetFrameAttributes(self)
    }
    
    open var lines: [CTLine] {
        return CTFrameGetLines(self) as? [CTLine] ?? []
    }
}

extension CTLine {
    
    open func truncatedLine(_ width: Double, _ truncationType: CTLineTruncationType, _ truncationToken: CTLine?) -> CTLine? {
        return CTLineCreateTruncatedLine(self, width, truncationType, truncationToken)
    }
    
    open func justifiedLine(_ justificationFactor: CGFloat, _ justificationWidth: Double) -> CTLine? {
        return CTLineCreateJustifiedLine(self, justificationFactor, justificationWidth)
    }
    
    open var glyphCount: Int {
        return CTLineGetGlyphCount(self)
    }
    
    open var glyphRuns: [CTRun] {
        return CTLineGetGlyphRuns(self) as? [CTRun] ?? []
    }
    
    open var stringRange: CFRange {
        return CTLineGetStringRange(self)
    }
    
    open func penOffsetForFlush(_ flushFactor: CGFloat, _ flushWidth: Double) -> Double {
        return CTLineGetPenOffsetForFlush(self, flushFactor, flushWidth)
    }
    
    open func imageBounds(_ context: CGContext?) -> CGRect {
        return CTLineGetImageBounds(self, context)
    }
    
    open func typographicBounds(_ ascent: UnsafeMutablePointer<CGFloat>?,
                                  _ descent: UnsafeMutablePointer<CGFloat>?,
                                  _ leading: UnsafeMutablePointer<CGFloat>?) -> Double {
        return CTLineGetTypographicBounds(self, ascent, descent, leading)
    }
    
    open var trailingWhitespaceWidth: Double {
        return CTLineGetTrailingWhitespaceWidth(self)
    }
    
    open func stringIndexForPosition(_ position: CGPoint) -> CFIndex {
        return CTLineGetStringIndexForPosition(self, position)
    }
    
    open func offsetForStringIndex(_ charIndex: CFIndex, _ secondaryOffset: UnsafeMutablePointer<CGFloat>?) -> CGFloat {
        return CTLineGetOffsetForStringIndex(self, charIndex, secondaryOffset)
    }
}

extension CTRun {
    
    open var glyphCount: Int {
        return CTRunGetGlyphCount(self)
    }
    
    open var attributes: CFDictionary {
        return CTRunGetAttributes(self)
    }
    
    open var status: CTRunStatus {
        return CTRunGetStatus(self)
    }
    
    open var glyphs: [CGGlyph] {
        let count = glyphCount
        return Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            guard let buffer = buffer.baseAddress else { return }
            CTRunGetGlyphs(self, CFRange(), buffer)
            initializedCount = count
        }
    }
    
    open var positions: [CGPoint] {
        let count = glyphCount
        return Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            guard let buffer = buffer.baseAddress else { return }
            CTRunGetPositions(self, CFRange(), buffer)
            initializedCount = count
        }
    }
    
    open var advances: [CGSize] {
        let count = glyphCount
        return Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            guard let buffer = buffer.baseAddress else { return }
            CTRunGetAdvances(self, CFRange(), buffer)
            initializedCount = count
        }
    }
    
    open var stringIndices: [CFIndex] {
        let count = glyphCount
        return Array(unsafeUninitializedCapacity: count) { buffer, initializedCount in
            guard let buffer = buffer.baseAddress else { return }
            CTRunGetStringIndices(self, CFRange(), buffer)
            initializedCount = count
        }
    }
    
    open var stringRange: CFRange {
        return CTRunGetStringRange(self)
    }
    
    open func typographicBounds(_ range: CFRange = CFRange(),
                                  _ ascent: UnsafeMutablePointer<CGFloat>?,
                                  _ descent: UnsafeMutablePointer<CGFloat>?,
                                  _ leading: UnsafeMutablePointer<CGFloat>?) -> Double {
        return CTRunGetTypographicBounds(self, range, ascent, descent, leading)
    }
    
    open func imageBounds(_ context: CGContext?, _ range: CFRange = CFRange()) -> CGRect {
        return CTRunGetImageBounds(self, context, range)
    }
    
    open var textMatrix: CGAffineTransform {
        return CTRunGetTextMatrix(self)
    }
}

extension CGContext {
    
    open func draw(_ string: CFAttributedString, in path: CGPath) {
        let framesetter = CTFramesetterCreateWithAttributedString(string)
        let frame = framesetter.createFrame(path)
        self.draw(frame)
    }
    
    open func draw(_ frame: CTFrame) {
        CTFrameDraw(frame, self)
    }
    
    open func draw(_ line: CTLine) {
        CTLineDraw(line, self)
    }
    
    open func draw(_ run: CTRun, _ range: CFRange = CFRange()) {
        CTRunDraw(run, self, range)
    }
}

#endif
