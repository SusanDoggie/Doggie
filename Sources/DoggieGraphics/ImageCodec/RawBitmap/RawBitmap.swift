//
//  RawBitmap.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

extension _ColorSpaceProtocol {
    
    @inlinable
    @inline(__always)
    func __create_image(width: Int, height: Int, resolution: Resolution, bitmaps: [RawBitmap], premultiplied: Bool, fileBacked: Bool) -> any _ImageProtocol {
        let colorSpace = self as! ColorSpace<Model>
        return colorSpace._create_image(width: width, height: height, resolution: resolution, bitmaps: bitmaps, premultiplied: premultiplied, fileBacked: fileBacked)
    }
}

extension AnyImage {
    
    @inlinable
    public init(width: Int, height: Int, resolution: Resolution = .default, colorSpace: AnyColorSpace, bitmaps: [RawBitmap], premultiplied: Bool, fileBacked: Bool = false) {
        self.init(base: colorSpace._base.__create_image(width: width, height: height, resolution: resolution, bitmaps: bitmaps, premultiplied: premultiplied, fileBacked: fileBacked))
    }
}

@frozen
public struct RawBitmap {
    
    public let bitsPerPixel: Int
    public let bytesPerRow: Int
    
    public let endianness: Endianness
    public let startsRow: Int
    
    public let predictor: TIFFPrediction
    
    public let channels: [Channel]
    
    public let data: Data
    
    public init(bitsPerPixel: Int, bytesPerRow: Int, endianness: Endianness = .big, startsRow: Int = 0, predictor: TIFFPrediction = .none, channels: [Channel], data: Data) {
        
        precondition(channels.allSatisfy({ 0...bitsPerPixel ~= $0.bitRange.lowerBound && 0...bitsPerPixel ~= $0.bitRange.upperBound }), "Invalid channel bitRange.")
        
        if endianness == .little {
            
            precondition(bitsPerPixel % 8 == 0, "Unsupported bitsPerPixel with little-endian.")
            
            if channels.allSatisfy({ $0.bitRange.lowerBound % 8 == 0 && $0.bitRange.upperBound % 8 == 0 }) {
                
                self.endianness = .big
                self.channels = channels.map { RawBitmap.Channel(index: $0.index, format: $0.format, endianness: $0.endianness == .big ? .little : .big, bitRange: bitsPerPixel - $0.bitRange.upperBound..<bitsPerPixel - $0.bitRange.lowerBound) }
                
            } else {
                
                self.endianness = .little
                self.channels = channels
            }
            
        } else {
            self.endianness = .big
            self.channels = channels
        }
        
        self.bitsPerPixel = bitsPerPixel
        self.bytesPerRow = bytesPerRow
        self.startsRow = startsRow
        self.predictor = predictor
        self.data = data
    }
}

extension RawBitmap {
    
    @frozen
    public struct Channel: Hashable {
        
        public let index: Int
        
        public let format: Format
        public let endianness: Endianness
        
        public let bitRange: Range<Int>
        
        public init(index: Int, format: Format, endianness: Endianness, bitRange: Range<Int>) {
            
            if format == .float {
                precondition(bitRange.count == 16 || bitRange.count == 32 || bitRange.count == 64, "Only supported Float16, Float32 or Float64.")
            }
            
            if endianness == .little {
                precondition(bitRange.count % 8 == 0, "Unsupported bitRange with little-endian.")
            }
            
            self.index = index
            self.format = format
            self.endianness = bitRange.count == 8 ? .big : endianness
            self.bitRange = bitRange
        }
    }
}

extension RawBitmap {
    
    public enum Format: CaseIterable {
        
        case unsigned
        case signed
        case float
    }
    
    public enum Endianness: CaseIterable {
        
        case big
        case little
    }
}
