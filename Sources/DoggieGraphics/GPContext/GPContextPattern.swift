//
//  GPContextPattern.swift
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
public struct GPContextPattern {
    
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

extension GPContext {
    
    private func draw_pattern(bound: Rect, xStep: Double, yStep: Double, callback: (GPContext) -> Void) {
        
        let transform = self.transform.inverse
        let frame = Rect.bound(Rect(x: 0, y: 0, width: width, height: height).points.map { $0 * transform })
        
        let minX = Int(((frame.minX - bound.minX) / xStep).rounded(.down))
        let maxX = Int(((frame.maxX - bound.minX) / xStep).rounded(.up))
        let minY = Int(((frame.minY - bound.minY) / xStep).rounded(.down))
        let maxY = Int(((frame.maxY - bound.minY) / xStep).rounded(.up))
        
        for y in minY..<maxY {
            for x in minX..<maxX {
                
                self.saveGraphicState()
                self.translate(x: Double(x) * xStep, y: Double(y) * yStep)
                
                callback(self)
                
                self.restoreGraphicState()
            }
        }
    }
    
    public func drawPattern(_ pattern: GPContextPattern) {
        
        guard self.width != 0 && self.height != 0 && !self.transform.determinant.almostZero() else { return }
        
        self.beginTransparencyLayer()
        self.concatenate(pattern.transform)
        
        self.opacity = pattern.opacity
        
        let width = Int((Point(x: pattern.bound.width, y: 0) * self.transform).magnitude.rounded(.up))
        let height = Int((Point(x: 0, y: pattern.bound.height) * self.transform).magnitude.rounded(.up))
        
        if width < self.width && height < self.height {
            
            let context = GPContext(width: width, height: height)
            
            context.scale(x: Double(width) / pattern.bound.width, y: Double(height) / pattern.bound.height)
            context.translate(x: -pattern.bound.minX, y: -pattern.bound.minY)
            
            pattern.callback(context)
            
            let image = context.image
            
            self.draw_pattern(bound: pattern.bound, xStep: pattern.xStep, yStep: pattern.yStep) { context in
                
                context.translate(x: pattern.bound.minX, y: pattern.bound.minY)
                context.scale(x: pattern.bound.width / Double(width), y: pattern.bound.height / Double(height))
                
                context.draw(image: image, transform: .identity)
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
