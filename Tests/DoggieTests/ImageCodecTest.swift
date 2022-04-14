//
//  ImageCodecTest.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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

import Doggie
import XCTest

class ImageCodecTest: XCTestCase {
    
    let images_dir = Bundle.module.resourceURL!.appendingPathComponent("images")
    
    func testRGBA32Big() {
        
        let width = 256
        let height = 256
        let length = width * height
        
        var data = Data()
        
        for _ in 0..<length {
            let value = UInt32.random(in: 0...UInt32.max)
            withUnsafeBytes(of: value.bigEndian) { data.append(contentsOf: $0) }
        }
        
        let bitmap = RawBitmap(bitsPerPixel: 32, bytesPerRow: width * 4, endianness: .big, channels: [
            RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<8),
            RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 8..<16),
            RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 16..<24),
            RawBitmap.Channel(index: 3, format: .unsigned, endianness: .big, bitRange: 24..<32),
        ], data: data)
        
        let image = AnyImage(width: width, height: height, colorSpace: AnyColorSpace.sRGB, bitmaps: [bitmap], premultiplied: false, fileBacked: false).base as? Image<RGBA32ColorPixel>
        
        XCTAssertEqual(data, image?.pixels.data)
    }
    
    func testRGBA32Little() {
        
        let width = 256
        let height = 256
        let length = width * height
        
        var data = Data()
        var answer = Data()
        
        for _ in 0..<length {
            let value = UInt32.random(in: 0...UInt32.max)
            withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: value.bigEndian) { answer.append(contentsOf: $0) }
        }
        
        let bitmap = RawBitmap(bitsPerPixel: 32, bytesPerRow: width * 4, endianness: .little, channels: [
            RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<8),
            RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 8..<16),
            RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 16..<24),
            RawBitmap.Channel(index: 3, format: .unsigned, endianness: .big, bitRange: 24..<32),
        ], data: data)
        
        let image = AnyImage(width: width, height: height, colorSpace: AnyColorSpace.sRGB, bitmaps: [bitmap], premultiplied: false, fileBacked: false).base as? Image<RGBA32ColorPixel>
        
        XCTAssertEqual(answer, image?.pixels.data)
    }
    
    func testRGBA64Big() {
        
        let width = 256
        let height = 256
        let length = width * height
        
        var data = Data()
        
        for _ in 0..<length {
            let value = UInt64.random(in: 0...UInt64.max)
            withUnsafeBytes(of: value.bigEndian) { data.append(contentsOf: $0) }
        }
        
        let bitmap = RawBitmap(bitsPerPixel: 64, bytesPerRow: width * 8, endianness: .big, channels: [
            RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<16),
            RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 16..<32),
            RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 32..<48),
            RawBitmap.Channel(index: 3, format: .unsigned, endianness: .big, bitRange: 48..<64),
        ], data: data)
        
        let image = AnyImage(width: width, height: height, colorSpace: AnyColorSpace.sRGB, bitmaps: [bitmap], premultiplied: false, fileBacked: false).base as? Image<RGBA64ColorPixel>
        
        XCTAssertNotNil(image)
        
        guard let pixels = image?.pixels else { return }
        
        var result = Data()
        
        for i in 0..<pixels.count {
            withUnsafeBytes(of: pixels[i].r.bigEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i].g.bigEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i].b.bigEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i].a.bigEndian) { result.append(contentsOf: $0) }
        }
        
        XCTAssertEqual(data, result)
    }
    
    func testRGBA64Little() {
        
        let width = 256
        let height = 256
        let length = width * height
        
        var data = Data()
        var answer = Data()
        
        for _ in 0..<length {
            let value = UInt64.random(in: 0...UInt64.max)
            withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: value.bigEndian) { answer.append(contentsOf: $0) }
        }
        
        let bitmap = RawBitmap(bitsPerPixel: 64, bytesPerRow: width * 8, endianness: .little, channels: [
            RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<16),
            RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 16..<32),
            RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 32..<48),
            RawBitmap.Channel(index: 3, format: .unsigned, endianness: .big, bitRange: 48..<64),
        ], data: data)
        
        let image = AnyImage(width: width, height: height, colorSpace: AnyColorSpace.sRGB, bitmaps: [bitmap], premultiplied: false, fileBacked: false).base as? Image<RGBA64ColorPixel>
        
        XCTAssertNotNil(image)
        
        guard let pixels = image?.pixels else { return }
        
        var result = Data()
        
        for i in 0..<pixels.count {
            withUnsafeBytes(of: pixels[i].r.bigEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i].g.bigEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i].b.bigEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i].a.bigEndian) { result.append(contentsOf: $0) }
        }
        
        XCTAssertEqual(answer, result)
    }
    
    func testRGB555Big() {
        
        let width = 128
        let height = 256
        let length = width * height
        
        var data = Data()
        var answer: [UInt16] = []
        
        for _ in 0..<length {
            let value = UInt16.random(in: 0..<0x8000)
            withUnsafeBytes(of: value.bigEndian) { data.append(contentsOf: $0) }
            answer.append(value)
        }
        
        let bitmap = RawBitmap(bitsPerPixel: 16, bytesPerRow: width * 2, endianness: .big, channels: [
            RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 1..<6),
            RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 6..<11),
            RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 11..<16),
        ], data: data)
        
        let image = AnyImage(width: width, height: height, colorSpace: AnyColorSpace.sRGB, bitmaps: [bitmap], premultiplied: false, fileBacked: false).base as? Image<RGBA32ColorPixel>
        
        XCTAssertNotNil(image)
        
        guard let pixels = image?.pixels else { return }
        
        for (i, pixel) in zip(answer, pixels) {
            
            let red = round(Double(((i >> 10) & 0x1F) * 0xFF) / 31) / 255
            let green = round(Double(((i >> 5) & 0x1F) * 0xFF) / 31) / 255
            let blue = round(Double((i & 0x1F) * 0xFF) / 31) / 255
            
            XCTAssertEqual(red, pixel.red)
            XCTAssertEqual(green, pixel.green)
            XCTAssertEqual(blue, pixel.blue)
            XCTAssertEqual(1, pixel.opacity)
        }
    }
    
    func testRGB555Little() {
        
        let width = 128
        let height = 256
        let length = width * height
        
        var data = Data()
        var answer: [UInt16] = []
        
        for _ in 0..<length {
            let value = UInt16.random(in: 0..<0x8000)
            withUnsafeBytes(of: value.littleEndian) { data.append(contentsOf: $0) }
            answer.append(value)
        }
        
        let bitmap = RawBitmap(bitsPerPixel: 16, bytesPerRow: width * 2, endianness: .little, channels: [
            RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 1..<6),
            RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 6..<11),
            RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 11..<16),
        ], data: data)
        
        let image = AnyImage(width: width, height: height, colorSpace: AnyColorSpace.sRGB, bitmaps: [bitmap], premultiplied: false, fileBacked: false).base as? Image<RGBA32ColorPixel>
        
        XCTAssertNotNil(image)
        
        guard let pixels = image?.pixels else { return }
        
        for (i, pixel) in zip(answer, pixels) {
            
            let red = round(Double(((i >> 10) & 0x1F) * 0xFF) / 31) / 255
            let green = round(Double(((i >> 5) & 0x1F) * 0xFF) / 31) / 255
            let blue = round(Double((i & 0x1F) * 0xFF) / 31) / 255
            
            XCTAssertEqual(red, pixel.red)
            XCTAssertEqual(green, pixel.green)
            XCTAssertEqual(blue, pixel.blue)
            XCTAssertEqual(1, pixel.opacity)
        }
    }
    
    func testRGB8816Big() {
        
        let width = 256
        let height = 256
        let length = width * height
        
        var data = Data()
        var answer: [UInt32] = []
        
        for _ in 0..<length {
            let value = UInt32.random(in: 0...UInt32.max)
            withUnsafeBytes(of: value.bigEndian) { data.append(contentsOf: $0) }
            answer.append(value)
        }
        
        let bitmap = RawBitmap(bitsPerPixel: 32, bytesPerRow: width * 4, endianness: .big, channels: [
            RawBitmap.Channel(index: 0, format: .unsigned, endianness: .big, bitRange: 0..<8),
            RawBitmap.Channel(index: 1, format: .unsigned, endianness: .big, bitRange: 8..<16),
            RawBitmap.Channel(index: 2, format: .unsigned, endianness: .big, bitRange: 16..<32),
        ], data: data)
        
        let image = AnyImage(width: width, height: height, colorSpace: AnyColorSpace.sRGB, bitmaps: [bitmap], premultiplied: false, fileBacked: false).base as? Image<RGBA64ColorPixel>
        
        XCTAssertNotNil(image)
        
        guard let pixels = image?.pixels else { return }
        
        for (i, pixel) in zip(answer, pixels) {
            
            let red = round(Double(((i >> 24) & 0xFF) * 0xFFFF) / 255) / 65535
            let green = round(Double(((i >> 16) & 0xFF) * 0xFFFF) / 255) / 65535
            let blue = Double(i & 0xFFFF) / 65535
            
            XCTAssertEqual(red, pixel.red)
            XCTAssertEqual(green, pixel.green)
            XCTAssertEqual(blue, pixel.blue)
            XCTAssertEqual(1, pixel.opacity)
        }
    }
    
    func testRGBFloat16Big() {
        
        let width = 256
        let height = 256
        let length = width * height
        
        var data = Data()
        
        for _ in 0..<length {
            let red = float16.random(in: 0...1)
            let green = float16.random(in: 0...1)
            let blue = float16.random(in: 0...1)
            withUnsafeBytes(of: red.bitPattern.bigEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: green.bitPattern.bigEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: blue.bitPattern.bigEndian) { data.append(contentsOf: $0) }
        }
        
        let bitmap = RawBitmap(bitsPerPixel: 48, bytesPerRow: width * 6, endianness: .big, channels: [
            RawBitmap.Channel(index: 0, format: .float, endianness: .big, bitRange: 0..<16),
            RawBitmap.Channel(index: 1, format: .float, endianness: .big, bitRange: 16..<32),
            RawBitmap.Channel(index: 2, format: .float, endianness: .big, bitRange: 32..<48),
        ], data: data)
        
        let image = AnyImage(width: width, height: height, colorSpace: AnyColorSpace.sRGB, bitmaps: [bitmap], premultiplied: false, fileBacked: false).base as? Image<Float16ColorPixel<RGBColorModel>>
        
        XCTAssertNotNil(image)
        
        guard let pixels = image?.pixels else { return }
        
        var result = Data()
        
        for i in 0..<pixels.count {
            withUnsafeBytes(of: pixels[i]._color.red.bitPattern.bigEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i]._color.green.bitPattern.bigEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i]._color.blue.bitPattern.bigEndian) { result.append(contentsOf: $0) }
            XCTAssertEqual(1, pixels[i].opacity)
        }
        
        XCTAssertEqual(data, result)
    }
    
    func testRGBFloat16Little() {
        
        let width = 256
        let height = 256
        let length = width * height
        
        var data = Data()
        
        for _ in 0..<length {
            let red = float16.random(in: 0...1)
            let green = float16.random(in: 0...1)
            let blue = float16.random(in: 0...1)
            withUnsafeBytes(of: red.bitPattern.littleEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: green.bitPattern.littleEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: blue.bitPattern.littleEndian) { data.append(contentsOf: $0) }
        }
        
        let bitmap = RawBitmap(bitsPerPixel: 48, bytesPerRow: width * 6, endianness: .big, channels: [
            RawBitmap.Channel(index: 0, format: .float, endianness: .little, bitRange: 0..<16),
            RawBitmap.Channel(index: 1, format: .float, endianness: .little, bitRange: 16..<32),
            RawBitmap.Channel(index: 2, format: .float, endianness: .little, bitRange: 32..<48),
        ], data: data)
        
        let image = AnyImage(width: width, height: height, colorSpace: AnyColorSpace.sRGB, bitmaps: [bitmap], premultiplied: false, fileBacked: false).base as? Image<Float16ColorPixel<RGBColorModel>>
        
        XCTAssertNotNil(image)
        
        guard let pixels = image?.pixels else { return }
        
        var result = Data()
        
        for i in 0..<pixels.count {
            withUnsafeBytes(of: pixels[i]._color.red.bitPattern.littleEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i]._color.green.bitPattern.littleEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i]._color.blue.bitPattern.littleEndian) { result.append(contentsOf: $0) }
            XCTAssertEqual(1, pixels[i].opacity)
        }
        
        XCTAssertEqual(data, result)
    }
    
    func testRGBFloat32Big() {
        
        let width = 256
        let height = 256
        let length = width * height
        
        var data = Data()
        
        for _ in 0..<length {
            let red = Float.random(in: 0...1)
            let green = Float.random(in: 0...1)
            let blue = Float.random(in: 0...1)
            withUnsafeBytes(of: red.bitPattern.bigEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: green.bitPattern.bigEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: blue.bitPattern.bigEndian) { data.append(contentsOf: $0) }
        }
        
        let bitmap = RawBitmap(bitsPerPixel: 96, bytesPerRow: width * 12, endianness: .big, channels: [
            RawBitmap.Channel(index: 0, format: .float, endianness: .big, bitRange: 0..<32),
            RawBitmap.Channel(index: 1, format: .float, endianness: .big, bitRange: 32..<64),
            RawBitmap.Channel(index: 2, format: .float, endianness: .big, bitRange: 64..<96),
        ], data: data)
        
        let image = AnyImage(width: width, height: height, colorSpace: AnyColorSpace.sRGB, bitmaps: [bitmap], premultiplied: false, fileBacked: false).base as? Image<Float32ColorPixel<RGBColorModel>>
        
        XCTAssertNotNil(image)
        
        guard let pixels = image?.pixels else { return }
        
        var result = Data()
        
        for i in 0..<pixels.count {
            withUnsafeBytes(of: pixels[i]._color.red.bitPattern.bigEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i]._color.green.bitPattern.bigEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i]._color.blue.bitPattern.bigEndian) { result.append(contentsOf: $0) }
            XCTAssertEqual(1, pixels[i].opacity)
        }
        
        XCTAssertEqual(data, result)
    }
    
    func testRGBFloat32Little() {
        
        let width = 256
        let height = 256
        let length = width * height
        
        var data = Data()
        
        for _ in 0..<length {
            let red = Float.random(in: 0...1)
            let green = Float.random(in: 0...1)
            let blue = Float.random(in: 0...1)
            withUnsafeBytes(of: red.bitPattern.littleEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: green.bitPattern.littleEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: blue.bitPattern.littleEndian) { data.append(contentsOf: $0) }
        }
        
        let bitmap = RawBitmap(bitsPerPixel: 96, bytesPerRow: width * 12, endianness: .big, channels: [
            RawBitmap.Channel(index: 0, format: .float, endianness: .little, bitRange: 0..<32),
            RawBitmap.Channel(index: 1, format: .float, endianness: .little, bitRange: 32..<64),
            RawBitmap.Channel(index: 2, format: .float, endianness: .little, bitRange: 64..<96),
        ], data: data)
        
        let image = AnyImage(width: width, height: height, colorSpace: AnyColorSpace.sRGB, bitmaps: [bitmap], premultiplied: false, fileBacked: false).base as? Image<Float32ColorPixel<RGBColorModel>>
        
        XCTAssertNotNil(image)
        
        guard let pixels = image?.pixels else { return }
        
        var result = Data()
        
        for i in 0..<pixels.count {
            withUnsafeBytes(of: pixels[i]._color.red.bitPattern.littleEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i]._color.green.bitPattern.littleEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i]._color.blue.bitPattern.littleEndian) { result.append(contentsOf: $0) }
            XCTAssertEqual(1, pixels[i].opacity)
        }
        
        XCTAssertEqual(data, result)
    }
    
    func testRGBFloat64Big() {
        
        let width = 256
        let height = 256
        let length = width * height
        
        var data = Data()
        
        for _ in 0..<length {
            let red = Double.random(in: 0...1)
            let green = Double.random(in: 0...1)
            let blue = Double.random(in: 0...1)
            withUnsafeBytes(of: red.bitPattern.bigEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: green.bitPattern.bigEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: blue.bitPattern.bigEndian) { data.append(contentsOf: $0) }
        }
        
        let bitmap = RawBitmap(bitsPerPixel: 192, bytesPerRow: width * 24, endianness: .big, channels: [
            RawBitmap.Channel(index: 0, format: .float, endianness: .big, bitRange: 0..<64),
            RawBitmap.Channel(index: 1, format: .float, endianness: .big, bitRange: 64..<128),
            RawBitmap.Channel(index: 2, format: .float, endianness: .big, bitRange: 128..<192),
        ], data: data)
        
        let image = AnyImage(width: width, height: height, colorSpace: AnyColorSpace.sRGB, bitmaps: [bitmap], premultiplied: false, fileBacked: false).base as? Image<Float64ColorPixel<RGBColorModel>>
        
        XCTAssertNotNil(image)
        
        guard let pixels = image?.pixels else { return }
        
        var result = Data()
        
        for i in 0..<pixels.count {
            withUnsafeBytes(of: pixels[i].red.bitPattern.bigEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i].green.bitPattern.bigEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i].blue.bitPattern.bigEndian) { result.append(contentsOf: $0) }
            XCTAssertEqual(1, pixels[i].opacity)
        }
        
        XCTAssertEqual(data, result)
    }
    
    func testRGBFloat64Little() {
        
        let width = 256
        let height = 256
        let length = width * height
        
        var data = Data()
        
        for _ in 0..<length {
            let red = Double.random(in: 0...1)
            let green = Double.random(in: 0...1)
            let blue = Double.random(in: 0...1)
            withUnsafeBytes(of: red.bitPattern.littleEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: green.bitPattern.littleEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: blue.bitPattern.littleEndian) { data.append(contentsOf: $0) }
        }
        
        let bitmap = RawBitmap(bitsPerPixel: 192, bytesPerRow: width * 24, endianness: .big, channels: [
            RawBitmap.Channel(index: 0, format: .float, endianness: .little, bitRange: 0..<64),
            RawBitmap.Channel(index: 1, format: .float, endianness: .little, bitRange: 64..<128),
            RawBitmap.Channel(index: 2, format: .float, endianness: .little, bitRange: 128..<192),
        ], data: data)
        
        let image = AnyImage(width: width, height: height, colorSpace: AnyColorSpace.sRGB, bitmaps: [bitmap], premultiplied: false, fileBacked: false).base as? Image<Float64ColorPixel<RGBColorModel>>
        
        XCTAssertNotNil(image)
        
        guard let pixels = image?.pixels else { return }
        
        var result = Data()
        
        for i in 0..<pixels.count {
            withUnsafeBytes(of: pixels[i].red.bitPattern.littleEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i].green.bitPattern.littleEndian) { result.append(contentsOf: $0) }
            withUnsafeBytes(of: pixels[i].blue.bitPattern.littleEndian) { result.append(contentsOf: $0) }
            XCTAssertEqual(1, pixels[i].opacity)
        }
        
        XCTAssertEqual(data, result)
    }
    
    var sample1: Image<ARGB32ColorPixel> = {
        
        let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.sRGB)
        
        context.draw(rect: Rect(x: 0, y: 0, width: 100, height: 100), color: .white)
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), stroke: Stroke(width: 1, cap: .round, join: .round, color: RGBColorModel()))
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), stroke: Stroke(width: 1, cap: .round, join: .round, color: RGBColorModel()))
        
        return context.image
    }()
    
    var sample2: Image<ARGB32ColorPixel> = {
        
        let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.sRGB)
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), stroke: Stroke(width: 1, cap: .round, join: .round, color: RGBColorModel()))
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), stroke: Stroke(width: 1, cap: .round, join: .round, color: RGBColorModel()))
        
        return context.image
    }()
    
    var sample3: Image<Gray16ColorPixel> = {
        
        let context = ImageContext<Gray16ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.genericGamma22Gray)
        
        context.draw(rect: Rect(x: 0, y: 0, width: 100, height: 100), color: .white)
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: GrayColorModel(white: 217/255))
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), stroke: Stroke(width: 1, cap: .round, join: .round, color: GrayColorModel()))
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: GrayColorModel(white: 24/255))
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), stroke: Stroke(width: 1, cap: .round, join: .round, color: GrayColorModel()))
        
        return context.image
    }()
    
    var sample4: Image<Gray16ColorPixel> = {
        
        let context = ImageContext<Gray16ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.genericGamma22Gray)
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: GrayColorModel(white: 217/255))
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), stroke: Stroke(width: 1, cap: .round, join: .round, color: GrayColorModel()))
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: GrayColorModel(white: 24/255))
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), stroke: Stroke(width: 1, cap: .round, join: .round, color: GrayColorModel()))
        
        return context.image
    }()
    
    func testPng1() throws {
        
        guard let data = sample1.pngRepresentation() else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testPng2() throws {
        
        guard let data = sample2.pngRepresentation() else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testPng3() throws {
        
        guard let data = sample3.pngRepresentation() else { XCTFail(); return }
        
        let result: Image<Gray16ColorPixel> = try AnyImage(data: data).convert(to: .genericGamma22Gray)
        
        XCTAssertEqual(sample3.pixels, result.pixels)
    }
    
    func testPng4() throws {
        
        guard let data = sample4.pngRepresentation() else { XCTFail(); return }
        
        let result: Image<Gray16ColorPixel> = try AnyImage(data: data).convert(to: .genericGamma22Gray)
        
        XCTAssertEqual(sample4.pixels, result.pixels)
    }
    
    func testPng1Interlaced() throws {
        
        guard let data = sample1.pngRepresentation(interlaced: true) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testPng2Interlaced() throws {
        
        guard let data = sample2.pngRepresentation(interlaced: true) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testPng3Interlaced() throws {
        
        guard let data = sample3.pngRepresentation(interlaced: true) else { XCTFail(); return }
        
        let result: Image<Gray16ColorPixel> = try AnyImage(data: data).convert(to: .genericGamma22Gray)
        
        XCTAssertEqual(sample3.pixels, result.pixels)
    }
    
    func testPng4Interlaced() throws {
        
        guard let data = sample4.pngRepresentation(interlaced: true) else { XCTFail(); return }
        
        let result: Image<Gray16ColorPixel> = try AnyImage(data: data).convert(to: .genericGamma22Gray)
        
        XCTAssertEqual(sample4.pixels, result.pixels)
    }
    
    func testBmp1() throws {
        
        guard let data = sample1.representation(using: .bmp, properties: [:]) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testBmp2() throws {
        
        guard let data = sample2.representation(using: .bmp, properties: [:]) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testTiff1() throws {
        
        guard let data = sample1.tiffRepresentation() else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testTiff2() throws {
        
        guard let data = sample2.tiffRepresentation() else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testTiff3() throws {
        
        guard let data = sample3.tiffRepresentation() else { XCTFail(); return }
        
        let result: Image<Gray16ColorPixel> = try AnyImage(data: data).convert(to: .genericGamma22Gray)
        
        XCTAssertEqual(sample3.pixels, result.pixels)
    }
    
    func testTiff4() throws {
        
        guard let data = sample4.tiffRepresentation() else { XCTFail(); return }
        
        let result: Image<Gray16ColorPixel> = try AnyImage(data: data).convert(to: .genericGamma22Gray)
        
        XCTAssertEqual(sample4.pixels, result.pixels)
    }
    
    func testTiff5() throws {
        
        guard let data = Image<Float32ColorPixel<LabColorModel>>(image: sample1, colorSpace: .default).tiffRepresentation() else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testTiff6() throws {
        
        guard let data = Image<Float32ColorPixel<LabColorModel>>(image: sample2, colorSpace: .default).tiffRepresentation() else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testTiff1PackBits() throws {
        
        guard let data = sample1.tiffRepresentation(compression: .packBits) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testTiff2PackBits() throws {
        
        guard let data = sample2.tiffRepresentation(compression: .packBits) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testTiff3PackBits() throws {
        
        guard let data = sample3.tiffRepresentation(compression: .packBits) else { XCTFail(); return }
        
        let result: Image<Gray16ColorPixel> = try AnyImage(data: data).convert(to: .genericGamma22Gray)
        
        XCTAssertEqual(sample3.pixels, result.pixels)
    }
    
    func testTiff4PackBits() throws {
        
        guard let data = sample4.tiffRepresentation(compression: .packBits) else { XCTFail(); return }
        
        let result: Image<Gray16ColorPixel> = try AnyImage(data: data).convert(to: .genericGamma22Gray)
        
        XCTAssertEqual(sample4.pixels, result.pixels)
    }
    
    func testTiff5PackBits() throws {
        
        guard let data = Image<Float32ColorPixel<LabColorModel>>(image: sample1, colorSpace: .default).tiffRepresentation(compression: .packBits) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testTiff6PackBits() throws {
        
        guard let data = Image<Float32ColorPixel<LabColorModel>>(image: sample2, colorSpace: .default).tiffRepresentation(compression: .packBits) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testTiff1LZW() throws {
        
        guard let data = sample1.tiffRepresentation(compression: .lzw) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testTiff2LZW() throws {
        
        guard let data = sample2.tiffRepresentation(compression: .lzw) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testTiff3LZW() throws {
        
        guard let data = sample3.tiffRepresentation(compression: .lzw) else { XCTFail(); return }
        
        let result: Image<Gray16ColorPixel> = try AnyImage(data: data).convert(to: .genericGamma22Gray)
        
        XCTAssertEqual(sample3.pixels, result.pixels)
    }
    
    func testTiff4LZW() throws {
        
        guard let data = sample4.tiffRepresentation(compression: .lzw) else { XCTFail(); return }
        
        let result: Image<Gray16ColorPixel> = try AnyImage(data: data).convert(to: .genericGamma22Gray)
        
        XCTAssertEqual(sample4.pixels, result.pixels)
    }
    
    func testTiff5LZW() throws {
        
        guard let data = Image<Float32ColorPixel<LabColorModel>>(image: sample1, colorSpace: .default).tiffRepresentation(compression: .lzw) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testTiff6LZW() throws {
        
        guard let data = Image<Float32ColorPixel<LabColorModel>>(image: sample2, colorSpace: .default).tiffRepresentation(compression: .lzw) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testTiff1Deflate() throws {
        
        guard let data = sample1.tiffRepresentation(compression: .deflate) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testTiff2Deflate() throws {
        
        guard let data = sample2.tiffRepresentation(compression: .deflate) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testTiff3Deflate() throws {
        
        guard let data = sample3.tiffRepresentation(compression: .deflate) else { XCTFail(); return }
        
        let result: Image<Gray16ColorPixel> = try AnyImage(data: data).convert(to: .genericGamma22Gray)
        
        XCTAssertEqual(sample3.pixels, result.pixels)
    }
    
    func testTiff4Deflate() throws {
        
        guard let data = sample4.tiffRepresentation(compression: .deflate) else { XCTFail(); return }
        
        let result: Image<Gray16ColorPixel> = try AnyImage(data: data).convert(to: .genericGamma22Gray)
        
        XCTAssertEqual(sample4.pixels, result.pixels)
    }
    
    func testTiff5Deflate() throws {
        
        guard let data = Image<Float32ColorPixel<LabColorModel>>(image: sample1, colorSpace: .default).tiffRepresentation(compression: .deflate) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testTiff6Deflate() throws {
        
        guard let data = Image<Float32ColorPixel<LabColorModel>>(image: sample2, colorSpace: .default).tiffRepresentation(compression: .deflate) else { XCTFail(); return }
        
        let result: Image<ARGB32ColorPixel> = try AnyImage(data: data).convert(to: .sRGB)
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testPngSuite() throws {
        
        let images = try FileManager.default.contentsOfDirectory(at: images_dir.appendingPathComponent("png_test_suite"), includingPropertiesForKeys: nil, options: [])
        
        for image in images where image.pathExtension == "png" {
            
            let png_image = try AnyImage(contentsOf: image)
            let tiff_image = try AnyImage(contentsOf: image.deletingPathExtension().appendingPathExtension("tif"))
            
            XCTAssertEqual(png_image.width, tiff_image.width)
            XCTAssertEqual(png_image.height, tiff_image.height)
            
            switch (png_image.base, tiff_image.base) {
            case let (result, answer) as (Image<Gray16ColorPixel>, Image<Gray16ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            case let (result, answer) as (Image<Gray32ColorPixel>, Image<Gray32ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            case let (result, answer) as (Image<RGBA32ColorPixel>, Image<RGBA32ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            case let (result, answer) as (Image<RGBA64ColorPixel>, Image<RGBA64ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            default: XCTFail()
            }
            
        }
        
    }
    
    func testApngSuite() throws {
        
        let images = try FileManager.default.contentsOfDirectory(at: images_dir.appendingPathComponent("apng_test_suite"), includingPropertiesForKeys: nil, options: [])
        
        for image in images where image.pathExtension == "png" {
            
            let imageRep = try ImageRep(contentsOf: image)
            let png_image = AnyImage(imageRep: imageRep)
            
            let tiff_image = try AnyImage(contentsOf: image.deletingPathExtension().appendingPathComponent("default.tif"))
            
            XCTAssertEqual(png_image.width, tiff_image.width)
            XCTAssertEqual(png_image.height, tiff_image.height)
            
            switch (png_image.base, tiff_image.base) {
            case let (result, answer) as (Image<Gray16ColorPixel>, Image<Gray16ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            case let (result, answer) as (Image<Gray32ColorPixel>, Image<Gray32ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            case let (result, answer) as (Image<RGBA32ColorPixel>, Image<RGBA32ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            case let (result, answer) as (Image<RGBA64ColorPixel>, Image<RGBA64ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            default: XCTFail()
            }
            
            XCTAssertTrue(imageRep.isAnimated, "Failed: \(image)")
            
            for i in 0..<imageRep.numberOfPages {
                
                let png_image = AnyImage(imageRep: imageRep.page(i))
                
                let tiff_image = try AnyImage(contentsOf: image.deletingPathExtension().appendingPathComponent("\(i).tif"))
                
                XCTAssertEqual(png_image.width, tiff_image.width)
                XCTAssertEqual(png_image.height, tiff_image.height)
                
                switch (png_image.base, tiff_image.base) {
                case let (result, answer) as (Image<Gray16ColorPixel>, Image<Gray16ColorPixel>):
                    
                    for (result, answer) in zip(result.pixels, answer.pixels) {
                        XCTAssertEqual(result, answer, "Failed: \(image)")
                    }
                    
                case let (result, answer) as (Image<Gray32ColorPixel>, Image<Gray32ColorPixel>):
                    
                    for (result, answer) in zip(result.pixels, answer.pixels) {
                        XCTAssertEqual(result, answer, "Failed: \(image)")
                    }
                    
                case let (result, answer) as (Image<RGBA32ColorPixel>, Image<RGBA32ColorPixel>):
                    
                    for (result, answer) in zip(result.pixels, answer.pixels) {
                        XCTAssertEqual(result, answer, "Failed: \(image)")
                    }
                    
                case let (result, answer) as (Image<RGBA64ColorPixel>, Image<RGBA64ColorPixel>):
                    
                    for (result, answer) in zip(result.pixels, answer.pixels) {
                        XCTAssertEqual(result, answer, "Failed: \(image)")
                    }
                    
                default: XCTFail()
                }
                
            }
        }
        
    }
    
    func testTiffOrientation1() throws {
        
        let images = try FileManager.default.contentsOfDirectory(at: images_dir.appendingPathComponent("tiff_orientation_test_1"), includingPropertiesForKeys: nil, options: [])
        
        let answer = try AnyImage(contentsOf: images[0])
        
        for image in images.dropFirst() {
            
            let result = try AnyImage(contentsOf: image)
            
            XCTAssertEqual(answer.width, result.width)
            XCTAssertEqual(answer.height, result.height)
            
            switch (result.base, answer.base) {
            case let (result, answer) as (Image<Gray16ColorPixel>, Image<Gray16ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            case let (result, answer) as (Image<Gray32ColorPixel>, Image<Gray32ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            case let (result, answer) as (Image<RGBA32ColorPixel>, Image<RGBA32ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            case let (result, answer) as (Image<RGBA64ColorPixel>, Image<RGBA64ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            default: XCTFail()
            }
            
        }
    }
    
    func testTiffOrientation2() throws {
        
        let images = try FileManager.default.contentsOfDirectory(at: images_dir.appendingPathComponent("tiff_orientation_test_2"), includingPropertiesForKeys: nil, options: [])
        
        let answer = try AnyImage(contentsOf: images[0])
        
        for image in images.dropFirst() {
            
            let result = try AnyImage(contentsOf: image)
            
            XCTAssertEqual(answer.width, result.width)
            XCTAssertEqual(answer.height, result.height)
            
            switch (result.base, answer.base) {
            case let (result, answer) as (Image<Gray16ColorPixel>, Image<Gray16ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            case let (result, answer) as (Image<Gray32ColorPixel>, Image<Gray32ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            case let (result, answer) as (Image<RGBA32ColorPixel>, Image<RGBA32ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            case let (result, answer) as (Image<RGBA64ColorPixel>, Image<RGBA64ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            case let (result, answer) as (Image<ARGB64ColorPixel>, Image<ARGB64ColorPixel>):
                
                for (result, answer) in zip(result.pixels, answer.pixels) {
                    XCTAssertEqual(result, answer, "Failed: \(image)")
                }
                
            default: XCTFail()
            }
            
        }
    }
    
}
