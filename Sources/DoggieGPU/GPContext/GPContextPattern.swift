//
//  GPContextPattern.swift
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

#if canImport(CoreImage)

extension GPContext {
    
    @frozen
    public struct Pattern {
        
        public var bound: Rect
        
        public var xStep: Double
        public var yStep: Double
        
        public var transform: SDTransform = .identity
        public var opacity: Double = 1
        
        public var callback: (GPContext) -> Void
        
        @inlinable
        @inline(__always)
        public init(bound: Rect, xStep: Double, yStep: Double, callback: @escaping (GPContext) -> Void) {
            self.bound = bound
            self.xStep = xStep
            self.yStep = yStep
            self.callback = callback
        }
    }
    
    private func draw_pattern(bound: Rect, xStep: Double, yStep: Double, callback: (GPContext) -> Void) {
        
        let frame = Rect(x: 0, y: 0, width: width, height: height)._applying(self.transform.inverse)
        
        let minX = Int(((frame.minX - bound.minX) / xStep).rounded(.down))
        let maxX = Int(((frame.maxX - bound.minX) / xStep).rounded(.up))
        let minY = Int(((frame.minY - bound.minY) / yStep).rounded(.down))
        let maxY = Int(((frame.maxY - bound.minY) / yStep).rounded(.up))
        
        for y in minY..<maxY {
            for x in minX..<maxX {
                
                self.saveGraphicState()
                self.translate(x: Double(x) * xStep, y: Double(y) * yStep)
                
                callback(self)
                
                self.restoreGraphicState()
            }
        }
    }
    
    public func drawPattern(_ pattern: Pattern) {
        
        guard self.width != 0 && self.height != 0 && self.transform.invertible else { return }
        
        guard !pattern.bound.width.almostZero() && !pattern.bound.height.almostZero() && !pattern.xStep.almostZero() && !pattern.yStep.almostZero() else { return }
        guard !pattern.bound.isEmpty && pattern.xStep.isFinite && pattern.yStep.isFinite else { return }
        guard pattern.transform.invertible else { return }
        
        self.beginTransparencyLayer()
        self.concatenate(pattern.transform)
        
        self.opacity = pattern.opacity
        
        var transform = self.transform
        transform.tx = 0
        transform.ty = 0
        
        let width = max(1, Int((Point(x: pattern.bound.width, y: 0) * transform).magnitude.rounded(.up)))
        let height = max(1, Int((Point(x: 0, y: pattern.bound.height) * transform).magnitude.rounded(.up)))
        
        if width < self.width && height < self.height {
            
            let cell_transform = SDTransform.scale(x: pattern.bound.width / Double(width), y: pattern.bound.height / Double(height)) * SDTransform.translate(x: pattern.bound.minX, y: pattern.bound.minY)
            
            let image: CIImage = {
                
                let context = GPContext(width: width, height: height)
                
                context.concatenate(cell_transform.inverse)
                
                pattern.callback(context)
                
                return context.image._insertingIntermediate()
            }()
            
            var combined_row: CIImage?
            var combined: CIImage?
            
            let frame = Rect(x: 0, y: 0, width: self.width, height: self.height)._applying(self.transform.inverse)
            
            let minX = Int(((frame.minX - pattern.bound.minX) / pattern.xStep).rounded(.down))
            let maxX = Int(((frame.maxX - pattern.bound.minX) / pattern.xStep).rounded(.up))
            let minY = Int(((frame.minY - pattern.bound.minY) / pattern.yStep).rounded(.down))
            let maxY = Int(((frame.maxY - pattern.bound.minY) / pattern.yStep).rounded(.up))
            
            for x in minX..<maxX {
                let transform = cell_transform * SDTransform.translate(x: Double(x) * pattern.xStep, y: 0) * cell_transform.inverse
                combined_row = combined_row.map { image.transformed(by: transform).composited(over: $0) } ?? image.transformed(by: transform)
            }
            
            if let combined_row = combined_row {
                
                for y in minY..<maxY {
                    let transform = cell_transform * SDTransform.translate(x: 0, y: Double(y) * pattern.yStep) * cell_transform.inverse
                    combined = combined.map { combined_row.transformed(by: transform).composited(over: $0) } ?? combined_row.transformed(by: transform)
                }
            }
            
            if let combined = combined {
                self.draw(image: combined, transform: cell_transform)
            }
            
        } else {
            
            self.draw_pattern(bound: pattern.bound, xStep: pattern.xStep, yStep: pattern.yStep) { context in
                
                context.clip(rect: pattern.bound)
                context.beginTransparencyLayer()
                
                pattern.callback(context)
                
                context.endTransparencyLayer()
            }
        }
        
        self.endTransparencyLayer()
    }
    
}

#endif
