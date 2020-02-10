//
//  GPContextBase.swift
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

#if canImport(CoreImage)

struct GPContextBase {
    
    let width: Int
    let height: Int
    
    let _image: CIImage?
    
    var graphic_stack: [GraphicInfo] = []
    
}

extension GPContextBase {
    
    struct GraphicInfo {
        
        let colorSpace: CGColorSpace
        
        let color: CGColor
        
        let path: CGPath
        
        let rule: CGPathFillRule
        
        let shouldAntialias: Bool
    }
}

extension GPContextBase {
    
    var extent: Rect {
        return Rect(x: 0, y: 0, width: width, height: height)
    }
    
    var image: CIImage {
        
        var image = self._image
        let graphic_stack = self.graphic_stack
        
        if let colorSpace = graphic_stack.first?.colorSpace {
            
            guard let _extent = graphic_stack.lazy.map({ $0.path.boundingBoxOfPath }).reduce({ $0.union($1) }) else { return image ?? .empty() }
            
            let extent = CGRect(self.extent).intersection(_extent).insetBy(dx: .random(in: -1..<0), dy: .random(in: -1..<0))
            guard let layer = try? CGContextProcessorKernel.apply(withExtent: extent, colorSpace: colorSpace, transform: .identity, shouldAntialias: true, callback: { context in
                
                for item in graphic_stack {
                    context.setShouldAntialias(item.shouldAntialias)
                    context.setFillColor(item.color)
                    context.addPath(item.path)
                    context.fillPath(using: item.rule)
                }
                
            }) else { return image ?? .empty() }
            
            image = image.map { layer.composited(over: $0) } ?? layer
        }
        
        return image ?? .empty()
    }
}

extension GPContextBase {
    
    func insertingIntermediate() -> GPContextBase {
        if #available(macOS 10.14, iOS 12.0, tvOS 12.0, *) {
            return GPContextBase(width: width, height: height, _image: image.insertingIntermediate())
        }
        return self
    }
    
    mutating func draw(path: CGPath, rule: CGPathFillRule, color: CGColor, shouldAntialias: Bool) {
        let colorSpace = color.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        graphic_stack.append(GPContextBase.GraphicInfo(colorSpace: colorSpace, color: color, path: path, rule: rule, shouldAntialias: shouldAntialias))
    }
    
    func composited(over dest: CIImage) -> GPContextBase {
        return GPContextBase(width: width, height: height, _image: image.composited(over: dest))
    }
    
    func applyingFilter(_ filterName: String, parameters params: [String : Any]) -> GPContextBase {
        return GPContextBase(width: width, height: height, _image: image.applyingFilter(filterName, parameters: params))
    }
}

#endif
