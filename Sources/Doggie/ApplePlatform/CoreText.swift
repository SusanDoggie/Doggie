//
//  CoreText.swift
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

#if canImport(CoreGraphics)

extension CTFramesetter {
    
    public var typesetter: CTTypesetter {
        return CTFramesetterGetTypesetter(self)
    }
    
    public func createFrame(_ path: CGPath,
                            _ stringRange: CFRange = CFRange(),
                            _ frameAttributes: CFDictionary? = nil) -> CTFrame {
        return CTFramesetterCreateFrame(self, stringRange, path, frameAttributes)
    }
    
    public func suggestFrameSize(_ constraints: CGSize,
                                 _ stringRange: CFRange = CFRange(),
                                 _ frameAttributes: CFDictionary? = nil,
                                 _ fitRange: UnsafeMutablePointer<CFRange>? = nil) -> CGSize {
        return CTFramesetterSuggestFrameSizeWithConstraints(self, stringRange, frameAttributes, constraints, fitRange)
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
}

#endif
