//
//  DrawPattern.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

extension ImageContext {
    
    @inlinable
    func draw_pattern(bound: Rect, xStep: Double, yStep: Double, callback: (ImageContext) -> Void) {
        
        let transform = self.transform.inverse
        let frame = Rect.bound(Rect(x: 0, y: 0, width: width, height: height).points.map { $0 * transform })
        
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
    
    @inlinable
    public func drawPattern(_ pattern: Pattern) {
        
        guard self.width != 0 && self.height != 0 && !self.transform.determinant.almostZero() else { return }
        guard !pattern.bound.width.almostZero() && !pattern.bound.height.almostZero() && !pattern.xStep.almostZero() && !pattern.yStep.almostZero() else { return }
        guard !pattern.transform.determinant.almostZero() else { return }
        
        self.beginTransparencyLayer()
        self.concatenate(pattern.transform)
        
        self.opacity = pattern.opacity
        
        self.draw_pattern(bound: pattern.bound, xStep: pattern.xStep, yStep: pattern.yStep) { context in
            
            context.clip(rect: pattern.bound)
            context.beginTransparencyLayer()
            
            pattern.callback(context)
            
            context.endTransparencyLayer()
        }
        
        self.endTransparencyLayer()
    }
    
}
