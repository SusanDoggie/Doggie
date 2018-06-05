//
//  ImageProtocol.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

public protocol ImageProtocol {
    
    associatedtype Color: ColorProtocol
    
    typealias ColorSpace = Color.ColorSpace
    
    init(image: Self, option: MappedBufferOption)
    
    init<P>(image: Image<P>, colorSpace: ColorSpace, intent: RenderingIntent)
    
    init<P>(image: Image<P>, colorSpace: ColorSpace, intent: RenderingIntent, option: MappedBufferOption)
    
    init(image: AnyImage, colorSpace: ColorSpace, intent: RenderingIntent)
    
    init(image: AnyImage, colorSpace: ColorSpace, intent: RenderingIntent, option: MappedBufferOption)
    
    var colorSpace: ColorSpace { get }
    
    var width: Int { get }
    
    var height: Int { get }
    
    subscript(x: Int, y: Int) -> Color { get set }
    
    var resolution: Resolution { get set }
    
    var isOpaque: Bool { get }
    
    var option: MappedBufferOption { get }
    
    func linearTone() -> Self
    
    func transposed() -> Self
    
    func verticalFlipped() -> Self
    
    func horizontalFlipped() -> Self
    
    mutating func setWhiteBalance(_ white: Point)
    
    func convert<P>(to colorSpace: Doggie.ColorSpace<P.Model>, intent: RenderingIntent) -> Image<P>
    
    func convert<P>(to colorSpace: Doggie.ColorSpace<P.Model>, intent: RenderingIntent, option: MappedBufferOption) -> Image<P>
    
    func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent) -> AnyImage
    
    func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent, option: MappedBufferOption) -> AnyImage
}

extension ImageProtocol {
    
    @inlinable
    public func convert<P>(to colorSpace: Doggie.ColorSpace<P.Model>, intent: RenderingIntent = .default) -> Image<P> {
        return self.convert(to: colorSpace, intent: intent, option: self.option)
    }
    
    @inlinable
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default) -> AnyImage {
        return self.convert(to: colorSpace, intent: intent, option: self.option)
    }
}

extension Image {
    
    @inlinable
    public func convert<P>(to colorSpace: Doggie.ColorSpace<P.Model>, intent: RenderingIntent = .default, option: MappedBufferOption) -> Image<P> {
        return Image<P>(image: self, colorSpace: colorSpace, intent: intent, option: option)
    }
    
    @inlinable
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default, option: MappedBufferOption) -> AnyImage {
        return AnyImage(image: self, colorSpace: colorSpace, intent: intent, option: option)
    }
}

extension AnyImage {
    
    @inlinable
    public func convert<P>(to colorSpace: Doggie.ColorSpace<P.Model>, intent: RenderingIntent = .default, option: MappedBufferOption) -> Image<P> {
        return Image<P>(image: self, colorSpace: colorSpace, intent: intent, option: option)
    }
    
    @inlinable
    public func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent = .default, option: MappedBufferOption) -> AnyImage {
        return AnyImage(image: self, colorSpace: colorSpace, intent: intent, option: option)
    }
}

extension ImageProtocol {
    
    @inlinable
    public init<P>(image: Image<P>, colorSpace: ColorSpace, intent: RenderingIntent = .default) {
        self.init(image: image, colorSpace: colorSpace, intent: intent, option: image.option)
    }
    
    @inlinable
    public init(image: AnyImage, colorSpace: ColorSpace, intent: RenderingIntent = .default) {
        self.init(image: image, colorSpace: colorSpace, intent: intent, option: image.option)
    }
}

extension Image : ImageProtocol {
    
}
