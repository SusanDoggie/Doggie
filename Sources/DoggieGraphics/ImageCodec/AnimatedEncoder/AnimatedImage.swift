//
//  AnimatedImage.swift
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

protocol AnimatedImageEncoder {
    
    static func encode(image: AnimatedImage, properties: [ImageRep.PropertyKey: Any]) -> Data?
}

public struct AnimatedImage {
    
    public var frames: [AnimatedImageFrame]
    
    public var repeats: Int
    
    public init(frames: [AnimatedImageFrame], repeats: Int) {
        self.frames = frames
        self.repeats = repeats
    }
}

public struct AnimatedImageFrame {
    
    public var image: AnyImage
    
    public var duration: Double
    
    public init(image: AnyImage, duration: Double) {
        self.image = image
        self.duration = duration
    }
}

extension AnimatedImage {
    
    public func representation(using storageType: MediaType, properties: [ImageRep.PropertyKey: Any]) -> Data? {
        
        let Encoder: AnimatedImageEncoder.Type
        
        switch storageType {
        case .png: Encoder = PNGEncoder.self
        case .webp: Encoder = WEBPAnimatedEncoder.self
        default: return nil
        }
        
        return Encoder.encode(image: self, properties: properties)
    }
}
