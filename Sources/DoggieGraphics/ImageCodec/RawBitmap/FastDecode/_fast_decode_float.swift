//
//  _fast_decode_float.swift
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

extension ColorModel {
    
    @inlinable
    @inline(__always)
    func _denormalized() -> Self {
        var color = self
        for i in 0..<Self.numberOfComponents where Self.rangeOfComponent(i) != 0...1 {
            color.setNormalizedComponent(i, self[i])
        }
        return color
    }
}

extension Image {
    
    @inlinable
    @inline(__always)
    mutating func _fast_decode_float<T, R: _FloatComponentPixel>(_ bitmaps: [RawBitmap], _ is_opaque: Bool, _ should_denormalized: Bool, _ premultiplied: Bool, _: T.Type, _: R.Type, callback: (UnsafeMutablePointer<R>, UnsafePointer<T>) -> Void) {
        
        let numberOfComponents = is_opaque ? Pixel.numberOfComponents - 1 : Pixel.numberOfComponents
        
        let width = self.width
        let height = self.height
        
        let should_denormalized = should_denormalized && (0..<Pixel.Model.numberOfComponents).contains { Pixel.Model.rangeOfComponent($0) != 0...1 }
        
        self.withUnsafeMutableBufferPointer {
            
            guard var dest = $0.baseAddress else { return }
            
            for bitmap in bitmaps {
                
                guard bitmap.startsRow < height else { return }
                
                let bytesPerPixel = bitmap.bitsPerPixel >> 3
                
                dest += bitmap.startsRow * width
                
                var data = bitmap.data
                
                for _ in bitmap.startsRow..<height {
                    
                    let _length = min(bitmap.bytesPerRow, data.count)
                    guard _length != 0 else { return }
                    
                    data.popFirst(bitmap.bytesPerRow).withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
                        
                        guard var source = bytes.baseAddress else { return }
                        var destination = dest
                        let source_end = source + _length
                        
                        for _ in 0..<width {
                            
                            guard source + bytesPerPixel <= source_end else { return }
                            
                            let _source = source.bindMemory(to: T.self, capacity: numberOfComponents)
                            let _destination = UnsafeMutableRawPointer(destination).bindMemory(to: R.self, capacity: Pixel.numberOfComponents)
                            
                            callback(_destination, _source)
                            
                            if should_denormalized {
                                destination.pointee.color = destination.pointee.color._denormalized()
                            }
                            if premultiplied {
                                destination.pointee = destination.pointee.unpremultiplied()
                            }
                            
                            source += bytesPerPixel
                            destination += 1
                        }
                        
                        dest += width
                    }
                }
            }
        }
    }
}
