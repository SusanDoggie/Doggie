//
//  ImageProtocol.swift
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

public protocol ImageProtocol: Hashable {
    
    associatedtype Color: ColorProtocol
    
    typealias ColorSpace = Color.ColorSpace
    
    var colorSpace: ColorSpace { get }
    
    var numberOfComponents: Int { get }
    
    var width: Int { get }
    
    var height: Int { get }
    
    subscript(x: Int, y: Int) -> Color { get set }
    
    var resolution: Resolution { get set }
    
    var isOpaque: Bool { get }
    
    var visibleRect: Rect { get }
    
    var fileBacked: Bool { get set }
    
    func setMemoryAdvise(_ advise: MemoryAdvise)
    
    func memoryLock()
    
    func memoryUnlock()
    
    mutating func setOrientation(_ orientation: ImageOrientation)
    
    func linearTone() -> Self
    
    func premultiplied() -> Self
    
    func unpremultiplied() -> Self
    
    func transposed() -> Self
    
    func verticalFlipped() -> Self
    
    func horizontalFlipped() -> Self
    
    func withWhiteBalance(_ white: Point) -> Self
    
    func convert<P>(to colorSpace: DoggieGraphics.ColorSpace<P.Model>, intent: RenderingIntent) -> Image<P>
    
    func convert(to colorSpace: AnyColorSpace, intent: RenderingIntent) -> AnyImage
    
    func isStorageEqual(_ other: Self) -> Bool
}

extension ImageProtocol {
    
    @inlinable
    func _isStorageEqual(_ other: any ImageProtocol) -> Bool {
        guard let other = other as? Self else { return false }
        return self.isStorageEqual(other)
    }
}

extension Image {
    
    @inlinable
    public func convert<P>(to colorSpace: DoggieGraphics.ColorSpace<P.Model>, intent: RenderingIntent = .default) -> Image<P> {
        return Image<P>(image: self, colorSpace: colorSpace, intent: intent)
    }
}

@usableFromInline
protocol _ImageProtocol: ImageProtocol, RawPixelProtocol where RawPixel: ColorPixel, Color == DoggieGraphics.Color<RawPixel.Model> {
    
    func color(x: Int, y: Int) -> AnyColor
    
    mutating func setColor<C: ColorProtocol>(x: Int, y: Int, color: C)
    
}
