//
//  ImageCodecTest.swift
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

import Doggie
import XCTest

class ImageCodecTest: XCTestCase {
    
    var sample1: Image<ARGB32ColorPixel> = {
        
        let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.sRGB)
        
        context.draw(rect: Rect(x: 0, y: 0, width: 100, height: 100), color: .white)
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
        
        context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
        
        context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
        
        return context.image
    }()
    
    var sample2: Image<ARGB32ColorPixel> = {
        
        let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.sRGB)
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
        
        context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
        
        context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
        
        return context.image
    }()
    
    var sample3: Image<Gray16ColorPixel> = {
        
        let context = ImageContext<Gray16ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.genericGamma22Gray)
        
        context.draw(rect: Rect(x: 0, y: 0, width: 100, height: 100), color: .white)
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: GrayColorModel(white: 217/255))
        
        context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 1, cap: .round, join: .round, color: GrayColorModel())
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: GrayColorModel(white: 24/255))
        
        context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 1, cap: .round, join: .round, color: GrayColorModel())
        
        return context.image
    }()
    
    var sample4: Image<Gray16ColorPixel> = {
        
        let context = ImageContext<Gray16ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.genericGamma22Gray)
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: GrayColorModel(white: 217/255))
        
        context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 1, cap: .round, join: .round, color: GrayColorModel())
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: GrayColorModel(white: 24/255))
        
        context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 1, cap: .round, join: .round, color: GrayColorModel())
        
        return context.image
    }()
    
    func testPng1() {
        
        guard let data = sample1.pngRepresentation() else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testPng2() {
        
        guard let data = sample2.pngRepresentation() else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testPng3() {
        
        guard let data = sample3.pngRepresentation() else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<Gray16ColorPixel>(image: AnyImage(data: data), colorSpace: .genericGamma22Gray) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample3.pixels, result.pixels)
    }
    
    func testPng4() {
        
        guard let data = sample4.pngRepresentation() else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<Gray16ColorPixel>(image: AnyImage(data: data), colorSpace: .genericGamma22Gray) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample4.pixels, result.pixels)
    }
    
    func testPng1Interlaced() {
        
        guard let data = sample1.pngRepresentation(interlaced: true) else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testPng2Interlaced() {
        
        guard let data = sample2.pngRepresentation(interlaced: true) else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testPng3Interlaced() {
        
        guard let data = sample3.pngRepresentation(interlaced: true) else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<Gray16ColorPixel>(image: AnyImage(data: data), colorSpace: .genericGamma22Gray) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample3.pixels, result.pixels)
    }
    
    func testPng4Interlaced() {
        
        guard let data = sample4.pngRepresentation(interlaced: true) else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<Gray16ColorPixel>(image: AnyImage(data: data), colorSpace: .genericGamma22Gray) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample4.pixels, result.pixels)
    }
    
    func testBmp1() {
        
        guard let data = sample1.representation(using: .bmp, properties: [:]) else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testBmp2() {
        
        guard let data = sample2.representation(using: .bmp, properties: [:]) else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testTiff1() {
        
        guard let data = sample1.tiffRepresentation else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testTiff2() {
        
        guard let data = sample2.tiffRepresentation else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testTiff3() {
        
        guard let data = sample3.tiffRepresentation else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<Gray16ColorPixel>(image: AnyImage(data: data), colorSpace: .genericGamma22Gray) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample3.pixels, result.pixels)
    }
    
    func testTiff4() {
        
        guard let data = sample4.tiffRepresentation else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<Gray16ColorPixel>(image: AnyImage(data: data), colorSpace: .genericGamma22Gray) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample4.pixels, result.pixels)
    }
    
    func testTiff5() {
        
        guard let data = Image<FloatColorPixel<LabColorModel>>(image: sample1, colorSpace: .default).tiffRepresentation else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testTiff6() {
        
        guard let data = Image<FloatColorPixel<LabColorModel>>(image: sample2, colorSpace: .default).tiffRepresentation else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testPngSuite() {
        
        for (name, png_data) in png_test_suite {
            
            guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: png_data), colorSpace: .sRGB) else {
                XCTFail()
                return
            }
            
            guard let answer = try? Inflate().process(png_test_suite_answer_data[png_test_suite_answer_search_table[name]!]) else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(answer, result.pixels.data)
        }
    }
    
    static func blob(_ base64: String) -> Data {
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)!
    }
    
    // download: http://www.schaik.com/pngsuite/
    let png_test_suite = ["s39i3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACcAAAAnBAMAAAEJinyQAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAARlJREFUeJxtkDFygzAQRZ/HkwSTFM4NGE7AjC6QIgdw457KtTtaSpVu3VFTuafhADpUVhIS
        COUxwPC1u/8voHtmM6NUg9ZgDBSimUSbaZRAUWgRjAXlFPmWavdaavypdopKlb6wStM4xTX1PeNQ
        jh4q6gW67qPzMBAL6npTEGA5HcYhFFQ1a8E9FIyU2O20Dy0NSyPqqDzNmqHCzF8uuqwf49ylP06A
        dYKKE2LGym8eJsQ4OusvR8KEoyJMkCzE/s1ChAnoTYIBx5Tw4nZr5U5oeT547nhwlevtmnDhV3CP
        lR++BfdYOcOnuGXukih3zxH3nMvOeOOeOh/OmfE0Zc7tuzXfuT9O1nzv7n/lf+b7tQ8uQOpurXn9
        AQyWNfYM/uLgAAAAAElFTkSuQmCC
        """),
        "s38i3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACYAAAAmBAMAAAEtFMQLAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAANpJREFUeJylkT8LgkAchp/+WEFfokVapamDhvxGtTYduGmDi7s0NDc1Cwn6sTpF7w7PQEju
        9/L48N6pCMcCqeZuzeYjOfZT0I6sT1HNYtNkVHcpi5aB2/5xIW/z8TtzKzsDcbCOD5VaEknVY3yw
        7NrYaoABGucVxmJbmL2zUK0X7zTU6Gl8YWxqupnGlUGsbjYNUzR6ZzSGjFisbjjWbQrtdU2ewi/7
        JHkGlEOX4zsOwdLZK3z3PNexEjunp17FeYZ995dr/uR24JpvYoIb3euVlyl7x3pCnZd8AfUFRB95
        /EUWAAAAAElFTkSuQmCC
        """),
        "s05n3p02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFAgMAAADwAc52AAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAlQTFRFAP//dwD//wAAQaSqcwAAABRJREFUeJxjWNXAMLWBYSKYXNUAACoHBZCu
        jPRKAAAAAElFTkSuQmCC
        """),
        "cs5n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BQUFGCbeQwAAAGJJREFUeJztlbERgEAMw5Q7L0EH+w/Fd4zxbEAqUUUDROfCcW1cwmELLltw2gI9
        wQgaastFyOPeJ7ctWLZATzCCjsLuAfIgBPlXBHkQ/kgwgm8KeRCCPAhB/hVh2QI9wQgaXuXOFG8Q
        ELloAAAAAElFTkSuQmCC
        """),
        "bgwn6a08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAAYagMeiWXwAAAAZiS0dE
        AP8A/wD/oL2nkwAAAG9JREFUeJzt1jEKgDAMRuEnZGhPofc/VQSPIcTdxUV4HVLoUCj8H00o2YoB
        MF57fpz/ujODHXUFRwPKBqj5DVigB041HiJ9gFyCVOMbsEIPXNwuAHkgiJL/4qABNqB7QAeUPBAE
        2QAZUDZAfwEb8ABSIBqcFg+4TAAAAABJRU5ErkJggg==
        """),
        "basn3p02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgAgMAAAAOFJJnAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        AQEBfC53ggAAAAxQTFRFAP8A/wAA//8AAAD/ZT8rugAAACJJREFUeJxj+B+6igGEGfAw8MnBGKug
        LHwMqNL/+BiDzD0AvUl/geqJjhsAAAAASUVORK5CYII=
        """),
        "bggn4a16": blob("""
        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
        """),
        "tbgn3p08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAABGdBTUEAAYagMeiWXwAAAuJQTFRF
        ////gFZWtbW4qEJCn5+fsSAgixUVnZ2dGxtZm5ubAACEmZmZj6ePl5eXlZWVk5OTKSlWkZGRAACb
        j4+Pi5WLLi6njY2NgAAAi4uLuQAAiYmJDAzVeHV1h4eHAACyhYWFpQAA3gAAgYGBf39/AACefX19
        AADJe3t7eXl5NzdWd3d3dXV1c3NzSKlIjgAAAgJkAABiVolWKCh8U4tTiYmPZ2dnZWVlXW1dE+UT
        hiYmby0tRJFEYWFhO507RIlEPZM9AACkAPMAAPEAWVlZV1dXVVVVU1NTNIU0UVFRJJckT09POjpB
        EBC6sg8PAMcAAMUA/Pz8AMMABASXAMEALXct+vr6AL8AAABoAL0A2tTUEBB7Ca0J+Pj4ALkAALcA
        nJyh9vb2DKEMALMAALEAEJEQAKsA8vLyAKkAAKcA7u7u7OzsAJcA6urqAABrAI0AAIsAAIkAAIcA
        MTExGRkqBwdAEhKuCQnu09bTzMzMkwAAoyoqxsbGxMTEzAAA0woKgWtreD4+AwNtAACfCgpWRkZI
        QUFNc11dUQcHqKio7e3voKCgnp6enJycAAC5mpqasgAAmJiY6wAAlpaWngAAlJSUExMckpKSkJCQ
        jo6OAACRioqKiIiIdqJ2hYiFhoaGhISEeA8PgoKCfoJ+fn5+fHx8enp6SsBKdnZ2dHR0cnJycHBw
        mAAAbm5uanBqemZmampqhAAARKJES5ZLYWRhYmJiAPQAOJg4XFxcWlpaAOYAAgJdQnhCVlZWAADw
        LpQuR2hHMTFgANgAUlJSUFBQAM4AIZghFBRtAMgATExM/f39AMYAAACdb2tr6g4OSEhIALwANGY0
        AgL1U1NgALAAAK4AtwAAAKQA7+/vAKIAj09PlTQ0AJgAAJYAAJIA5+fnAIwA4+PjAIAAkgYGAQFv
        ZFZZAABkTk5rz8/P3d3gAAB7ycnJFhZBISFZV1dZRER4v7+/693dLS1UCgpgAAD/v319qqqqeGU9
        NQAAAAF0Uk5TAEDm2GYAAAABYktHRPVF0hvbAAACiklEQVQ4jWNgoDJ48CoNj+w9psVmTyyZv3zA
        Kpv5Xsq0rYFNb4P4htVVXyIDUGXTavhWnmmwrJxcKb7Aqr29fcOjdV3PY2CyMa/6luu0WT6arNBf
        WyupwGa5QHy13pM1Oss5azLBCiqUl2tr35Lsv+p76yarouLEiYq1kuJntIFgfR9YwQv52fPVGX1Z
        b8poaWnVM9edPVtXxQhkrtp+6D1YQc58pbkzpJQ1UMHyLa6HT9yDuGGR5zVbEX7h+eowsHSpxnqX
        wyfOOUNdOSvplOOyaXy8U2SXQMHK7UZBUQItC6EKpkVHbLUQnMLLzcktobx4sarWlks+ajPDwwU6
        oAqmJCbt3DqHX2SjLk93z4zF63e8ld7btKvEgKMcqqDjaOrxrcum6Z5P38fO0rV0h7PoZ7VdxVOb
        NWHBybTvxpWdTiIbj9/e1tPNssL52cW9jd7nXgushAVltXty3hHHTbZ+t+052bvXAA1weNMa1TQz
        HqYgcnfyw1inFNtT2fZ9nOymb8v2Nh4IUnn5qRqmIGf3lcLEgxmegXfsJ/T12Lz73Mvx+mVuLkcC
        TEHA/vQ7IcH+d4PvbuLl7tshepHrY7H+Y6FniNhee+3a/sSD+WF5m/h4J7mU7g1vLToml2uCUCB2
        4/IFu+PZ5+9b8/MJ7/Hp1W854HC6uRqhIJTHfbNZ9JXYfGNBfinX0tOfDgTJcTChJKnna8z2JcUV
        GAoLKrlGcelzzTz2HC1JZs0zv5xUYCwmvNT1Y+NTA6MXDOggoOPo5UJDCbEVbt7FJe86MeSBoHxb
        yKLZEmsOeRVphWKTZ2C43jV/3mxTj8NdJ7HLA8F7+Xk2h5hwSgPBi+lmFfjkGRgSHuCXxwQADa7/
        kZ2V28AAAAAASUVORK5CYII=
        """),
        "basi0g08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAAAAAEhFhW+AAAABGdBTUEAAYagMeiWXwAAALVJREFU
        eJy1kF0KwjAQhJ26yBxCxHv4Q88lPoh4sKoXEQ8hS9ymviQPXSGllM7T5JvNMiwWJBFVFRVJmKpC
        SCKoKlYkoaqKiyTFj5mZmQgTCYmgSgDXbCwJ52zyGtyyCTk6ZVNXfaFxQKLFnnDsv6OI3/HwO4L7
        gr0H8F98sT+AuwetL9YMARw8WI7v8fTgO77HzoMtypJ66gBeQxtiV5Y0UwewGchF5r/Du5h2nYT5
        77AupsAPm7n/RegfnygAAAAASUVORK5CYII=
        """),
        "bgbn4a08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAQAAADZc7J/AAAABGdBTUEAAYagMeiWXwAAAAJiS0dE
        AACqjSMyAAAANUlEQVR4nGP8z8DAAYWcaDQxIpws3xkoAyw/hr4Bo2EwGgZUMWA0EEfDgCoGjAbi
        aBhQwwAA3yogfcTrhcgAAAAASUVORK5CYII=
        """),
        "basn4a16": blob("""
        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
        """),
        "s04n3p01": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAQAAAAEAQMAAACTPww9AAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAZQTFRF/wB3//8AmvdDuQAAAA9JREFUeJxj+MAwAQg/AAAMCAMBgre2CgAAAABJ
        RU5ErkJggg==
        """),
        "s33i3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACEAAAAhBAMAAAHSze/KAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAAPZJREFUeJxdjzFywjAQRT/JMCjEBdzAkxN4RhdIwQHcuKeiplNLqZKWzrUr+jQ+gA6Vv6sV
        lnkey5K+Vm8NxBvmNMP7DpHzxLmL/HCHG+Cy8xI6l+M0y2GGYBw1lN0kq5gTOaThawlM434SRrT4
        UVqEsAvCFSNKmjNejpCz3RWTAUs/WsldVOM0Wug/vfISsPcmaWtFxBqrAkqVAesJ+jOkKQ0E/bMY
        Xalhl1bUWRUbykVooPwtPHG5nPkunPG441Fzx8BnOyz0OBEdjF8ciQ7GAfjm9WsX5W+uWqMMK3r0
        tUZE5qo8m0OtEd48qlq5vtRXm8Td/wMULdZI1p9klQAAAABJRU5ErkJggg==
        """),
        "s32i3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAAH2U1dRAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAANhJREFUeJx9kL0OgjAURj9FfuJTuBjXhqkkDvBGujo1casOLOyEgZmpM4kk8Fi29FYpMTbN
        l8O59+Y2AByC48nw5Ehe4Pr25orpfEeQ6LhPNgLgdmpQm2iWsdVxqA3V9lOyWKajTCEwWpDpx8TO
        6Oz3zMIoHYgtlWDORlWFqqDKgiAk6OBM6XoqgsgBPj0mC4QWcgUHJZW+QD1F56Yighx0ro82Ow5z
        4tEyDJ6ocfQFMuz8ER1/BaLs4HforcN6hMRF18KlMIyluP4QbCX0qz0hsN6yWjv/iTeEUtKElO3E
        IwAAAABJRU5ErkJggg==
        """),
        "cm0n0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAACT4cgpAAAABGdBTUEAAYagMeiWXwAAAAd0SU1F
        B9ABAQwiON2c/4AAAADISURBVHicXdHBDcIwDAVQHypACPAIHaEjsAojVOLIBTEBGzACbFBGYAPY
        oEY9lQKfxElR4hwq58V17ZRgFiVxa4ENSJ7xmoip8bSAbQL3f80I/LXg358J0Y09LBS4ZuxPSwrn
        B6DQdI7AKMjvBeSS1x6m7UYLO+hQuoCvvnt4cOddAzmHLwdwjyokKOwq6Xns1YOg1/4e2unn6ED3
        Q7wgEglj1HEWnotO21UjhCkxMbcujYEVchDk8GYDF+QwsIHkZ2gopYF0/QAe2cJF+P+JawAAAABJ
        RU5ErkJggg==
        """),
        "basn3p01": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgAQMAAABJtOi3AAAABGdBTUEAAYagMeiWXwAAAAZQTFRF
        7v8iImb/bBrSJgAAABVJREFUeJxj4AcCBjTiAxCgEwOkDgC7Hz/Bk4JmWQAAAABJRU5ErkJggg==
        """),
        "basi2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAGLH901AAAABGdBTUEAAYagMeiWXwAAAPJJREFU
        eJzVk0GqBCEMRKvAe3gTPVnTczO9iddoaLVm0Qz0Z1r4WWQxoRZifFaIkZKA4xIlfdagpM8aAQCO
        4xKl88acN+b8w/R+Z3agf4va9bQP7tLTPgJeL/T+LUpj4aFtkRgLc22LxFhUxW2VGGP0p+C2bc8J
        qQDz/6KUjUCR5TyobASKZDkPZitQSpmWYM7ZBhgrmgGovgClZASm7eGCsSI7QCXjLE3jQwRjRXaA
        yTqtpsmbc4Zaqy/AlJINkBogP13f4ZcNKEVngybP+6/v/NMGVPRtEZvkeT+Cc4f8DRidW8TWmjwj
        1Fp/24AxRleDN99NCjEh/D0zAAAAAElFTkSuQmCC
        """),
        "bgyn6a16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAYAAAAj6qa3AAAABGdBTUEAAYagMeiWXwAAAAZiS0dE
        /////wAAt37lIwAADSJJREFUeJzdmV9sHNd1xn/zj7NLck0u5VqOSwSgrIcEkQDKtNvYxlKJAstN
        EIgWIFkuUtQyWsCQW8mKlAJecf1iLLUGWsmKDCgwUMByigC25UKh0SaIXNMpiSiJHZoERAN+kEQ0
        lR1LkLhLL8nd4fzrwzl3qVVVNI9BHhbfzp07d+537r3nfOeMlaZpCtB8FwCaE+3YmLh9+x/LfStN
        G/8hfzPfgN6x5iZ98P/B5ubfr98fWn/TD5rvZrbVRt01W/AsQGYuMwf5clqWxnRMMDH4N4LxccFI
        28O/F3T12tHnnW8JWj9U1PvsUjTv2aL41zr+TxT1fvT0Le97RPGQYPBrRb3fHFU013/ZIr4pc6Fa
        guZIZhxuMkCqNhLq2VK2BL3ldFiJTynerxM7rBPSdm9SJ6SjuM8I2nrf1vvWvYpP6du0PTXj36P4
        RPv4kRm/T3FECU+1YzOr+KhgY8oQb5Szo7USNDdl5gCCCX8buGunJDmmU1GbCfXO4c5hyJfTfu31
        VTWArmD0r4rzOrFP1AC2oPNFNcBDSvwLOp8HFHUnpfp8ohj/VsdNdNw/FVz9MyX8J4rPKuHLSlOf
        X5k3xFcmOwvVEjTHMqMAzdHMGEDwqv9U2w5IdO1am11tJ9S7NnRtgN5yuqh3/0snWteJXtGJfqQT
        m1FD/LsaYlYNoe2WYqrtiV7HipHBh5W4XgerSvi6Eo6V5oLgcov48uWugVoJGlPZAqwZINjgXwZY
        nejY1maAeJ9ORU+52exmzYV695buLZAvpz/Vu6d1ohU1gK5EcF7Q03ZH0VaXy48Uv6Pj6P34Ax1H
        r1cVAzV88w0lrO3LvxNcmjXEl2a6B6slWFno7ANoTmaGAYLf+PcDBL/2/xwg/IG3r90ApxR1U5pT
        bja7WXOhnjuSOwK95eTv1AA6wXDrLRP+J0FXr+29gtb7OpoeheRVHUfPcHj4lnH+Qonr9fK/CNY/
        N8TrR3PFWgmW7+76DKARZx2AYMovAATH/MMA4WbvAkD4Je/jNh8QbVfUI9ByP3rKzWY3ay7Ue3p6
        eiBfTvSsRpHgqtmqDUHPE3QcNYClBkh1dN3KYajEA8GGPr+8rDR1Fost4ouLPXdUS7Bc6SoCrOzt
        PA3QzGXqNxsgHPHGAcJN3hxAeM7b3rYDIvUBJqAZv27cmznlZrObNRfq+Xw+D73l5EkdRb10U3FF
        0VW0dqoBduhoxqvr8w29XlJcVKyOGOLVar63VoJ6PZcDWKl0FgGab2T2AAT9/hWA1cmOYYBwzBsF
        iH7ufg0gmnDbfYBjApiJtMYg6teNezOn3Gx2s+ZCfd3b696GfDk6p4ReVAPoynlK0Nb7iXr18DUl
        /leC9ecEa9rvRov4jR3rxqslWDzRcxBgebmrC6BZyRQBgkW/B2B1taMDIAw8HyCaczcBRE+7rwDE
        E067AWxdCyNhTCQ3Ac34dePezOk0m92suVBfv339dugth3NqAPXStf/Ut9zicZpNJa5xfuFTwavv
        GOJXz61/pFaC2kjvOMBStTsP0GhkswDBUf8IwOpDHecBoofdXwBEl9x7AaJT7j6AuMf5HCD5Z/tv
        23yArafYaDcjYUwkNwHN+HXj3swpN5vdrLlQ7z/Ufwjy5aYepKoqPrdXzVUTNF78+lnBKy8Z4leO
        93+3WoKFT/vuAag/l3sRoDGTHQQIAt8HCCteESB8wXseIJp3BwDi3wqD5An7dYD4J8IwmbBv2QH7
        BY1oNdrNSBgTyU1AM37duDdzys1mN2su1De+vPFl6C0vTkvrfz+m5lLC1+4QvHjAEL+4f+PJWgmu
        n71zJ0C9L7cA0Phl9kGA4Fn/BEAYygyiilsEiD9wHgCIv+x8DJCctx8ESMbsUYB0s3UBIHnZ3t9m
        AEvPvFHrLdGq2s1IGBPJTUAzft24N3PKzWY3ay7Uh4aGhiBfvnxJ71YFpz80xKenh+6rluDagbtO
        AiwVuicBmlszkwDha/KGqOrmAeJYZpB83z4IkKyzbwAkX7V/BZBOWcMA6SVhlG6y5gDSCat9B/BN
        RY37Rq0b0Wq0m5EwJpKbgGb8unFv5pSbzW7WXKjvfnz349BbfnyPIX7mzd27aiWoVvN5gODH/k6A
        qCYjxIGTAUhG7HGA9Kz1GECaygzSilUE4Dsyw3TeGgBgigJA+qoyeksZ/pRvtvkAVNu18jM9Ai21
        brSWajcjYUwkNwHN+PVWvqin3Gx2s+Zr1GWE3bvOvAmQz0sP/0BwUgwoIzin4mcA7HJSArAeS88C
        WJY8bx1NjwAwyyCAVUnFIJMMA1hPpSK2dvEWAP/AP94+GzSJqckFTJqiO8CIVqPdjIQxkdwENOPX
        jXszp1w2+5k3YfeuWmn3Lvl/5q0zb+1+HGDovulpgLveu7YNoHtwaQYgM9ncCuA9KW9wq1EewHFk
        BnYlKQLYM8kWAHs+GQCwptICgDWWjgJYYeoBWBNp+xFIjDTRjLyVmJr8zKQrqtZbotVoNyNhTCTX
        gGb8uri36WkYuq9aqlYhn5dftQpD98m96Q+nPxwaAth48uJ+gDt3ygi5BRkxW2/kAPwTkgl6nszA
        rURFAOcBmaEzHw8A2JNJAcB+XVJs64fC0H4lebrdAForMaUIk5G3ElM1gElTWmrdiFbdAUbCmEgu
        Ae3ifth4sla6dgDuOgnBj8HfCf4BCE7CXe/BtW2w8aT0vXjg4oGNLwM05zMDAH33yIi5F+UN2cHG
        DIDvywy8Y+H3ALznwxcA3MvRBgAnit2bDeBsji8A2Elit9cDDiphU4MxuYBR+SYxvSU/M2rdiFaj
        3UTCXDkO/d+tlq6fhTt3wlIBuifFM7i98otq0D0ISzPS5/pZCZ6ZAbjy0pWX+g8BhI945wCCEX8c
        oHt2aRAgm5UZ+JWgCNAxu7oFwJ2PBgBcWxi4+6JTAM6meA7APpEcbM8G1Qe0ik+mBmNKEUYJ3pKf
        mTTFqHURrVfPwfpHaqWFT6HvHjkQuQVoboXMJMQBOBmJFfEz0tbcKn3qffLMwqdS+vLOwdV3rr6z
        fjtANO7uAAjf874Oa5I3c7R5BMDvkRl2fLT6FQDvE2HgjkUlAPcVYehMxO0+IPq2oskF9Ay3ajAm
        vzMZuRrC5GeSptzYAevGq6XaCPSOy4HIvQiNX0L2QXGR3pOQjIA9DnYZkpK0ha9Btg6NnDxTfw6C
        EfDHIRoHdwfcGLkxsu5tgKTXrgJEkevCTUpwj/cGgH8l6AfoeF8YeOMi1t2vRT8HcP8t+nabAUI9
        u61yo5G2WnwyNZhWKUIzcklMq1XI99ZKiyeg5yAsVaE7D40ZyA5K6co/AVEV3DykZ8F6TH7pWXCr
        EOWlT/CsPNOYge5ZWBqE8D3wvg5JL9hVqNaqNdELSWLbsKYEo9PuXoCo7uYAokl3+GYDeL8LvwDg
        HQqPt/mA8EuKps5qyo1adTPFJ1ODkVLE4iL03FEt1euQy8mB6OoSz5DNiov0fYkVnidB03Ek9luW
        /NJU2uJY+oShPBMEMkajISlXR4fknq4rSbhtw+Lni5/39AAkFbsIkHxm3w0QO04MEE25BQD/cHAM
        IDruHoLbpMPhbiVsCsymzqrpr9H2EtfrRyFXrJWWK9BVlH3RWYRmBTJFCI6Cf0RihleUKoJbhOT7
        YB+EtAJWEayjkB4BuwJJEdwKREXwjkH4PfArEBQhcxSatxuvAnYR6pV6JXcEIB0UzZr02QsA8ZRT
        AIjLTgnA3xxcAIj3OT9oM8CqOsFWZV3jvKmzSrlxaQa6B6ul5buh6zNY2Qudp8UzZPaIi/R7YPUh
        6DgP4QvgPS/qwXkAknVg30D05I+AWWBQMo1ki/SJP5BnwhegYxZWt8iYwSKEe8B7A6LT4O6F5DOw
        74Z0UMT60uzSbPcWgHTAugyQTNrDAMnP7EcBkk32HNymHhBoXG99UtDKuhSYly9D10CttLIAnX1y
        ILIONHOQqUPQD/6Vm7bqw+D+QupJ7gDEXwbnYymx2r8SfWkNgFWBtAj2PCQD4MxDPADuZYg2gDsP
        0QB0fASrX5F3BP0Q1cHNQeyAE0PSB/YCpANgXYbl+eX5rg0A6ZRVaDOAZoXJMftwmw8ItOhpvqXI
        J4WVSegsVEuNKcgWoDkJmWE5IH5hDVcnoWMYwgA8H6JL4N4rMsr5IiTnwX5QBLY1DEwBBWASGAZr
        CtKCJOFJAZwIYlfKMVEC3icSkDvel7gUTYI7LGrFLUA8BU4Bkkmwh/U9BViZWpnqlGxwzJJ0WLPB
        /1UPMAUN+YjUKEN2tFZqjkFmVMySGYXgN+DfD8Ex8A9LrPDGIRwDbxSiOXA3QXQK3H2iJ+3X5WuD
        PQrpJUm001cl37Se0v9jkI5q3yfW0N2nY41BVNJ3jayhf1jmEpfBKUHyM7AfXcN0DKxRaIw1xrIl
        gPSCJP7puDUCVppmtinxCfNxNHNBPiZm5/5vbG7+/fr9ofVvbgb5NJbZ1ny3NmqZZLb5LmS2iRlu
        xsYEZG/T/kdx/xvwP2XY7MOt27XzAAAAAElFTkSuQmCC
        """),
        "ps1n2c16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAIAAACsiDHgAAAABGdBTUEAAYagMeiWXwAABRpzUExU
        c2l4LWN1YmUACAAAAP8AAAAAM/8AAAAAZv8AAAAAmf8AAAAAzP8AAAAA//8AAAAzAP8AAAAzM/8A
        AAAzZv8AAAAzmf8AAAAzzP8AAAAz//8AAABmAP8AAABmM/8AAABmZv8AAABmmf8AAABmzP8AAABm
        //8AAACZAP8AAACZM/8AAACZZv8AAACZmf8AAACZzP8AAACZ//8AAADMAP8AAADMM/8AAADMZv8A
        AADMmf8AAADMzP8AAADM//8AAAD/AP8AAAD/M/8AAAD/Zv8AAAD/mf8AAAD/zP8AAAD///8AADMA
        AP8AADMAM/8AADMAZv8AADMAmf8AADMAzP8AADMA//8AADMzAP8AADMzM/8AADMzZv8AADMzmf8A
        ADMzzP8AADMz//8AADNmAP8AADNmM/8AADNmZv8AADNmmf8AADNmzP8AADNm//8AADOZAP8AADOZ
        M/8AADOZZv8AADOZmf8AADOZzP8AADOZ//8AADPMAP8AADPMM/8AADPMZv8AADPMmf8AADPMzP8A
        ADPM//8AADP/AP8AADP/M/8AADP/Zv8AADP/mf8AADP/zP8AADP///8AAGYAAP8AAGYAM/8AAGYA
        Zv8AAGYAmf8AAGYAzP8AAGYA//8AAGYzAP8AAGYzM/8AAGYzZv8AAGYzmf8AAGYzzP8AAGYz//8A
        AGZmAP8AAGZmM/8AAGZmZv8AAGZmmf8AAGZmzP8AAGZm//8AAGaZAP8AAGaZM/8AAGaZZv8AAGaZ
        mf8AAGaZzP8AAGaZ//8AAGbMAP8AAGbMM/8AAGbMZv8AAGbMmf8AAGbMzP8AAGbM//8AAGb/AP8A
        AGb/M/8AAGb/Zv8AAGb/mf8AAGb/zP8AAGb///8AAJkAAP8AAJkAM/8AAJkAZv8AAJkAmf8AAJkA
        zP8AAJkA//8AAJkzAP8AAJkzM/8AAJkzZv8AAJkzmf8AAJkzzP8AAJkz//8AAJlmAP8AAJlmM/8A
        AJlmZv8AAJlmmf8AAJlmzP8AAJlm//8AAJmZAP8AAJmZM/8AAJmZZv8AAJmZmf8AAJmZzP8AAJmZ
        //8AAJnMAP8AAJnMM/8AAJnMZv8AAJnMmf8AAJnMzP8AAJnM//8AAJn/AP8AAJn/M/8AAJn/Zv8A
        AJn/mf8AAJn/zP8AAJn///8AAMwAAP8AAMwAM/8AAMwAZv8AAMwAmf8AAMwAzP8AAMwA//8AAMwz
        AP8AAMwzM/8AAMwzZv8AAMwzmf8AAMwzzP8AAMwz//8AAMxmAP8AAMxmM/8AAMxmZv8AAMxmmf8A
        AMxmzP8AAMxm//8AAMyZAP8AAMyZM/8AAMyZZv8AAMyZmf8AAMyZzP8AAMyZ//8AAMzMAP8AAMzM
        M/8AAMzMZv8AAMzMmf8AAMzMzP8AAMzM//8AAMz/AP8AAMz/M/8AAMz/Zv8AAMz/mf8AAMz/zP8A
        AMz///8AAP8AAP8AAP8AM/8AAP8AZv8AAP8Amf8AAP8AzP8AAP8A//8AAP8zAP8AAP8zM/8AAP8z
        Zv8AAP8zmf8AAP8zzP8AAP8z//8AAP9mAP8AAP9mM/8AAP9mZv8AAP9mmf8AAP9mzP8AAP9m//8A
        AP+ZAP8AAP+ZM/8AAP+ZZv8AAP+Zmf8AAP+ZzP8AAP+Z//8AAP/MAP8AAP/MM/8AAP/MZv8AAP/M
        mf8AAP/MzP8AAP/M//8AAP//AP8AAP//M/8AAP//Zv8AAP//mf8AAP//zP8AAP////8AACL/aC4A
        AADlSURBVHic1ZbBCoMwEESn4EF/y363/a32lh4GA5KGJmaTzHoYhkXkPdagjxBCAD4v4JrvZHJz
        fhg9JzNfzuLzWne3AuvOdChwojOX8+3ycF3RAWDzsoFf6OzyAnl0prDAP3Sm5BkoQ+dcbAM16Owy
        AvXoTAGBu+jMqWegDZ3zSRuwQGcfLmCHzhwoYI0eBfjH7g8dALZn5w30RGfvJtAfvZvAKPQoYPcd
        GIvO+402MAOdvVlgHnqzwGz0KFB/BjTQOa/cgBI6e7GAHnqxgCp6FMifAW10zjMb8IDOngj4QU8E
        vKEzv+ZC/l4Hu8TsAAAAAElFTkSuQmCC
        """),
        "g03n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAABGdBTUEAAIi4vcVJsAAAAB5QTFRF
        AAAAAP///wD/AMjIra0A3d0A//////8A/93//63/MbogiAAAAGNJREFUeJxjKAcCJSAwBgJBIGBA
        FmAAAfqoCAWCmUAAV4EsQEcVLkDQAQRwFcgClKlg6DA2YEZS0dDBYcxsgGIGB1wFCKSlJaTBVUAE
        2MACCBUJDGzMQC1IKtLS4O5AFiBTBQBS03C95h21qwAAAABJRU5ErkJggg==
        """),
        "basn6a16": blob("""
        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
        27XzAAAAAElFTkSuQmCC
        """),
        "ccwn3p08": blob("""
        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
        s8MzAAAAAElFTkSuQmCC
        """),
        "oi1n2c16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAIAAACsiDHgAAAABGdBTUEAAYagMeiWXwAAAOVJREFU
        eJzVlsEKgzAQRKfgQX/Lfrf9rfaWHgYDkoYmZpPMehiGReQ91qCPEEIAPi/gmu9kcnN+GD0nM1/O
        4vNad7cC6850KHCiM5fz7fJwXdEBYPOygV/o7PICeXSmsMA/dKbkGShD51xsAzXo7DIC9ehMAYG7
        6MypZ6ANnfNJG7BAZx8uYIfOHChgjR4F+MfuDx0AtmfnDfREZ+8m0B+9m8Ao9Chg9x0Yi877jTYw
        A529WWAeerPAbPQoUH8GNNA5r9yAEjp7sYAeerGAKnoUyJ8BbXTOMxvwgM6eCPhBTwS8oTO/5kL+
        Xge7xOwAAAAASUVORK5CYII=
        """),
        "f03n0g08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAAAAABWESUoAAABTElEQVR4nH3SsUtCURTH8e/phERR
        EBENIUWCUBQ0BC4OQcsDB6EhCIoiECEDg6JIzOfaXxBCBUHQIDg0tTgINTQEDUHgH+C/8RrU53nK
        e3e5HPhw77n3d9R1Mtndvf3Do5Nc/vSseH5xeXV9UyqXbysV1626VU2JIIDQ24ZK3fKihW5KtNAN
        ooWuEi00SbTQBNFCl8QXhUb99eX56aF2nx8IjeOLJv2VG5yhi/ii+6d1+DC36IIMhCAcwLvtQ+cJ
        iALUA53qHFaU4DH4Fp3FiDvgrZG1QmfM8/nGdZoEhE7bD0qlPRkSOoUViCdOk4yJe5IR0cIxcU8w
        Ij7ZMXHHxBetdje5L7ZN3DHPFx3aCaAGaRP3uPgi3qH99/sDRZO+KgEBcGznQ8ewYnklubYemCAV
        rAgmJ4D2yzDRBRFCe0MWKvogVPggTAxAiPgHY2dcQrz+CzkAAAAASUVORK5CYII=
        """),
        "f02n0g08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAAAAABWESUoAAABKklEQVR4nIXRL0uDURgF8MP5OBaL
        IIggCIJBDAODTdgHGCxYh0kwDFYEwwsLA8Ng4U2CYBLBYrEYLIJBEARB9H3uX8Om97nvwr35x+Wc
        83BwOjyvJtP66ub2/uHx6fnl9e394/PruzHW+RAifxppRESMMdZa66x33nsfQogxRkRKQbApCEpB
        UAqCUhA0BUHR4mB/d3tzPRM0SnQBAMgEbRJ9oJpM61zQJAEMRURqQOWgTQKYJwVUUtokesfzLoDq
        QqfEogug2tIuiS6g9qBriz5QqcXoWuJk0eVP0OdiBAyy1ekzMQZ6+V3otJgBR63LMShxDXTat6VP
        4g7A7HJ8MTpTgiEJ/D/1B0MSK6trG1s7e51DnYNBieXVRRgLgrEgGAuCsSCIgiAK4hfp5Je/v8zr
        /QAAAABJRU5ErkJggg==
        """),
        "oi1n0g16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAAAAAAGgflrAAAABGdBTUEAAYagMeiWXwAAAF5JREFU
        eJzV0jEKwDAMQ1E5W+9/xtygk8AoezLVKgSj2Y8/OICnuFcTE2OgOoJgHQiZAN2C9kDKBOgW3AZC
        JkC3oD2QMgG6BbeBkAnQLWgPpExgP28H7E/0GTjPfwAW2EvYX64rn9cAAAAASUVORK5CYII=
        """),
        "s06i3p02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGAgMAAAHqpTdNAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAlQTFRFAP8AAHf//wD/o0UOaAAAACJJREFUeJxjaGBoYJgAxA4MLQwrGDwYIhim
        JjBMSGBYtQAAWccHTMhl7SQAAAAASUVORK5CYII=
        """),
        "tbyn3p08": blob("""
        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
        kZ2V28AAAAAASUVORK5CYII=
        """),
        "s07i3p02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHAgMAAAHOO4/WAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAxQTFRF/wB3AP93//8AAAD/G0OznAAAACVJREFUeJxjOMBwgOEBwweGDQyvGf4z
        /GFIAcI/DFdjGG7MAZIAweMMgVWC+YkAAAAASUVORK5CYII=
        """),
        "cdhn2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAICAIAAAAX52r4AAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAlwSFlzAAAABAAAAAEAH+hVZQAAAOtJREFUeJx9kmuxwyAUhL/M1MBawEIsxEIs
        xEIs3FiohVjAAhaOhSMh9wePQtt0hwEG5rx2d7r4QADVxbg3eN3zxbr7iEc5BTOssJaHFtIHeleo
        9RDao8EBCawvIFgglN5dRIjwLLNsuHBh3RRy5AQgwSn8D2aYA+TlEEuZB+sr0EpeHJE/zl1PtshG
        rMPICAdz3GFNzIJoJANr8+foE6xRdAeBMJGQqhSGnE6kOzjAdPUULfjyRtECAQfXIEJmCYMY8D1T
        5HDU1JWi6WqdhkFkH63xZhCNIr8oPsAGkacvNu2d8YOH3ql+a9N/CM1cqmi++6QAAAAASUVORK5C
        YII=
        """),
        "f03n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAE0klEQVR4nH2WXYhUZRjHf8+8Z2fn
        zNcZv1r7kCyyD7Gy1CiN2kK3kAXDQjJCKk2FCr0QDAp6D3hjflB30lV30k1Xe9FtIMEiXlh2YRBi
        5UWCre7sfO6cfbo45505M7O7w2GY4Rze3/v/P8/7/I9RcjZXsMWKray2q9fa+x+y69bbRx6zG560
        GzfZpzfb57babS/al162r4zb13faiTft7km75y279x2771373vv2wAf24CF75Kj95FN77Lg9ccKe
        /Nx+8aX9ytpTp8yxdcYvRQRQhjKUoARFKEIBCpCHPPiQc9+jkHXfIzACHnhgwEAGMiAgAOboU55W
        8IOIgARTSmG6jEIKk0thYka2n2F6DPPh84ZANMBfkWKUHaCL6erIp3R0pSytw+zfnqGsVNBA/ZUD
        DKUozi6lIMnqvpITp0PJClkYUUbAEzzwFAMZIYN5+9UMJaEMFdEAf3WaIZSUklCEglBQ8kIB8oKv
        +EIORsUxJPFqRPDE6RAzuStDkT7GmiUYRcfIgy8pHcKoMuoYiY6EYSbeyCQmlIWSY4wty4i9WkZH
        imHGd0vSJHFJy0qABuqv7cQMCf4Kz/8bnr8VnrsZnvszPHs9PPt7eOZqeOZK+PW0Pb2l11qj/a01
        Ah5m4/ZMA+pQgzmkCrMwi9xVmn40C9+ELZb+fGafbUArdc3DPLRhHiIw67dJA6lDHeaglmLMKHU/
        +sgWDtrgkF31sR07bB88Yh/+LrwVr35N99WhAQ1oQtMx2g4zD+a+zdJ0D9USHTgGM6o1v3PP/a3C
        TvktXv0n3VWDeGdpRhtppxgm2EiLAYY4hszCjFL1o5hxWP6OV7+g2+bchgYATWghsY42mNzj0oYm
        0oKG29EwY9aPzko1Xv2EbqjCHMy555fRYcyjya8mEt9zNZdaijG1otMt7C/hf5fC2w/bVV0Raa8G
        dBhdJ/NOTiu516t5tx7VCwqsV2/M5u+EbeBqeHuFXTmXtEbXK+nXgek8QAQd11ttaKEttIk20Dpa
        Q2to5jiZk8zqwozfzttcO+wAN8LbozaooXW0jjaggTbRJtpCW9BCDWNZ8Nz5y7rxGA+BvJvUBaEE
        ZQjQSuSX8nasHd4ByvaJ4QCRVIAYVuYQA158+CQ5jjmXL11GHBFlCFQrHT/Q8Cbg263pAJGhADFU
        fNQgnjvdMSM7zBCKbo4HaKCnrwFZ+9pAgEh/gBhKOfBQk9IRD/hYiq92mql/ZOIZx4h1VPTbaSBj
        9wyFVFFSdhnyfpJAgzqSYnD5BsDUHzLxQpexsPlc3LIL9gCDQdjnlSGXA0mCrl9Hcu3YxOXrAFNX
        +fGKXpzW7y/Fq8uNi6pBx1+zKCMuuyGbdQEaM7yUji5jC5d/HZij8vMPUIIKGkT+2DAjDhDDSBaV
        fkbslZeSMsqOHYyPy8SETE7K3r2yfz+9egRoEPlrF2UYMgYVFpQFkiuCSOlIcvwGDnqjN0zSg1fv
        aqfp96ZufNWSFwxQQRWFKMWIhHnoOEDbjfzuUIynRGq4R3Wf9HCvYpIXMAWEBUWX1tFyjGUDJKr1
        MUyvaup0DHjV1bGoV4syqj2GcdvvZ6S96iiR9AGGvRpidGYThulrvZjUZSyvo5myq+6kpBl3fe4N
        AAYYw14t2lfNVM0HdMz4/wOljpe9l86W/gAAAABJRU5ErkJggg==
        """),
        "f02n2c08": blob("""
        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
        PhSnV2U9PQAAAABJRU5ErkJggg==
        """),
        "cs8n3p08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAABGdBTUEAAYagMeiWXwAAAGBQTFRF
        IP8A/x8AAP8fAP/foP8AAP8/AP//AP8AgP8AAP9fAP9/YP8A/wAA4P8AAP+fAOD/QP8A//8AAMD/
        /98AAKD//78AAID/wP8AAP+//58AAGD//38AAED//18AACD//z8As4GzYwAAAEtJREFUeJyFwQUB
        wAAAgDDu7u79Wz4CG7UgEHyCR3AJDsEimASDoBFsgliQCypBL1CZIBQkgkJQClrBLogEqaATjIJZ
        sApOwS14xQ8p4j4B+PNT2QAAAABJRU5ErkJggg==
        """),
        "basn3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAC1QTFRFIgD/AP//iAD/Iv8AAJn//2YA3QD/d/8A/wAAAP+Z3f8A/wC7/7sAAET/
        AP9E0rBJvQAAAEdJREFUeJxj6OgIDT1zZtWq8nJj43fvZs5kIEMAlSsoSI4AKtfFhRwBVO7du+QI
        oHEZyBFA5SopkSOAyk1LI0cAlbt7NxkCAODE6tEPggV9AAAAAElFTkSuQmCC
        """),
        "g04n0g16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAAAAAAGgflrAAAABGdBTUEAAK/INwWK6QAAASJJREFU
        eJytlDkOwjAQRSciLAEkmjQpUtJwAE6AT+0bcAAaCgoKmhQgZWEJCUVkhZkxGVnGhaX5Up6fvxQH
        bQtoBQGetcbzbofnsK5xsN3C4KIHMEAcDwOocfh+42C18jRYLh0NKGCxcDR4vXAwn3saRJGjAQXM
        Zp4G06mjAe1AAjADV4DYwWTiaSABxA6cDZ7PPxuMx3huGkcD+i/c74IBBVADChANKIAu0SAMhwHM
        4PGwG2w2AIeDSZUyzyszsAPW6+PR7ABKaW120aC7wun0PX0/7cyAttx3kKbnc59351sMqsoOSJLL
        hX9uMShLHHQdxDFAkgBkmVJaK9XXyAyKwmZwvZpZa6GDPLdf4ddiBrcbDkajYQAzyDJPg/3eDUAN
        Pik0iSilDmOAAAAAAElFTkSuQmCC
        """),
        "g05n0g16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAAAAAAGgflrAAAABGdBTUEAANbY1E9YMgAAAQpJREFU
        eJyt1b0KgzAQB/AI0X4gSMcOzu3SxTdpHvQexdk+QRdBCqK2VewgQXOnCUeaQS8B//nlQA3GURgj
        CMw5gDm/3825/H7NhctFWAfeQPa9uXA62QOwmAiShCnAAXHsKTgemQLcA1eAU3A4MAWfDy/AKdjv
        mQJuABHgI+x2ngJXwP8F3ACnIIo8BThgGJgC/DK1rUPwftsFOIAIXAF4OAVhaA9gCLIsz3WtlP68
        EkHXrQtut7lWCkBfiWAroCiuV10DWAS4y8sm6toqwAHLJq41lAiaBi3I6X4+C5Gmz6dSAMsjEAEO
        0LuW5XSfHpt/cERQ19tHWBtE8HrxAoigqtCCZAoeDz/BD+1fhGYCQbPgAAAAAElFTkSuQmCC
        """),
        "cthn0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAACT4cgpAAAABGdBTUEAAYagMeiWXwAAACZpVFh0
        VGl0bGUAAABoaQDgpLbgpYDgpLDgpY3gpLfgpJUAUG5nU3VpdGVT/Uu3AAAAPmlUWHRBdXRob3IA
        AABoaQDgpLLgpYfgpJbgpJUAV2lsbGVtIHZhbiBTY2hhaWsgKHdpbGxlbUBzY2hhaWsuY29tKc9N
        fecAAABoaVRYdENvcHlyaWdodAAAAGhpAOCkleClieCkquClgOCksOCkvuCkh+CknwDgpJXgpYng
        pKrgpYDgpLDgpL7gpIfgpJ8gV2lsbGVtIHZhbiBTY2hhaWssIDIwMTEg4KSV4KSo4KS+4KSh4KS+
        3xTVhQAAAmVpVFh0RGVzY3JpcHRpb24AAABoaQDgpLXgpL/gpLXgpLDgpKMA4KSV4KSw4KSo4KWH
        IOCkleClhyDgpLLgpL/gpI8gUE5HIOCkquCljeCksOCkvuCksOClguCkqiDgpJXgpYcg4KS14KS/
        4KSt4KS/4KSo4KWN4KSoIOCksOCkguCklyDgpKrgpY3gpLDgpJXgpL7gpLAg4KSq4KSw4KWA4KSV
        4KWN4KS34KSjIOCkrOCkqOCkvuCkr+CkviDgpJvgpLXgpL/gpK/gpYvgpIIg4KSV4KS+IOCkj+Ck
        lSDgpLjgpYfgpJ8g4KSV4KS+IOCkj+CklSDgpLjgpILgpJXgpLLgpKguIOCktuCkvuCkruCkv+Ck
        siDgpJXgpL7gpLLgpYcg4KSU4KSwIOCkuOCkq+Clh+Ckpiwg4KSw4KSC4KSXLCDgpKrgpYjgpLLg
        pYfgpJ/gpYfgpKEg4KS54KWI4KSCLCDgpIXgpLLgpY3gpKvgpL4g4KSa4KWI4KSo4KSyIOCkleCl
        hyDgpLjgpL7gpKUg4KSq4KS+4KSw4KSm4KSw4KWN4KS24KS/4KSk4KS+IOCkuOCljeCkteCksOCl
        guCkquCli+CkgiDgpJXgpYcg4KS44KS+4KSlLiDgpLjgpK3gpYAg4KSs4KS/4KSfIOCkl+CkueCk
        sOCkvuCkiCDgpJXgpLLgpY3gpKrgpKjgpL4g4KSV4KWHIOCkheCkqOClgeCkuOCkvuCksCDgpJXg
        pYAg4KSF4KSo4KWB4KSu4KSk4KS/IOCkpuClgCDgpK7gpYzgpJzgpYLgpKYg4KS54KWI4KSCLvrU
        kQYAAACRaVRYdFNvZnR3YXJlAAAAaGkA4KS44KWJ4KSr4KWN4KSf4KS14KWH4KSv4KSwAOCkj+Ck
        lSBOZVhUc3RhdGlvbiAicG5tdG9wbmcgJ+CkleCkviDgpIngpKrgpK/gpYvgpJcg4KSV4KSwIOCk
        sOCkguCklyDgpKrgpLAg4KSs4KSo4KS+4KSv4KS+IOCkl+Ckr+Ckvi4VxVHXAAAAQmlUWHREaXNj
        bGFpbWVyAAAAaGkA4KSF4KS44KWN4KS14KWA4KSV4KSw4KSjAOCkq+CljeCksOClgOCkteClh+Ck
        r+CksC4tT0C7AAAAYElEQVQokWP4/19Q8P9/Y2MXl9DQtLTycgayBJSU/v+HcTs6yBMAARh35kzy
        BFxc/v8HO4kByGUgTyA09P9/sJMYVq0iTwDJSRBAhgCMCzLwzBnyBGDc3bsZGO7eJUsAAEBI89kM
        zfvBAAAAAElFTkSuQmCC
        """),
        "cs3n3p08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        AwMDo5KgQgAAAFRQTFRFkv8AAP+SAP//AP8AANv/AP9t/7YAAG3/tv8A/5IA2/8AAEn//yQA/wAA
        JP8ASf8AAP/bAP9JAP+2//8AAP8kALb//9sAAJL//20AACT//0kAbf8A33ArFwAAAEtJREFUeJyF
        yscBggAAALGzYldUsO2/pyMk73SGGE7QF3pDe2gLzdADHA7QDqIfdIUu0AocntAIbaAFdIdu0BIc
        1tAEvaABOkIf+AMiQDPhd/SuJgAAAABJRU5ErkJggg==
        """),
        "bgai4a08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAQAAAGudILpAAAABGdBTUEAAYagMeiWXwAAAI1JREFU
        eJztj80KgzAMx3+BHvTWvUH7KPbB9yhzT7Dt5LUeHBWiEkFWhpgQGtL/RyIZOhLJ3Zli2UgOJAvz
        gECcs/ygoZsDyb7wA5Hoek2pMpAXeDw3VaVbMHTUADx/biG5Wbt+Lve2LD4W4FKoZnFYQQZovtmq
        d8+kNR2sMG8wBU6wwQlOuDb4hw2OCozsTz0JHVlVXQAAAABJRU5ErkJggg==
        """),
        "basi3p08": blob("""
        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
        """),
        "g05n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAABGdBTUEAANbY1E9YMgAAAB5QTFRF
        AAAAAP//zMwA/8z/AK6u/wD/i4sA//////8A/4v/c+IkkgAAAFtJREFUeJxj6ACCUCBwAQJBIGBA
        FmAAAfqoUAKCmUAAV4EsQEcVaUBgDARwFcgClKkwMHZxYEFWwWDswuKAQwUIlJcXlMNVIAsgqWBg
        ZwFqQVJRXg53B7IAmSoA1Ah4O0rtoFUAAAAASUVORK5CYII=
        """),
        "g04n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAABGdBTUEAAK/INwWK6QAAAB5QTFRF
        AAAAAP///9T/1NQA/wD/ALq6//////8A/5v/m5sAIugsggAAAGhJREFUeJy9zsEJgDAQRNEhsLnb
        gaQFW7CAXOae07ZgC7Zgt04IhPWq4D8Oj2VxqF1RLQpxQO8fsalTTRGHH8WlipoiDt8ECqsFsZZE
        q48biaxD9NybkzbEGLILBNGQDYjCff4Rh5fiBou1fg11pxGVAAAAAElFTkSuQmCC
        """),
        "bgan6a16": blob("""
        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
        27XzAAAAAElFTkSuQmCC
        """),
        "f04n0g08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAAAAABWESUoAAAA1ElEQVR4nIXRwW3CMBSA4d/2s81M
        naFiBqQOwA0pp26A1EsnqJQtWAtCIebAAdsP2zlEetGn/9mKfG/iJsYYQwjeey/eiXPOWWuNMQYj
        Z1qPBUySpQmeQi5tgAV6BbAjgB0BrFz7QBW2nCqgCtUH+S/GLw3qwl+1syxMUN+qWsFRgVs2/OhA
        XTioX5MXZlhg4re5gt0FoKjIPZ+W7P0WzABMHFsrytITrC/x4UMMcWYfs1PIHdUoD7mixFKDUnwG
        DfSWDKSBkERfSKIvJNEXwkAIA/EAFiZMByGZYIEAAAAASUVORK5CYII=
        """),
        "ct0n0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAACT4cgpAAAABGdBTUEAAYagMeiWXwAAAMhJREFU
        eJxd0cENwjAMBVAfKkAI8AgdoSOwCiNU4sgFMQEbMAJsUEZgA9igRj2VAp/ESVHiHCrnxXXtlGAW
        JXFrgQ1InvGaiKnxtIBtAvd/zQj8teDfnwnRjT0sFLhm7E9LCucHoNB0jsAoyO8F5JLXHqbtRgs7
        6FC6gK++e3hw510DOYcvB3CPKiQo7CrpeezVg6DX/h7a6efoQPdDvCASCWPUcRaei07bVSOEKTEx
        ty6NgRVyEOTwZgMX5DCwgeRnaCilgXT9AB7ZwkX4/4lrAAAAAElFTkSuQmCC
        """),
        "ct1n0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAACT4cgpAAAABGdBTUEAAYagMeiWXwAAAA50RVh0
        VGl0bGUAUG5nU3VpdGVPVc9MAAAAMXRFWHRBdXRob3IAV2lsbGVtIEEuSi4gdmFuIFNjaGFpawoo
        d2lsbGVtQHNjaGFpay5jb20pjsxHHwAAADh0RVh0Q29weXJpZ2h0AENvcHlyaWdodCBXaWxsZW0g
        dmFuIFNjaGFpaywgU2luZ2Fwb3JlIDE5OTUtOTaEUAQ4AAAA+3RFWHREZXNjcmlwdGlvbgBBIGNv
        bXBpbGF0aW9uIG9mIGEgc2V0IG9mIGltYWdlcyBjcmVhdGVkIHRvIHRlc3QgdGhlCnZhcmlvdXMg
        Y29sb3ItdHlwZXMgb2YgdGhlIFBORyBmb3JtYXQuIEluY2x1ZGVkIGFyZQpibGFjayZ3aGl0ZSwg
        Y29sb3IsIHBhbGV0dGVkLCB3aXRoIGFscGhhIGNoYW5uZWwsIHdpdGgKdHJhbnNwYXJlbmN5IGZv
        cm1hdHMuIEFsbCBiaXQtZGVwdGhzIGFsbG93ZWQgYWNjb3JkaW5nCnRvIHRoZSBzcGVjIGFyZSBw
        cmVzZW50Lk0JDWsAAAA5dEVYdFNvZnR3YXJlAENyZWF0ZWQgb24gYSBOZVhUc3RhdGlvbiBjb2xv
        ciB1c2luZyAicG5tdG9wbmciLmoSZHkAAAAUdEVYdERpc2NsYWltZXIARnJlZXdhcmUuX4AsSgAA
        AMhJREFUeJxd0cENwjAMBVAfKkAI8AgdoSOwCiNU4sgFMQEbMAJsUEZgA9igRj2VAp/ESVHiHCrn
        xXXtlGAWJXFrgQ1InvGaiKnxtIBtAvd/zQj8teDfnwnRjT0sFLhm7E9LCucHoNB0jsAoyO8F5JLX
        HqbtRgs76FC6gK++e3hw510DOYcvB3CPKiQo7CrpeezVg6DX/h7a6efoQPdDvCASCWPUcRaei07b
        VSOEKTExty6NgRVyEOTwZgMX5DCwgeRnaCilgXT9AB7ZwkX4/4lrAAAAAElFTkSuQmCC
        """),
        "f04n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAADoElEQVR4nK2WzY4bRRSFv1tV/ed2
        25SigSgiCx6AF+AJ2CTvAXv27Fmxy1vwAKyyZ8kqQooQUQQsBjwzjstjuy+Lqm6XPWPLIFpH1q3q
        dp+qW+ee206pqSvqOqGpH4//262mdn89V2/WVOxRn4jzYQEFOLBgSJdCD1vYwgYMCG7xDJx6t6bk
        ANVlw0jj0uv2NDvYgsEtPlZKoVBfrdO6cpQXz4y7OaRxiydKpdRCpb4JaTkJmoIii0/Oa4otGEU0
        0ribudIIjTIRGvVtwHIO7uK78QxuOpgoE6FVpkKrvgsY/gXsubvutoEWWqUTpspM6NTPA8L/AndX
        KRU0MIEpdMpcmKv3K9AMgIq8BlRfHs0/iEfZqnt3Rxv3gE6RKXToDOnQuQ/5asbrDwKDXuL8wxgQ
        MOB+X2qNxA00aItMBrIW7XwY8/mFvIkE7wmXH5D7c0mFjkXaQA3NkLMGbf3KonbY+A/6+TvSzKM4
        Upm7XmqBFPsi1QqpiKxSQ4U2Pnwrt5HgV8JBqYz1cAp/f8ChFin2TyfKAi2REoph+V/r1VvC+bo+
        mne3qyhlNUi2NbWIA4s65KfPtpHgF8J5x3o445arJACDDoGMQ5N55fNr+4ZVheaoj4dH5qsuBM0l
        mPSeDfoXKXi/2AHi77ZyB3yqT2u2NbsMfU3fHA4d61IROaw/xUjSscA1YF9/wsKAUQz8BgSuLmkg
        jlDEN8Z8SHIWq8llbCTQm6vBzFwkWPFUKTNUmiU/DpXScW/Zv8sqVpIljkqLifr5KI9L+XEJT/Sr
        8+3CcS+HbuuUQpK44x/OXYFnj6l/XxiRYJDPAUdSnXzzJW3NtGJa09Uyq/sX3wPm7XfMm0B7tj9Y
        xybaXn7I8QzGTVRQSbKPRpkkqS0+gqnSrnynmCMwBI5NDybz2JHDZCdRKKUkkTTpwcUMpjBTuuDn
        pxqCYxfbc4QeGjp56oa8VfLqFV3HTWogMFfmwftHD8mx2aaX74ZvjQ1sYA1rCLCCD7CEBo0eOzQQ
        pgPFDO1Yzb0KewAGx3ZHvofxs+ke7iFAGCzmyNAnENvtJJFpS+j8cU+m72FITw8WduCGfThYZ/qu
        BrITDUQbQutzHTm0pwcBBZPlysI2+xIp2MtqrJAy4xvtrSI0fiwJhyrapzOPmzBDrmympoNazCgf
        Y9WCVeW1QAtc0oz2jPUQaQR2g92ZIcgpzYOqcgcrCIWnTFbzgIPsNw+OyjEP8qUMCwrW/wPZ2mq+
        jvKj/AAAAABJRU5ErkJggg==
        """),
        "tbbn2c16": blob("""
        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
        """),
        "cten0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAACT4cgpAAAABGdBTUEAAYagMeiWXwAAABlpVFh0
        VGl0bGUAAABlbgBUaXRsZQBQbmdTdWl0ZdWsxR4AAAA4aVRYdEF1dGhvcgAAAGVuAEF1dGhvcgBX
        aWxsZW0gdmFuIFNjaGFpayAod2lsbGVtQHNjaGFpay5jb20pRVcgpAAAAEFpVFh0Q29weXJpZ2h0
        AAAAZW4AQ29weXJpZ2h0AENvcHlyaWdodCBXaWxsZW0gdmFuIFNjaGFpaywgQ2FuYWRhIDIwMTHS
        6zPBAAABDGlUWHREZXNjcmlwdGlvbgAAAGVuAERlc2NyaXB0aW9uAEEgY29tcGlsYXRpb24gb2Yg
        YSBzZXQgb2YgaW1hZ2VzIGNyZWF0ZWQgdG8gdGVzdCB0aGUgdmFyaW91cyBjb2xvci10eXBlcyBv
        ZiB0aGUgUE5HIGZvcm1hdC4gSW5jbHVkZWQgYXJlIGJsYWNrJndoaXRlLCBjb2xvciwgcGFsZXR0
        ZWQsIHdpdGggYWxwaGEgY2hhbm5lbCwgd2l0aCB0cmFuc3BhcmVuY3kgZm9ybWF0cy4gQWxsIGJp
        dC1kZXB0aHMgYWxsb3dlZCBhY2NvcmRpbmcgdG8gdGhlIHNwZWMgYXJlIHByZXNlbnQufjUNRAAA
        AEdpVFh0U29mdHdhcmUAAABlbgBTb2Z0d2FyZQBDcmVhdGVkIG9uIGEgTmVYVHN0YXRpb24gY29s
        b3IgdXNpbmcgInBubXRvcG5nIi7EGQUHAAAAJGlUWHREaXNjbGFpbWVyAAAAZW4ARGlzY2xhaW1l
        cgBGcmVld2FyZS7TvjIJAAAATElEQVQokWP4DwbGxi4uoaFpaeXlDGQJKCkhuB0d5An8/4/gzpxJ
        ngDcSRBAlgAIQAxctYo8AYSTwFyyBBDc3bvPnCFPAMGFeo50AQDds/NRVdY0lwAAAABJRU5ErkJg
        gg==
        """),
        "basn0g01": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgAQAAAABbAUdZAAAABGdBTUEAAYagMeiWXwAAAFtJREFU
        eJwtzLEJAzAMBdHr0gSySiALejRvkBU8gsGNCmFFB1Hx4IovqurSpIRszqklUwbnUzRXEuIRsiG/
        SyY9G0JzJSVei9qynm9qyjBpLp0pYW7pbzBl8L8fEIdJL9AvFMkAAAAASUVORK5CYII=
        """),
        "tm3n3p02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgAgMAAAAOFJJnAAAADFBMVEUAAP8AAP8AAP8AAP+1n0PO
        AAAAA3RSTlMAVaoLuSc5AAAAFElEQVR4XmNkAIJQIB4sjFWDiwEAKxcVYRYzLkEAAAAASUVORK5C
        YII=
        """),
        "g03n0g16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAAAAAAGgflrAAAABGdBTUEAAIi4vcVJsAAAARBJREFU
        eJy11U0KwjAQBeBXrFpFUCjFXcFTNJfwtF4itxBcCCKCpeJfbXUhQTMTE0N0FoEZ6Os3pbTR/Q6t
        okjvpdT7otD7uGn0wXwOa9EbsIAsswdQMQsYjwMFo1GgYDgMFAwGnoLbTR/0+4GCJAkU9HqBAtcK
        TkG36ynwXeH/AlcAE9T1jwVxrPdt6ymgr/Ll4hDQACqgAU4BDaDFBNerX8DXgtkMWC7VVAj1eWUC
        umOnAwB5vlqpExBCSnUygXmF9fq9k9IiOJ9NAgCYTjcbtYBFQFdQzyBNdzsYiglOJ5NgMgHSFNjv
        hZDyfQUmOB5NAVWl+udlrx8cExwOpoDPxQRl6RfABNttoGCxCBM8AHUVjIYrRN23AAAAAElFTkSu
        QmCC
        """),
        "basn2c16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAIAAACsiDHgAAAABGdBTUEAAYagMeiWXwAAAOVJREFU
        eJzVlsEKgzAQRKfgQX/Lfrf9rfaWHgYDkoYmZpPMehiGReQ91qCPEEIAPi/gmu9kcnN+GD0nM1/O
        4vNad7cC6850KHCiM5fz7fJwXdEBYPOygV/o7PICeXSmsMA/dKbkGShD51xsAzXo7DIC9ehMAYG7
        6MypZ6ANnfNJG7BAZx8uYIfOHChgjR4F+MfuDx0AtmfnDfREZ+8m0B+9m8Ao9Chg9x0Yi877jTYw
        A529WWAeerPAbPQoUH8GNNA5r9yAEjp7sYAeerGAKnoUyJ8BbXTOMxvwgM6eCPhBTwS8oTO/5kL+
        Xge7xOwAAAAASUVORK5CYII=
        """),
        "s40n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACgAAAAoBAMAAAB+0KVeAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAAHVJREFUeJzN0LENgDAMRNFDiiwhlqBhiGxFNkifJagyBwWDEagQ/kXoSOHiyVZOp1K1HKnU
        +Jhi3BBHQCFGjxnRAGVRHms3Xq8LC51/Qurz99iacDg3tDcqpCyHbRLipgBXQk0ed8FHGggpUuCc
        uOnDYyF3dSfnZ1dwSF0UKQAAAABJRU5ErkJggg==
        """),
        "basi4a08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAQAAAGudILpAAAABGdBTUEAAYagMeiWXwAAAI1JREFU
        eJztj80KgzAMx3+BHvTWvUH7KPbB9yhzT7Dt5LUeHBWiEkFWhpgQGtL/RyIZOhLJ3Zli2UgOJAvz
        gECcs/ygoZsDyb7wA5Hoek2pMpAXeDw3VaVbMHTUADx/biG5Wbt+Lve2LD4W4FKoZnFYQQZovtmq
        d8+kNR2sMG8wBU6wwQlOuDb4hw2OCozsTz0JHVlVXQAAAABJRU5ErkJggg==
        """),
        "cs5n3p08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BQUFGCbeQwAAAGBQTFRF/xkAQv8Axf8AAP97AP+9AP//AP8AAMX/AKX//94Apf8AAGP//5wAACH/
        /1oAAP86/zoAY/8A5v8A/wAAAP9aIf8AAP+cAP/eAOb///8AAIT//70AAEL//3sAhP8AAP8ZRy+F
        9QAAAEtJREFUeJyFwQUBwAAAgDDu7u79Wz4CG5NA9YJW8AhqwSUoBIdgFISCUvAKBkEgWASp4BN0
        glkQCVZBLNgEiWAXZIJccAoqwS1oxA/GcT4B7dbxuwAAAABJRU5ErkJggg==
        """),
        "s37n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACUAAAAlBAMAAAA3sD0wAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAAMVJREFUeJxl0S0Og0AQhuEvoU36J+AGDSfYhAsgegAMHoWuq62sxOJWr6rHcAAO1dkppbMz
        D9kRmxB4M0D0kp58hUl6I4SAU5A8+r6jI3WoKmRVwmEcMKYGlPSJMnFFS8++lRosyzLH8TfjRnhs
        ajwIj80dBeGxybnV9J4pUPV6+j/TS3e2V3M69ttrUK/RpKmiV6QylcoKLVerXXMnjd4NGrxqjbW2
        12W2F0fbC9vbwPbOF91Lq96t+xXw26+MjUfFHuh8APqFElFWDb0cAAAAAElFTkSuQmCC
        """),
        "s36n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACQAAAAkBAMAAAATLoWrAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAAHdJREFUeJxjYACBwu5llqpHoCQDFiEgxcCCLmTAcARdiIEVXWgBgyq6ENB0DCEsxlsqYDpC
        lSwhBixCbBjGNwDdhe4ILE5F4lBXCBToqEILgEKMqEIMnKoHGNCEgCQWoULCQgYYNjJgsZGBWBvJ
        E8L0EBZvgwMHAABJBMjTkay+AAAAAElFTkSuQmCC
        """),
        "s01i3p01": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAFS3GZcAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAANQTFRFAAD/injSVwAAAApJREFUeJxjYAAAAAIAAUivpHEAAAAASUVORK5CYII=
        """),
        "g07n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAABGdBTUEAARFwiTtYVgAAAQtJREFU
        eJzVlkEKgzAQRSciiaK49QS5gCsv4EnqsXImryHdlhZtKdhFK1U6HzM0YDvMIowhz+dXUE3ElyJw
        xSl+fuDH8Q0AypKfH8F+AlwIKAohAAhDQJ6jk0BJDbJMCJAaiAFSgzQVAqQGYgAyuIYC7GaAAEki
        BCAD9IjEgJ8zMEYIkL5F/28AAXcwlxoUUgAyGMF+aHAB890yQAZaCwHAIBqJ2DZm1U2jnotXtZwB
        114Gda22nVAGgweg66aqUhsAlAECfIbMxN4SuXn9jQE/adcMYBANRGxr/W5rFRFZq7Sez3XzuUsD
        rmP03Szvt+8X/o74NcrAB+BVKINzKAAyOIUCIAP0MxvK4AEWgFoVP+GhCgAAAABJRU5ErkJggg==
        """),
        "basn0g02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgAgAAAAAcoT2JAAAABGdBTUEAAYagMeiWXwAAAB9JREFU
        eJxjYAhd9R+M8TCIUMIAU4aPATMJH2OQuQcAvUl/gYsJiakAAAAASUVORK5CYII=
        """),
        "basn0g16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAAAAAAGgflrAAAABGdBTUEAAYagMeiWXwAAAF5JREFU
        eJzV0jEKwDAMQ1E5W+9/xtygk8AoezLVKgSj2Y8/OICnuFcTE2OgOoJgHQiZAN2C9kDKBOgW3AZC
        JkC3oD2QMgG6BbeBkAnQLWgPpExgP28H7E/0GTjPfwAW2EvYX64rn9cAAAAASUVORK5CYII=
        """),
        "tbrn2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAABGdBTUEAAYagMeiWXwAAAAZ0Uk5T
        AP8A/wD/N1gbfQAAAAZiS0dEAP8AAAAAMyd88wAABfRJREFUSInNlgtM03cQx7//UmwwRQ1olQYM
        hpEgFZiRRLApqBgQxFAppZRBIiLg6GDI04mFoZRXKZT3+yFBnQynzgFzG8NlIoMwwWUhZgFMNHNO
        EQaDaXyxa8mWEQtiNpNdGkIov/vc3e/uez/MvmHD/whw586d3t7eycnJ/xhw7969tra2tLS0iIiI
        WH//NEfH0x4ePVrtg5GRfwUYHx/v6urKzc2NiopShIYedXXNMzPTACogBcgEqhmmycGhS6kcGRx8
        9uzZUgFTU1NXr14tKyuLj49/X6FI2bUre/36MoZpAIqAD4F4LjfMwUGyYoUYkOt5xcuWHY2MbGxs
        HBgYePz4sWHAo0eP+vr6qqurk5OTExISjoWGZjs6lnA49cBZ4ALQCwwAl4Emhsm3sFDZ26ebm2cA
        5UAhoJBIYmNj6SAdr6mpoRCpAPMA/f396enp9HWS3sqdnD4HPgPagXNcbum2bcVi8WUbmyEW6zYw
        AfwC/KRHfgEoGYZyTfqHRUdHU6zzAMPDwyqVKicnJzMzMzU1VRUQ0GFuftbKSuPndyQpKeUvy1Ao
        WnbsGLK2Hlu16lcud9DM7JSdXWpQ0N//EBcXFxIS4u/v39nZOQ9w//59cp2RkaHKURUUFNDdUkIf
        vI5R9uHh4QEBAWKx2NfX9+7du/MAdDnpmem2FbbsU2zXZld1qbqkpKSwsPDEiROpC9tRvZF3qolM
        Jptz7e3tLZfLDXRRXl4ec4nBNWAK8nZ5cXEx9VJFRUVpaWl2dvaxBezw4cPBwfvt7FRsdgmXe8TO
        LsjT0+f48eMGAOSR+zEXncA0rEesi4qKyDUBqqqqqDHop1qtprql6U2pVFLFDxw4IJHsNzP7Guin
        dgXeBaLs7aWtra0GAOSOd5Kna53bOkZyUzJVSVOh8az39DzjWVBfUF9fX1tbSzdEAKpJcHCwTBa8
        bt33wG9AI4u1n2FEQJiVlXxoaMgAoLm5eUPlBrQA3+kAwj4h5eTT6oOvdLPgVO1UV1fX0NBAA0V1
        J+9U6M2bTwKzwDUjo3csLN7ictdwuVKhUPL06VMDgPb2dkGhAE3U+cADcB5ycstyPc546GasCi5l
        LhQ+JUGMxMRE8i4WRxkbz1D4RkZxLi6eu3fv5vFcBQIpSYCBSSbr6elxznLGRYAU5wfgd/jW+Arr
        hegBKiEqFdFNUBLEoKElgEBwTh/+aVtbuYeHH4+XBjQwTEFt7UnDgJs3b7op3XSAVIDmeBJr1WuF
        tUJdX1VAVCKi4ZxjkPzJZHITk3EKn81WbNkSzOFoAZKVY6amoRSoYQDNmleil64+KphUmmAYOAOb
        Sht8q1Mc92L3yspKYlChwsLCdu5M14d/mc8P5fG89UEp6GNpGTg9PW0YQJIrfk+s07YyOKQ44Bug
        G0wJo/tFiz1Fe+Zalhh0wwJBM/AHkOXkJLGweJvFCgcSgJq9e+Nm59s8uT6UcAh0sBluEW6rT63G
        j4Aa6AIK4KP1mZu78vJyGlo+vw0YBQ65u+8RCARcbgxwiTLIyipeDJCfn29cb0zq7BzpvF21HX26
        6uvaNB/eBd40FsQg/QgMDFy5soPqY2QU6eXl5eR0ELrmqzMxCeru7l4M8OTJE+0FrbPKOexgWHh0
        +LLzy/CJfgmoIdFIaLaJQToolUqXL/+IPHI44c7OIWx2DXCRz9/b1vbl7EtmYGUODg7GxMTQBnYo
        dMCn+p2QC6laSrETgxSXAGvWUFNmMkwEw9D2LLK0jL1+ffBlV4YBZGNjY1lZWUFxQTivr20OJLkS
        jUZDDBpj0uRNm7xZLGobKk74xo2Jt279bNDPgoBZfVO1tLToxIMWZhZk2TISO2LQGEskEpFIxOfb
        mJp6eHnFP3w4sZCTxQBzdmPohkuNC3WtMkNJ+44YVD1aWH5+flu3biVBpWtb3MOr30UTExMkcLR5
        qGjEoDHet28f7Rb64/Pnz195fEkvuxcvXly5coWWNjFojCmDjo6OpRxcKmDORkdHtVotdRc9QZZ+
        6vUevzMzM/RCfa0jb/x1/Sd+IPxqXp1JowAAAABJRU5ErkJggg==
        """),
        "tbbn0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAACT4cgpAAAABGdBTUEAAYagMeiWXwAAAAJ0Uk5T
        AA/mLNCpAAAAAmJLR0QAAKqNIzIAAAFISURBVCiRddExT8JAFMBxPoJHWUxcriQuJiaFqpNLWxkd
        LOVCHJjunSau9GByohwTk8Il+hkcHd0kLrIymLCaOLBq0epdbRRIeNv9pnfvn/temdw6eJktQXJP
        K7cL8BbRklmsjzNInsJquWRjc/8mhc9B6JZt13aLe6z9rGDEm2W7VvU8d5vzcwUTEXqMcxocMd48
        VfAqBM8mDI4VvENr2M3eXkMDE1Km4iO7r+BDgxaKkXGnAURv0JZd6uON/FRBDK1eBHIQOAgX9GJz
        OBO8psA0nIN0UyBdTuS1j228qeELKh0NJ9hCWxoSCCKmwMljtJv+FgJOiLwqGRg1foEyDVbBQv0U
        IspqRHawgnEKMQBoMNBOdsJHBb0ORvlxBkkERDQtdPh35FiDU5j9ZxgRQf3LxS5DQetL5eaCPiyn
        nFystE2m6+r/AOOSVs9bKk33AAAAAElFTkSuQmCC
        """),
        "g25n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAABGdBTUEAA9CQ+FSITwAAAUxJREFU
        eJytlcttAjEQQMeLgSAQ4SPK2I44UAB1oC1gC+BACVQSykB8hIgSSIJzwFq8xE/KSB75MIxn5+lp
        LGGcxMMI3OQmXn+Ll+0WAOoArt2lAoCw3acCkMGB+uED2hkaHFMByIAAWRav3whABiclAIMMkgHI
        4Az9jYYSQAYEsFYJIIP3VAAySAYggw/ob7WUADIgQLOpBJDBJ/S320oAGVy0gB+okwEBXl/ggl4F
        GXxBf6ejBJDBVQugIINv6O92lQAy+A9guTQiMpsFMzYief0DrUGv55OyNPO5C5N4kAG9ugpwz4vC
        PBWfAwyym0j09Pv+iEhRmMXCififj9jUDWLH0l9gOKss3d+in14tg3ZAgMHAJ6uVm07NPXlMzOvT
        hXdAW6sAIrJeB13h4wlzMiDAcAgXFGRA/aOREkAG1D8eKwFag8lECQCDX4gtYR8yuXeNAAAAAElF
        TkSuQmCC
        """),
        "exif2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAD0mVYSWZNTQAqAAAACAAHARIAAwAA
        AAEAAQAAARoABQAAAAEAAABiARsABQAAAAEAAABqASgAAwAAAAEAAgAAAhMAAwAAAAEAAQAAgpgA
        AgAAABcAAAByh2kABAAAAAEAAACKAAAA3AAAAEgAAAABAAAASAAAAAEyMDE3IFdpbGxlbSB2YW4g
        U2NoYWlrAAAABZAAAAcAAAAEMDIyMJEBAAcAAAAEAQIDAJKGAAcAAAAQAAAAzKAAAAcAAAAEMDEw
        MKABAAMAAAAB//8AAAAAAABBU0NJSQAAAFBuZ1N1aXRlAAYBAwADAAAAAQAGAAABGgAFAAAAAQAA
        ASoBGwAFAAAAAQAAATIBKAADAAAAAQACAAACAQAEAAAAAQAAAToCAgAEAAAAAQAAApcAAAAAAAAA
        SAAAAAEAAABIAAAAAf/Y/+AAEEpGSUYAAQEAAAEAAQAA/9sAQwADAgIDAgIDAwMDBAMDBAUIBQUE
        BAUKBwcGCAwKDAwLCgsLDQ4SEA0OEQ4LCxAWEBETFBUVFQwPFxgWFBgSFBUU/9sAQwEDBAQFBAUJ
        BQUJFA0LDRQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFBQU
        /8AAEQgACAAIAwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQ
        AAIBAwMCBAMFBQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYX
        GBkaJSYnKCkqNDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqS
        k5SVlpeYmZqio6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz
        9PX29/j5+v/EAB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQE
        AAECdwABAgMRBAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKSo1
        Njc4OTpDREVGR0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKj
        pKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5+jp6vLz9PX29/j5+v/aAAwD
        AQACEQMRAD8A+7EGoxTRqz3ySM6AuwITn7+fbkf04ooor+Y6k27M66VCLWrb+Z//2QC6iKqDAAAC
        5UlEQVRIib2W3W8SQRDA+a/HEBONGqPGRNP4YNQ3EyUYTUqQKjbVBx5IpbRQwCscl+OA40NCkQbK
        5+HM7ma5u3K5WsBkc5ndvZnf7uzuzAQWC9hqC/wnwMUFGAaUy6INhzRomqKraVCpQLsN4zFYFk1N
        p9Dp0CBOVauk7gMYjUih1QJddwPw22wSHm2hPJnAbEYCdnGw0aAv6l7XRdyoHcBlNFqrkdHLS+j1
        aB1IRRhO4Z64sDEAbhSFfl+4y/8MvpkAKUdLtqA3JuHxsXCRZkAwBXfS5MxI2f0/IlfaOfztDcDx
        J1mST1Vab6JE8luVVn0VgBu9CSBcJPlnm+RYTSigHNX+BYDO3TOok2hBZwiKATkV+szvSZ3GQxrJ
        zwskd8ckt7uQ1yBUEFpFwwFIMPfyNp0zQESlie+a4y6iglEnvz/IQH8Ct1LwNCfODVXwdobzpHWg
        ipstAWnnlQ3M5xBjK/3yS1jHe8KvB8o7JzTF/bNrLNXwoXFHfVVoWd2uN8BrgrcfDZq6naZvoeeY
        uqp1E0B9II4reASj2XoAe5MvyFrAfeall4qb7QWwt5nlB8D2nvl639wa4A17DRFjbYD9/kqdiSVO
        WN5RX4DdjuV7yMU/y+XYwRu7RdEqTT1kQemwswXAs7wIKfh9p20UgM/4lIWQR8dQ1ukd3Duhw+dJ
        AuNzrEKz8bNlzoizBx9XHHl09SFP5mRoj4WzEAsGOxmS9T6NKyrkNPjI8FEFsiUCyJi2X3Lk0dXX
        FH2Chl4z1ys9Uv7MlA9MGg/n3P8jAPPoJ4XkFAvpMo96Auom3E1DME27QUCGhfRXZ54AdNqHwrVD
        BQKyzOKLnCgpyhrjHYFeWw2Q4GRTFCg8j3oWXvaiiNcQmI3lIXOLGKV5NcW7XBgMliWWP4Bfj5Xj
        5+d0mLKOcpUa/Le1ALghLGRkJegqljYAQJnKGU10eR7lLwD/kXl0LQA6BMtT2eUFK0/sMo9uvbr+
        CztK5Y3mPSskAAAAAElFTkSuQmCC
        """),
        "basi6a08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAAEEfUpiAAAABGdBTUEAAYagMeiWXwAAASBJREFU
        eJzFlUFOwzAQRZ+lQbi7smZBuAabhh6LTRLBwRLBRSpxCipl2EDVlJBB/EgeyYrifH8/jSfj5GSA
        R2AP7A0fOQ+74mM6MeKTieTk6nv9vz2aa4AKuJ8b1rVTz8uwZ56WBWPXLgqSk7cze5+YjMZ/Xw4Y
        bSDoCAQvHJcFThMJ2kDQLX4n+S4DbL/GTfD8MRemIQobatGgDfIcGrzyoBlExxAbDLVooAGQnJz5
        45nPPY2dRmCodUBdmmDQALBeLeVeJXgLelJo4GIhGOI5mqsGOoFYCEYvGrhokPwuA+SLsQne19Js
        5L9ZDbkbrABQdH/sUBXOgNoOVwAoG+Uz8M5tWQC1m8sA6m0gAxTPgB+qsgDqdSgDqNepDFA6A5+C
        SlP0aU5zQgAAAABJRU5ErkJggg==
        """),
        "tbwn0g16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAAAAAAGgflrAAAABGdBTUEAAYagMeiWXwAAAAJ0Uk5T
        ///Itd/HAAAAAmJLR0T//xSrMc0AAAS8SURBVEiJY/hPIWCgqQGPH588+fEjWQa8eLF1a11damrU
        Tjf9hB8LBR8JEG3Au3f793d2pqcnTvDZZSaiFaD+Unmr+hy9VwGeE72vbP/zB48Bnz4dOTJ1alFR
        zrzgSbYLdLP0t2s3q2VqLbc5rnRIglFqq/pLA46ctAULzp//8QPNgO/fT52aNausrLg4bZXHY0NO
        /SyjbSYXbALsZM1bDAOtZ7tWGFerbdNl1noZ1Z6XV1xcVjZ79pEj797BDThzpr6+rKwUCPzEzc3N
        mM3m2sSE2qTIBag5zne+6L7dNdAxy07O/IKaWc68UijIypo1C27AnTutrR0dLS3V1ckcLp7u8omv
        yqLLwaCINeFw2N4gEb9Yb1HfVUk3IaIFBTExQUF798INePWqpaWxsd2zr6+zs76+Ei8oK0tODgkJ
        CPDxefYMbsCPH02FGe5JVypsJtyYPLm/v7m5GgNUAUFlZVZWeDhIs6dnZCRKLHR1ZV4pmdXXPEF2
        0qSpU6dPnzKlvb0GDRQWRnMb3RQpkSjTXeO2p6kJxYBJkzLX5fv2b+zPnThxypTp02fOnD175szu
        7vr6OiCorS0vT0oKuaR6XbxY4ASPEPd1fek1a1AMmDIl/WMWQ6t4/8YJ8ZMnTy6skqxPnf5r3rw5
        c/r66uqysqKiwtfrPJOeLpTCc4H9Obe6CvO1aygGLFmSbpoiW3oc6IbCSZNaGPK2JbflGc2dO3/+
        ggVVVVFRkZF2grIBYod4FaVieUVFCmz//v6NYsC2bWn88empD7tS+ionzKpTL4uLksr7M2fOvHnz
        55eUREYGfVWYLT2dv8vyioeHlIz+/6IitKR8/HhKXYZNMGf16n6pqkulHaWGkc0FlbNnz507b15e
        XmSklYxsgLCotrzLEiUuIXdBs7n6aAbcuJEckWHjkZ8T3fsmOr0kqmRWxJv8R7NmgYxITw+fpBwD
        tP+2+XqxY0KafI5i9sePoxnw6lXi8dSHfsGx9o19SREZnEXXIkILFGbMmDVrzpzERE9X2QBRF8Vz
        0p/5lHl8eXyVjn/5gmbAnz8JZ5PbwvdHHCxcUcIc9rtwRcjZkhZQdM6aFRVlKSLjzp9hHCS9j1eD
        10LwUmAwluyc9yhhSsKUUNPMipobgbcLqoLnFzeDktS0aeHh2q8lW7m/OizQ1hY3EpnM49v+HIsB
        PT3x8ulLA5dlPCr7GvEmb1tQUeHryZOnTu3vDwtTihd14Utxdzd1F5ovxCMkd/QoFgN+/Vqckfw8
        WTW9KbMnrSLnU+Dt0uqJEydP7uwMDZUxFuIRnGVxVjReJFL++7a0//+xGAACFy7k5qampj3OuJyt
        F7CuVKm/f+LExsbQUEV1fl2eBgEBgdWqnec5///HacD//2/etLWlVaXzZWYGiBcr9Pb291dVhYTo
        N/KJcNdzJxqeeDDh/3+8BoDiY9WqdNP0pX4vi2d3d/f2lpQEB9vaSisLO/lYvNNAV42jWL9yuKg1
        4mD9jY6O7u7c3KAgf39z8/LyX7+wqcVRL7x/v2BBc3NbW0dHenpgYEDAggV//2JXibNm+vfvwIHW
        1ra2xMSgoO3bcakiULXduzdhQmrqmTP41BCoXL9+ffwYvwqKa2cA4MyW1TM3HhMAAAAASUVORK5C
        YII=
        """),
        "z03n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAAr0lEQVR4XrXR3Q5AMAwF4Epc8P4P
        y91sIgxb15/TRUSC76Q9U0q0U7m28/5/Zl7Vv/Q+mwsZeJbQgIUoB+Q5Q07RidagCS79nADfwaNH
        BLx0eAdfHdtBQweuqK2jAro6JIDT/SUPdGfJY92zIpFuDpDqtg4UuqEDna5dkVpXBVh0eQdGXdiB
        XZesyKUPA7w6HwDQmZIxeq9kmN5cEVL/B4D1Twd4ve4gRL9XFKXngANVk05u39tDGQAAAABJRU5E
        rkJggg==
        """),
        "s08n3p02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAgMAAAC5YVYYAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAxQTFRFAP//dwD/d/8A/wAAqrpZHAAAABtJREFUeJxjYGBg0FrBoP+DQbcChIAM
        IJeBAQA9VgU9+UwQEwAAAABJRU5ErkJggg==
        """),
        "s09n3p02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJAgMAAACd/+6DAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAxQTFRFAP8AAHf//wD//3cA/1YAZAAAAB9JREFUeJxjYAAC+/8MDFarGRgso4FY
        GkKD+CBxIAAAaWUFw2pDfyMAAAAASUVORK5CYII=
        """),
        "pp0n6a08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAAYagMeiWXwAAAohQTFRF
        AAAAAAAzAABmAACZAADMAAD/ADMAADMzADNmADOZADPMADP/AGYAAGYzAGZmAGaZAGbMAGb/AJkA
        AJkzAJlmAJmZAJnMAJn/AMwAAMwzAMxmAMyZAMzMAMz/AP8AAP8zAP9mAP+ZAP/MAP//MwAAMwAz
        MwBmMwCZMwDMMwD/MzMAMzMzMzNmMzOZMzPMMzP/M2YAM2YzM2ZmM2aZM2bMM2b/M5kAM5kzM5lm
        M5mZM5nMM5n/M8wAM8wzM8xmM8yZM8zMM8z/M/8AM/8zM/9mM/+ZM//MM///ZgAAZgAzZgBmZgCZ
        ZgDMZgD/ZjMAZjMzZjNmZjOZZjPMZjP/ZmYAZmYzZmZmZmaZZmbMZmb/ZpkAZpkzZplmZpmZZpnM
        Zpn/ZswAZswzZsxmZsyZZszMZsz/Zv8AZv8zZv9mZv+ZZv/MZv//mQAAmQAzmQBmmQCZmQDMmQD/
        mTMAmTMzmTNmmTOZmTPMmTP/mWYAmWYzmWZmmWaZmWbMmWb/mZkAmZkzmZlmmZmZmZnMmZn/mcwA
        mcwzmcxmmcyZmczMmcz/mf8Amf8zmf9mmf+Zmf/Mmf//zAAAzAAzzABmzACZzADMzAD/zDMAzDMz
        zDNmzDOZzDPMzDP/zGYAzGYzzGZmzGaZzGbMzGb/zJkAzJkzzJlmzJmZzJnMzJn/zMwAzMwzzMxm
        zMyZzMzMzMz/zP8AzP8zzP9mzP+ZzP/MzP///wAA/wAz/wBm/wCZ/wDM/wD//zMA/zMz/zNm/zOZ
        /zPM/zP//2YA/2Yz/2Zm/2aZ/2bM/2b//5kA/5kz/5lm/5mZ/5nM/5n//8wA/8wz/8xm/8yZ/8zM
        /8z///8A//8z//9m//+Z///M////Y7C7UQAAAFVJREFUeJzt0DEKwDAMQ1EVPCT3v6BvogzO1KVL
        QcsfNBgMeuixLcnrlf1x//WzS2pJjgUAAAADyPWrwgMAAABgAMF+VXgAAAAAXIAdS3U3AAAAooAD
        G8P2VRMVDwMAAAAASUVORK5CYII=
        """),
        "cs8n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAABGdBTUEAAYagMeiWXwAAAExJREFU
        eJzt1UENADAMQlGa4GPzr2pT0olo/mkgoO9EqRYba9HADhBgmGq4CL7sffkECDBNie6B4EGw4F8R
        4AOgBA+CBQ+CdQIEGOYB69wUb0ah5KoAAAAASUVORK5CYII=
        """),
        "f99n0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAACT4cgpAAABcUlEQVR4nHVRsU4CQRDd5Y5kj2oX
        tDi7u1IbNFRWiom1iYk/IMYfMIpfQPwCPf0CobAzAQmxMkaOxMLCgl3srNzdCtaCrLNgMEGdu8zt
        7cy8eW/GQ3PmT7xXpsj2n2e3C3snYAeb7oxdfDdmkKFEF3IycLEVRwwsH5dcFGDKS2EYBAFCJvvm
        QMt5xjCUIBvJe5dzmDTaaa+fdlvJcRFAF/fjmDKIKCvE000GrTIG/wxezFgBQEvLYY5ARmCIRurB
        9xiUOTaIKipZEfnVqzaX0lopebdZ28DZo7Vo2lYrJXkzM+VPvx2w8NbDfECAJjLQWXF/fh4oe9pI
        BWAC6kfaOt/5DWqt1giUIefh7OGVkGFMjEF2ZN5lzx8rJ9yhaXgUzGz7rJFy4Mp52rqo/CVfKqu0
        0nbyGYB8W8gR+kkMtB2KWzfTTkQpU473oD8lu11NLuv166RW+W9R446QQgzEZLmeqxm+kpGSL48/
        2x/fzdR/AW8Fs1uE53SkAAAAAElFTkSuQmCC
        """),
        "ps2n0g08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAAAAABWESUoAAAABGdBTUEAAYagMeiWXwAACHpzUExU
        c2l4LWN1YmUAEAAAAAAAAAD/AAAAAAAAADMA/wAAAAAAAABmAP8AAAAAAAAAmQD/AAAAAAAAAMwA
        /wAAAAAAAAD/AP8AAAAAADMAAAD/AAAAAAAzADMA/wAAAAAAMwBmAP8AAAAAADMAmQD/AAAAAAAz
        AMwA/wAAAAAAMwD/AP8AAAAAAGYAAAD/AAAAAABmADMA/wAAAAAAZgBmAP8AAAAAAGYAmQD/AAAA
        AABmAMwA/wAAAAAAZgD/AP8AAAAAAJkAAAD/AAAAAACZADMA/wAAAAAAmQBmAP8AAAAAAJkAmQD/
        AAAAAACZAMwA/wAAAAAAmQD/AP8AAAAAAMwAAAD/AAAAAADMADMA/wAAAAAAzABmAP8AAAAAAMwA
        mQD/AAAAAADMAMwA/wAAAAAAzAD/AP8AAAAAAP8AAAD/AAAAAAD/ADMA/wAAAAAA/wBmAP8AAAAA
        AP8AmQD/AAAAAAD/AMwA/wAAAAAA/wD/AP8AAAAzAAAAAAD/AAAAMwAAADMA/wAAADMAAABmAP8A
        AAAzAAAAmQD/AAAAMwAAAMwA/wAAADMAAAD/AP8AAAAzADMAAAD/AAAAMwAzADMA/wAAADMAMwBm
        AP8AAAAzADMAmQD/AAAAMwAzAMwA/wAAADMAMwD/AP8AAAAzAGYAAAD/AAAAMwBmADMA/wAAADMA
        ZgBmAP8AAAAzAGYAmQD/AAAAMwBmAMwA/wAAADMAZgD/AP8AAAAzAJkAAAD/AAAAMwCZADMA/wAA
        ADMAmQBmAP8AAAAzAJkAmQD/AAAAMwCZAMwA/wAAADMAmQD/AP8AAAAzAMwAAAD/AAAAMwDMADMA
        /wAAADMAzABmAP8AAAAzAMwAmQD/AAAAMwDMAMwA/wAAADMAzAD/AP8AAAAzAP8AAAD/AAAAMwD/
        ADMA/wAAADMA/wBmAP8AAAAzAP8AmQD/AAAAMwD/AMwA/wAAADMA/wD/AP8AAABmAAAAAAD/AAAA
        ZgAAADMA/wAAAGYAAABmAP8AAABmAAAAmQD/AAAAZgAAAMwA/wAAAGYAAAD/AP8AAABmADMAAAD/
        AAAAZgAzADMA/wAAAGYAMwBmAP8AAABmADMAmQD/AAAAZgAzAMwA/wAAAGYAMwD/AP8AAABmAGYA
        AAD/AAAAZgBmADMA/wAAAGYAZgBmAP8AAABmAGYAmQD/AAAAZgBmAMwA/wAAAGYAZgD/AP8AAABm
        AJkAAAD/AAAAZgCZADMA/wAAAGYAmQBmAP8AAABmAJkAmQD/AAAAZgCZAMwA/wAAAGYAmQD/AP8A
        AABmAMwAAAD/AAAAZgDMADMA/wAAAGYAzABmAP8AAABmAMwAmQD/AAAAZgDMAMwA/wAAAGYAzAD/
        AP8AAABmAP8AAAD/AAAAZgD/ADMA/wAAAGYA/wBmAP8AAABmAP8AmQD/AAAAZgD/AMwA/wAAAGYA
        /wD/AP8AAACZAAAAAAD/AAAAmQAAADMA/wAAAJkAAABmAP8AAACZAAAAmQD/AAAAmQAAAMwA/wAA
        AJkAAAD/AP8AAACZADMAAAD/AAAAmQAzADMA/wAAAJkAMwBmAP8AAACZADMAmQD/AAAAmQAzAMwA
        /wAAAJkAMwD/AP8AAACZAGYAAAD/AAAAmQBmADMA/wAAAJkAZgBmAP8AAACZAGYAmQD/AAAAmQBm
        AMwA/wAAAJkAZgD/AP8AAACZAJkAAAD/AAAAmQCZADMA/wAAAJkAmQBmAP8AAACZAJkAmQD/AAAA
        mQCZAMwA/wAAAJkAmQD/AP8AAACZAMwAAAD/AAAAmQDMADMA/wAAAJkAzABmAP8AAACZAMwAmQD/
        AAAAmQDMAMwA/wAAAJkAzAD/AP8AAACZAP8AAAD/AAAAmQD/ADMA/wAAAJkA/wBmAP8AAACZAP8A
        mQD/AAAAmQD/AMwA/wAAAJkA/wD/AP8AAADMAAAAAAD/AAAAzAAAADMA/wAAAMwAAABmAP8AAADM
        AAAAmQD/AAAAzAAAAMwA/wAAAMwAAAD/AP8AAADMADMAAAD/AAAAzAAzADMA/wAAAMwAMwBmAP8A
        AADMADMAmQD/AAAAzAAzAMwA/wAAAMwAMwD/AP8AAADMAGYAAAD/AAAAzABmADMA/wAAAMwAZgBm
        AP8AAADMAGYAmQD/AAAAzABmAMwA/wAAAMwAZgD/AP8AAADMAJkAAAD/AAAAzACZADMA/wAAAMwA
        mQBmAP8AAADMAJkAmQD/AAAAzACZAMwA/wAAAMwAmQD/AP8AAADMAMwAAAD/AAAAzADMADMA/wAA
        AMwAzABmAP8AAADMAMwAmQD/AAAAzADMAMwA/wAAAMwAzAD/AP8AAADMAP8AAAD/AAAAzAD/ADMA
        /wAAAMwA/wBmAP8AAADMAP8AmQD/AAAAzAD/AMwA/wAAAMwA/wD/AP8AAAD/AAAAAAD/AAAA/wAA
        ADMA/wAAAP8AAABmAP8AAAD/AAAAmQD/AAAA/wAAAMwA/wAAAP8AAAD/AP8AAAD/ADMAAAD/AAAA
        /wAzADMA/wAAAP8AMwBmAP8AAAD/ADMAmQD/AAAA/wAzAMwA/wAAAP8AMwD/AP8AAAD/AGYAAAD/
        AAAA/wBmADMA/wAAAP8AZgBmAP8AAAD/AGYAmQD/AAAA/wBmAMwA/wAAAP8AZgD/AP8AAAD/AJkA
        AAD/AAAA/wCZADMA/wAAAP8AmQBmAP8AAAD/AJkAmQD/AAAA/wCZAMwA/wAAAP8AmQD/AP8AAAD/
        AMwAAAD/AAAA/wDMADMA/wAAAP8AzABmAP8AAAD/AMwAmQD/AAAA/wDMAMwA/wAAAP8AzAD/AP8A
        AAD/AP8AAAD/AAAA/wD/ADMA/wAAAP8A/wBmAP8AAAD/AP8AmQD/AAAA/wD/AMwA/wAAAP8A/wD/
        AP8AAJbQi4YAAABBSURBVHicY2RgJAAUCMizDAUFjA8IKfj3Hz9geTAcFDDKEZBnZKJ5XAwGBYyP
        8Mr+/8/4h+ZxMRgUMMrglWVkBABQ5f5xNeLYWQAAAABJRU5ErkJggg==
        """),
        "s34i3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACIAAAAiBAMAAAG/biZnAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAANJJREFUeJx9jr0KgzAURr9q/elbdJGu4mTAQR+pa6eAW+yQxV06ODs5CxX0sWrURHstDcnH
        4eTe3ABxBz6d5+74b8S7zcck72D7KvMx4XPaHfC4vVCpeP0OS0W1hAg9EQ0imqZhWElEm/OMm28t
        TdwQQkPzOrVl1pYpWplpcjQ1ME6aulKTawhbXUnI0dRsZG5hyJVHUr9bX5Hp8tl7UbOgXxJFHaL/
        NhUCYsBwJl0soO9QA5ddSc00vD90/TOgprpQA9rFXWpQMxAzLzIdh/+g/wDxGv/uWt+IKQAAAABJ
        RU5ErkJggg==
        """),
        "s35i3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACMAAAAjBAMAAAGb8J78AAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAAQRJREFUeJxlkD2uglAUhMf4A1GL93ZAWIHJ2YCFC7Cxt7Kmo7WktLWjprJ/DQu4i3pzzuUA
        F4fwk5k7+SYAzRN96CFyQsPvEIC80ZcIDf04iYZ5HmOeZaQOYzoxDRY05og7MCePDtQ5Al2770wo
        UEahrrPahBaeluWUqiqmMWqBMS2GtEYGHR4XdK2flLVI3OO0AqE/hrjXuRWb3sVIEfHuRLMifxEG
        bsauFdl/Dk1NvTsthXeDdytUMP3N9MHjcec90x3vF96JXrjx2t5muuJC2cN1xi9lD9cPcCBjQeSG
        JXEpEhMYdU1hm5E4wlZGTGAHFj9IYTsd8A1MiVujzokXHXH+B9CK7qGbaRQOAAAAAElFTkSuQmCC
        """),
        "ctzn0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAACT4cgpAAAABGdBTUEAAYagMeiWXwAAAA50RVh0
        VGl0bGUAUG5nU3VpdGVPVc9MAAAAMXRFWHRBdXRob3IAV2lsbGVtIEEuSi4gdmFuIFNjaGFpawoo
        d2lsbGVtQHNjaGFpay5jb20pjsxHHwAAAEF6VFh0Q29weXJpZ2h0AAB4nHPOL6gsykzPKFEIz8zJ
        Sc1VKEvMUwhOzkjMzNZRCM7MS08syC9KVTC0tDTVtTQDAIthD6RSWpQSAAAAu3pUWHREZXNjcmlw
        dGlvbgAAeJwtjrEOwjAMRPd+xU1Mpf/AhFgQv2BcQyLcOEoMVf8eV7BZvnt3dwLbUrOSZyuwBwhd
        fD/yQk/p4CbkMsMNLt3hSYYPtWzv0EytHX2r4QsiJNyuZzysLeQTLoX1PQdLTYa7Er8Oa8ou4w8c
        UUnFI3zEmj2BtCYCJypF9PcbvFHpNQIKb//gPuGkinv24yzVUw9Qbd17mK3NuTyHfW2s6VV4b0dt
        0qX49AUf8lYE8mJ6iAAAAEB6VFh0U29mdHdhcmUAAHiccy5KTSxJTVHIz1NIVPBLjQgpLkksyQTy
        kvNz8osUSosz89IVlAryckvyC/LSlfQApuwRQp5RqK4AAAAdelRYdERpc2NsYWltZXIAAHiccytK
        TS1PLErVAwARVQNg1K617wAAAMhJREFUeJxd0cENwjAMBVAfKkAI8AgdoSOwCiNU4sgFMQEbMAJs
        UEZgA9igRj2VAp/ESVHiHCrnxXXtlGAWJXFrgQ1InvGaiKnxtIBtAvd/zQj8teDfnwnRjT0sFLhm
        7E9LCucHoNB0jsAoyO8F5JLXHqbtRgs76FC6gK++e3hw510DOYcvB3CPKiQo7CrpeezVg6DX/h7a
        6efoQPdDvCASCWPUcRaei07bVSOEKTExty6NgRVyEOTwZgMX5DCwgeRnaCilgXT9AB7ZwkX4/4lr
        AAAAAElFTkSuQmCC
        """),
        "s03n3p01": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAMAAAADAQMAAABs5if8AAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAZQTFRFAP8A/3cAseWlnwAAAA5JREFUeJxjYGBwYGAAAADGAEE5MQxLAAAAAElF
        TkSuQmCC
        """),
        "s02n3p01": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAIAAAACAQMAAABIeJ9nAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAANQTFRFAP//GVwvJQAAAAxJREFUeJxjYGBgAAAABAAB9hc4VQAAAABJRU5ErkJg
        gg==
        """),
        "z09n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAAp0lEQVR42rXRSw6AIBAD0JqwwPsf
        Fna4MX4QYT4dVySS19BuraECFSg4D9158ktyLaEi8suhARnICSVQB/agF5x6UEW3HhHw0ukb9Dp3
        g4FOrGisswJ+dUrATPePvNCdI691T0Ui3Rwg1W0bKHTDBjpdW5FaVwVYdPkGRl24gV2XVOTSlwFe
        fR5A0Ccjc/S/kWn6sCKm/g0g690GfP25QYh+VRSlA/kAVZNObtYRvvUAAAAASUVORK5CYII=
        """),
        "g10n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAABGdBTUEAAYagMeiWXwAAANRJREFU
        eJztljEKhDAURP8HC+32HpYewdbS+/zNfbyCx7D1FAu7xUK2cA0aM0j4ARWcKhlNJsNTkS2FxQSu
        CIf9Z9jO3iAgz8P+B9xPIDdDC6IDQOHoAKhUDaBQA8SgKCIDDmtwM3C6GezqsAbJIF+HwRf4sQ0e
        KOAF/GQMUMB1GCApG7Qtd916D0NERDJPNQ2ahv1IM2/tBpqvad/buuYAdrMY6xn4znR2l6F/inxH
        1lNNg7JkIqoqHgb7P7hsIGsYjONitWwGk87+HuzrdA1S/VX8ANStTVTe34+eAAAAAElFTkSuQmCC
        """),
        "cm7n0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAACT4cgpAAAABGdBTUEAAYagMeiWXwAAAAd0SU1F
        B7IBAQAAAB4KVgsAAADISURBVHicXdHBDcIwDAVQHypACPAIHaEjsAojVOLIBTEBGzACbFBGYAPY
        oEY9lQKfxElR4hwq58V17ZRgFiVxa4ENSJ7xmoip8bSAbQL3f80I/LXg358J0Y09LBS4ZuxPSwrn
        B6DQdI7AKMjvBeSS1x6m7UYLO+hQuoCvvnt4cOddAzmHLwdwjyokKOwq6Xns1YOg1/4e2unn6ED3
        Q7wgEglj1HEWnotO21UjhCkxMbcujYEVchDk8GYDF+QwsIHkZ2gopYF0/QAe2cJF+P+JawAAAABJ
        RU5ErkJggg==
        """),
        "ccwn2c08": blob("""
        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
        """),
        "basn0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAACT4cgpAAAABGdBTUEAAYagMeiWXwAAAEhJREFU
        eJxjYGAQFFRSMjZ2cQkNTUsrL2cgQwCV29FBjgAqd+ZMcgRQuatWkSOAyt29mxwBVO6ZM+QIoHLv
        3iVHAJX77h0ZAgAfFO4B6v9B+gAAAABJRU5ErkJggg==
        """),
        "g07n0g16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAAAAAAGgflrAAAABGdBTUEAARFwiTtYVgAAAPhJREFU
        eJzNlbsNhDAMhg1C4SVomYABqFiASchcmYkxEC2Ip4S4AuVEbCAXpbm/SUzx+cMC2TkOUOI4ai2E
        Wte1Wnvbpj7IMngNbkAAafoOwMYEkCSWBnFsaRBFlgY6gNYgDC0NdACtQRAYGqyrGeAPDUwBWgPf
        tzTQAYwN9t3QAP/O02RpgAHEYFneATjEwBSADdwFhX1TVYwxBgDA+dVAzaNBWd7baGdw9gRomqKQ
        92vIDOb5HoDvnJ8bghj8BuBcIrCBO6HIEeY5QJ4zxjmAEELIHXWgePhDkV3b9jzlapMnmcE4Pr/C
        XcgMhsEMQAz63tKg6+wMPgLFodTQLHMsAAAAAElFTkSuQmCC
        """),
        "basi3p01": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgAQMAAAE+s9ghAAAABGdBTUEAAYagMeiWXwAAAAZQTFRF
        7v8iImb/bBrSJgAAAClJREFUeJxjYICCD1C4CgpD0bCxMcOZM9hJCININj8QQIgPQAAhKBADAAm6
        Qi12qcOeAAAAAElFTkSuQmCC
        """),
        "basn2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAABGdBTUEAAYagMeiWXwAAAEhJREFU
        eJzt1cEJADAMAkCF7JH9t3ITO0Qr9KH4zuErtA0EO4AKFPgcoO3kfUx4QIECD0qHH8KEBxQo8KB0
        OCOpQIG7cHejwAGCsfleD0DPSwAAAABJRU5ErkJggg==
        """),
        "oi9n2c16": blob("""
        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
        XqTrARsAAAAASUVORK5CYII=
        """),
        "basi4a16": blob("""
        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
        RK5CYII=
        """),
        "s04i3p01": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAQAAAAEAQMAAAHkODyrAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAZQTFRF/wB3//8AmvdDuQAAABRJREFUeJxjaGAAwQMMDgwTGD4AABmuBAG53zf2
        AAAAAElFTkSuQmCC
        """),
        "ctjn0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAACT4cgpAAAABGdBTUEAAYagMeiWXwAAACBpVFh0
        VGl0bGUAAABqYQDjgr/jgqTjg4jjg6sAUG5nU3VpdGUPGlwCAAAAOGlUWHRBdXRob3IAAABqYQDo
        kZfogIUAV2lsbGVtIHZhbiBTY2hhaWsgKHdpbGxlbUBzY2hhaWsuY29tKeXxzKEAAABTaVRYdENv
        cHlyaWdodAAAAGphAOacrOaWh+OBuADokZfkvZzmqKnjgqbjgqPjg6zjg6Djg7TjgqHjg7Pjgrfj
        g6PjgqTjgq/jgIHjgqvjg4rjg4AyMDExhF9tvgAAAXdpVFh0RGVzY3JpcHRpb24AAABqYQDmpoLo
        poEAUE5H5b2i5byP44Gu5qeY44CF44Gq6Imy44Gu56iu6aGe44KS44OG44K544OI44GZ44KL44Gf
        44KB44Gr5L2c5oiQ44GV44KM44Gf44Kk44Oh44O844K444Gu44K744OD44OI44Gu44Kz44Oz44OR
        44Kk44Or44CC5ZCr44G+44KM44Gm44GE44KL44Gu44Gv6YCP5piO5bqm44Gu44OV44Kp44O844Oe
        44OD44OI44Gn44CB44Ki44Or44OV44Kh44OB44Oj44ON44Or44KS5oyB44Gk44CB55m96buS44CB
        44Kr44Op44O844CB44OR44Os44OD44OI44Gn44GZ44CC44GZ44G544Gm44Gu44OT44OD44OI5rex
        5bqm44GM5a2Y5Zyo44GX44Gm44GE44KL5LuV5qeY44Gr5b6T44Gj44Gf44GT44Go44GM44Gn44GN
        44G+44GX44Gf44CCwwUNtAAAAGNpVFh0U29mdHdhcmUAAABqYQDjgr3jg5Xjg4jjgqbjgqfjgqIA
        InBubXRvcG5nIuOCkuS9v+eUqOOBl+OBpk5lWFRzdGF0aW9u6Imy5LiK44Gr5L2c5oiQ44GV44KM
        44G+44GZ44CCwoP4MAAAADJpVFh0RGlzY2xhaW1lcgAAAGphAOWFjeiyrOS6i+mghQDjg5Xjg6rj
        g7zjgqbjgqfjgqLjgIJ28EPmAAAAZUlEQVQokWNgYPgPBMbGLi6hoWlp5eUMZAgICiop/f8P43Z0
        kCOgpGRs/P8/jDtzJjkCIAP//4cayLBqFTkCaFwGcgSQnMSwe/eZM+QIwLggA8+cuXuXHAEYd/du
        oKMY3r0jQwAATn/xuQxIlj4AAAAASUVORK5CYII=
        """),
        "s33n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACEAAAAhBAMAAAClyt9cAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAAL5JREFUeJxdzy0SwyAQhuGv0+n0V6Q36HCCzHCBih4gBh8VXVeLjIyNi0bV13CAHKrLDi27
        vAwrEMADpMaS5wN8Sm+EEHAKpQXD0NMu9bAWWytqMU+YZRMMXWxENzhaO1fqsK5rTONXxIPikbvj
        RfHIPXGleOQaNlWuM1GUa6H/VC46qV26ForEKRLnVB06SaJwiZKUUNn1D/vsEqZNI0mjP3h4SUrR
        60G3aBOzalcL5TqyTbmMqVzJqV0R5PoCM2LWk+YxJesAAAAASUVORK5CYII=
        """),
        "s32n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAAHxJREFUeJyV0b0NgCAQBeBXAIlxCRt6WrbyNqB3CSsnYTAPTYzvSIhSXMhHcn8A7ch25Fiv
        iA40wDEkVAZ4hh2RQXMa6JLmxZaNPwEdBJO0aB9u3NhzraJvBKuCfwNmXQVBW9YQ5AskC1xW2n4Z
        MDEU2FlCNrOYae+Pt3ACA2HDSOt6Ji4AAAAASUVORK5CYII=
        """),
        "oi9n0g16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAAAAAAGgflrAAAABGdBTUEAAYagMeiWXwAAAAFJREFU
        eHbmhOYAAAABSURBVJzRgaKHAAAAAUlEQVTV3oFbswAAAAFJREFU0kDlzhAAAAABSURBVDF55n3S
        AAAAAUlEQVQKyO2U9gAAAAFJREFUwLNcv1gAAAABSURBVDAO4U1EAAAAAUlEQVQMIY4xwwAAAAFJ
        REFUQ8ftbcIAAAABSURBVFE0VByKAAAAAUlEQVQ5dz314AAAAAFJREFUW9SB9ZQAAAABSURBVO8Y
        jYIBAAAAAUlEQVR/6IIRRQAAAAFJREFUxlo/Gm0AAAABSURBVNynXeMXAAAAAUlEQVSg/u7eAAAA
        AAFJREFUk0E+vxYAAAABSURBVMCzXL9YAAAAAUlEQVQoHY3VEgAAAAFJREFUe+/v1VwAAAABSURB
        VDLg7yxoAAAAAUlEQVTV3oFbswAAAAFJREFUKvODtD4AAAABSURBVAQvVbnxAAAAAUlEQVSjZ+eP
        ugAAAAFJREFU2dc3F5gAAAABSURBVI9VP+NZAAAAAUlEQVQ/nl5Q1QAAAAFJREFUOAA6xXYAAAAB
        SURBVIDFgP7IAAAAAUlEQVSnYIpLowAAAAFJREFUuO2CRlYAAAABSURBVFfdN7m/AAAAAUlEQVQT
        rIY8NgAAAAFJREFUE6yGPDYAAAABSURBVGP8g00KAAAAAUlEQVSg/u7eAAAAAAFJREFUOu40pFoA
        AAABSURBVIIrjp/kAAAAAUlEQVRgZYocsAAAAAFJREFUHUs+ETEAAAABSURBVAgm4/XaAAAAAUlE
        QVSZoetWCAAAAAFJREFUACg4fegAAAABSURBVN3QWtOBAAAAAUlEQVSCK46f5AAAAAFJREFU9nzm
        KsEAAAABSURBVEBe5Dx4AAAAAUlEQVTKU4lWRgAAAAFJREFUBC9VufEAAAABSURBVOiG6ReiAAAA
        AUlEQVQW3OzIuQAAAAFJREFU3Kdd4xcAAAABSURBVAbBW9jdAAAAAUlEQVRCsOpdVAAAAAFJREFU
        Jvo1+BUAAAABSURBVEBe5Dx4AAAAAUlEQVS3fT1bxwAAAAFJREFUoP7u3gAAAAABSURBVD1wUDH5
        AAAAAUlEQVSQ2DfurAAAAAFJREFUMuDvLGgAAAABSURBVAFfP01+AAAAAUlEQVS6A4wnegAAAAFJ
        REFUBVhSiWcAAAABSURBVLd9PVvHAAAAAUlEQVSBsofOXgAAAAFJREFUkNg37qwAAAABSURBVAlR
        5MVMAAAAAUlEQVTQruuvPAAAAAFJREFULW3nIZ0AAAABSURBVGhrUZSCAAAAAUlEQVQPuIdgeQAA
        AAFJREFUpPmDGhkAAAABSURBVExXUnBTAAAAAUlEQVRgZYocsAAAAAFJREFUP55eUNUAAAABSURB
        VG/1NQEhAAAAAUlEQVQHtlzoSwAAAAFJREFU7IGE07sAAAABSURBVE/OWyHpAAAAAUlEQVT0kuhL
        7QAAAAFJREFUGUxT1SgAAAABSURBVDgAOsV2AAAAAUlEQVTPI+OiyQAAAAFJREFUf+iCEUUAAAAB
        SURBVAAoOH3oAAAAAUlEQVQW3OzIuQAAAAFJREFU2KAwJw4AAAABSURBVEvJNuXwAAAAAUlEQVTY
        oDAnDgAAAAFJREFUX9PsMY0AAAAASUVORK5CYII=
        """),
        "g03n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAABGdBTUEAAIi4vcVJsAAAASlJREFU
        eJzllk2KwkAQRqsx/kQEERR3LrzEeAiP6yH6FC4EFzKCGGRGZ0bjwojJJI/kw7iyVpVKpV+/LgLt
        YisOZ/DGu+L6R3E5OANgPi+uL6DfgIuA0YhWggBhBPT7IoAM/qC/1xMBqkG3KwLUGYShCFANOh0R
        oM6g3RYBqoEMUA1aLRFABrUBVINmUwS8n0EQiAAy+IV+NLhAXTUIyeAH6qoBHhEByID6Xz4DGfCM
        wXTqzGy5zK4xMzMzf38kg1LAZOJWqzidJKv7bEIGJwA0GkmyXsf5ovnKBgT4N4Px2G02qU1WNzgC
        4LFZs+HQbbd0Q7sHGXyXAQYDd2OY2W4XJ1vOHxEZfJUBoij7qc8ltyCDAwBq+w/20J+eQaUgg8+6
        AGRAt+W6DK5anlkjB1vfagAAAABJRU5ErkJggg==
        """),
        "basn0g08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAAAAABWESUoAAAABGdBTUEAAYagMeiWXwAAAEFJREFU
        eJxjZGAkABQIyLMMBQWMDwgp+PcfP2B5MBwUMMoRkGdkonlcDAYFjI/wyv7/z/iH5nExGBQwyuCV
        ZWQEAFDl/nE14thZAAAAAElFTkSuQmCC
        """),
        "basi3p02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgAgMAAAF5E6LxAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        AQEBfC53ggAAAAxQTFRFAP8A/wAA//8AAAD/ZT8rugAAAFFJREFUeJxjeMewmwGEXRgEwdjMjCE5
        GUreuAFi9Pais78u+LqAgT+KP4oByPjKAGTw4xZDSCBkEUpIUvc/dBUYIxiYQqugLAQDKvEfwaCS
        OQC0Wn3pH3XhAwAAAABJRU5ErkJggg==
        """),
        "tp0n2c08": blob("""
        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
        """),
        "bgan6a08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAAYagMeiWXwAAAG9JREFU
        eJzt1jEKgDAMRuEnZGhPofc/VQSPIcTdxUV4HVLoUCj8H00o2YoBMF57fpz/ujODHXUFRwPKBqj5
        DVigB041HiJ9gFyCVOMbsEIPXNwuAHkgiJL/4qABNqB7QAeUPBAE2QAZUDZAfwEb8ABSIBqcFg+4
        TAAAAABJRU5ErkJggg==
        """),
        "oi2n2c16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAIAAACsiDHgAAAABGdBTUEAAYagMeiWXwAAAIBJREFU
        eJzVlsEKgzAQRKfgQX/Lfrf9rfaWHgYDkoYmZpPMehiGReQ91qCPEEIAPi/gmu9kcnN+GD0nM1/O
        4vNad7cC6850KHCiM5fz7fJwXdEBYPOygV/o7PICeXSmsMA/dKbkGShD51xsAzXo7DIC9ehMAYG7
        6MypZ6ANnfNJG7BAZx+ZiKBzAAAAZUlEQVQuYIfOHChgjR4F+MfuDx0AtmfnDfREZ+8m0B+9m8Ao
        9Chg9x0Yi877jTYwA529WWAeerPAbPQoUH8GNNA5r9yAEjp7sYAeerGAKnoUyJ8BbXTOMxvwgM6e
        CPhBTwS8oTO/5kL+Xk13nmIAAAAASUVORK5CYII=
        """),
        "f00n0g08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAAAAABWESUoAAABBklEQVR4nIXSL0xCURTH8a/gGHNj
        Bjc3AoFioFhIr7z0molmsxFpVCONSLPRbCYSiWKxWAwWN4ObG5ubcwzk6f3jds71hXPr/eye3/3d
        y/VkOruZ394tlqv7h8en55fXt/f1x+fXZrv73pflD2NDMDIEQ0NwZQguDcHAEFwYgkILwkoEuRJQ
        FWQi3Jafkgr6IiDmAJWDcxEQkroTVFJ6IsAn9SHUXTgTgX+5kFLdlq4I8DlwZ6g+6IgANwV/W9UY
        bRHh9DBFdcqpCL8f+1CtcyLC7Sd9BMGxCEj6iIKWCKIg9vEnOEpFWPr1aVZF8j9oJCLLi38/iEND
        UDcENUNwYAgsgSWwxC/EfcpYUKbOtgAAAABJRU5ErkJggg==
        """),
        "f01n0g08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAAAAABWESUoAAABCElEQVR4nIXSIUvEQRAF8Pd2dnb2
        BDEIgsFgMVgsJovJZhIMNsFgFC4IpuOSYDi4IlwQDIJBMIjB5Cew+I0MHvff2bC7+ce+meFxki2b
        maWUVFWjShQRCSGQJMjbUUfcWFvwOnfEpXXEhXXEmXXEaWoLnpgT5/j2gsepFFfAl/+DR1qIMYAP
        n8LDNIgpALz5OXigKzEHZmO8+Em5ryuxwCTf4cnvwr04iGyjKR79ttxVJx4w8/fgTnRijnt/MW5H
        JxaoGsQtceIZVYO4KU68omoQN6IT76gaxPXgxCeqBnFNBvGD/1emMIdB/C5BmcIUClHedCkYQ1tQ
        2BYMbAuSbUF0BNERREf8AZVRLIMTf6sKAAAAAElFTkSuQmCC
        """),
        "s05i3p02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFAgMAAAGHBv7gAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAlQTFRFAP//dwD//wAAQaSqcwAAABlJREFUeJxjaGBoYFjAACI7gHQAEE9tACIA
        TYMG43AkRkUAAAAASUVORK5CYII=
        """),
        "oi2n0g16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAAAAAAGgflrAAAABGdBTUEAAYagMeiWXwAAAEBJREFU
        eJzV0jEKwDAMQ1E5W+9/xtygk8AoezLVKgSj2Y8/OICnuFcTE2OgOoJgHQiZAN2C9kDKBOgW3AZC
        JkC3oD2QMjqwwDMAAAAeSURBVAG6BbeBkAnQLWgPpExgP28H7E/0GTjPfwAW2EvYX7J6X30AAAAA
        SUVORK5CYII=
        """),
        "f00n2c08": blob("""
        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
        Ohz8D28m/FokjZPFAAAAAElFTkSuQmCC
        """),
        "f01n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAEY0lEQVR4nK2WP+wlVRmGn/f8/c6c
        M+fsCDQEIhRYidlCY4GRBBIrsdCQmFCwncZGCk0oLGhIKCgsjDGxojBWkoCxNdBSkKWl2cJCowkN
        JSzXYu7cndn97Yagk6d4zzfJfZtv7nN0wrCM2ZliV+ev9qqYPnk8L07kTLYzZlfnr/RKt76bR2AJ
        ImWS3SHb/+Womy+kkTQiSxYxE+1Asv9xovdvxJEZppFZigi2IxMKwYi7fN95Jtg2v5P111+GXjQK
        Y9IoLFV425Hx5ZDDfeZrCHYne8MX/ek3oU/0SaMymkZlmYWzHRlXHpT9fp5xts/6w+thbvRKnzUa
        o2vMLEPIdmRUvnTOyC5Zb77pW2Oe6V29MwZjaAyWRWB3IX0AnE4/uvfV/dArr/naqI0607paZx70
        oXkwFgm78Jg+BoB/nX4A5rb5lRlMa/7pr51VlcbUKDO1a+rUQRuqg3mRwxz2Pf2b7fnw9P11+GXQ
        c79wuZIr1siNMss6pVOGpkEZ1EU39Bm7593Tdzx2PwJlf9T1lxWrYiVVUiM18qzcyZ08ZIPfPvn5
        +rtvnB55Vf8Bfnd6OmB74vEYKJesJ15UmPBVsRIqoREbcVbsxE4aevf658CNU4zYH/Up8KvTUxFb
        SVu4i0RZgx76oVzBT7gqX/EV3/ANPyt0fCcMhYEfxEXv6TPgx6fHE7aSt3DVpCRM9rxUUMFNqKKK
        q1LDNTTjOq7LDdxAg3987TbwrdPDGcvbv3zeYZTj0cQzyKBAgQkqVFShQYMZOuowYHD7SYB2epAK
        yvEovp3IkokiiphEFdWpiuZoYnZ0qTuGu339n0A4ff3BKii7o/hmxUR2mKM4Fc/kqJ7qqJ7maZ7Z
        qwe6/+LZjwD3yTNawtEAZwmUe5wgvtFJDvNkj3mKVwlMnhrOtEgLzFE9fvHC3wF36yeMqCXf44Fo
        pHKciCcGKZA85snrEkeVwBSpkZqokZZomTmdXnobcDd/xjBG1lLsKBA7eyBesnj02rkgBSySIxYp
        USUxJWqmJqrRMs1OP38LcO+/yiiMiVG0VDsKZOXiCvHINaInRVIgRSyS1yXOlMyUqcbv3+GqR7f+
        zKhaZjsKxHbSENc6MRAjaSVhiZyxTDGKMRlv/eXqgpt/Y3TGrGXYUSAXIYh5xntiJEZSOmNGXr+b
        QilME7VSq2qlNTaBsAmEMbQs99qggLCCD3hPiMRITMS1xs6XJStYoUyUSqlMlZ1A2ATCPDQW2wsE
        ikOEhPe4rcNHYiKsNUbM5/3OBZvIlVKxyk4gbAKhDs3LXUIQLuAc8viA8/iIj4SET8R0voOc97uQ
        J1LlKBA2gTANylBd9n4QchseF3AeF/ERn84Ew2fiut+FOBErR4GwCQQb5KGyXMwgVi4d2joU8QmX
        cGl/zyEUwoSvHAXCJhDSIA7ysppB676dO9g65FFEEZfQWmMo49cVPwuEo0DYBMImEEvngq2DrYOA
        PEQUUYKE0vHOcxAIR4FwEYhf/gtC7nstgnuX5wAAAABJRU5ErkJggg==
        """),
        "s39n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACcAAAAnBAMAAAB+jUwGAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAANVJREFUeJxt0iEOg0AQheFHSJuUGnqDhhOQcIEKDoDBo9A4LBKJxaFX4TEcgEN1ZklDZ2Z/
        YMQa+DIA3Cga/Bk20QrnHBInWtC2DT2iBkWBuJDlmCfMqgkZvSeTvVHTdatFFY7j2Hn8taOk/Lj6
        oKf8uOrwovy4Sr3b2p9k1faFvtPa6TBgN+UGftptZLdViv1nL0P2PmSX7ihV7JEXPhj2ttGxYidM
        V+7mznRlz2OmK/v0YDo0m25o+/kXGjfoDtED9g565dFv7WLlni/tDMeq7AxPli8bpjUVK/+f5gAA
        AABJRU5ErkJggg==
        """),
        "s38n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACYAAAAmBAMAAABaE/SdAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAAGpJREFUeJxjYACBwu5llqpHYCQDNjEgzcCCIWbAcARDjIEVQ2wBgyqGGNAKTDFsdlgqYHGL
        KrliDNjE2DDtaAC6D8Mt2NyMzBs4MaDL0MUMgGLcaGLAuClgQBcDkmSLYTEPm72DyS3gsAIA8mkr
        g86sROEAAAAASUVORK5CYII=
        """),
        "tp0n0g08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAAAAABWESUoAAAABGdBTUEAAYagMeiWXwAAAoZJREFU
        OI1jqCcAGEhU8PjkRzwKXmytS41yS1z4EKuCd/s70xN9zbQ0VDT0AyZe+YOq4NORqUU5wXZ6Bjrq
        2rbKEtIaBjkLzv+AKfh+alZZcZqnoYGxqY2dhaGNq7G6rnZUXnHZ7CPvwArO1JeVlvqZm5nbhKYE
        OLl4uDrZWajllAJB1iywgjutHS3VyS7uSWXl5eVFieFBft5+yUBmQUzQXrCCVy2N7X2d9ZWooCw5
        JMDnGVjBj6aMpIoJk/ubq2GgqqoyKzzAxzMS6ouuzJK+/klTp09pr4GCwmhjEQldtyaogkmZ+f39
        E6dMnzl7Znd9XV1teVKIqrggD4/+GqiCKemZLf0TJk+uqp8+b05fXVZUuK60EC8Ht8o1qIIl6Sml
        /f2TmvOS8+bOX1AVFWknK8YrxSti9xuqYFtafGpX34S6sqi8OfPml0QGK0jzW3lIGRTBgvp4SkZw
        dV9VaWlkwey58/IirWSFtV2UhATnwhTcSM7wyOmNLimJyJ81e256uLK0gLm4EJ/YcZiCV4mpfrGN
        SRlFEQUzZs1J9JQVVZLh4+FR/gJT8CchOTyisDi8MKRk+sxZUZYy/MYyvLxCgYjozktICM2sCSwI
        Lp46fVq4jiSPg7a4CE87QkFPfHpgRllEXlDh5Kn9YUqifO6mQkJCRxEKfi1OTk7PTMsJLJ04uTNU
        RkjQUlREYRtKkruQm5qWkR1Q2j+xMVSRn0dAQPUcWpp805aWnhlQ3NtfFaLPx81t+AAj0f5ZlZ7u
        X9zdWxJsKy3s8xZbsr9SFFHf0Z0b5G9e/gt7vni/oLmtIz0wYMFfbPkCBP4daG1LDNqOLISe9e5N
        SD1Tj09B/dfH9fgVYAAA90bMUdlj1V0AAAAASUVORK5CYII=
        """),
        "tbgn2c16": blob("""
        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
        """),
        "cdun2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAlwSFlzAAAD6AAAA+gBtXtSawAAAmdJREFUeJyVluGR3CAMhb/bcQNqgRZowVeC
        r4RLCZsSsiXcteASQglxC7RACckPEEbYeDeandkZDHpP0hPi7S/PzIPoL1uCCBHS08O8DQEczI3T
        kW0Q/hdAYAb3nF2xBAHiiwAOlpddtzYIxQLM8Hl+PPNLh3L0GI8LAAdfMJvPNfqunA48+M5Zgo8+
        jqn8S+8aWGE7ZaoiCrB0xfKQzLFb+beCSfA99v5km3U1FfpWM48+mR6cJj93wVbTtsLvYxyaqFvB
        bMxKzsGnyjYTE/DwWdWWYO2K5PcgpuKkibopkoM/ZXVTWNESAyzwUU8ZebuSu6lLTuNdSjojPApD
        qUw93NF2D8DWJX8E0CTHg5DgJ6zMSroIdwXJTeNrPWIrXHU7tRW3endQzt7hXjwncIn5HWLUxlO2
        sesMgWQBkvkoGUBKLN/6PQKeOda8qIv+bhVI3AZdr6spB9L1cnTG5Rhgb7SRSa2usRcGQdl0G+zV
        Vcnk25tEyPmhVtIGYm3SQjX7y5kEgoeVFaToKBdZr4drgFQBGm670nMFPXhCZAOPCBKr9yL7A1wP
        YMXV3CJb+fALZlJoejAnzNdtZc0AaENN3ajzppnXwjO7q8LfCYUK4LsU7QAN10xk2a/SBD9gAbF+
        K/fQhmRsBICOKo0j3/nucF3vnXEyxcNeyak4sRj3/bKqfM5fDXIcapi9OjJDv2sBacfKmTndZswO
        h2boC3z10dZB0PKvE+FEl+/9CLXPFn9KaT+ert9jAdZ+7fDwkiuMKwvnr4TB23Q+inJs0cjmNQD2
        iXkVTS7R5fNmDFCtNsDx+f6C/QMQQNfOLmy7EgAAAABJRU5ErkJggg==
        """),
        "g10n0g16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAAAAAAGgflrAAAABGdBTUEAAYagMeiWXwAAAL1JREFU
        eJztlTEOhCAQRT8bCyw9hlzD0tIDIQfyCF7D0ktYSGLBFoTFmUQC2WRjsv4CZqaYefwQEM6BSAia
        a03zcaR5ZS0tSImk+IDiBpy42ndaqOtfEzwe3MGDrwlKTfxHD46jkKBp0g2KPdi2QoI73YNhmKYQ
        GxOe12wP+j7Gxmgd1myCee66sx/G+J0TvCyT/Ajwa2QAAMeUNDHG8XvhBKJtaSEYpxQALItS/vyh
        SfbPtK7n2dcEz6sMvAHqCJi/5fyWiAAAAABJRU5ErkJggg==
        """),
        "ch1n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAC1QTFRFIgD/AP//iAD/Iv8AAJn//2YA3QD/d/8A/wAAAP+Z3f8A/wC7/7sAAET/
        AP9E0rBJvQAAAB5oSVNUAEAAcAAwAGAAYAAgACAAUAAQAIAAQAAQADAAUABwSJlZQQAAAEdJREFU
        eJxj6OgIDT1zZtWq8nJj43fvZs5kIEMAlSsoSI4AKtfFhRwBVO7du+QIoHEZyBFA5SopkSOAyk1L
        I0cAlbt7NxkCAODE6tEPggV9AAAAAElFTkSuQmCC
        """),
        "ps2n2c16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAIAAACsiDHgAAAABGdBTUEAAYagMeiWXwAACHpzUExU
        c2l4LWN1YmUAEAAAAAAAAAD/AAAAAAAAADMA/wAAAAAAAABmAP8AAAAAAAAAmQD/AAAAAAAAAMwA
        /wAAAAAAAAD/AP8AAAAAADMAAAD/AAAAAAAzADMA/wAAAAAAMwBmAP8AAAAAADMAmQD/AAAAAAAz
        AMwA/wAAAAAAMwD/AP8AAAAAAGYAAAD/AAAAAABmADMA/wAAAAAAZgBmAP8AAAAAAGYAmQD/AAAA
        AABmAMwA/wAAAAAAZgD/AP8AAAAAAJkAAAD/AAAAAACZADMA/wAAAAAAmQBmAP8AAAAAAJkAmQD/
        AAAAAACZAMwA/wAAAAAAmQD/AP8AAAAAAMwAAAD/AAAAAADMADMA/wAAAAAAzABmAP8AAAAAAMwA
        mQD/AAAAAADMAMwA/wAAAAAAzAD/AP8AAAAAAP8AAAD/AAAAAAD/ADMA/wAAAAAA/wBmAP8AAAAA
        AP8AmQD/AAAAAAD/AMwA/wAAAAAA/wD/AP8AAAAzAAAAAAD/AAAAMwAAADMA/wAAADMAAABmAP8A
        AAAzAAAAmQD/AAAAMwAAAMwA/wAAADMAAAD/AP8AAAAzADMAAAD/AAAAMwAzADMA/wAAADMAMwBm
        AP8AAAAzADMAmQD/AAAAMwAzAMwA/wAAADMAMwD/AP8AAAAzAGYAAAD/AAAAMwBmADMA/wAAADMA
        ZgBmAP8AAAAzAGYAmQD/AAAAMwBmAMwA/wAAADMAZgD/AP8AAAAzAJkAAAD/AAAAMwCZADMA/wAA
        ADMAmQBmAP8AAAAzAJkAmQD/AAAAMwCZAMwA/wAAADMAmQD/AP8AAAAzAMwAAAD/AAAAMwDMADMA
        /wAAADMAzABmAP8AAAAzAMwAmQD/AAAAMwDMAMwA/wAAADMAzAD/AP8AAAAzAP8AAAD/AAAAMwD/
        ADMA/wAAADMA/wBmAP8AAAAzAP8AmQD/AAAAMwD/AMwA/wAAADMA/wD/AP8AAABmAAAAAAD/AAAA
        ZgAAADMA/wAAAGYAAABmAP8AAABmAAAAmQD/AAAAZgAAAMwA/wAAAGYAAAD/AP8AAABmADMAAAD/
        AAAAZgAzADMA/wAAAGYAMwBmAP8AAABmADMAmQD/AAAAZgAzAMwA/wAAAGYAMwD/AP8AAABmAGYA
        AAD/AAAAZgBmADMA/wAAAGYAZgBmAP8AAABmAGYAmQD/AAAAZgBmAMwA/wAAAGYAZgD/AP8AAABm
        AJkAAAD/AAAAZgCZADMA/wAAAGYAmQBmAP8AAABmAJkAmQD/AAAAZgCZAMwA/wAAAGYAmQD/AP8A
        AABmAMwAAAD/AAAAZgDMADMA/wAAAGYAzABmAP8AAABmAMwAmQD/AAAAZgDMAMwA/wAAAGYAzAD/
        AP8AAABmAP8AAAD/AAAAZgD/ADMA/wAAAGYA/wBmAP8AAABmAP8AmQD/AAAAZgD/AMwA/wAAAGYA
        /wD/AP8AAACZAAAAAAD/AAAAmQAAADMA/wAAAJkAAABmAP8AAACZAAAAmQD/AAAAmQAAAMwA/wAA
        AJkAAAD/AP8AAACZADMAAAD/AAAAmQAzADMA/wAAAJkAMwBmAP8AAACZADMAmQD/AAAAmQAzAMwA
        /wAAAJkAMwD/AP8AAACZAGYAAAD/AAAAmQBmADMA/wAAAJkAZgBmAP8AAACZAGYAmQD/AAAAmQBm
        AMwA/wAAAJkAZgD/AP8AAACZAJkAAAD/AAAAmQCZADMA/wAAAJkAmQBmAP8AAACZAJkAmQD/AAAA
        mQCZAMwA/wAAAJkAmQD/AP8AAACZAMwAAAD/AAAAmQDMADMA/wAAAJkAzABmAP8AAACZAMwAmQD/
        AAAAmQDMAMwA/wAAAJkAzAD/AP8AAACZAP8AAAD/AAAAmQD/ADMA/wAAAJkA/wBmAP8AAACZAP8A
        mQD/AAAAmQD/AMwA/wAAAJkA/wD/AP8AAADMAAAAAAD/AAAAzAAAADMA/wAAAMwAAABmAP8AAADM
        AAAAmQD/AAAAzAAAAMwA/wAAAMwAAAD/AP8AAADMADMAAAD/AAAAzAAzADMA/wAAAMwAMwBmAP8A
        AADMADMAmQD/AAAAzAAzAMwA/wAAAMwAMwD/AP8AAADMAGYAAAD/AAAAzABmADMA/wAAAMwAZgBm
        AP8AAADMAGYAmQD/AAAAzABmAMwA/wAAAMwAZgD/AP8AAADMAJkAAAD/AAAAzACZADMA/wAAAMwA
        mQBmAP8AAADMAJkAmQD/AAAAzACZAMwA/wAAAMwAmQD/AP8AAADMAMwAAAD/AAAAzADMADMA/wAA
        AMwAzABmAP8AAADMAMwAmQD/AAAAzADMAMwA/wAAAMwAzAD/AP8AAADMAP8AAAD/AAAAzAD/ADMA
        /wAAAMwA/wBmAP8AAADMAP8AmQD/AAAAzAD/AMwA/wAAAMwA/wD/AP8AAAD/AAAAAAD/AAAA/wAA
        ADMA/wAAAP8AAABmAP8AAAD/AAAAmQD/AAAA/wAAAMwA/wAAAP8AAAD/AP8AAAD/ADMAAAD/AAAA
        /wAzADMA/wAAAP8AMwBmAP8AAAD/ADMAmQD/AAAA/wAzAMwA/wAAAP8AMwD/AP8AAAD/AGYAAAD/
        AAAA/wBmADMA/wAAAP8AZgBmAP8AAAD/AGYAmQD/AAAA/wBmAMwA/wAAAP8AZgD/AP8AAAD/AJkA
        AAD/AAAA/wCZADMA/wAAAP8AmQBmAP8AAAD/AJkAmQD/AAAA/wCZAMwA/wAAAP8AmQD/AP8AAAD/
        AMwAAAD/AAAA/wDMADMA/wAAAP8AzABmAP8AAAD/AMwAmQD/AAAA/wDMAMwA/wAAAP8AzAD/AP8A
        AAD/AP8AAAD/AAAA/wD/ADMA/wAAAP8A/wBmAP8AAAD/AP8AmQD/AAAA/wD/AMwA/wAAAP8A/wD/
        AP8AAJbQi4YAAADlSURBVHic1ZbBCoMwEESn4EF/y363/a32lh4GA5KGJmaTzHoYhkXkPdagjxBC
        AD4v4JrvZHJzfhg9JzNfzuLzWne3AuvOdChwojOX8+3ycF3RAWDzsoFf6OzyAnl0prDAP3Sm5Bko
        Q+dcbAM16OwyAvXoTAGBu+jMqWegDZ3zSRuwQGcfLmCHzhwoYI0eBfjH7g8dALZn5w30RGfvJtAf
        vZvAKPQoYPcdGIvO+402MAOdvVlgHnqzwGz0KFB/BjTQOa/cgBI6e7GAHnqxgCp6FMifAW10zjMb
        8IDOngj4QU8EvKEzv+ZC/l4Hu8TsAAAAAElFTkSuQmCC
        """),
        "basi3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAAH2U1dRAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAC1QTFRFIgD/AP//iAD/Iv8AAJn//2YA3QD/d/8A/wAAAP+Z3f8A/wC7/7sAAET/
        AP9E0rBJvQAAALZJREFUeJxj6KljOP6QoU6W4eElhihLhsVTGCwdGKawMcQst5vIAMS+DEDMxADE
        2Qytp4pfQiSADBGILJBxAaIEyFCDqOsIPbOq3PjdTAYoLcgApV0YoPRdBhjNAKWVGKB0GgOU3o0w
        B9NATJMxrcC0C9NSTNsxnYFwT0do6Jkzq1aVlxsbv3s3cyamACpXUBBTAJXr4oIpgMq9exdTAI3L
        gCmAylVSwhRA5aalYQqgcnfvxhAAALN26mgMdNBfAAAAAElFTkSuQmCC
        """),
        "cs3n2c16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAIAAACsiDHgAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        DQ0N0DeNwQAAAH5JREFUeJztl8ENxEAIAwcJ6cpI+q8qKeNepAgelq2dCjz4AdQM1jRcf3WIDQ13
        qUNsiBBQZ1gR0cARUFIz3pug3586wo5+rOcfIaBOsCSggSOgpcB8D4D3R9DgfUyECIhDbAhp4Ajo
        KPD+CBq8P4IG72MiQkCdYUVEA0dAyQcwUyZpXH92ZwAAAABJRU5ErkJggg==
        """),
        "s06n3p02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAYAAAAGAgMAAACdogfbAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAlQTFRFAP8AAHf//wD/o0UOaAAAABZJREFUeJxjWLWAYWoCwwQwAjJWLQAAOc8G
        Xylw/coAAAAASUVORK5CYII=
        """),
        "s07n3p02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAcAAAAHAgMAAAC5PL9AAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAxQTFRF/wB3AP93//8AAAD/G0OznAAAABpJREFUeJxj+P+H4WoMw605DDfmgEgg
        +/8fAHF5CrkeXW0HAAAAAElFTkSuQmCC
        """),
        "g25n0g16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAAAAAAGgflrAAAABGdBTUEAA9CQ+FSITwAAATZJREFU
        eJyllMsNwjAMQN0SQHwixGeNbsSBAToHXQDuHLoCi5A1CgjxhxY4RFGxLRJZ+FDXVvLy6laN3m9A
        EUW4ThJcbza4VkUBoqAHqO1WBqDGarfznxA02O9lAGYgBTCDw+FPAwqIY6HB8YgbjYbQQApgBqfT
        nwbnM2koocHlghvNptDgepUBmAEFtFpCg9sNN9ptocH97geUZcCAAgYDXNPXzAweD9zodPwAZvB8
        +gE0mAEFdLt+ADOgQ+r1bF6tAGYze29M/WtlBlWFG/0+AMBikabuGjCgAK1dzrK6qoMaxBUJrbXW
        GiDL5vNvgDHOAId6vTDRfQfL5XdljJsEmwF9Jrslz6dTgDy325KkHiSbAW0Mhzav1za7+bscNHCA
        XxE0GI38AGZAF4zHQgO6YDKRGXwAuz+aGCA4FKQAAAAASUVORK5CYII=
        """),
        "z06n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAAp0lEQVR4nLXRSw6AIBAD0JqwwPsf
        Fna4MX4QYT4dVySS19BuraECFSg4D9158ktyLaEi8suhARnICSVQB/agF5x6UEW3HhHw0ukb9Dp3
        g4FOrGisswJ+dUrATPePvNCdI691T0Ui3Rwg1W0bKHTDBjpdW5FaVwVYdPkGRl24gV2XVOTSlwFe
        fR5A0Ccjc/S/kWn6sCKm/g0g690GfP25QYh+VRSlA/kAVZNObjFSwSwAAAAASUVORK5CYII=
        """),
        "basi6a16": blob("""
        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
        C+9JQJpSCQAAAABJRU5ErkJggg==
        """),
        "cm9n0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAACT4cgpAAAABGdBTUEAAYagMeiWXwAAAAd0SU1F
        B88MHxc7O3UwH+AAAADISURBVHicXdHBDcIwDAVQHypACPAIHaEjsAojVOLIBTEBGzACbFBGYAPY
        oEY9lQKfxElR4hwq58V17ZRgFiVxa4ENSJ7xmoip8bSAbQL3f80I/LXg358J0Y09LBS4ZuxPSwrn
        B6DQdI7AKMjvBeSS1x6m7UYLO+hQuoCvvnt4cOddAzmHLwdwjyokKOwq6Xns1YOg1/4e2unn6ED3
        Q7wgEglj1HEWnotO21UjhCkxMbcujYEVchDk8GYDF+QwsIHkZ2gopYF0/QAe2cJF+P+JawAAAABJ
        RU5ErkJggg==
        """),
        "cdsn2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAIAAABLbSncAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAlwSFlzAAAAAQAAAAEATyXE1gAAAHtJREFUeJxFzlENwkAURNFTgoFnYS3UQisB
        C1gACSCBSsDCVgIroSuhlbB8NIX5mUwyubldQzCQ2KjMcBZ8zKFiP0zcaRd53Stb3n2LNWvJSVIw
        X/PoNvbbNlQkJ0dqRI0Qxz5Qg+VlffxQXQuyEsphFxNP3V93hxQKfAEqsC/QF17WrgAAAABJRU5E
        rkJggg==
        """),
        "tbbn3p08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAABGdBTUEAAYagMeiWXwAAAuJQTFRF
        ////gFZWtbW4qEJCn5+fsSAgixUVnZ2dGxtZm5ubAACEmZmZj6ePl5eXlZWVk5OTKSlWkZGRAACb
        j4+Pi5WLLi6njY2NgAAAi4uLuQAAiYmJDAzVeHV1h4eHAACyhYWFpQAA3gAAgYGBf39/AACefX19
        AADJe3t7eXl5NzdWd3d3dXV1c3NzSKlIjgAAAgJkAABiVolWKCh8U4tTiYmPZ2dnZWVlXW1dE+UT
        hiYmby0tRJFEYWFhO507RIlEPZM9AACkAPMAAPEAWVlZV1dXVVVVU1NTNIU0UVFRJJckT09POjpB
        EBC6sg8PAMcAAMUA/Pz8AMMABASXAMEALXct+vr6AL8AAABoAL0A2tTUEBB7Ca0J+Pj4ALkAALcA
        nJyh9vb2DKEMALMAALEAEJEQAKsA8vLyAKkAAKcA7u7u7OzsAJcA6urqAABrAI0AAIsAAIkAAIcA
        MTExGRkqBwdAEhKuCQnu09bTzMzMkwAAoyoqxsbGxMTEzAAA0woKgWtreD4+AwNtAACfCgpWRkZI
        QUFNc11dUQcHqKio7e3voKCgnp6enJycAAC5mpqasgAAmJiY6wAAlpaWngAAlJSUExMckpKSkJCQ
        jo6OAACRioqKiIiIdqJ2hYiFhoaGhISEeA8PgoKCfoJ+fn5+fHx8enp6SsBKdnZ2dHR0cnJycHBw
        mAAAbm5uanBqemZmampqhAAARKJES5ZLYWRhYmJiAPQAOJg4XFxcWlpaAOYAAgJdQnhCVlZWAADw
        LpQuR2hHMTFgANgAUlJSUFBQAM4AIZghFBRtAMgATExM/f39AMYAAACdb2tr6g4OSEhIALwANGY0
        AgL1U1NgALAAAK4AtwAAAKQA7+/vAKIAj09PlTQ0AJgAAJYAAJIA5+fnAIwA4+PjAIAAkgYGAQFv
        ZFZZAABkTk5rz8/P3d3gAAB7ycnJFhZBISFZV1dZRER4v7+/693dLS1UCgpgAAD/v319AAAAzmH7
        FgAAAAF0Uk5TAEDm2GYAAAABYktHRPVF0hvbAAACiklEQVQ4jWNgoDJ48CoNj+w9psVmTyyZv3zA
        Kpv5Xsq0rYFNb4P4htVVXyIDUGXTavhWnmmwrJxcKb7Aqr29fcOjdV3PY2CyMa/6luu0WT6arNBf
        WyupwGa5QHy13pM1Oss5azLBCiqUl2tr35Lsv+p76yarouLEiYq1kuJntIFgfR9YwQv52fPVGX1Z
        b8poaWnVM9edPVtXxQhkrtp+6D1YQc58pbkzpJQ1UMHyLa6HT9yDuGGR5zVbEX7h+eowsHSpxnqX
        wyfOOUNdOSvplOOyaXy8U2SXQMHK7UZBUQItC6EKpkVHbLUQnMLLzcktobx4sarWlks+ajPDwwU6
        oAqmJCbt3DqHX2SjLk93z4zF63e8ld7btKvEgKMcqqDjaOrxrcum6Z5P38fO0rV0h7PoZ7VdxVOb
        NWHBybTvxpWdTiIbj9/e1tPNssL52cW9jd7nXgushAVltXty3hHHTbZ+t+052bvXAA1weNMa1TQz
        HqYgcnfyw1inFNtT2fZ9nOymb8v2Nh4IUnn5qRqmIGf3lcLEgxmegXfsJ/T12Lz73Mvx+mVuLkcC
        TEHA/vQ7IcH+d4PvbuLl7tshepHrY7H+Y6FniNhee+3a/sSD+WF5m/h4J7mU7g1vLToml2uCUCB2
        4/IFu+PZ5+9b8/MJ7/Hp1W854HC6uRqhIJTHfbNZ9JXYfGNBfinX0tOfDgTJcTChJKnna8z2JcUV
        GAoLKrlGcelzzTz2HC1JZs0zv5xUYCwmvNT1Y+NTA6MXDOggoOPo5UJDCbEVbt7FJe86MeSBoHxb
        yKLZEmsOeRVphWKTZ2C43jV/3mxTj8NdJ7HLA8F7+Xk2h5hwSgPBi+lmFfjkGRgSHuCXxwQADa7/
        kZ2V28AAAAAASUVORK5CYII=
        """),
        "ps1n0g08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAAAAABWESUoAAAABGdBTUEAAYagMeiWXwAABRpzUExU
        c2l4LWN1YmUACAAAAP8AAAAAM/8AAAAAZv8AAAAAmf8AAAAAzP8AAAAA//8AAAAzAP8AAAAzM/8A
        AAAzZv8AAAAzmf8AAAAzzP8AAAAz//8AAABmAP8AAABmM/8AAABmZv8AAABmmf8AAABmzP8AAABm
        //8AAACZAP8AAACZM/8AAACZZv8AAACZmf8AAACZzP8AAACZ//8AAADMAP8AAADMM/8AAADMZv8A
        AADMmf8AAADMzP8AAADM//8AAAD/AP8AAAD/M/8AAAD/Zv8AAAD/mf8AAAD/zP8AAAD///8AADMA
        AP8AADMAM/8AADMAZv8AADMAmf8AADMAzP8AADMA//8AADMzAP8AADMzM/8AADMzZv8AADMzmf8A
        ADMzzP8AADMz//8AADNmAP8AADNmM/8AADNmZv8AADNmmf8AADNmzP8AADNm//8AADOZAP8AADOZ
        M/8AADOZZv8AADOZmf8AADOZzP8AADOZ//8AADPMAP8AADPMM/8AADPMZv8AADPMmf8AADPMzP8A
        ADPM//8AADP/AP8AADP/M/8AADP/Zv8AADP/mf8AADP/zP8AADP///8AAGYAAP8AAGYAM/8AAGYA
        Zv8AAGYAmf8AAGYAzP8AAGYA//8AAGYzAP8AAGYzM/8AAGYzZv8AAGYzmf8AAGYzzP8AAGYz//8A
        AGZmAP8AAGZmM/8AAGZmZv8AAGZmmf8AAGZmzP8AAGZm//8AAGaZAP8AAGaZM/8AAGaZZv8AAGaZ
        mf8AAGaZzP8AAGaZ//8AAGbMAP8AAGbMM/8AAGbMZv8AAGbMmf8AAGbMzP8AAGbM//8AAGb/AP8A
        AGb/M/8AAGb/Zv8AAGb/mf8AAGb/zP8AAGb///8AAJkAAP8AAJkAM/8AAJkAZv8AAJkAmf8AAJkA
        zP8AAJkA//8AAJkzAP8AAJkzM/8AAJkzZv8AAJkzmf8AAJkzzP8AAJkz//8AAJlmAP8AAJlmM/8A
        AJlmZv8AAJlmmf8AAJlmzP8AAJlm//8AAJmZAP8AAJmZM/8AAJmZZv8AAJmZmf8AAJmZzP8AAJmZ
        //8AAJnMAP8AAJnMM/8AAJnMZv8AAJnMmf8AAJnMzP8AAJnM//8AAJn/AP8AAJn/M/8AAJn/Zv8A
        AJn/mf8AAJn/zP8AAJn///8AAMwAAP8AAMwAM/8AAMwAZv8AAMwAmf8AAMwAzP8AAMwA//8AAMwz
        AP8AAMwzM/8AAMwzZv8AAMwzmf8AAMwzzP8AAMwz//8AAMxmAP8AAMxmM/8AAMxmZv8AAMxmmf8A
        AMxmzP8AAMxm//8AAMyZAP8AAMyZM/8AAMyZZv8AAMyZmf8AAMyZzP8AAMyZ//8AAMzMAP8AAMzM
        M/8AAMzMZv8AAMzMmf8AAMzMzP8AAMzM//8AAMz/AP8AAMz/M/8AAMz/Zv8AAMz/mf8AAMz/zP8A
        AMz///8AAP8AAP8AAP8AM/8AAP8AZv8AAP8Amf8AAP8AzP8AAP8A//8AAP8zAP8AAP8zM/8AAP8z
        Zv8AAP8zmf8AAP8zzP8AAP8z//8AAP9mAP8AAP9mM/8AAP9mZv8AAP9mmf8AAP9mzP8AAP9m//8A
        AP+ZAP8AAP+ZM/8AAP+ZZv8AAP+Zmf8AAP+ZzP8AAP+Z//8AAP/MAP8AAP/MM/8AAP/MZv8AAP/M
        mf8AAP/MzP8AAP/M//8AAP//AP8AAP//M/8AAP//Zv8AAP//mf8AAP//zP8AAP////8AACL/aC4A
        AABBSURBVHicY2RgJAAUCMizDAUFjA8IKfj3Hz9geTAcFDDKEZBnZKJ5XAwGBYyP8Mr+/8/4h+Zx
        MRgUMMrglWVkBABQ5f5xNeLYWQAAAABJRU5ErkJggg==
        """),
        "basi0g02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgAgAAAAFrpg0fAAAABGdBTUEAAYagMeiWXwAAAFFJREFU
        eJxjUGLoYADhcoa7YJyTw3DsGJSUlgYxNm5EZ7OuZ13PEPUh6gMDkMHKAGRE4RZDSCBkEUpIUscQ
        uuo/GMMZGAIMMEEEA6YKwaCSOQCcUoBNhbbZfQAAAABJRU5ErkJggg==
        """),
        "basi0g16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAAAAAFxhsn9AAAABGdBTUEAAYagMeiWXwAAAOJJREFU
        eJy1kTsOwjAQRMdJCqj4XYHD5DAcj1Okyg2okCyBRLOSC0BDERKCI7xJVmgaa/X8PFo7oESJEtka
        TeLDjdjjgCMe7eTE96FGd3AL7HvZsdNEaJMVo0GNGm775bgwW6Afj/SAjAY+JsYNXIHtz2xYxTXi
        UoOek4AbFcCnDYEK4NMGsgXcMrGHJytkBX5HIP8FAhVANIMVIBVANMPfgUAFEM3wAVyG5cxcecY5
        /dup3LVFa1HXmA61LY59f6Ygp1Eg1gZGQaBRILYGdxoFYmtAGgXx9YmCfPD+RMHwuuAFVpjuiRT/
        //4AAAAASUVORK5CYII=
        """),
        "basn4a08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAQAAADZc7J/AAAABGdBTUEAAYagMeiWXwAAADVJREFU
        eJxj/M/AwAGFnGg0MSKcLN8ZKAMsP4a+AaNhMBoGVDFgNBBHw4AqBowG4mgYUMMAAN8qIH3E64XI
        AAAAAElFTkSuQmCC
        """),
        "s37i3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACUAAAAlBAMAAAFAtw2mAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAAP5JREFUeJxlkDsSgjAQhv8RHfFR6A0cTsBMLmDhAWjsrajpaFNS0tqlprK3yQFyKDcb8jD5
        GJLMssu3G2CS0EZDiBYTnY0Bat59DHxuBYG6nihgLBAcmSywm+Sclr9qjkvOKSOIESmxqOPCKNzQ
        OG4Yx/3IDFAICU2TJDAglhUVEzYhYaA/2JFco4tacyEq4YhWGH02brigp0pfG0QQntiQu5S11vUN
        dzk8dmgx1FaxV1+rTWza19bWS3xTPuj7F70pL7xnvP+Z8aRn90zp8CB4CdxxJXgJXIATiXIvtVJ4
        C8hb0OVK5ppzyUa1FE5rLb04FN4OuZdG367zplJ6fx0nFJojsT+zAAAAAElFTkSuQmCC
        """),
        "s36i3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACQAAAAkBAMAAAFkKbU9AAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAANlJREFUeJyNkb0KgzAURj/b+tO36CJdxUnBob5Ru3YKuGkHF3dxcHZyDlTQx2piTaJJC4bk
        43juvUEUiCgIO6/V8d6IVptMSUZx9HhmU0IwJwWe1+aOes7mV9ZzHr6JJfPAzcORbRCMC+Whcq50
        44bIgQoKXEGhcDn4svoqZRt9mQqyBXWQrpR9lSBHElRf9ZdgLdRVkCSqnaraqnozifXN61G0sT8s
        iaINMGiqhq8rxDjpg7Fv3GUoOPFF72LvoF+/etipav4DtgosYSptELsHdXX2qaZa/jk/GoQXLvsY
        f8IAAAAASUVORK5CYII=
        """),
        "s01n3p01": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAANQTFRFAAD/injSVwAAAApJREFUeJxjYAAAAAIAAUivpHEAAAAASUVORK5CYII=
        """),
        "s40i3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACgAAAAoBAMAAAEJ15XIAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAANpJREFUeJytjrEKgzAURa/FWmv7EV2kq2RS6FD/qK5OATd1cHEXB2cn50IL+lnVUBMxr4VC
        Q97N4ZC8POT+HcexclEQp/3g8GVBnHy4JANgT5kM66zjcx1jIxKLrFfpTFndROLN6aZPmdjgTKLj
        SUwXyL6gt+MSexCWAei2YVeKjXaBpUQotAoKAWPGTtmu/B1hzViEoPCqEK1EQ2GocGyWNXCfUdYE
        i0RW7QmJQJfcIiSaALqcltaTuvlJEiP9VZ7GAa21nCYBIUFIHHQJg3huUj3NiGvSHb9pXgoWak5w
        83t4AAAAAElFTkSuQmCC
        """),
        "g25n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAABGdBTUEAA9CQ+FSITwAAAB5QTFRF
        AAAAAC0tAP//EBAA/1z//xD//wD/XFwA//////8AUlHX5QAAAGRJREFUeJy9zrENgDAMRFFbSpHW
        K7ACC7jICqzACrSUXoFtc1EkczVI+eX5FZYHncjQhoQHGa0RFzpQCh4Wih01lIKHf0KaKQtvZQyv
        cC8pRnHXaqpTzCEqziRCQo0Fyj94+Cg6NXRmxzu0UNgAAAAASUVORK5CYII=
        """),
        "tp1n3p08": blob("""
        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
        gg==
        """),
        "tp0n3p08": blob("""
        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
        """),
        "basi2c16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAIAAAHbjwF2AAAABGdBTUEAAYagMeiWXwAAAgpJREFU
        eJzVliFz4zAQhT/PGDjMYaGBgYWlPlZ4f6E/oTCFLjtYeLSwsDCBuX9wMAcLU+awV6CokSu7kWO5
        8Qns7LxZvX3PK0VJJAnWbwDrHdg8tUl9ZUVq644QQJE7OywEUEyTbdWpx+LG67G48XpY6NBD2lbw
        bw+fYuUhe2ujobdvbJ6Z6GlqKnLixPseTUUukuyWUrgHSG0Stmab4A2zjZEUsMGWHjdUYaVfdmgq
        hcNnrW9oL/U6nCo1MZF2S3i7B9jdw8l8GVDzkWdFx7mFLHPC8hJgWkZqUCcFyDOAaci56E76uUHr
        OTqX1Mn9YxSDFCCfHB00NOhH6tY4DeKR1vJqJcHrtQR/XyTYXEnw8izB00KCxycJyrkEd78luJ1J
        8PNRgiKX4OqXBPNMgryUACRI7eUYZuVlau9dfGo4XLTYDmpTjOugTm3ySA6aqE3e20E7tcl7ODhF
        bfLU/sLHpwaYPnR00IX66CCoQXdqgwc4OJc6wEE/6i8dxKBucRCP2nMQm9rkiVStYL+Geqw85Ex8
        FYmnEc+Kgd+bIZZ52W0c7D2Lu+qiASYm34x4Au2iAbLS4CObQJhoFx/BBLqLdvELTaCfaBf/xgnE
        E+3iZ/0furRogMkPgOzPABMYXrSLR7oD3yvare8xgcuJdvGOExiHaBcPmMD4RLt4ywTGLdrFnQn8
        P6Jd/B2kFN6z3xNE9wAAAABJRU5ErkJggg==
        """),
        "pp0n2c16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAIAAACsiDHgAAAABGdBTUEAAYagMeiWXwAAAohQTFRF
        AAAAAAAzAABmAACZAADMAAD/ADMAADMzADNmADOZADPMADP/AGYAAGYzAGZmAGaZAGbMAGb/AJkA
        AJkzAJlmAJmZAJnMAJn/AMwAAMwzAMxmAMyZAMzMAMz/AP8AAP8zAP9mAP+ZAP/MAP//MwAAMwAz
        MwBmMwCZMwDMMwD/MzMAMzMzMzNmMzOZMzPMMzP/M2YAM2YzM2ZmM2aZM2bMM2b/M5kAM5kzM5lm
        M5mZM5nMM5n/M8wAM8wzM8xmM8yZM8zMM8z/M/8AM/8zM/9mM/+ZM//MM///ZgAAZgAzZgBmZgCZ
        ZgDMZgD/ZjMAZjMzZjNmZjOZZjPMZjP/ZmYAZmYzZmZmZmaZZmbMZmb/ZpkAZpkzZplmZpmZZpnM
        Zpn/ZswAZswzZsxmZsyZZszMZsz/Zv8AZv8zZv9mZv+ZZv/MZv//mQAAmQAzmQBmmQCZmQDMmQD/
        mTMAmTMzmTNmmTOZmTPMmTP/mWYAmWYzmWZmmWaZmWbMmWb/mZkAmZkzmZlmmZmZmZnMmZn/mcwA
        mcwzmcxmmcyZmczMmcz/mf8Amf8zmf9mmf+Zmf/Mmf//zAAAzAAzzABmzACZzADMzAD/zDMAzDMz
        zDNmzDOZzDPMzDP/zGYAzGYzzGZmzGaZzGbMzGb/zJkAzJkzzJlmzJmZzJnMzJn/zMwAzMwzzMxm
        zMyZzMzMzMz/zP8AzP8zzP9mzP+ZzP/MzP///wAA/wAz/wBm/wCZ/wDM/wD//zMA/zMz/zNm/zOZ
        /zPM/zP//2YA/2Yz/2Zm/2aZ/2bM/2b//5kA/5kz/5lm/5mZ/5nM/5n//8wA/8wz/8xm/8yZ/8zM
        /8z///8A//8z//9m//+Z///M////Y7C7UQAAAOVJREFUeJzVlsEKgzAQRKfgQX/Lfrf9rfaWHgYD
        koYmZpPMehiGReQ91qCPEEIAPi/gmu9kcnN+GD0nM1/O4vNad7cC6850KHCiM5fz7fJwXdEBYPOy
        gV/o7PICeXSmsMA/dKbkGShD51xsAzXo7DIC9ehMAYG76MypZ6ANnfNJG7BAZx8uYIfOHChgjR4F
        +MfuDx0AtmfnDfREZ+8m0B+9m8Ao9Chg9x0Yi877jTYwA529WWAeerPAbPQoUH8GNNA5r9yAEjp7
        sYAeerGAKnoUyJ8BbXTOMxvwgM6eCPhBTwS8oTO/5kL+Xge7xOwAAAAASUVORK5CYII=
        """),
        "basi0g01": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgAQAAAAEsBnfPAAAABGdBTUEAAYagMeiWXwAAAJBJREFU
        eJwtjTEOwjAMRd/GgsQVGHoApC4Zergeg7En4AxWOQATY6WA2FgsZckQNXxLeLC/v99PcBaMGees
        uXCj8tHe2Wlc5b9ZY9/ZKq9Mn9kn6kSeZIffW5w255m5G98IK01L1AFP5AFLAat6F67mlNKNMoot
        Y4N6cEUeFkhwLZqf9KEdL3pRqiHloYx//QCU41EdZhgi8gAAAABJRU5ErkJggg==
        """),
        "g10n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAABGdBTUEAAYagMeiWXwAAAB5QTFRF
        AAAAqakAAP///6r/VFQA/wD/AH9///////8A/1X/7g7bWgAAAGNJREFUeJxj6ACCUCBIAwIlIGBA
        FmAAAfqoEASCmUAAV4EsQEcVLkBgDARwFcgClKkwME5LYENWwWCcxpaApoKNAaICBMrLC8rTGKAq
        4AJALUgqGNjZgIYiqSgvh7sDWYBMFQBG4oXJmToRDgAAAABJRU5ErkJggg==
        """),
        "basn3p08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAABGdBTUEAAYagMeiWXwAAAwBQTFRF
        IkQA9f/td/93y///EQoAOncAIiL//xH/EQAAIiIA/6xVZv9m/2Zm/wH/IhIA3P//zP+ZRET/AFVV
        IgAAy8v/REQAVf9Vy8sAMxoA/+zc7f//5P/L/9zcRP9EZmb/MwAARCIA7e3/ZmYA/6RE//+q7e0A
        AMvL/v///f/+//8BM/8zVSoAAQH/iIj/AKqqAQEARAAAiIgA/+TLulsAIv8iZjIA//+Zqqr/VQAA
        qqoAy2MAEf8R1P+qdzoA/0RE3GsAZgAAAf8BiEIA7P/ca9wA/9y6ADMzAO0A7XMA//+ImUoAEf//
        dwAA/4MB/7q6/nsA//7/AMsA/5mZIv//iAAA//93AIiI/9z/GjMAAACqM///AJkAmQAAAAABMmYA
        /7r/RP///6r/AHcAAP7+qgAASpkA//9m/yIiAACZi/8RVf///wEB/4j/AFUAABER///+//3+pP9E
        Zv///2b/ADMA//9V/3d3AACI/0T/ABEAd///AGZm///tAAEA//XtERH///9E/yL//+3tEREAiP//
        AAB3k/8iANzcMzP//gD+urr/mf//MzMAY8sAuroArP9V///c//8ze/4A7QDtVVX/qv//3Nz/VVUA
        AABm3NwA3ADcg/8Bd3f//v7////L/1VVd3cA/v4AywDLAAD+AQIAAQAAEiIA//8iAEREm/8z/9Sq
        AABVmZn/mZkAugC6KlUA/8vLtP9m/5sz//+6qgCqQogAU6oA/6qqAADtALq6//8RAP4AAABEAJmZ
        mQCZ/8yZugAAiACIANwA/5MiAADc/v/+qlMAdwB3AgEAywAAAAAz/+3/ALoA/zMz7f/t/8SIvP93
        AKoAZgBmACIi3AAA/8v/3P/c/4sRAADLAAEBVQBVAIgAAAAiAf//y//L7QAA/4iIRABEW7oA/7x3
        /5n/AGYAuv+6AHd3c+0A/gAAMwAzAAC6/3f/AEQAqv+q//7+AAARIgAixP+IAO3tmf+Z/1X/ACIA
        /7RmEQARChEA/xER3P+6uv//iP+IAQAB/zP/uY7TYgAAAbFJREFUeJwNwQcACAQQAMBHqIxIZCs7
        Mwlla1hlZ+8VitCw9yoqNGiYDatsyt6jjIadlVkysve+u5jC9xTmV/qyl6bcJR7kAQZzg568xXmu
        E2lIyUNM5So7OMAFIhvp+YgGvEtFNnOKeJonSEvwP9NZzhHiOfLzBXPoxKP8yD6iPMXITjP+oTdf
        sp14lTJMJjGtOMFQfiFe4wWK8BP7qUd31hBNqMos2tKYFbRnJdGGjTzPz2yjEA1ZSKymKCM5ylaW
        cJrZxCZK8jgfU4vc/MW3xE7K8RUvsZb3Wc/XxCEqk4v/qMQlFvMZcZIafMOnLKM13zGceJNqPMU4
        KnCQAqQgbrKHpXSgFK/Qn6REO9YxjWE8Sx2SMJD4jfl8wgzy0YgPuEeUJQcD6EoWWpCaHsQkHuY9
        RpGON/icK0RyrvE680jG22TlHaIbx6jLnySkF+M5QxzmD6pwkTsMoSAdidqsojipuMyHzOQ4sYgf
        yElpzjKGErQkqvMyC7jFv9xmBM2JuTzDRDLxN4l4jF1EZjIwmhfZzSOMpT4xiH70IQG/k5En2UKc
        owudycsG8jCBmtwHgRv+EIeWyOAAAAAASUVORK5CYII=
        """),
        "z00n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAMK0lEQVR42gEgDN/zAf//APgAAPgA
        APcAAPgAAPgAAPgAAPcAAPgAAPgAAPgAAPgAAPcAAPgAAPgAAPgAAPcAAPgAAPgAAPgAAPcAAPgA
        APgAAPgAAPgAAPcAAPgAAPgAAPgAAPcAAPgAAPgAAAQA+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAgEAPgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAIBAD3
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAACAAACQQA+AAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAgAAAgAAAkAAAgEAPgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAIAAAJAAAI
        AAAIBAD4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAACAAACQAACAAACAAACAQA9wAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAgAAAgAAAkAAAgAAAgAAAgAAAkEAPgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAIAAAJAAAIAAAI
        AAAIAAAJAAAIBAD4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAACAAACQAACAAACAAACAAACQAACAAACAQA+AAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAgAAAgAAAkAAAgAAAgAAAgAAAkAAAgAAAgAAAgEAPgAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAIAAAJAAAIAAAIAAAI
        AAAJAAAIAAAIAAAIAAAIBAD3AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAACAAACAAACQAACAAACAAACAAACQAACAAACAAACAAACAAACQQA
        +AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAgAAAgAAAkAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAgAAAkAAAgEAPgAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAIAAAJAAAIAAAIAAAIAAAJ
        AAAIAAAIAAAIAAAIAAAJAAAIAAAIBAD4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAACAAACAAACQAACAAACAAACAAACQAACAAACAAACAAACAAACQAACAAA
        CAAACAQA9wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgA
        AAgAAAkAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAkEAPgAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAIAAAJAAAIAAAIAAAIAAAJAAAI
        AAAIAAAIAAAIAAAJAAAIAAAIAAAIAAAJAAAIBAD4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAAAAAACAAACAAACQAACAAACAAACAAACQAACAAACAAACAAACAAACQAACAAACAAA
        CAAACQAACAAACAQA+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAgA
        AAkAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAkAAAgAAAgAAAgEAPcAAAAA
        AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAIAAAJAAAIAAAIAAAIAAAJAAAIAAAI
        AAAIAAAIAAAJAAAIAAAIAAAIAAAJAAAIAAAIAAAIAAAJBAD4AAAAAAAAAAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAAAAAACAAACAAACQAACAAACAAACAAACQAACAAACAAACAAACAAACQAACAAACAAACAAA
        CQAACAAACAAACAAACQAACAQA+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAgAAAkA
        AAgAAAgAAAgAAAkAAAgAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAkAAAgAAAgE
        APgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAIAAAJAAAIAAAIAAAIAAAJAAAIAAAIAAAI
        AAAIAAAJAAAIAAAIAAAIAAAJAAAIAAAIAAAIAAAJAAAIAAAIAAAIBAD4AAAAAAAAAAAAAAAAAAAA
        AAAAAAAAAAAACAAACAAACQAACAAACAAACAAACQAACAAACAAACAAACAAACQAACAAACAAACAAACQAA
        CAAACAAACAAACQAACAAACAAACAAACAQA9wAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAgAAAkAAAgA
        AAgAAAgAAAkAAAgAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAkAAAgAAAgAAAgA
        AAgAAAkEAPgAAAAAAAAAAAAAAAAAAAAAAAAIAAAIAAAJAAAIAAAIAAAIAAAJAAAIAAAIAAAIAAAI
        AAAJAAAIAAAIAAAIAAAJAAAIAAAIAAAIAAAJAAAIAAAIAAAIAAAIAAAJAAAIBAD4AAAAAAAAAAAA
        AAAAAAAACAAACAAACQAACAAACAAACAAACQAACAAACAAACAAACAAACQAACAAACAAACAAACQAACAAA
        CAAACAAACQAACAAACAAACAAACAAACQAACAAACAQA+AAAAAAAAAAAAAAAAAgAAAgAAAkAAAgAAAgA
        AAgAAAkAAAgAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAgA
        AAkAAAgAAAgAAAgEAPcAAAAAAAAAAAAIAAAIAAAJAAAIAAAIAAAIAAAJAAAIAAAIAAAIAAAIAAAJ
        AAAIAAAIAAAIAAAJAAAIAAAIAAAIAAAJAAAIAAAIAAAIAAAIAAAJAAAIAAAIAAAIAAAJBAD4AAAA
        AAAACAAACAAACQAACAAACAAACAAACQAACAAACAAACAAACAAACQAACAAACAAACAAACQAACAAACAAA
        CAAACQAACAAACAAACAAACAAACQAACAAACAAACAAACQAACAQA+AAAAAgAAAgAAAkAAAgAAAgAAAgA
        AAkAAAgAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAkAAAgAAAgAAAgAAAgAAAkA
        AAgAAAgAAAgAAAkAAAgAAAhVk05uHxPwlQAAAABJRU5ErkJggg==
        """),
        "basi0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAAHk5vi/AAAABGdBTUEAAYagMeiWXwAAAK5JREFU
        eJxljlERwjAQRBccFBwUHAQchDoodRDqINRBwEHBQcFBwEGRECRUA5lJmM7Nftzs7bub28OywrZF
        dUX7xLrBvkNzR/fGanc8I9YNsV6I9cViczilQWwuaRqbR1qJzSftoSiVro39q0PWHlkHZPXIOiJr
        QNZpvsMH+TJHcBaHcjq/Mf+DoihLpbSua2OsZSCtcwyk7XsG0g4DA2m9ZyDtODKQNgQG0k4TgR8n
        geup000HFgAAAABJRU5ErkJggg==
        """),
        "s34n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACIAAAAiBAMAAADIaRbxAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAAG1JREFUeJyVz7ENgCAQBdBfIIlb2NDbMpYb0LMEFZMwGKcWJv9HwSsu5CX8uwPOOnKNod0d
        KtbhSHY0EiwkBYHEglk0OW4yPfwXqHhOTraPG234vCcFYykqKwtUeFZS8Sx2NUjqhFz1LVl+vUgH
        rMXtiDoroU4AAAAASUVORK5CYII=
        """),
        "s35n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACMAAAAjBAMAAADs965qAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAACdQTFRFAAAA/wB3AP//AP8AdwD/AHf/d/8A/wD//wAAAP93//8A/3cAAAD/9b8G
        OwAAAMdJREFUeJxl0SEOg0AQheHXtJSmmPYGhBOQcIEKDoDBo9C42spKLA6Nqq/hAHuoPqZhM7P7
        E0asmOyXBbbeqpec4Kv6YFkWXBfVjL7v+Ks6VBWOla7ENGIyjSi4vdDlaPklraqBc27dhm9FzWTs
        PfBkMvYG3JmMvZv4QmNGlTXOvFdo5FFkDCoD4N8YRqPhsSbgsdXyTt7oeak3et5BjIZ3EaPhZVwv
        76h4kuWdN3JMjIwjImMOa0zEaY3Ocb021tsVrJE+pMMPA+LuR86i5UgAAAAASUVORK5CYII=
        """),
        "s03i3p01": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAMAAAADAQMAAAEb4RdqAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAZQTFRFAP8A/3cAseWlnwAAAAxJREFUeJxjYIADBwAATABB2snmHAAAAABJRU5E
        rkJggg==
        """),
        "s02i3p01": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAIAAAACAQMAAAE/f6/xAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAANQTFRFAP//GVwvJQAAAAtJREFUeJxjYAABAAAGAAH+jGfIAAAAAElFTkSuQmCC
        """),
        "s08i3p02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAgAAAAIAgMAAAHOZmaOAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAxQTFRFAP//dwD/d/8A/wAAqrpZHAAAACVJREFUeJxjYAACASB+wGDHoAWk9zDM
        YVjBoLWCQbeCQf8HUAAAUNcF93DTSq8AAAAASUVORK5CYII=
        """),
        "s09i3p02": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJAgMAAAHq+N4VAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAxQTFRFAP8AAHf//wD//3cA/1YAZAAAACNJREFUeJxjYEACC4BYC4wYGF4zXAdi
        Bgb7/wwMltEQDGQDAHX/B0YWjJcDAAAAAElFTkSuQmCC
        """),
        "tbwn3p08": blob("""
        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
        28AAAAAASUVORK5CYII=
        """),
        "g05n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAABGdBTUEAANbY1E9YMgAAARVJREFU
        eJzlljkOwjAQRcdS2EJEQUdDiWiochI4aG5Cj7gADaJA7ItCwSJC8iR/cMdUzvjHL8+xorjcqssZ
        zGSuuj+ubkdnAAwG1f055A24COh2aSUoEI4ukO90RIBqkCQigAwI0G6LANUgjkWAatBqiQDVQAao
        Bs2mCCCDE+QbDRHwfwYyQDWo10UAGQTbomAGV+iTwRHyCQH20A9mQADVoFaDCSoyIECwU3SA/IdB
        mrrptLjGxMzMsuflLwajkfvo2OS59Gvwi8Fslg+HruCUeRvQoSi/5ELH3+BLQLnIYOcB6PWcmfX7
        brHIH49c3iIy2HoAlsu3u7PS4F5ksPEAeBUZrCEfRSKADFaQD2ZAf8uhvkU3ajlNmZwVLFcAAAAA
        SUVORK5CYII=
        """),
        "g04n2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAABGdBTUEAAK/INwWK6QAAATBJREFU
        eJzVlj1uwkAQRr+VzJ+MRAMFBS0FB+AG8aF9hByAgoKGgoJIKFIifpLIFBiwg1+cT3GTKaz1eHfe
        vJ3GIVN1BMGXNFTnn6rT0ScA5vPq/DPsF3ARMBxSJQgQRsBgYAJcg37fBLgGcWwCXINezwS4BjaA
        DD5gf7drAlwDG+DOoNMxAWRAV9RumwB3Bv/fwAa4Bq2WCSCDE+xHgy/IuwYxGRDANcArOkCeDGwA
        BRkcmwL8xWA2C5IWi3KNRJKUXl9dgyjKF9NpWC6z4iKvnpYXZEAzuwFWq+wxeW/8FmRAgG8zmEzC
        ev3QZFIgkcEeAPdmpfE4bDY/Vhcb1AJGo3BhSNpus7xucmWobgbvdYDdrnw0LTyLQQZvdYDfBhm8
        NgUgg5emAGRAf8tNGZwBkU1XhkiDotcAAAAASUVORK5CYII=
        """),
        "ch2n3p08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAABGdBTUEAAYagMeiWXwAAAwBQTFRF
        IkQA9f/td/93y///EQoAOncAIiL//xH/EQAAIiIA/6xVZv9m/2Zm/wH/IhIA3P//zP+ZRET/AFVV
        IgAAy8v/REQAVf9Vy8sAMxoA/+zc7f//5P/L/9zcRP9EZmb/MwAARCIA7e3/ZmYA/6RE//+q7e0A
        AMvL/v///f/+//8BM/8zVSoAAQH/iIj/AKqqAQEARAAAiIgA/+TLulsAIv8iZjIA//+Zqqr/VQAA
        qqoAy2MAEf8R1P+qdzoA/0RE3GsAZgAAAf8BiEIA7P/ca9wA/9y6ADMzAO0A7XMA//+ImUoAEf//
        dwAA/4MB/7q6/nsA//7/AMsA/5mZIv//iAAA//93AIiI/9z/GjMAAACqM///AJkAmQAAAAABMmYA
        /7r/RP///6r/AHcAAP7+qgAASpkA//9m/yIiAACZi/8RVf///wEB/4j/AFUAABER///+//3+pP9E
        Zv///2b/ADMA//9V/3d3AACI/0T/ABEAd///AGZm///tAAEA//XtERH///9E/yL//+3tEREAiP//
        AAB3k/8iANzcMzP//gD+urr/mf//MzMAY8sAuroArP9V///c//8ze/4A7QDtVVX/qv//3Nz/VVUA
        AABm3NwA3ADcg/8Bd3f//v7////L/1VVd3cA/v4AywDLAAD+AQIAAQAAEiIA//8iAEREm/8z/9Sq
        AABVmZn/mZkAugC6KlUA/8vLtP9m/5sz//+6qgCqQogAU6oA/6qqAADtALq6//8RAP4AAABEAJmZ
        mQCZ/8yZugAAiACIANwA/5MiAADc/v/+qlMAdwB3AgEAywAAAAAz/+3/ALoA/zMz7f/t/8SIvP93
        AKoAZgBmACIi3AAA/8v/3P/c/4sRAADLAAEBVQBVAIgAAAAiAf//y//L7QAA/4iIRABEW7oA/7x3
        /5n/AGYAuv+6AHd3c+0A/gAAMwAzAAC6/3f/AEQAqv+q//7+AAARIgAixP+IAO3tmf+Z/1X/ACIA
        /7RmEQARChEA/xER3P+6uv//iP+IAQAB/zP/uY7TYgAAAgBoSVNUAAQABAAEAAQABAAEAAQABAAE
        AAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQA
        BAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAE
        AAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQA
        BAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAE
        AAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQA
        BAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAE
        AAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQA
        BAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAE
        AAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAAQABAAEAARNzPXjAAABsUlEQVR4nA3BBwAI
        BBAAwEeojEhkKzszCWVrWGVn7xWK0LD3Kio0aJgNq2zK3qOMhp2VWTKy9767mML3FOZX+rKXptwl
        HuQBBnODnrzFea4TaUjJQ0zlKjs4wAUiG+n5iAa8S0U2c4p4midIS/A/01nOEeI58vMFc+jEo/zI
        PqI8xchOM/6hN1+ynXiVMkwmMa04wVB+IV7jBYrwE/upR3fWEE2oyiza0pgVtGcl0YaNPM/PbKMQ
        DVlIrKYoIznKVpZwmtnEJkryOB9Ti9z8xbfETsrxFS+xlvdZz9fEISqTi/+oxCUW8xlxkhp8w6cs
        ozXfMZx4k2o8xTgqcJACpCBusoeldKAUr9CfpEQ71jGNYTxLHZIwkPiN+XzCDPLRiA+4R5QlBwPo
        ShZakJoexCQe5j1GkY43+JwrRHKu8TrzSMbbZOUdohvHqMufJKQX4zlDHOYPqnCROwyhIB2J2qyi
        OKm4zIfM5DixiB/ISWnOMoYStCSq8zILuMW/3GYEzYm5PMNEMvE3iXiMXURmMjCaF9nNI4ylPjGI
        fvQhAb+TkSfZQpyjC53JywbyMIGa3AeBG/4Qh5bI4AAAAABJRU5ErkJggg==
        """),
        "bgai4a16": blob("""
        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
        RK5CYII=
        """),
        "cdfn2c08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAAAgAAAAgCAIAAACgkq6HAAAABGdBTUEAAYagMeiWXwAAAANzQklU
        BAQEd/i1owAAAAlwSFlzAAAAAQAAAAQAMlIwkwAAASdJREFUeJxV0mFx7DAMBOCvmRAQBVMIhVAI
        haNwFPogvFI4CA2FQGggVBDcH3acNpMZja1daVfWWwWClWRvZ3OPGwGSA6YOjw5QepxgcX+lg2ZY
        Kc7BXNip1G9f1bP6X9WqvqtMregBTk691NTCcbUYCXX19d0qbuqyVvVTDZNwdjWFJS+/c/PEw/5Q
        ZNnTGa1HIsNHeAUlEc0gztheyguRLlWN8XRs2Vv0Hm12xRGt5j2rS/qY753w6+oPI+OefuPNA/Ky
        HuISZZYCJf+VyKVrlINR8nyw3I95MRy2XeCMwSiwK0FGSwxGODk4yyV8lgpP0o612UlTU3EtjXL5
        nNozrQTLr8RbxZMix9Z9cDQfxz1B2kK0WY0dabc5EtlRf0B1/Ku63McfFzN1pnMg8LcAAAAASUVO
        RK5CYII=
        """),
        "basn6a08": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAAYagMeiWXwAAAG9JREFU
        eJzt1jEKgDAMRuEnZGhPofc/VQSPIcTdxUV4HVLoUCj8H00o2YoBMF57fpz/ujODHXUFRwPKBqj5
        DVigB041HiJ9gFyCVOMbsEIPXNwuAHkgiJL/4qABNqB7QAeUPBAE2QAZUDZAfwEb8ABSIBqcFg+4
        TAAAAABJRU5ErkJggg==
        """),
        "g07n3p04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAMAAACBVGfHAAAABGdBTUEAARFwiTtYVgAAAB5QTFRF
        AAAAAP//AJycv78A/3b/dnYA/wD///////8A/7//TpdUbAAAAFxJREFUeJxj6ACCNCBQAgJBIGBA
        FmAAAfqoMAYCFyCAq0AWoKOKUCCYCQRwFcgClKmYMFOJCUUFA1gAuwoQKC8vKFdiYoKogAswMCCr
        YGBnUkJRUV4OdweyAJkqACOga73pcj3PAAAAAElFTkSuQmCC
        """),
        "oi4n2c16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAIAAACsiDHgAAAABGdBTUEAAYagMeiWXwAAAGNJREFU
        eJzVlsEKgzAQRKfgQX/Lfrf9rfaWHgYDkoYmZpPMehiGReQ91qCPEEIAPi/gmu9kcnN+GD0nM1/O
        4vNad7cC6850KHCiM5fz7fJwXdEBYPOygV/o7PICeXSmsMA/dKbkGShDblRaWAAAAB1JREFU51xs
        AzXo7DIC9ehMAYG76MypZ6ANnfNJG7BAZx9l6MXmAAAAY0lEQVQuYIfOHChgjR4F+MfuDx0Atmfn
        DfREZ+8m0B+9m8Ao9Chg9x0Yi877jTYwA529WWAeerPAbPQoUH8GNNA5r9yAEjp7sYAeerGAKnoU
        yJ8BbXTOMxvwgM6eCPhBTwS8oTO/5kIg4uIpAAAAAklEQVT+XnoXDXoAAAAASUVORK5CYII=
        """),
        "oi4n0g16": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgEAAAAAAGgflrAAAABGdBTUEAAYagMeiWXwAAAB9JREFU
        eJzV0jEKwDAMQ1E5W+9/xtygk8AoezLVKgSj2Y8/OIdtk98AAAAfSURBVICnuFcTE2OgOoJgHQiZ
        AN2C9kDKBOgW3AZCJkC3oD3Oo8vsAAAAAklEQVSQMsVtZiAAAAAeSURBVAG6BbeBkAnQLWgPpExg
        P28H7E/0GTjPfwAW2EvYX7J6X30AAAAASUVORK5CYII=
        """),
        "ctfn0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAACT4cgpAAAABGdBTUEAAYagMeiWXwAAABtpVFh0
        VGl0bGUAAABmaQBPdHNpa2tvAFBuZ1N1aXRl8x/ISQAAADlpVFh0QXV0aG9yAAAAZmkAVGVraWrD
        pABXaWxsZW0gdmFuIFNjaGFpayAod2lsbGVtQHNjaGFpay5jb20pTbKY1QAAAEhpVFh0Q29weXJp
        Z2h0AAAAZmkAVGVraWrDpG5vaWtldWRldABDb3B5cmlnaHQgV2lsbGVtIHZhbiBTY2hhaWssIEth
        bmFkYSAyMDExGP2/hwAAAOtpVFh0RGVzY3JpcHRpb24AAABmaQBLdXZhdXMAa29rb2VsbWEgam91
        a29uIGt1dmlhIGx1b3R1IHRlc3RhdGEgZXJpIHbDpHJpLXR5eXBwaXNpw6QgUE5HLW11b2Rvc3Nh
        LiBNdWthbmEgb24gbXVzdGF2YWxrb2luZW4sIHbDpHJpLCBwYWxldHRlZCwgYWxwaGEta2FuYXZh
        LCBhdm9pbXV1ZGVuIG11b2Rvc3NhLiBLYWlra2kgYml0LXN5dnl5ZGVzc8OkIG11a2FhbiBzYWxs
        aXR0dWEgc3BlYyBvbiDigIvigItsw6RzbsOkLsc2cVkAAAA/aVRYdFNvZnR3YXJlAAAAZmkAT2hq
        ZWxtaXN0b3QATHVvdHUgTmVYVHN0YXRpb24gdsOkcmnDpCAicG5tdG9wbmciLlFtpV0AAAAtaVRY
        dERpc2NsYWltZXIAAABmaQBWYXN0dXV2YXBhdXNsYXVzZWtlAEZyZWV3YXJlLvx3Hi8AAABISURB
        VCiRY/gPBsbGLi6hoWlp5eUMZAkoKSG4HR3kCfz/j+DOnEmeAAqXgTwBBHfVKvIE0LhkCSC4u3ef
        OUOeAILLAAGkCwAA+XLyQRLQxL0AAAAASUVORK5CYII=
        """),
        "ctgn0g04": blob("""
        iVBORw0KGgoAAAANSUhEUgAAACAAAAAgBAAAAACT4cgpAAAABGdBTUEAAYagMeiWXwAAACBpVFh0
        VGl0bGUAAABlbADOpM6vz4TOu86/z4IAUG5nU3VpdGUgh0C5AAAARmlUWHRBdXRob3IAAABlbADO
        o8+FzrPOs8+BzrHPhs6tzrHPggBXaWxsZW0gdmFuIFNjaGFpayAod2lsbGVtQHNjaGFpay5jb20p
        1io2ZgAAAIlpVFh0Q29weXJpZ2h0AAAAZWwAzqDOvc61z4XOvM6xz4TOuc66zqwgzrTOuc66zrHO
        uc+OzrzOsc+EzrEAzqDOvc61z4XOvM6xz4TOuc66zqwgzrTOuc66zrHOuc+OzrzOsc+EzrEgU2No
        YWlrIHZhbiBXaWxsZW0sIM6azrHOvc6xzrTOrM+CIDIwMTHXI+R2AAAB9WlUWHREZXNjcmlwdGlv
        bgAAAGVsAM6gzrXPgc65zrPPgc6xz4bOrgDOnM65zrEgz4PPhc67zrvOv86zzq4gzrHPgM+MIM6t
        zr3OsSDPg8+Nzr3Ov867zr8gzrXOuc66z4zOvc+Jzr0gz4DOv8+FIM60zrfOvM65zr/Phc+BzrPO
        rs64zrfOus6xzr0gzrPOuc6xIM+EzrcgzrTOv866zrnOvM6uIM+Ez4nOvSDOtM65zrHPhs+Mz4HP
        ic69IM+Hz4HPic68zqzPhM+Jzr0tz4TPjc+Az4nOvSDPhM6/z4UgzrzOv8+Bz4bOriBQTkcuIM6g
        zrXPgc65zrvOsc68zrLOrM69zr/Ovc+EzrHOuSDOv865IM6xz4PPgM+Bz4zOvM6xz4XPgc61z4Is
        IM+Hz4HPjs68zrEsIHBhbGV0dGVkLCDOvM61IM6szrvPhs6xIM66zrHOvc6szrvOuSwgzrzOtSDO
        vM6/z4HPhs6tz4Igz4TOt8+CIM60zrnOsc+GzqzOvc61zrnOsc+CLiDOjM67zr/OuSDOu86vzrPO
        vy3Oss6szrjOtyDOtc+AzrnPhM+Bzq3PgM61z4TOsc65IM+Dz43OvM+Gz4nOvc6xIM68zrUgz4TO
        vyBzcGVjIM61zq/Ovc6xzrkgz4DOsc+Bz4zOvc+EzrXPgi6miCkYAAAAiWlUWHRTb2Z0d2FyZQAA
        AGVsAM6bzr/Os865z4POvM65zrrPjADOlM63zrzOuc6/z4XPgc6zzq7OuM63zrrOtSDPg861IM6t
        zr3OsSDPh8+Bz47OvM6xIE5lWFRzdGF0aW9uIM+Hz4HOt8+DzrnOvM6/z4DOv865z47Ovc+EzrHP
        giAicG5tdG9wbmciLkN4y+sAAABDaVRYdERpc2NsYWltZXIAAABlbADOkc+Azr/PgM6/zq/Ot8+D
        zrcAzpTPic+BzrXOrM69IM67zr/Os865z4POvM65zrrPjC4snq9sAAAAXUlEQVQokZ3OQREAIQxD
        0WjBAhawgAUsYKEWsFALWEALFrLTnd3pPcf/DpkAIEuptbXex5gTAkSSf5ppkINma2nQGvl9hLsC
        keR7KRIK5CX3vTXIBM7RIAcj7xXgAUU58kEPspNFAAAAAElFTkSuQmCC
        """),
    ]
    
    let png_test_suite_answer_data = [
        blob("""
        eJz7//8/w38MzLANgnHxERgAAxIurQ==
        """),
        blob("""
        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
        XP73
        """),
        blob("""
        eJzdljEKhTAMhr2eF/EUXsGLeAD3zs6uro6Ojsr/IBJC2ibybMHAg9KX/l+TprHn+VE7jqMqv2ma
        quyS8S/L8mOO43jza1jbtlX5sGmazr7v/66777vJ763YuW6qtkrwUwz8F0K4x/KHPNI4x9u2zcyn
        OZy/po89YW6e59s/daYxHnS6rlP9h2FQ51P79fLlOuJKTirHmoY0fodyfOScahI9KFcfuTnOpp6S
        2ztqxZNTi6YcY1/ruqrr0YOfsD18zU+rRQ87poszRaxcn/xwh6x9xuIXi1/OE9eiiXq07hF9gMek
        8a1cGPLm7cNcP8a3GPU/r3Em1TLXsXz/cD8s9ZjjP11P75/SBrbWF0qxa721a73zLL3+LXtyt7/A
        9vS/N9jyHfARuwCja5kR
        """),
        blob("""
        eJztlu1LlXcYx/0HfLtXvtr/EARjMIQYeyEyRhFiKI5gCzfEaNVIG5EPkxitGbI5JptrpuQwk9Hh
        WFvlw1B0aZaWj6nHzJzHc7Tjw+Hc313f6zr3rZkerGzsxa7Dh/tW8fe5Hn6/nwL/R8KYxDSqcR35
        +FmefgxgBDH5/BvRjEHsEit5F2eVDBxDMU5qXq8zWjGKd1CvHMQv2Icqz09OIgvdkuHriCksSM1+
        pMGn0M/+kw9xyvNXIxPtKN/xeXwplb0Xdx+R2ZMy1Kr/hPSB/f8WH6mfdKFUMojsiHsQ81p7Btrw
        MW6ouxi3UIHfNAfXT68f2cotpOM+Du9IDoXoVzehl5xFi+LmcAlnFNfdgz3KjGSHV5gF574Hf0ll
        HcjDbZ1DuTwJz6Dh9/zsew+Oa+1TkgcJS39eNodaBNSfLSvnxb3kAvrQICZCvx+Nuu9c/4jsDLoX
        kKo4zsUXdi8jKu4BcffGax9ApeyGWpkH4V1A/3XclE+TvNUp45IH+06iTpaCp9lwVnwv5O+Uzrn+
        Exh6xk834Z1AP8+96yYhfINVp8hz42GWEW7Ztr8Oj9WfL55i6ehXGNN5XMEj6feEurvwQHkgWZAp
        2ZOcN6Ff3dNHzN19wHjUvS3/IengZn66O8R0R35OeP+Pya6ne07grHXesxUG/X1Hzd2aCVyR/TA7
        ntA9I9N/W1ZkDmR97c2Y9fy8G3jvu+4I/ZxzqM6g/36B+emO+9GwP2EOHVjy/CWy8ndCjeBDUP3c
        G3TzfD6ROS1IFjHnnqIzDviMoatAe7lBt3iVikPKVjnUOlGkOhHkim+jv13cd2MRmcKy9unv2Ir6
        sTxqfs7Xdbv+a0KjUHPG3KezPJxQ+Dl/qaybLj3IwVN9r5TOMif62RvXTzfPqd6z4td66Cd90oeO
        NsBXadBNcguM/YcNvm/IgW7yyarzrD9qsxmRJ/0hOIjFHHGv2BqBOaNtAvi9X/0RXxdwvskoqTEK
        q4G0YmN3iX3NNSS4ZvqqQX/RiuO5Secy1E8i8h6dX5INu6je6Mg80PXYcHMg1b3G+jw+E3J+WsuB
        35McuO5699dS1sU4rQuydAgYFgLTSwgGo4gOiLMv6Dmda/J/0GVx18W939+RP+D+NfLqDLrJ7irz
        My+pg/WlzwD5QcP110+JP86AjDncE1TU7ZsxXG/5gFFyFzjWYmT+AaQ2GeqsUj/ns34Pskb6Sdm4
        Qbfrb5ZyxpvnMHMJSuzCkoLSWeP4Q0QLxJt721jnjaZcRviNKqtV+uVw72wI+g8OG66/ote8pLEe
        Cd3I6Dfe+lNxnYHkX5+rdbPgfD/oM3K6zF1106B7sNAIfb6Gs3fO2DWkRJJ71deTVIPF8koE7k1v
        Wutmwb1F74EbBr1HfwCuFhme/31HCb+5qO71TsJaF8OJa93KT29Wg0F32aebuydTnmB0X8Bztpzr
        0Fpj26x1s+Dvuu69X5jb9bclTXj4kzpxOvlHhd6XqXWr4Pmim5xKmVTOpY15Ptc5PDzxSrUmCq7L
        +4XwrqHLZSdr/Y/FP1zOgWI=
        """),
        blob("""
        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
        JcM=
        """),
        blob("""
        eJzNl0EOwyAMBPn/g/gezSE4hhjsqGLXQnMoyWEFzo7aSiktQgMSzlSBNJshz+KdU1QDncd6fprX
        0ndGWyrhkIdxQp37FlfzDZ+mi3rTM8y/9R6KbVXoMzteS4JXFfL9HaqiD/UkPD3OGCibJxNuoDyf
        sX03XyzTd65/wQ1lOS6d71Isptcc32UC7bK/fccBWTvx/yO4QYlnYg9P3HMMKB7bwHTZCp2H3diz
        a9P4rmeSRT4l3QNZfCd51B7Va+qM0viuZxr3WZU0fGvTM9Yg7X3L89rat/hBclz7Ayw1+TU=
        """),
        blob("""
        eJzN08sOABEMBdD+/0+b1SSTCaH30ZJYEByqHaOxRUSr3eW/dof/tWf+7l7Mvf92pT+zq/yVfeLv
        xozt9ne20z+xV+cgexDb4WfsTJ47bKWP2Nk6VtsKn7FZn7UZX2GjvrI21e92+pl4ZucVtstX5RMS
        f2U+K9ZXxZ+tZ8ZHbUX8GZv1WVv5X5V+l31BfwCG6dKs
        """),
        blob("""
        eJwlwyEMrAQAANCLRCKRSsRGJLkRLxiI2EhuJHdNmkRJjmBg++VMUgxYHJuF4obFDYtjBscMDoMB
        3+bb3uO+78DQyNjE1MzcwqellbWNL1s7ewdH307OLq5u7h6eXvf/Hv/++29gaGRsYmpmbuHT0sra
        xpetnb2Do28nZxdXN3cPTy9vH//8809gaGRsYmpmbuHT0sraxpetnb2Do28nZxdXN3cPTy9vH3//
        /XdgaGRsYmpmbuHT0sraxpetnb2Do28nZxdXN3cPTy9vH3/99VdgaGRsYmpmbuHT0sraxpetnb2D
        o28nZxdXN3cPTy9vH3/++WdgaGRsYmpmbuHT0sraxpetnb2Do28nZxdXN3cPTy9vH3/88UdgaGRs
        YmpmbuHT0sraxpetnb2Do28nZxdXN3cPTy9vH7///ntgaGRsYmpmbuHT0sraxpetnb2Do28nZxdX
        N3cPTy9vH7/99ltgaGRsYmpmbuHT0sraxpetnb2Do28nZxdXN3cPTy9vH7/++mtgaGRsYmpmbuHT
        0sraxpetnb2Do28nZxdXN3cPTy9vH7/88ktgaGRsYmpmbuHT0sraxpetnb2Do28nZxdXN3cPTy9v
        Hz///HNgaGRsYmpmbuHT0sraxpetnb2Do28nZxdXN3cPTy9vH+u6BoZGxiamZuYWPi2trG182drZ
        Ozj6dnJ2Wf+3uXt4enn7+OmnnwJDI2MTUzNzC5+WVtY2vmzt7B0cfTs5u7i6uXt4enn7+PHHHwND
        I2MTUzNzC5+WVtY2vmzt7B0cfTs5u7i6uXt4enn7+OGHHwJDI2MTUzNzC5+WVtY2vmzt7B0cfTs5
        u7i6uXt4enn7+P777wNDI2MTUzNzC5+WVtY2vmzt7B0cfTs5u7i6uXt4enn7+O677wJDI2MTUzNz
        C5+WVtY2vmzt7B0cfTs5u7i6uXt4enn7+PbbbwNDI2MTUzNzC5+WVtY2vmzt7B0cfTs5u7i6uXt4
        enn7+PDhQ2BoZGxiamZu4dPSytrGl62dvYOjbydnF1c3dw9PL28f33zzTWBoZGxiamZu4dPSytrG
        l62dvYOjbydnF1c3dw9PL28fX3/9dWBoZGxiamZu4dPSytrGl62dvYOjbydnF1c3dw9PL28fX331
        VWBoZGxiamZu4dPSytrGl62dvYOjbydnF1c3dw9PL28fX375ZWBoZGxiamZu4dPSytrGl62dvYOj
        bydnF1c3dw9PL28fX3zxRWBoZGxiamZu4dPSytrGl62dvYOjbydnF1c3dw9PL28fn3/+eWBoZGxi
        amZu4dPSytrGl62dvYOjbydnF1c3dw9PL28fn332WWBoZGxiamZu4dPSytrGl62dvYOjbydnF1c3
        dw9PL28fn376aWBoZGxiamZu4dPSytrGl62dvYOjbydnF1c3dw9PL28fn3zySWBoZGxiamZu4dPS
        ytrGl62dvYOjbydnF1c3dw9PL28fH3/8cWBoZGxiamZu4dPSytrGl62dvYOjbydnF1c3dw9PL28f
        H330UWBoZGxiamZu4dPSytrGl62dvYOjbydnF1c3dw9PL28fBIZGxiamZuYWPi2trG182drZOzj6
        dnJ2cXVz9/D08vY/EgciFw==
        """),
        blob("""
        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
        ihiK4z9fvwhM
        """),
        blob("""
        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
        """),
        blob("""
        eJzll9EOwyAIRf3/D/L33JZYS1spLHUcksWch5YmEL1ySyulNA8NwF1bBWhzDnUp3/yaOkHWNYtH
        cVnyLPElKj3URe7YRj9d7R5gantTO1st52f5LprbFiP3cFnbcmO1mHFfH7aqhe1tsPsCKbg5e23x
        grP8Moufng88g5+aPg91uJmHpvXTVIv2TIefZoTyysd+ykK0rVV++q+C0+dNVnCueRgQktvDASFZ
        uUm/tHKjM6iVe8SBnbNyjzigOHkntfcfMK+0+wjrmVo9/a7EtLSvYOfOe3LMnVY8notvajFIVKbX
        wz9wxjz8AkdEaSI=
        """),
        blob("""
        eJzFl1sOhSAMRNn/gtge3two1jKFfjBDmvlQTFrp40ArpbSMGlHpGCpRDevjP/hmlyqQ9Y/Wd2sw
        mwOZmYg+/hU78OjOSlSP9Gr4qd56fPpn+46laevaPeGNiFXr9v7Qj4eud04qCgLrjYFXECseqHnh
        E6XkxZJX5AmBGHGcF0eM+IfZ8wkz09kY2CyAfHD+ua0PNDKI2fYRezx/uAUxcgezh18A8X0hdYDY
        Is+c4d6iLIiIRaqCAFLyIOREn5MHrccg4MVynZjxGZeUvMjwij8eJjH81y/zTwMl
        """),
        blob("""
        eJztl7uNwzAQRNWeGlEVakEduAIXoNyxYqVKFTp0yMMYmMN4sCR1ou3oFlhAH4tv/6RT+pdTcr/f
        077v6fF4fI0J1rZtaZ7ndL1e0+VySdM0Pa+XZXna9Cnm7XZ7csgdxzENw/CieIZ3sAWxaWHie6zj
        voJBJRPPcd33/YstjMtRW5RJrjPJ0+d6TzZjgTW4Hm2JagbP+Tsq46wcrsl4REo7lK0+wQ4X1A5y
        TFX/WWO+luaGqjZG/kBRT1HOla92tKraCPtyPas1ju9wj1idtcW5jE1OyCebfNWjdrB20BNQ1g++
        zwnWr/FrdtBn9qMqbFjXtcqHag2QqX3kdmisWf/kdl33OxtKMxK2ef61BviOPaR2aZ6Vrdd4VxL0
        hTKiPmBv5ficf5pzziT8riSYQTrjGQOvK8+B7wnOpv/R3FFBbsjnzAGfzBrffff6q+0DmAvqP9Rn
        Qo4f7UHKxv2Rs4Lz3e+IH8Xe+aW5E/Fpg/td4mude/xLc0fFzxnK17rU/vd5E/H/ch7ROeB6hK9s
        PI/2u5poL0Z8nUu5eYtnrecwn3vK52zw/DMG7zqPaj5yfO2/0h5/Vng+c77vO7UZ2yLwSc8jzq/N
        13cJ/w8o/0yNtwjPq+C31HiLIB+f+M/1RfkBOIyUsA==
        """),
        blob("""
        eJztl/kvXXsUxf8mP9cUDYq2MQsq/aEDQprQSs0tgoRUUbPWUEVVjaWmtGqqolQl/EKCUENUDFFD
        W/bLZydHmvZRQ/NeXvJ28s257j33rrXXXnvvQ+T/OFGsr6/L3Nyc7Ozs/GOYX758kfHxcWlra5OK
        igopLi6W+/fvS1lZmQwPD8va2tofx9za2pKpqSnp7OyUZ8+eKVZmZqbcuXNHgoKC5MaNG+Ln56fX
        27dvS05Ojrx9+1aWlpZkb2/vRJhoOjMzI319fVJfXy/V1dWSn58viYmJEhISIqGhoXLz5k0JDAxU
        DgkJCeLr6yvu7u7i7e2tXLiH76HL4uKifP/+/VDMb9++aT3fv38vjY2N8uLFC803LS1NwsLCNLeI
        iAiJioqS+Ph45XL37l39jL9TUlIkMjJSOd26dUuCg4OlqKhIampq9Lf4zcHBQc0LTX+O+fl5rSv3
        NTQ06MnKylIMtOaA8/DhQ3n69KnqnJycLPfu3ZPU1FTFT0pKUl4xMTHKg/yN3zJOVVWV5vhzrKys
        SHt7u3R0dMjr16+lpaVFysvL93+fusPt5cuX+4falJaWyqNHjyQ3N1f5PnjwQK9898d76+rq5PHj
        x5KXlyeTk5O/4G9ubiruq1ev5M2bN9LT06OeQ5OmpqYTHzjDBf+gWUZGhmxsbPyCjz/Arqys3OeO
        j9+9e6dcDE1+d5qbm/WAjdYFBQX7uOnp6VJYWHigB8n3+fPnWicwwe/t7dU+6O/vVy5o8zsO1IXZ
        gF8dHR3Fw8ND+4ZZQY4HBVjg19bWKj6H98AFf2BgQD3MtaurS2tjnNbWVtUM7fBoQECAuLm5yblz
        58TMzEwPPTQ2NnYgPjjoDwe8aGjA+xx0BQsuQ0NDyoV7eA+t6Tf0pv8uXbok58+fFwsLCzExMZEz
        Z86Iv7+/fP78+UD8kZER7Xn6C9/8qAH1Rxfyo6fB//Dhg84XeIFNbem/y5cvi6urq1haWoqXl5de
        qQOf7e7uHog/MTGhc/3Jkyd6xQ+GBugLJ3DgQe4GB/wCNr119epVzd3Gxkbi4uJ0fsGBeYgvDotP
        nz5p7tSA38JL4JOfMT/Ap5cNfA56gA8euV+4cEHnH7Pj+vXrWgc7Ozu997BYXl5WfcGHN/Oru7tb
        vWzggwM+M8zgQM2oO3vIyJ25SQ0cHBzk7Nmz4uLiovkdFswg5hzaM8NKSkq0XwxOzHEDnx4wOPAd
        epvcnZycNGcfHx+xsrISc3NzPeynr1+/HorPvmSegkc+YFEzcPmb1/QWOhj9CAdqEhsbq5jW1ta6
        h3iN7zhowHw+SuAtOHDAohfxAd8nb+YofIyZxIEb+9jT01P7nD1E/el/fE/+7JWjBPXG/+gNJld8
        jxZww5fowDyAA/5k/6Av2lNr9lV0dLT6jtw5s7OzR8KnPz9+/Kh9QB3wFhpwxY9wQn9jLtKj6ITe
        4Njb22stnJ2dNfcrV65oXx83eGahr/Ai2OjAjGOXGPsBDvgT/GvXrmnt0drW1lbnLjN4YWHh2NhG
        0A/sG/ANHcCn/tTJmA14gtmO301NTXXWhoeH/5HnUXpidHR0X4Ps7GzFZ//AAS3A5xmQ3r948aLu
        2r97xjpN8DyL7/Ah+wY/w4Ea4Ul4MXPYgYfN+NPE9va27ht2EXWBA7rgSerCZyd95j5OTE9P636G
        A7OP/E/i8dPE6uqq7kX6g2fnfyP4n4H/A//D8RcippO9
        """),
        blob("""
        eJzNl1EOhCAMRLn/gbgebqJi1dI2WXg1ZD523YSJTOctrZTSImqAwl4qoKbr5mPwm9mqiqQP7fkq
        vZY8G3wJZzcf5Bs5dZzWKLdYWn6qh869n5/ld6tljrx8R+srxhv5Pk959dJ19S4ZGF2Xl/WB8XiT
        xaPnAWbwyOUi1DAagz7Do9SVwR2HR18Qwhl/PnwezVLAC1QbUaYRQYgzjeTMX39gpijMNCAwkmnm
        /QsITPQ+iHDG2DP3DqSs7iWbQVV4QSrGluQAxSOXV0TFFGM/kWmmYvx5hoMx7Ln9+QbpNW51
        """),
        blob("""
        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
        """),
        blob("""
        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
        qQ==
        """),
        blob("""
        eJzF1iHMgkAUB3DFYXEjWAwmgolkIpmMJpuRZjRSjTSizWazmUgmi4VCIVDcDG5szo05hsr/m9/G
        dnOovJNxbJfY+P929949MJ/PYVkWbNvGYrHAcrnEarXCer3GZrOB4zjYbrfY7XbY7/dwXRee58H3
        fQRBgMPhgOPxiNPphDAMcT6fcblcEEURrtcr4jhGkiS43W643+94PB5I0/R/PR/TNCHSMJvNhBqm
        06lQg2EYQg2TyUSoYTweCzWMRiOhhuFwWNhQq9UKLYphMBgUNhTNp+yDruskQ95ZsNnUs+j3+z8Z
        2GyeetA0jdvAZvPWZK/X4zKw2b/0haqqZMO7uuMxdLtdsiHLy+sLqqHT6XAZPvUmxdBut0s3UOpB
        UZTSDFk+5a5utVqlGbJ8yrxoNpuFDdn3v/UFZWbJslzYwNbYq4F9R5mbjUaD25C3qLNbkqTSDDz/
        D/V6nctQxtx8Gp5ukYZs70QZ2PMTYXitoaoNeXVcpeFdL1Vl+HSXVGD4A7mRaIA=
        """),
        blob("""
        eJzF1SHIwkAUB3B1zCIYLAaTwWRaMi0ZTTajzbhoNdqMtjXbmslkWlmxWBZWBIMgiDCGuOlfvg8O
        DnF67zZ2g0uD+/+4e+8eZrMZ5vM5FosFlsslbNvGarWC4zhYr9fYbDbYbrdwXRee52G322G/38P3
        fQRBgMPhgOPxiNPphPP5jMvlguv1ijAMEUURbrcb7vc74jhGkiR4PB54Pp//6++bTqdQabAsS6lh
        MpkoNYzHY6WG0Wik1DAcDpUaBoOBUkO/3ycbSqXSxyVjME2TZEjLljX0ej1hA5/zfheyBsMwhA1s
        /7R6YP8p9dDtdoUNbP+0mmT/KTXZ6XRIhm99wfIpfdFut3MzsHxKb7ZarVwMfP1R3odms5nZ8K0v
        fhkajUYmA58t807W63VpA58t+1bXajUpA5+dZV5Uq1Wygc/OOrN0XScZ+Ow85qamacKGX7OHLYqh
        UqkIG0TzKedQLpdJhrzean5mqTSwM1Nl4O9NheG9doo2fKrfIg1pPVSU4VsfF2B4AZxrdBQ=
        """),
        blob("""
        eJzF1iERACEAAEFiUuCTICmBIwOGBhgKYAiAwPMxdm62w70XwqMilrCCNWxgCzvYsy62sYl1rGIZ
        +zBfxBJWsIYNbGEHwwdwsY1NrGMVy9hH/WMgrBc=
        """),
        blob("""
        eJzt1mEKgCAMgNHd/0Beb5mYuNSiwPqKEfujCx+zdKoiqiGGioYYIjnWkaD1dDOQ8tMTpuV/yVds
        dN/E9e76bO3Avsnr3fHZ2nF9T6x3OX/kK+MMX/O++y7v71G47/z+IO6v+yb5IOez+9znPvf91ze4
        7wm+k57kVV/t2OXbvultXz+f7CPXr+2LOb5+387wGRPs++vVi+OrLcT/d3NQz5f2fGb56Ocz9H5T
        +9/i+oMy3bfl/AUUqTjq
        """),
        blob("""
        eJzF1gERABEAAEFZfRl6kIIORKABCXyMnZvtcO+F8KiIJaxgDRvYwg72rIttbGIdq1jGPswXsYQV
        rGEDW9jB8AFcbGMT61jFMvZRP0B4rhc=
        """),
        blob("""
        eJzt1UERADEIBLDaxQ5GkIEJNNQCJyOP3jBRAOzunrNPCyyxwhob7GL7tosN1lhhiQX2j96AvkD9
        gTqBdALrBtINjF1ssMYKSyyoD6q6lZc=
        """),
        blob("""
        eJzF1i8MgkAUBnCRaXEjWAwmgolkMpGMJJuRZjRSjTajzWazkUgkCsVCMVjcDG5uzM05B+rncLuN
        OXT3h3FsL3+/e7x3gNlshvl8jsVigeVyidVqhfV6jc1mA9d14XkefN9HEAQIwxDb7RZRFGG322G/
        3+NwOOB4POJ0OuF8PiOOY1wuF1yvV9xuN9zvdyRJgjRN8Xg88Hw+8Xq9PpU9juNApmE6nUo1TCYT
        qQbbtqUaxuOxVMNoNJJqsCxLqmE4HHIbarXap0QMpmlyG0i+SB8GgwGXgWRnJfIu+v0+l4Fki86D
        YRjMhvzZRWey1+sxG0h2GXuh6zqTIX/2Mnaz2+0yGUh2WfdDp9OhNuTPXjQPPIZ2u01tIDllzoOm
        adQGkvM9kyLz0Gq1qA35/v8rFkOz2aQ20Oaz9KHRaDAZivaiaCZpDaqqChtIPs+3u16vCxt+7QWN
        QVGUUgy8/zCZW6aB9E6WIb83Mgzfu1u1oej+qNLw6w6ryvDvHq3A8AbjkJK5
        """),
        blob("""
        eJzF1iHIwkAYBmB1aBksWAwmg8lkMi0ZTbZFm9FoXVxbtNlsaybT0sqKxbKwIiwIgggiY7q9P/5w
        cIyb3B2yG1wYg++e3b33bbBtG47jwHVdbDYbbLdb7HY7eJ6H/X6Pw+EA3/cRBAHCMMTxeMTpdEIU
        RYjjGOfzGUmS4HK54Hq94na74X6/4/F44Pl8Ik1TZFmG1+uF9/uNPM9RFMX/+Fzr9RoqDavVSqlh
        uVwqNSwWC6UGy7KUGubzuVLDbDZTaphOp8KGRqPBHDIG0zSFDFVzyxomkwm3gZ6nvBeyhvF4zG0g
        9avyQJ6L5GE0GnEbSH1WJun3F8nkcDjkNpD65UyWMyByLgaDAbeB1KczycqgyNns9/vcBlK/nIfP
        oNdBpD/0ej1uA6lP7wWdB3Iv0qO63S63gbXWrL0Q6ZOGYXAbynNX9QeRXq3rOreBnlumP7AMnU6H
        20Dqy/SHKkO73eY20O9fdTZZ/eGbQdM0aQNriH67W63Wzwwy/w/NZlPKIPLd/Gb4uFUayNqpMtD7
        p8JQzlDdBlaO6zRUnaW6DN96SQ2GPzaUT1Q=
        """),
        blob("""
        eJzF1SHMgkAUB3DBaWEjUAgmg4lEIpmMJhvRRjRSiTYjzUajmUwmi8ViIVjYCG5ujs05h+j/G263
        MYZ+3t3Gsb1A+v927707eJ6H+XyOxWIB3/exXC4RBAHCMMRqtcJ6vcZms8F2u8Vut8N+v8fhcEAU
        RTgej4jjGEmS4HQ64Xw+43K5IE1TXK9X3G433O93ZFmGx+OBPM/xfD7xer3eVXyu60KkYTabCTU4
        jiPUMJ1OhRps2xZqmEwmQg3j8VioYTQaMRtarda7eAzD4ZDJQLKL4jkHy7KoDeXsonh6YZomlaGa
        XRTPPBiG8bOhnFk+B56ZHAwGPxtIHukF+efZi36/T2Wo6wXPbvZ6PWZDuResBl3XmQ0kn+eO0jSN
        2VCdBxaDqqrMBpLPc1crisJsIPk870W322U2kHyeN6vT6TAbSD7Pu9lut6kMdfdvuWgNsixTGf7L
        pz0HSZKoDbT35DdDYRZpIOcmylDunQhDdX6aNtTNcJOGT3vUlOHbLjdg+AMO25T8
        """),
        blob("""
        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
        """),
        blob("""
        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
        """),
        blob("""
        eJztl+krp30Uxv8nb6WkJE2SJpJMXogQCtlK1pDEoDH2fRs7M3bZdwZjauYNhawTsmQYjDlPn1Nf
        mZmHsTXPm0ed7vv+3ct1neucc32/pLe3V/6P+8fR0ZFsbm7K2dnZX8P8+vWrLC4u6nltba2UlpbK
        y5cvpbq6Wj58+CCHh4dPjnl6eiorKysyPDwsdXV1ipWdnS0xMTESFBQkgYGB4uvrq8fw8HDJzc2V
        iYkJ2dnZkR8/fjwIE03X1tZkampK3r59K01NTVJQUCDJyckSFhYmEREREhISIgEBARIcHCxJSUni
        4+MjLi4u4u7urlx4hvfQ5cuXL/L9+/dbMS8uLrSe79+/l/b2dnn37p3mm5WVJZGRkfq9qKgoiY6O
        lsTEROUSFxen97hOT0/X+3AKDQ1VXtSnublZv8U3Z2dnNS80/RV/a2tLjzzX1tam8fr1a4mNjVWt
        OYJTWFgob968UZ1TU1MlLS1NMjMzFZ9rw8vf31/zN98y0djYqDn+ir+/vy8DAwMyNDQk/f390t3d
        LTU1Nfr9jIwMPYdbR0fHVVAb+qG4uFjy8/OV76tXr/TI89efbW1tlfLycn1ueXn5N/yTkxPF7evr
        k8HBQRkbG9Oe415nZ+eDA85woX/QDH7Hx8e/4dMfYNfX119xHx8fl8nJSeViNPlTdHV1aYCN1mhj
        cOmlkpKSG3uQfBsaGrROYBLMEnMwPT2tXNDmTxyoS1lZmfajo6OjzgU9iVeQ4034YIHf0tLyEz64
        4M/MzGgPcxwZGfnp3Z6eHtXMaO3n5yfOzs5ib28vVlZWGvjD58+fb8QHh5mDA3qDb2pAoCvPwWVu
        bk658Ay/oTXzht7kig88e/ZMrK2txcLCQiwtLdWndnd3b8T/+PGj4jNfv9YAPswy+XEEf35+Xv0F
        XmBTW+bPw8NDnj9/rthubm56pA7cu7y8vBF/aWlJ8SsrK9Xf6QejgfEG4ynkbjjAFWx09/T01Nxt
        bW0lISFBvQEO+Bd9cZsHbmxsaO7MAN+il8AnP+Mf4DDLBp+AD7+DR+4ODg7qf3iHt7e31oE+4Nnb
        8Pf29lRf8OGNf42OjmovX8enP/EwwwHNqDtrALnb2dmpX9J/YNvY2Gg9yO82fDwIP0N7PKyiokLn
        xXBCP5M/M2A48A6zTe5OTk6a84sXLxTX9D7czs/Pb8VnvayqqlI88gELTNYPrjmnLuhg5hEO9ER8
        fLxiUnfmnnP6jkCDvLy8O6291BIOBGsNs0gf8D55gw8f40kE3FiPXV1dNdeUlBStP/rT9/yGb90F
        n3rT/9QUTHSn79ECbqwf6IAfwIH+LCoqUs3RHs1Zr1inydvE+vr6nfCZz4WFBa0BYfyII/0IJ/Q3
        vsiMohN6mz6nFnAhd+aRub7vHog9C/nSi2CjAx7HWmK8CQ70J/heXl5ae7Sm/wk8eHt7+97Y1+eB
        uoFvdACf+lMn4w30BN6O9vgswb7oKfajzMSnT5+uOOTk5Cg+6w8c0AJ89oDMPt7DWvtve6zHBPtZ
        M/9cs0+Cg+lJeOE5rIG3efxj4tu3b7resBZRFziYOaEu3Hvonvuuwd/q6qruFeGA95H/Q3r8MXFw
        cKDrIvNh9s5/O/ifgf8D/wvsJ4p/AEjOKo4=
        """),
        blob("""
        eJzF1gERADAEBdB1lWZBtNBBhjXQwGK8c6+Aw7d7zlKBXSyxwhp72GBrDfawxgpL7GKB+dId0BOg
        N0BfAH0BdQLoBMQfwGAPa6ywxC4W1AeQH67X
        """),
        blob("""
        eJz7z/CfOPh/G26MogaIMDAWNQzbEBivGhAkpIaAOQTdQ8BfBCAAUt/IDw==
        """),
        blob("""
        eJztV0tPk1kYPn/ALStXLl2wI2HDxsSwMMQYNy6clWFhYowsSsKiiUajEdJoIyOXUkpouKcp10Ip
        tNBSWlpaCqmDop3pDAwMQQeHIW0ZLq/neb/vq0CGcpE4mzF58n2etud5L8/7nAO5XC76H6fHxsYG
        LS8v09bW1nfj3NzcpPfvE/ze0dFB7WYLjd27R/GqKkoOD1Nqff3cOdPpNCWTSfJ6vdTZ2Ul9Vis5
        nj0j340b5BeC3BIj6jMsMVtWxrH8ubZGe3t7Z+JETRcXF2lqaop6e3up22ZjTuQalBxRiaDK67h6
        lbp1OqrLz88CsQQuX6YhGW8sFqPV1VXa2dnJyYnP0c/p6WkaGBigvr4+zhWc2AuccxILEisqEuoa
        aoHvIZYRtQ6oDfpjt9t5L+wZiUQ4L9T0MP/Kygo/8b3+/n7GlF7PHOD8gKfcH2v+mhp6d+cOfZZr
        QErF531xIQ7UTdtLg02uIcfD/Ovrf5HH46Hx8XFyu93kdDppxGxmTnCB0yF/73A4shiVe0F7a4WF
        lLpyhYF3aAC/3f/dnp4eam5upvr6etbTYf5UKsW8o6Oj5Bn3kN/vZ83hs8HBwTMD9Wxra6OGhgaq
        ra2l6upqnqN/679r1EV3Q3dJzAl6En1CvikfBYNBjkWryXEYGhpigBu1bmxszPIajUayWCxHahD5
        igVBYkniH0Gvfn1FgUCA5yAUCnEsY2Njx8aAmUGt79930qVLISoudtKDB2Z68cLI9T2KH1wF8wUk
        flH4S/4u4TXwgj8cDrOG8fT5fAd+OyxnHn1GrU2mFsn5MwmxLBGQ6GIghng8fiQ/eIpiRUoNNpUY
        BmYHeB29MMwayPjGSP64n6LRKMeC3uC3qHVTU5Ost4WKij5KvozEDOXlWSk//7l8b6Pbty209nHt
        SH7EVhouJfGT5P79YA/Ay3V5I6g8WM78MzMz7C/oN7jR2/LyuOQizh3ct26VUUnJD1RYaKaHD805
        PRHejr3FrOSZV2uwJbK5c0xhQY/Cjzh3LQbMNbhfv7ZJzm3O/eJFOz1+XMmau3mzkmsPXeTywKWl
        JdJ79CTeSZ4JiT+UGlSHqnkeNP6nwadZfgAedzD3OSottVBl5Y+sPfQBOohEYjn5cWZUOaoU/hGJ
        hJJ/caBY4cdchBR+eJgWA84l9L2gIJ3NvaKihbUvRFTCKevfwvnl4ocHMT9qPyYULX6S73Gh+MLi
        V37MgBZDa2srGQwONfcE6ww1B68QNgbWtre3c/JDGy+7XrLGwKNz6Ej8pvpBQCjvAaUf2jwiBmgP
        tVd67yadzsS6y8trpwsXuuVahLVxkrPX1mNj/wMQS7YGPomkogvwa54EwOOuXZtXZ66L+15RUUHX
        r9vl/xc4f6/XfyL+iYkJRf9vBek79WTwqrqX9eD5k/yGgIE9ATFg/s3yrFH8JsE5w+fQf+gQ/cfs
        Hdd7Dbu7u+wvmIPW9la+Z7Enzqt6lHUw+UxZX4Rn42xR8o+yzr5qb4H7rt3ZTgPcWTBX4GdPgCd+
        kPAKMnvNnDdigJ+DX5kzN+ePJ+YN9cc+p+XePw84b6x2K/eDY/Aq+aNPiAHeB35oDnMnRDt7Lc4e
        3CnOyr1/JrK+/FaZS+SP8wcxwPtMJhN7HTQPr8csptOZb+beD5wb8F3MJO4JuCchBvQId5oaeT+C
        5nEGQkPnya0hk8nweYO7CPqCGOB9dXV1fMfAZ2e9c58U+If7G+6KiAHeh/zPovFvAbQ1OTnJ86Hd
        nb834Of4O/C/4D4nfAFaEbpc
        """),
        blob("""
        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
        """),
        blob("""
        eJzt1aENACEQRFGqpQpaoAMqoAA8Go3FUgan5wzZ3CY3Yib5+pkNnGNcSgnKOUOlFKjWCrXWIPlc
        fowR8vZ675B8Lv89b2+MAcnn8r96IQRT8rn826z3NeeE5HP53u/JzZPP5Xt7ay1o7w3J5/K9Pev/
        I/9X/wFKlZ5m
        """),
        blob("""
        eJyV1S9KtGEUhvGzAatrcQuDO3AB060yzSiTjE4xCYJJGLAIg0UYLMJYBA2GCYYJggbhe75Tr+tO
        Pje/8r7nTzxjr2rAvuzRvlTYo6I9mfROOJAJHUiFCRVNZNo74VCmdCgVplQ0lVnvhCOZ0ZFUmFHR
        TOa9E6Yyp6lUmFPRXBa9E45lQcdSYUFFC7nunXAi13QiFa6p6FqWvRNOZUmnUmFJRUtZ9U44kxWd
        SYUVFa1k3TvhXNZ0LhXWVLSWTe+EC9nQhVTYUNFG3nonXMobXUqFNyp6k23vhCvZ0pVU2FLRVna9
        E25kRzdSYUdFO/npnXArP3QrFX6o6Ef6I93JoDvJqEPjo6BvNNzLoHvJqEPjo6BvNDzIoAfJqEPj
        o6BvNDzKoEfJqEPjo6BvNDzJoCfJqEPjo6BvNDzLoGfJqEPjo6BvNLzIoBfJqEPjo6BvNLzKoFfJ
        qEPjo6BvNLzLoHfJqEPjo6BvNHzIoA/JqEPjo6BvNGxl0FYy6tD4KOgbDZ8y6FMy6tD4KOgbDTsZ
        tJOMOjQ+CvpGw5cM+pKMOjQ+CvpGw7cM+paMOjQ+CvpGw68M+pWMOjQ+Cvz+yd9+//X9B4HWHv4=
        """),
        blob("""
        eJyl0yGOg0AYxfF3pl6CI/QCHKAWW4nE1dVVVWFINqnBYDCYCgSmoqKiggRR8aq2oSX7vt19TH5i
        hpCZP8mQAJXgNfEFLRgPaKsVpXB/aFMgSSi5/SO09ZqS238PpCklt/8GbbOh5PZfA1lGye2/QNtu
        Kbn9QyDPKbn9PbSioOT2nwO7HSW3v4O231Ny+9vA4UDJ7W+gHY+U3P46UJaU3P4TtKqi5PZXgdOJ
        kttfQqtrSm7/MdA0lNz+A7S2peT27wNdR8nt30E7n7mA2fpb5z/6i0Df8833d695tH8wcmjDwAXM
        1t3+beBy4QJm64v9P88RjAza9coFzNZ/7Pxl/yZwu/HN/NvX/PN//6E/hXa/U3Lv/zowjpTc+59A
        myZKbv8q8HhQcvuj80WP2f8EOXoeWQ==
        """),
        blob("""
        eJzt1bEJAEAIQ1H3nyFrOY/XntZpAl9I+eB3TlXNP0lr3b12D5/t03rxXp/Wi/f6tF6816f14r0+
        rRfP/8fz//EW/wBUY0ym
        """),
        blob("""
        eJy11aGKhFAUxvHzor6Ab2C1Ga0mk81iEhYsFovFYjBYDAaDQTAYvoVlvaiw39ndg3P54T0Mcuc/
        4AwgAkZ5G/IhnLIO4cznC7cr3u7fhHu7f1V4Hihr/yKc74Oy9s+KIABl7Z+EC0NQ1v5REUWgrP2D
        cHEMytrfK5IElLW/Ey5NQVn7W0WWgbL2N8LlOShrf60oClDW/kq4sgRl7S8VVQXK2l8IV9egrP25
        omlAWfsz4doWlLU/VXQdKGt/Ilzf48b9bp/ztfMf/bFiGODIZT736vnKioQbRzjyPbv/7tHeHyqm
        Cc55z7n/uj7Pf34OZQXCzTMcuczn/sfOX/b7imXBzXnfbX5+33/o94RbV1DW51+zbaCsz792/r6D
        erv/OEC93a+9jP2f5+f7nQ==
        """),
        blob("""
        eJztzSEBwDAQQ9GorZsaqYDx4XqohUq4jeYEJCTg0/+qgKJW63C3uKc1WqjZ2lR8sy/2/isV3+yL
        PWwuvtdXe5hcfK+v9ga4+F5f7b2t+F5f7d1WfLev9QqHim/1P/jOxrc=
        """),
        blob("""
        eJz7z/D//39CeBuQxIaR5f8zoGJs8tuA1DawIHny+MzH5z48GAC8rqx1
        """),
        blob("""
        eJz7z/AfFf7fhi7CAABiqBKl
        """),
        blob("""
        eJyl0yGug0AUheG7JjbBDtgAG8BikbU4FA5VVUVegqnBYBAYBAaBqKhoUoE4T71m+mjOSXOZfAkM
        IcM/AcAMjLgN+zFOjN24KAIl1zfuKcQxKG//w7gkAeXtvwtpCsrbfzMuy0B5+zchz0F5+1fjigKU
        t38RTidQ3v7ZuLIE5e2fhKoC5e0fjatrUN7+QWgaUN7+3rjzGZS3/ypcLqC8/Z1xbQvK298KXQfK
        238x7noF5e0/C30PytvfGDcMoLz9tTCOoLz9lXHThAML5j+2ftFfCvOMN3/Pva7DdT6di3Eybllw
        YMH8Yc3/eyD6C2FdcWDB/Me9/6I/N27bcGDBvNx/0Z8JtxvehM++rtn3J0Zq3P0Oyvv/J8LjAcr7
        /8fGPZ+gvP2RsO+gvP3q/dTh7P8F5Rkbbw==
        """),
        blob("""
        eJyl1CGOg1AUheG7JjbBEroBfDUWicThUDhUTZNJaiowGAwGgSFBIDAkFYhTMyVth5ybyeHlSx6P
        kMdPAoAZGOcy7Mc4Z2zGBQEod3/jHo4wBKX2r8adTqDU/sURRaDU/tm48xmU2j854hiU2j8alySg
        1P7Bkaag1P7euCwDpfZ3jjwHpfa3xhUFKLW/cZQlKLW/Nq6qQKn9d8flAkrtvxl3vYJS+6+O2w2U
        2n8x7n4HpfZXjroGpfaXxjUNKLW/cLQtKLU/N67r8GH/b7/Oj1r/0Z85+h47ezt/zT/2OZo7IzVu
        GHDIfq+p/YljHPGHva2r/bFx04QP9rXm7u/0nx3zjN33vfsae//OiIxbFlDq939yrCso9fsPjXs8
        QKn9gWPbQKn93vN5h9j/BF7cFpU=
        """),
        blob("""
        eJyl06GqhEAYxfHvmXwJH8EX2G62WjeabDaTySQXtmzZYjFYDAaDxWAQDIZz011cXM7H5Tj8wBkZ
        xr8gYAbGeQz7Mc4Zh3FBAMo937jdEYag1P7NuCgCpfavjtsNlNq/GBfHoNT+2ZEkoNT+ybg0BaX2
        j477HZTaPxiXZaDU/t6R56DU/s64ogCl9reOsgSl9r+MqypQav/TUdeg1P6HcU0DSu1vHI8HKLW/
        Nu75BKX2V47XC5TaXxrXtqDU/sLRdaDU/ty4vseFnda/tv6jP3MMAz787XvPz+d8u3fG3bhxxIWd
        1tX+1DFNuLDTutqfGDfPuLDTunu+0x87lgUfznvfc/b9nXEzbl1Bqf9/5Ng2UOr/Hxq376DU/sBx
        HKDUfu/9vEvs/wV3rRzR
        """),
        blob("""
        eJyl1LGORGAUhuFzTa7CHbgBF6DVKrU6lW4qlUayiUaj0WgUCo1kCoVCoVB82+zImLXfsTnkSfhF
        jjcCIAJGuQz5Ek7Zd+EcB5Q6X7hN4bqgrP2rcJ4Hytq/KHwflLV/Fi4IQFn7n4owBGXtn4SLIlDW
        /lERx6Cs/YNwSQLK2t8r0hSUtb8TLstAWftbxeMBytrfCJfnoKz9taIoQFn7K+HKEpS1v1RUFShr
        fyFcXYOy9ueKpgFl7X8I17agrP2ZoutAWftT4foeJ8d/+3V+1fqP/kQxDDjI2/nr+DTn6ljZY+HG
        EZfk59qf7/xmf6SYJvwib+t09o3+ULjnEyfysUZn3+gPFPOMw+e9x9rVnJv9vnDLAsr6/XuKdQVl
        /f5d4bYNlLXfUew7KGu/9nzaZuz/BhrBGAw=
        """),
        blob("""
        eJyll68ORlAcht2Ti3ALbkCWVVXUJE2SJLMpiiQogqAIgiAINsG3L9jOvp297769Z3s2wnHOg/P7
        8zxkOI4DaZoGwsZ93xDXdSFsfbb/67ognudBVP/zPCG+70NU/+M4IEEQQFT/fd8hYRhCVP9t2yBR
        FEFU/3VdIXEcQ1T/ZVkgSZJAVP95niFpmkJU/2maIFmWQVT/cRwheZ5DVP9hGCBFUUBU/77vIWVZ
        QlT/rusgVVVBVP+2bSF1XUNUf/Z8tj/Vn71f9n1Uf/Z/sf9T9Wfni51P1Z/FFxafVH8WX20x2Yzb
        Ntd//Fl++c1H77z33lzHds0Gy6+2nGzmbdWf1Re2muQ7771W/Vl9ZavJzLqNrc/8WX35W4+ac997
        9P7ZYPU1q8/V88/6C9afqOef9VesP1P9WX/J+lPVn+2PDdH/A3lti+U=
        """),
        blob("""
        eJyVk72xhSAQhWmPRqjCFuyACizAnJiYdNMNCQn3HWBVrlfn8ob5RoH948CKGCOPOLCAFXhlU/YH
        jj2vPqvGsC/x71j1iaBcZMCAQAJxINzmSe2qfRliCGtd7iWvH85B8BXEAhvow4EgpkQxGTtUoQvG
        PGNPonpZjD5j0RpGncY6bnpm5N+l41uUrc8SSl27WTYEEojtS4abdGYHzM3eynLGScV835f7Z35C
        fg+prEiyLGTpJNosC9ZNAHky//EupvXf9A5C17rC8fqv61p11d/N6j++g/reQxP4pAAGBJISH0hq
        U21z/oxRz3T2w0wvjPUcvTT23xtHn67q+7v//gC8QpLv
        """),
        blob("""
        eJyll6EKhEAURf0nf8JP8AfsZqPVZjTZTCaTCCaLxWAxWAwWwWAQDAaXDYIM7r0s98GBYVmdOerM
        e++6SFiWBamqCsLiPE+IbdsQNj9b/3EcEMdxIKr/vu8Q13Uhqv+2bRDP8yCq/7quEN/3Iar/siyQ
        IAggqv88z5AwDCGq/zRNkCiKIKr/OI6QOI4hqv8wDJAkSSCqf9/3kDRNIap/13WQLMsgqn/btpA8
        zyGqf9M0kKIoIKp/XdeQsiwhqj+7P1uf6s+eL3s/qj/7vtj3qfqz/cX2p+rPzhd2Pqn+7Hw1z2Pz
        3H5z/cef5ZdnLvr+3xw/53kbs2D59VdevnO36s/qi7ea5HvdPVb9WX1l1mNmzcbmZ/6svnzWoua1
        92/o+bNg9TWrz9X9z/oL1p+o+5/1V6w/U/1Zf8n6U9WfrY+F6P8B1SWHhg==
        """),
        blob("""
        eJyll6EKhTAUhn0mX8JX8AXsVrPRaDPZTCaTCCaDxWIxGCwGg8FgEAz3coMwZPw/l3/wgYa5fXM7
        O+fzIc1xHEjTNBDW7vuGuK4LYeOz+V/XBfE8D6L6n+cJ8X0fovofxwEJggCi+u/7DgnDEKL6b9sG
        iaIIovqv6wqJ4xii+i/LAkmSBKL6z/MMSdMUovpP0wTJsgyi+o/jCMnzHKL6D8MAKYoCovr3fQ8p
        yxKi+nddB6mqCqL6t20Lqesaovqz77P5qf5sfdn/Uf3Z/mL7U/Vn54udT9WfxRcWn1R/Fl9tMdmM
        2zbXf/zZ/fK+j55+z7s5ju2ZNXa/2u5k895+j/leA+bP8gtbTvLr9zzb1v4ff5Zf2XIyM29j68/8
        WX75zkfNvs872n+ssfya5efq+Wf1BatP1PPP6itWn6n+rL5k9anqz+bHmuj/Bbydh7M=
        """),
        blob("""
        eJy1l6EOgzAURflRfgCJw6KRKBQOhUIREhQGgcEgMAgEAoFAkCC2TDRpmuzebTdrcrKSrLQH6Huv
        jwdpnudBmqaBsHbfN0Sdn42/rgvyb//zPCG+70NU/+M4IEEQQFT/fd8hYRhCVP9t2yBRFEFU/3Vd
        IXEcQ1T/ZVkgSZJAVP95niFpmkJU/2maIFmWQVT/cRwheZ5DVP9hGCBFUUBU/77vIWVZQlT/rusg
        VVVBVP+2bSF1XUNUf3Z/tj7Vnz1f9n5Uf/Z9se9T9Wf7i+1P1Z/FFxafVH8WX9147MZt2/MXf5Zf
        7Fz0+r/bZ/OzxvKrnYtNvrZzt+rP6gu7FjFjTP/1687vroM1Vl/ZtZhdr5n+O89P/Vl96dajZpx9
        7T7vb/xZfc3qc3X/s/MFO5+o+5+tj53PVH8GO5/+25810f8JaeBvgw==
        """),
        blob("""
        eJzt0rENwCAQQ9GblilYgQ2Y4Aagp6ampWUMUjtNFOkSubClX7/G57xczhkqpUC1VsjdodYaJJ/L
        TylB0V7vHZLP5d8X7Y0xIPlc/teemUHyufxob84Jyefy//bkc/nR3loL2ntD8rn8aO/pb/Kp/Atm
        yMYm
        """),
        blob("""
        eJzt1KENACEMhWGmZQpWYAMmYAA8Go3FMgKSs/eeaS5HQkWb/IqEzzTdzrn9jsd7D4UQoBgjlFKC
        cs5QKQUy/64veTx/vVorZL4u//R+sddag8zX5bPH8/Wecb13yPy7vuTxSPslefxu/l3/9D1hb4wB
        ma/LP+3x/3NOyHxd/un9kry1FmT+Vf8Bc/yqlg==
        """),
        blob("""
        eJxVz6ENxTAMhOFbL4tkiqzQDTzBG6A8OLjUNDDQ8HpRraoPfOiXLjEJkEVMTvnJIUi7LdADHGkJ
        e3Z7GmiEO7EuNhaGq9Vns++u5nCedbGGcXq+8+mjTFoLVn76u39oexDR//f3/yY49cchl8TKW743
        WN62tbfdc7enPA==
        """),
        blob("""
        eJztl8tPU1kcx88/4JaVK5cu2JGwYWNiWBhijBsXzsqwMDFGFiVh0USj0Qyk0UZGHqWUQHinKc9C
        ebTQUlpaWh6pg6LMMAMDY9DBYUgLw+M3v+/v3l4lDEWQOJtZfHMvh/Z8fu9zqohI/a8TizY2Nmhl
        ZYW2t7e/GXNzc5PevFmgwcFBam1tpRa7g0bu3KFEWRktDgxQcn39zJmpVIoWFxfJ7/dTW1sbdTc0
        kPvJEwpcu0ZBpcjLGtKfUdZMUZHY8sfaGu3v75+KyTGlpaUlmpiYoK6uLupwOoUJX8PMiLPCOtd9
        +TJ1mExUlZ1tCLaELl6kfrZ3enqa3r17R7u7uxmZ/H/J5+TkJPX29lJ3d7f4Cib2AnOWNc9a1bWg
        ryEW+BxsGdLjgNggPy6XS/bCnrFYTPzimB7ir66uSl7xuZ6eHtGE2SwMMN/iyftjLVhRQa9v3aKP
        vAYldX38zC7Ygbil90rLyWvs4yH++vqf5PP5aHR0lLxeL3k8Hhqy24UJFphu/r7b7TY0zHuh9tZy
        cyl56ZII76gBfPfzz3Z2dlJ9fT1VV1ejng7xk8mkcIeHh8k36qNgMCg1h5j09fWdWohnc3Mz1dTU
        UGVlJZWXl6OP/jX/g8ODdDtym9SsokfxRxSYCFA4HBZb0jE5Tv39/SKwEeva2lqDa7VayeFwHFmD
        8FfNK1LLrL8VPf/lOYVCIemDSCQitoyMjBxrA3oGsb5710MXLkQoP99D9+7Z6elTK+J7JB+snLkc
        Uj9r/IK/CmQNXPCj0ajUMJ6BQEByk9YA9zzyjFjbbI3M/ImUWmGFWO0i2JBIJI7kg5M3nafFYFOz
        oXemV9aRC8uMhawvrRRMBCkej4styA34iHVdXR3H20F5ee+Zt8WaoqysBsrO/p7fm+nmTQetvV87
        ks+2UWG0kNSPzP7tYA7Albi8VFQcLhb+1NSUzBfkG2zOLRUXJ5hF4jvYN24UUUHBd5Sba6f79+2Z
        ZqLMduytZpgzp8eAj5e072JTVNGD6APxPW0D+hrsFy+czNwR38+fd9HDh6VSc9evl0rsuS4yzsDl
        5WUy+8ykXjNnjPW7FoPySLn0Q5r/OPzY4EOYcQd9n6XCQgeVlv4gtYc8oA5isemMfJwZZe4yjT/E
        WtD8zw/la3z0RUTjY06nbcC5hLzn5KQM30tKGqX2lYqzPBz/RviXkY8ZJHzEfkRptfiB37lkZS4s
        feKjB9I2NDU1kcXi1n1fkDpDzMFVyinC2s7OTkY+1wY9a38mNQaOyW0i9as+D0JKew9p+Uj3I2xA
        7SH2Wu69ZDLZpO6yslro3LkOXouhNr7o7HV2OmX+QbDFiEGAtajVBfjpmQRhxl25Mqf3XLvkvaSk
        hK5edfHf8+K/3x/8Iv7Y2JhW/68UmdvMZPHrdc/xkP5jviVkkZkAG9D/dj5rtHmzID5jziH/qEPk
        H713TO4N/t7enswX9EFTS5Pcs2Qmzun1yHGwBWzGXMTMxtmi+R+XOvtUe/OSd+7rE9+BcGdBX4Ev
        MwEz8S3Lr8jut4vfsAHnJfhan3nFfzzRb4g/73NS9oF+wHnT4GqQfIgNfs1/5Ak2YPaBj5pD3ynV
        IrMWZw/fKU7LPtATxlx+pfUl/Mf5Axsw+2w2m8w61DxmPXoxldr6WvYBO/jckLmLnsQ9Afck2IAc
        4U5Twfcj1DzOQK6hs2QbNmxtbcl5g7sI8gIbMPuqqqrkjoH/nfLOfSI78HsAd0XYgNkH/09R419l
        A+6r4+Pj0h98d/6WbMMGnuf4HfhfsM9K/wDdGF8e
        """),
        blob("""
        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
        gP8PDOJWGA==
        """),
        blob("""
        eJztlUlLlm0Yhv0Dblu5atHChYsgCEQIIUQiQkQRUYwiUdFwwBGntEwbHMqxwTnnIc1M09RMTXOe
        p9TUNDU105yyPD/OC67wP3yvcGxE3/d57vu6jgNGRkYwNjbGqVOnYGJigtOnT+PMmTMwNTWFmZkZ
        zp49i3PnzuH8+fMwNzeHhYUFLly4AEtLS1y8eBFWVlawtrbGpUuXcPnyZVy5cgU2NjawtbWFnZ0d
        7O3t4eDgAEdHRzg5OcHZ2RkuLi64evUqrl27huvXr+PGjRtwdXWFm5sb3N3d4eHhAU9PT3h5eeHm
        zZvw9vaGj48PfH194efnB39/fwQEBCAwMBBBQUEIDg5GSEgIQkNDERYWhvDwcERERCAyMhK3bt1C
        VFQUoqOjcfv2bdy5cwcxMTG4e/cuYmNjERcXh3v37uH+/ft48OABHj58iPj4eCQkJCAxMRFJSUl4
        9OgRHj9+jOTkZCElJQWpqalIS0tDeno6MjIy8OTJEzx9+lR49uwZnj9/jszMTGRlZQnZ2dnIyclB
        bm4u8vLyhPz8fLx48QIFBQUoLCwUioqKUFxcjJKSEqG0tBRlZWUoLy8XKioqUFlZKbx8+RJVVVWo
        rq4WXr16hZqaGuH169eora0V3rx5g7q6OtTX1wtv375FQ0OD0NjYiHfv3glNTU1Cc3MzWlpahPfv
        36O1tVX48OED2trahPb2dqGjowMfP34UOjs7ha6uLnz69Eno7u4Wenp60NvbK/T19Qn9/f0YGBgQ
        BgcHhaGhIWF4eBgjIyPC6OioMDY2JoyPjwsTExPC5OQkpqamhOnpaeHz58/CzMyMMDs7K8zNzQlf
        vnwR5ufnsbCwICwuLgpfv34VlpaWhOXlZeHbt2/CysqKsLq6KqytrQnfv38X1tfXhY2NDWFzc/Mf
        P378ELa2toSfP38K29vbws7OjvDr1y9hd3dX2Nvb+8f+/r5wcHAgHB4eCr9//xaOjo7+8efPH+Hv
        37/C8fGxcPJHf6d/o/9z8nP0s/W79Lv1WU4+nz6zvoO+k76jvrOegZ7JyXPSs9Oz1LPVs9az17vQ
        u9G70rvTu9S71bvmvesM6EzojOjM6AzpTOmMcd509nQWdTZ1VnV2Occ60zrjOvOcf90F3Q3uie6M
        7hD3SXdLd417pzuoO8n91F3l3uoOc591t3XXuffqAPpA3UBP0BfqDnpEnUK/qGvoHfpHXUQvqaPo
        K3pLHUaf0WvqOPqO3qP/1IX0Iv1IT6oz6U96lD5Vt9Kz9C29S//Sw/Sxupmepq/pbfqbHqfP6XX6
        nZ6n7+l9+p8dYA/YBfaBnWAv2A32gx1hT9gV9oWdYW/YHfaHHWKP2CX2iZ1ir9gt9osdY8/YNfaN
        nWPv2D32jx1kD9lF9pGdZC/ZTfaTHWVP2VX2lZ1lb9ld9pcdZo/ZZfaZnWav2W32mx1nz9l19p2d
        Z+8N3Td039B9Q/cN3Td039D9/233/wMeIzP0
        """),
        blob("""
        eJzt09VKGAwYh3FvwFOPduSBBx54IAiCCEOQISIioohMFIdDxYmBid06Oze7c+ac3d01u6bO7tmz
        /t/Ly4vsHj4f+F3CA7z0LJ7Eo3j4x734K+7Erbj5x7W4EpfiQvwR5+JMnP7jRByLI3EoDsS+2BO7
        Ykdsi99iS2ySDfFLrIs1sSpWxLJYIotiQcyLOTErfpIZMS2mxCSZEONijIyKETFMhsSgGCD9ok/0
        kh7RTbpEJ+kQ7aKNtIoW0iyaSCNpED9IvfhO6kQtqSHVoopUim+kgpSLMlJKSkQxKSKFpEDkkzyS
        S3JENskimSRDpJOv5AtJI6kkhSSLJJJIEkg8iSOxJIZEk88kikSSCBJOwkgoCSHBJIgEkgDiT/yI
        L/Eh3sSLeBIP4k7ciCtxIc7EiTiST8SB2BM7Yks+EhvygVgTK2JJLMh7Yk7MiCkxIcbEiBgSA6JP
        9Mg7okt0yFuiTbSIJtEg6kSNqBIVokzeECWiSBTw0uv+r/u/7v+6P173f93/df//2f54fn5mT09P
        7PHxkT08PLy4v79nf//+ZXd3d+z29pbd3Ny8uL6+ZldXV+zy8pJdXFywP3/+sPPzc3Z2dsZOT09f
        nJycsOPjY3Z0dMQODw/ZwcEB29/fZ3t7e2x3d5ft7Oyw7e1t9vv3b7a1tcU2NzexsbHBfv36xdbX
        19na2hpbXV1lKysrbHl5mS0tLWFxcZEtLCyw+fl5Njc3x2ZnZ9nPnz8xMzPDpqen2dTUFJucnMTE
        xAQbHx9nY2NjGB0dZSMjI2x4eBhDQ0NscHCQDQwMoL+/n/X19bHe3l709PSw7u5udHV1sc7OTnR0
        dLD29nbW1taG1tZW1tLSgubmZtbU1ITGxkY0NDSwHz9+oL6+nn3//h11dXWstrYWNTU1qK6uZlVV
        VaisrGTfvn1DRUUFysvLWVlZGUpLS1FSUsKKi4tRVFSEwsJCFBQUsPz8fOTl5SE3Nxc5OTksOzsb
        WVlZyMzMREZGBktPT8fXr1/x5csXpKWlITU1FSkpKUhOTmZJSUlITExEQkIC4uPjERcXh9jYWMTE
        xCA6OhqfP39GVFQUIiMjERERgfDwcISFhSE0NBQhISEIDg5GUFAQAgMDERAQAH9/f/j5+cHX1xc+
        Pj7w9vaGl5cXPD094eHhAXd3d7i5ucHV1RUuLi5wdnaGk5MTHB0d8enTJzg4OMDe3h52dnawtbXF
        x48fYWNjgw8fPsDa2hpWVlawtLSEhYUF3r9/D3Nzc5iZmcHU1BQmJiYwNjaGkZERDA0NYWBgAH19
        fejp6eHdu3fQ1dWFjo4O3r59C21tbWhpaUFTUxMaGhpQV1eHmpoaVFVVoaKiAmVlZbx58wZKSkpQ
        VFSEgoLCfzLQFRE=
        """),
        blob("""
        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
        """),
        blob("""
        eJz7z8DwHwAE/wH/
        """),
        blob("""
        eJwN1iEMKkcUhtGVmCaoBlFBnmhCRRPqkFgkEjl1WCQSsw0WiZznkLhdJJLMGizZNUgyz2CnRxz9
        XXf/qlT/jBgzYcqMOQuWrFizIbBlx54DR06ciVy4cuPOgycv3nz4UqhK0A/6QT/oB/2gH/SDftAP
        +kE/6Af9oB/0g37QD/pBP+gH/aAf9IN+0A/6QT/oB/2gH/SDfq1f69f6tX6tX+vX+rV+rV/r1/q1
        fq1f69f6tX6tX+vX+rV+rV/r1/q1fq1f69f6tX6tX+vX+rV+1I/6UT/qR/2oH/WjftSP+lE/6kf9
        qB/1o37Uj/pRP+pH/agf9aN+1I/6UT/qR/2oH/WjfvP3iDETpsyYs2DJijUbAlt27Dlw5MSZyIUr
        N+48ePLizYcvhaok/aSf9JN+0k/6ST/pJ/2kn/STftJP+kk/6Sf9pJ/0k37ST/pJP+kn/aSf9JN+
        0k/6ST/p9/q9fq/f6/f6vX6v3+v3+r1+r9/r9/q9fq/f6/f6vX6v3+v3+r1+r9/r9/q9fq/f6/f6
        vX6v3+tn/ayf9bN+1s/6WT/rZ/2sn/WzftbP+lk/62f9rJ/1s37Wz/pZP+tn/ayf9bN+1s/6WT/r
        l79GjJkwZcacBUtWrNkQ2LJjz4EjJ85ELly5cefBkxdvPnwpVL/0GTNhyow5C5asWLMhsGXHngNH
        TpyJXLhy486DJy/efPhSqAZ9xkyYMmPOgiUr1mwIbNmx58CRE2ciF67cuPPgyYs3H74Uqq78OWLM
        hCkz5ixYsmLNhsCWHXsOHDlxJnLhyo07D568ePPhS6Fq9RkzYcqMOQuWrFizIbBlx54DR06ciVy4
        cuPOgycv3nz4Uqh+6jNmwpQZcxYsWbFmQ2DLjj0Hjpw4E7lw5cadB09evPnwpVD9p8+YCVNmzFmw
        ZMWaDYEtO/YcOHLiTOTClRt3Hjx58ebDl0L1b/kxYsyEKTPmLFiyYs2GwJYdew4cOXEmcuHKjTsP
        nrx48+FLofpRqhFjJkyZMWfBkhVrNgS27Nhz4MiJM5ELV27cefDkxZsPX1xQ6Qf9oB/0g37QD/pB
        P+gH/aAf9IN+0A/6QT/oB/2gH/SDftAP+kE/6Af9oB/0g37QD/pBP1R/lHrEmAlTZsxZsGTFmg2B
        LTv2HDhy4kzkwpUbdx48efHmw5eCftSP+lE/6kf9qB/1o37Uj/pRP+pH/agf9aN+1I/6UT/qR/2o
        H/WjftSP+lE/6kf9qB/1o36j3+g3+o1+o9/oN/qNfqPf6Df6jX6j3+g3+o1+o9/oN/qNfqPf6Df6
        jX6j3+g3+o1+o9/oN/qNftJP+kk/6Sf9pJ/0k37ST/pJP+kn/aSf9JN+0k/6ST/pJ/2kn/STftJP
        +kk/6Sf9pJ/0U/V76UeMmTBlxpwFS1as2RDYsmPPgSMnzkQuXLlx58GTF28+fCnoZ/2sn/WzftbP
        +lk/62f9rJ/1s37Wz/pZP+tn/ayf9bN+1s/6WT/rZ/2sn/WzftbP+lk/6xf9ol/0i37RL/pFv+gX
        /aJf9It+0S/6Rb/oF/2iX/SLftEv+kW/6Bf9ol/0i37RL/pFv1S//SojxkyYMmPOgiUr1mwIbNmx
        58CRE2ciF67cuPPgyYs3H74Uqt8G/UF/0B/0B/1Bf9Af9Af9QX/QH/QH/UF/0B/0B/1Bf9Af9Af9
        QX/QH/QH/UF/0B/0B/1Bf9Af9Dv9Tr/T7/Q7/U6/0+/0O/1Ov9Pv9Dv9Tr/T7/Q7/U6/0+/0O/1O
        v9Pv9Dv9Tr/T7/Q7/U6/0+/0W/1Wv9Vv9Vv9Vr/Vb/Vb/Va/1W/1W/1Wv9Vv9Vv9Vr/Vb/Vb/Va/
        1W/1W/1Wv9Vv9Vv9Vr/Vbz2An2XEmAlTZsxZsGTFmg2BLTv2HDhy4kzkwpUbdx48efHmw5dCZQCM
        GDNhyow5C5asWLMhsGXHngNHTpyJXLhy486DJy/efPhSqAyAEWMmTJkxZ8GSFWs2BLbs2HPgyIkz
        kQtXbtx58OTFmw9fCv8DZZYqaA==
        """),
        blob("""
        eJz7/5+B4T82vA1IwTCyGIiLLoauDg0DAEfqOH4=
        """),
        blob("""
        eJz7/5/h/39cmGEbKkYRh0FixbGYgwUDAGpYZC0=
        """),
        blob("""
        eJztzjEKADAMw8D8/9Pu2pLdqCCCl8CBMpPcy348W6f/29N69FVP69GXPa1HX/W0Hn3Z03r0VU/r
        0Zc9rUff9Ac7i/d5
        """),
        blob("""
        eJwV1yHQtSoUheF/KHQqlUqmUolUqtFqtBqNRqvRaDRajUaj8cQvrvveOfPkNUdls7akf/rDDx9e
        PLhx4cSBHRtWLJgxYcSAHh0aKgoyEiICPBwsDP7/6Y98/PDhxYMbF04c2LFhxYIZE0YM6NGhoaIg
        IyEiwMPBwuDfn5F+5OOHDy8e3Lhw4sCODSsWzJgwYkCPDg0VBRkJEQEeDhbmxxP4WekjHz98ePHg
        xoUTB3ZsWLFgxoQRA3p0aKgoyEiICPBwsJ+R+XgLn5Ne8vHDhxcPblw4cWDHhhULZkwYMaBHh4aK
        goyEiAAP9xrZ18q8fAmvlx7y8cOHFw9uXDhxYMeGFQtmTBgxoEeHhoqCjISIAP8YucfKPk7m4Wt8
        gnSTjx8+vHhw48KJAzs2rFgwY8KIAT06NFQUZCREhNvI31budrK3l7k5EXeULvLxw4cXD25cOHFg
        x4YVC2ZMGDGgR4eGioKMhHgZhcvKX07u8rJXkLk4lVeSTvLxw4cXD25cOHFgx4YVC2ZMGDGgR4eG
        ioKMdBrF0yqcTv70cmeQPaPMyWQ4s3SQjx8+vHhw48KJAzs2rFgwY8KIAT06NFQU5MMoHVbxcAqH
        lz+C3BFljyRzMJ2OIu3k44cPLx7cuHDiwI4NKxbMmDBiQI8ODRVlN8q7Vdqd4u4V9iC/R7k9ye5Z
        ZmdC7lXayMcPH148uHHhxIEdG1YsmDFhxIAeHRrqZlQ2q7w5pc0rbkFhi/Jbktuy7FZkNqb01qSV
        fPzw4cWDGxdOHNixYcWCGRNGDOjRoa1GdbUqq1NevdIaFNeosCb5NcutRXatMis3xdpJC/n44cOL
        BzcunDiwY8OKBTMmjBjQo1uM2mJVF6eyeOUlKC1RcUkKS5ZfitxSZZcms3BbLb00k48fPrx4cOPC
        iQM7NqxYMGPCiAH9bNTNVm12qrNXmYPyHJXmpDhnhbnIz1VubrJzJzNzY86DNJGPHz68eHDjwokD
        OzasWDBjwohhMuonq25yapNXnYLKFJWnpDRlxakoTFV+anJTJzv1MhO39jRKI/n44cOLBzcunDiw
        Y8OKBTMmjKPRMFr1o1M3erUxqI5RZUzKY1Yai+JYFcYmP3ZyYy87DjIjzWGcpIF8/PDhxYMbF04c
        2LFhxYIZ02A0DlbD4NQPXt0Q1IaoOiSVISsPRWmoikNTGDr5oZcbBtlhlBloL8Ms9eTjhw8vHty4
        cOLAjg0rFsy90dRbjb3T0Hv1fVDXR7U+qfZZpS/KfVXqm2LfKfS9fD/I9aNsP8n0NKh+kTry8cOH
        Fw9uXDhxYMeGFUtnNHdWU+c0dl5DF9R3UV2X1Lqs2hWVrip3TanrFLteoRvku1Gum2S7WaajxXWr
        1MjHDx9ePLhx4cSBHRvWZrQ0q7k5Tc1rbEFDi+pbUteyWiuqraq0ptw6pdYrtkGhjfJtkmuzbFtk
        Gk2ybVIlHz98ePHgxoUTB3Zs1WitVkt1mqvXVIPGGjXUpL5mdbWo1apam0rtlGuvVAfFOirUSb7O
        cnWRratMpc3WXSrk44cPLx7cuHDiwF6MtmK1FqeleM0laCpRY0kaSlZfirpS1UpTLZ1K6ZXLoFRG
        xTIplFm+LHJllS2bTKFRl0PK5OOHDy8e3Lhw4shGe7bastOavZYcNOeoKSeNOWvIRX2u6nJTy51q
        7lXyoJxHpTwp5lkhL/J5lcubbN5lMq0+n1IiHz98ePHgxoUzGR3Jak9OW/JaU9CSouaUNKWsMRUN
        qapPTV3q1FKvmgaVNCqnSSnNimlRSKt82uTSLpsOmcRmkS4pko8fPrx4cOOKRme0OqLTHr22GLTG
        qCUmzTFrikVjrBpiUx87dbFXi4NqHFXipBxnpbgoxlUhbvJxl4uHbDxlIttNvKVAPn748OLBHYyu
        YHUGpyN47SFoC1FrSFpC1hyKplA1hqYhdOpDry4MamFUDZNKmJXDohRWxbAphF0+HHLhlA2XTGDD
        Co/kyccPH1483uj2Vpd3Or3X4YN2H7X5pNVnLb5o9lWTbxp9p8H36v2gzo9qflL1s4pflP2q5DdF
        vyv4Q96fcv6S9beMZ8vzr+TIxw8fXmf0OKvbOV3O63RBh4vaXdLmslZXtLiq2TVNrtPoeg1uUO9G
        dW5Sc7OqW1Tcquw2JbcrukPBnfLuknO3rHtkHJum+yRLPn74rNFrrR7rdFuvywadNuqwSbvN2mzR
        aqsW2zTbTpPtNdpBgx3V20mdndXsompXFbsp213JHor2VLCXvL3l7CNrXxnLtmt/kiEfP2P0GavX
        OD3G6zZBl4k6TdJhsnZTtJmq1TQtptNsek1m0GhGDWZSb2Z1ZlEzq6rZVMyubA4lcyqaS8Hc8uaR
        M6+s+WQMG7f5Y/0m/59hDbWsgo51zLMSBdaSyGqQqOeZilyoqZWq2KhrHZWpp7YMVIeR63viCp25
        xhaukpVxvjFSd8bawWg5Od4XR+zmM3/41F5e98cj//G3//6P/g/KGpxO
        """),
        blob("""
        eJztzSEBACEQBMCrRxFSUIEGJCAAHo3GYpFIJG9/C9yaFaPnmdn7CyGAGCNIKYGcMyilgForaK0B
        /dzf++u9A/3c3/sbYwD93N/7m3MC/dzf+1trAf3c3/vbewP93N/7O+cA/dzf+7v3Av3U/wP/OywF
        """),
        blob("""
        eJytl7uVhSAQQG2PRqiCFuiACiyA3NjYlNTQkJAdYEY+IqJvz557fK7AlQEGdG6a3DACkIAC5gyF
        z9iLtkbh6NAvkP/gZdivN96cGd/9a5+/en+NhS+/9TmQHa/2oXx4j9F+G8BdscAGLIBusAJ7o17A
        DsSB4Zg1/NuNs4V/v6Pl9zEQHT/NtcxvsV+j7py95ddTe42y7Hnm9+1c/wSggBlL+KsEWFGK53HI
        /a1xUFe/QUvZIjnvSDUYjoWt/a0Y6NJvL61xbAmwgAFWZAN2m56H2RL9Gu8u/nwe1GvdpPmmzpbm
        GMkDmAEVYSr9nhYatT2MB/k9tvarzC+v/qXwy3hn0VNVKdLcSn4NfpbmYu3P80GVYw9TjyaOuYHi
        Mhaz8DJ22oAVMO6gd9CAJb8429lafpoD1d6yF/4sihBfJmM6i8HWJ/4dFPkN+WXKTS0/BU33/Dz5
        oW0R/Efhjv41htTfbuRXKSe1/OKlH7rMg982/fNbP/V/NP5rHP81xN9k/gX8R0wr/nZ/Gf9q/tm7
        +bdHf9oebRgL/3ul6fRl/j2uP4F32D6HqoAEFCB4/F/A0Pqbi/XfXX+N/GMu+W+mTF6GPg1BjM+Z
        f8TpX57yz1D+ZZhJTcQCO2Dw6nJ0kX/NU/6tx8CkXpT7D+Xh3v4jXb3/XPa/1v5zs/8u2E4JD3Ob
        hdUx41WEfJuX87Omuf/enUHk1f/27HN7Bno6fxA35y/j7s99rXOgreqfft5x0zhsV7/DNo1rn8cW
        jNPRqHf6e2e/HF9umWJS6WCB46HMSb3eRr593n5z3THa796c/IKa/ud7lL4DR+Mx/9jnHnwqv8EJ
        OX391vwDQBkqhA==
        """),
        blob("""
        eJzt06ERACAQA8FuvzgaRAYLBcD8MCui1sRcZir7auQY/9u7/eFvvdsfrn+uf65/rn+uf37NF/sz
        0rU=
        """),
        blob("""
        eJz7z8Dw/z9e/H8bJkaSA5EwjFWOYRtuORz6cNqHHQMAVdZ1rQ==
        """),
        blob("""
        eJzVl10NhEAMhHnFDRrQgAY0YAELWMACFrCABSTspSS9zDVt4eCOLiTzxM83nRbYTUVRpKeoqqpU
        13VqmkYVnaNrfsksy/LNbNs2dV3niq5hL3Tv1XqR2/f9pmEYVPF59HE2D/KPXOSM46hKemEf9Kyr
        bGZM0+QKvZzxgGysFxnzPKuSPvj+ox6oVx5b8pZl2WT50DxY80CzSvMiM5dcZlqSPmQviKG9F5y7
        xZacdV0/ZPmQHqw+cO1a5h7X86H1gjPQ+r5X+x5bevAywDmgPLDvWu2SIQ/PAz8P5wB7oGXv1W4d
        RzOQPdjjH2FbHq7wv6l9L4Mn8qPzv2v+ot+/6O9P9Pc3h/9P9P83ev2Rw/orh/VnDutvnIeo/Qe+
        F1H7Ly2Pu/eff9YL6OLe0A==
        """),
        blob("""
        eJzt1QEKgCAMBdDd/0C73hqKouEwcuUXRglFkz1sTiEieTJEbyHWoQ+cXoR15ItHn5fiUV3mvMbk
        ksfD1a2VU55VV2vyzLPg6kzeeV667JoHcSHXfZmH2CdqWLhOcNW8oK6078DqfnZmQ/QvsL76eZ5w
        hStcuC6jL211Tfr4FldruMUP1+1vlxEfrsNcaPWFuh9RXaj/Eb3uw3V2faHuxxJvmXL8BWnJkII=
        """),
        blob("""
        eJztlw0KgCAMhXf/A+16S4zAlfMvfYuKGpQOPpbPNxMikpaQcAtxiPDA8UU4xH5xbrox35dvzifs
        vnom8FXtvd/zJj9lD63nOF+xh/U0xre1B+Y/QX/HvOf+O/nDz1/rv978qHMn/dV6zxf8Z9566nyz
        LgC/eq5YyFfaLfT31Xwz/+X8av6X+QD9mfmg/ZcbQPtPOqDZOP+99DfB8ov9Hej/Vj7C/8v/ta78
        DZYLc/E=
        """),
        blob("""
        eJztlwEKgCAMRXf/A+16axmJRsMV6H4xSqh81Ev2tYSIxNNEdyHWpgdcToS1HRvfdb/i0XxMvnGZ
        cv8nfDc2k97Xy7cuM8ffwXcus+thwNu1HOyDWM8nj5T32p0+SD71eWA+JUcg9TxaS3M+TD75j/BG
        biJ8xt/oQfPJhe+dFvsYPJrP6vqB9gHIl+8fONAn85U+f/ABWS/2C0h5r7zpUvgNv3kchQ==
        """),
        blob("""
        eJztzbENACAMA7A8yZM8WX4gUicPnp1kUjil5vb7/X6/3//nlqbk9/v9fr9//39MY/pM
        """),
        blob("""
        eJztlu0JwCAMRN1/BUdxDue5/mlLrekFjYHSRjgQgzyeHyiABBqtXAoPn65UF/BTogn/8P+zf608
        yKCx+rvzwz/8w/8xOfOggsbq784P/0/5n++2xD+8nPwb7t5vOFLfaf87/qS//j/q23Xc6j/Kv4+p
        /IX+Uk1kDZz/mfUX/Sfvvzs//N/svwGpAA/M
        """),
        blob("""
        eJzt1oEJgCAUBFD3n8FNnMN5LggMMzup7wepCw6iT1wPlAQQQDMap8TDXx9MJ/SHQCO//H/258yD
        CBqr371ffvnlv02MPMigsfrd++X/nH//b/f6i8vRf5wb2v66t75f3D8+H12v+rnV794/2d/Oul0P
        1v8b/+l7jPvfvV/+lf0bsG8WXA==
        """),
        blob("""
        eJztltsJwCAQBO2/BjuxDuvZ/ESJj6wGPQjJCgtyhwyjiAJwoBm1Q+DhywfdDXznaOQv/z/7x8gD
        D5pVf3O+/OUv/9t4z4MImlV/c778P+Wf3+0eP3kZ+Rfcc15wenOj82/4tfOk//h/1I5rnbIn/J/y
        6xplb/bv9TKzXmvk3+zH4v0358v/zf4HnTsSAg==
        """),
        blob("""
        eJztlwEKgDAIRXf/A3k9k6IxWbblxjQcJRR9fg/TuTClhD2BdGICCrqA8waB4jrg6fEnvRcOUVcw
        6HwncLBcaH0HOUqGIV89B2MY9tVxyDVqxOGpTm+dh77Nus1hwZHf44Tj7AvjOm3NuIjr2HzfzdGl
        F+doPI73fYUBh2F98Fw44DDsF54Lew7L9UOco9XcWMNR6YNztP+fY3CI+sXf5WccB2rq1W4=
        """),
        blob("""
        eJztlgEKgCAMRb3/GbyJ5/A8P4JYNvKPmIOoCZ+WIq83EANQQGMtt8bDtxurC/il0KR/+v/Zv3ce
        VNB4/cP56Z/+6T9NrTzooPH6h/PT/1P+cm9r/j4f7H/hHrXJX+gvzKEHXn/7/+gc45w8NV9/h+H/
        lK/rqWeAv+6BvOt+B/nfDe/5D+en/5v9NyMLCtU=
        """),
        blob("""
        eJzt1KENwCAQhWHWYxGmYAU2YAIGwKPRWCwSiWxt3zOkoemZu+RXJHzmcpcx5nq2G+89FEKAYoxQ
        SgnKOUPqy/rWWsg5B/GceqUUSH1Znz3eL55Tr9YKqS/r7/aL563H9621Bqkv6//t8bv6sv7X94T/
        771DYwxIfVn/1NvtF3tzTkh9Wf/U4/1in1trQeqL+jd34bb2
        """),
        blob("""
        eJztlgEKgCAQBP3/F+wnvsP3bCAYZrqH6UXUCQviIeOIogAcaKRyCDx8ulBdwHeOxvzN/8/+MfJg
        A82svzrf/M3f/LvxngcRNLP+6nzz/5x/erdb/Oyl6H/8G2p+yS37T/lnZr0Hgr/8P7q2cry59wP+
        S/m9/kL/utZkDZz/O/6n9Uzef3W++b/ZfwcXkxLw
        """),
        blob("""
        eJyFk7uxxCAMRdWeG1EVboEOqMAFkBMTk5ISOlSodwGxa7PPu+O5M7aPhIQ+qkTatUEecva96oCC
        aV/YdmHBzrlyt/BgPpNHKJOekOTxfstDwJQ0QAlSNZ/GePBsvKnZajK+Dx4uvKjFsNxO8PF4aFfX
        eHnXpHTO5n3AwjgPnjuPSkWUToElq0yOuqXGBZl7hIz4jQhnsdwmr7mXjffGvdbJUavYeClaqWpg
        eXN34bngmkkjV2U5PvhmPBkvDzw+8BZfKIOf/57feCJRz3rPb97vzMpgmx/3r+v9W2dRGypLfV71
        PXAGOiflXl/w+q0/1t9NmxzEvcuv/tp8xKf5+DVfNp8yJqDb3eaTbN5hL8n80rJDv/bj136R/Zuc
        H3bYfezuHzAamPc=
        """),
        blob("""
        eJztV92PEjEQ/7driIlGjVFjorn4YNQ3EyUYTSTIKV5OH3gg54kHB7gH7GZZPg8JyIW742vrjNOm
        ZVk+A96LD5N2Ou38pp2Zdso5Z/w/MX52xrjjMG6ais7PSVarqTHLYrxUYrzZZLzfZ9x1ac5wyHir
        RTKcUy6TzmXxLy9p/ekp47btj49to0F2IgbygwHjoxH1cQxl9Tq1qG+ds5B4XnzJI16lQngXF4x3
        OmQz2ob24Bw8F9nfNj6eGfa7XeWPVegz6GeH05QAvZ0+9e//UOdvwdkGYOxGkvwWNv3Xo13z9B/8
        WoyP8gdp4o+LtM94gfiXRdrvLHw8s03gh/LEf2sSH61Mro9Y6+OjL3cd4uOA1wIfG8BnYG9d4e+E
        TfKgRfzjHPHtPvHNNuNZkAVzSk/emcaPC39KGo4JP1wk+RdrOrdwvVMlf99JgU0wdg36DzMqflAH
        5lwoS3r2iyqHdfykTz6OwYao2N/Hnwob41rGMvI7RzRHnv17Z1IP3j/SD58M2ke7vRh/GTnS1zrN
        uZ6kNtdZXs8m8Ks9FTeB75B3o83je0m/S1yg28IHT43V9jFL/8hdHh/ptfDvXu1q8F+IeyDsbAff
        m5+6joGrYk/PvVXwvfrdFeIv/3vSdq99247/SJnm3BVvwYHP3G3iP8qqOxvbV9a/wce771jcz/fg
        DTZtyv9bRxSfsjbAtzZaonmxk8l6ISbuzJjhX5vNio/BmPTvinclKO7VnRTxdpfkBtiXAb1vhZ0R
        mJcuEL7+vuwV/Guzee8j6n8ufG50SN8HoW+/RvJQxn894mNt9s4g/lC8197abB5+FWQ3Ie8CSToP
        xE+J9/rZyWJ89Mub3Hr3L+KnBdaTjKp9TUvYBHFgV+bj6/YlGqrGlrXZIvLW/rLOxbpPjz+JhW+u
        /EfIMdnv9Sb/GKvgy1ieJ0dsjC/9/+BXG8s1m8bHM8G6XP8/+f0NtoWP/N/63FJjsjaTeY/z9dps
        0/h4zvgH1Mfk31DWlnptdsX0B7c76cA=
        """),
        blob("""
        eJzFl8lK9UAQhfsR+hXyCHmFrEQQJC5cuBGCIoi4iAi6UJDoRkWQgMNGEa+CiIgSh40DelEER1AU
        UcERB8T5Omz++kIH/jdoobFv16lzuqurKolS8ldUVKSqqqpUc3Oz6uzsVIODg2p8fFzNzs6qpaUl
        tbm5qQ4ODtTp6am6vr5WT09P6uPjQ/39/aWDOWvYwIDFB1844IITbjTQQtNoa/mni4uLdU1NjW5p
        adE9PT16aGhIT05O6sXFRb2+vq53d3f18fGxvry81I+Pj/r9/V2LdjqYs4YNDFh88IUDLjjhRgOt
        /87Nb0d+OiUlJU5tba3T1tbmxHHsjI6OOjMzM87y8rKztbXlHB4eOhcXF879/b3z9vbmiHY6mLOG
        DQxYfPCFAy444UbDnDeLOXti3ZV1t7S01K2vr3c7OjrcgYEBd2Jiwl1YWHDz+by7v7/vnp2duXd3
        d+7r66v7+/ubDuasYQMDFh984YALTrjNOdHM7pu4sDfsnti9srIyr6Ghwevq6vIkdt709LQn5/G2
        t7e9k5MT7+bmxnt5efFEOx3MWcMGBiw++MIBF5zmfGihmeUad0N82CM4X3B+eXm539TU5Pf29vpj
        Y2P+/Py8v7Gx4Ut8fbln//n52RftdDBnDRsYsPjgCwdc5lxooIVmlufkB3dEnNgr+EDwQUVFRdDa
        2hr09/cHU1NTwcrKSrC3txfIPQeS78HPz086mLOGDQxYfPCFw5wHbjTQQjOrMXKUPOGuiBd7xi8U
        v7CysjJsb28Ph4eHw7m5uVByK5QaCx8eHsLv7+90MGcNGxiw+OBrzgEn3GighWZW39QJuUq+cGfE
        jb3jH4l/VF1dHXV3d0dij1ZXVyOJcyT5FhUKhXQwZw0bGLD4mP3DBSfcaKCFZtZbqFXqhZwlb7g7
        4scZ4ImFJ66rq4v7+vriJEninZ2d+OrqKv76+koHc9awgQFr9g0HXHDCjQZaaGZ9jX5BzVI35C75
        wx0SR84CX074co2NjbmRkZHc2tpa7vz8PPf5+ZkO5qxhA2P2iy8ccMEJNxpooZn1VHoWfYPapX7I
        YfKIuySenAneRHgTyd1E4pcIPpG+kw7mrGEz+8QHXzjgghNuNNBCM+vn9E16F/2DGqaOyGXyiTsl
        rpwN/rzw5+Uu88KXl7pLB3PWzP7A4oMvHHDBCTcaaKGZPUvo3fRPehh9hFqmnshp8oq7Jb6cEZ0j
        0TmSsx0JPh3Mzb7AgMUHXzjgghNuNNBCM3uO8fygh9NH6WX0E2qauiK3yS/umDhzVvRuRe9WfqfD
        7AcbGLD44AsHXHDCjQZaaGbPUG2eI67pp/Q0+gq1TX2R4+QZd028OTO6BdEtmH2whg0MWHzwhQMu
        33Cj4RjN7PltVd92/G3nn+36s91/bPdf288f289f2+8ftt+/bL9/2n7/tv39Yfv7y/b3p+Xv739s
        vVQY
        """),
        blob("""
        eJzt1tEJwCAQA1D3n8FNXMN9UtqPYpXmBD2RNkJ+PEp8H1IBBNBY45R4+OfGdEJ/CDTyy/9nf848
        iKAZ9bv3yy+//K+JkQcZNKN+9375P+e//tt1/+lZ4L/fDb39m/vt91G7yv2mvz6H4Z/aX8bJX88a
        7wL/4zyD99+9X/6d/QcxdBiM
        """),
        blob("""
        eJzFl1VLNV0Yhv0DnvoDPPRA8EAQQRARRERERBFFFEVFRcXAxu7u7u7u7u7u7u7W++UeUITvO58N
        G/ZmZtZaz3Nd654ZSEhIQF5eHhoaGjA0NISVlRWcnZ3h4+OD0NBQxMXFIS0tDbm5uSgpKUF1dTUa
        GxvR3t6O3t5eDA8PY2JiArOzs1haWsL6+jp2dnZweHiI09NTXF1d4e7uDk9PT3h7e8PX1xdeX19x
        eXmJ7e1tSElJQVFREVpaWjA2NoaNjQ1cXV3h5+eH8PBwxMfHIz09Hfn5+SgrK0NNTQ2amprQ2dmJ
        vr4+jIyMYHJyEnNzc1heXsbGxgZ2d3dxdHSEs7MzXF9f4/7+Hs/Pz3h/f8f397fwm8d4rrS0NJSV
        laGjowNTU1PY2dnB3d0dAQEBiIyMRGJiIjIzM1FQUIDy8nLU1dWhpaUFXV1dGBgYwOjoKKamprCw
        sIDV1VVsbm5ib28Px8fHOD8/x83NDR4eHvDy8oKPjw/ww/88zvNlZGSgqqoKPT09mJubw8HBAZ6e
        nggKCkJ0dDSSk5ORnZ2NoqIiVFZWor6+Hq2treju7sbg4CDGxsYwMzODxcVFrK2tYWtrC/v7+zg5
        OcHFxYUw/+Pjo9Dzz89P4Xt7e4uDgwPhGjk5Oairq8PAwACWlpZwcnKCt7c3QkJCEBsbi9TUVOTk
        5KC4uBhVVVVoaGgQ2Pf09GBoaAjj4+P/Yc+xyZ6MOddf9mRAJ8iIzBQUFKCpqQkjIyNYW1vDxcUF
        vr6+CAsL+3UvLy8PpaWlgntk39HRIbCne//Hnu6R7497f9mTA7mQE7kpKSlBW1sbJiYmsLW1hZub
        G/z9/REREYGEhARkZGT8uldbW4vm5mbBvf7+fsE9jjE/P4+VlZVf9nSPc/x174c9WZANWbF3Kioq
        0NXVhZmZGezt7eHh4YHAwEBERUUhKSkJWVlZKCwsREVFheAe2f+4R/bT09O/7v2wp1s/7P+6x/rZ
        D/aH/WL/1NTUoK+vDwsLCzg6OsLLywvBwcGIiYlBSkqK4B7Z0z2yb2trE9jTPa7/r3vcz2TP+n7Y
        /3WPa+Ca2COumTWIlTtcN+sQK3d4LT0WK3d4PccTK3c4Bn0SK3fIkE6JlTvkSK5i5Q73MXsrVu6w
        n+yvWLnDmri/xMod1sU6xcodes1axcodjs/5xModzkHfxModOsa8ESt3yJncxcod7nPue7Fyh/1m
        7ouVO9xvvO+LlTusm899YuUOvedzv1i5w9zje59YucP7nqysrGi5w+ceSUnJf3uj7D4=
        """),
        blob("""
        eJz7z/D//38kDABjrAv1
        """),
        blob("""
        eJzt1KENwCAQhWHWYxGmYAU2YAIGwKPRWCySEVr9njlxTXriXvKrJnzm0uehxRghXs4ZKqVAtVao
        tQb13iH3bfkpJYin9cYYkPu2fGlab84JuW/L5/viSV4IAWKPv7tvy+f74kn3xe+vtSD3bflf/0/4
        fSn3//W1nnRf5xzIfVu+1tt7Q/z+vRdy35T/AmeVhXY=
        """),
        blob("""
        eJyllyHKhUAUhV2Tq3AHbsAFmK1Go81mMplMgpgsFoPFYjAIFoNBMBjezwuCDL5z/DkDHwwP9c73
        dObe+/mQYVkWpKoqCBvneUJs24aw+Gz9x3FAHMeBqP77vkNc14Wo/tu2QTzPg6j+67pCfN+HqP7L
        skCCIICo/vM8Q8IwhKj+0zRBoiiCqP7jOELiOIao/sMwQJIkgaj+fd9D0jSFqP5d10GyLIOo/m3b
        QvI8h6j+TdNAiqKAqP51XUPKsoSo/uz5bH2qP/t/2ftR/dn3xb5P1Z/tL7Y/VX92vrDzSfVn56t5
        Hpvn9pPrf/xZfrnnou/15vwe52nOBsuvv/Lylbt/vfO3/qy+eKpJvvddcxT7jT+rr8x6zKzZUOw3
        /qy+vNei5r3Xb09x3vqz+prV5+r+Z/0F60/U/c/6K9afqf6sv2T9qerP1seG6P8HFzyMYw==
        """),
        blob("""
        eJyll6GyR0AUxj2Tl/AKXkCXVVHTNE2SFMEoiqIogiIIgiCYEYT/nRvM7Oy433fv/c7Mb4awdn/Y
        s+d8PiQcx4E0TQNhcd83xHVdCJufrf+6LojneRDV/zxPiO/7ENX/OA5IEAQQ1X/fd0gYhhDVf9s2
        SBRFENV/XVdIHMcQ1X9ZFkiSJBDVf55nSJqmENV/miZIlmUQ1X8cR0ie5xDVfxgGSFEUENW/73tI
        WZYQ1b/rOkhVVRDVv21bSF3XENWfPZ+tT/Vn75d9H9Wf/V/s/1T92f5i+1P1Z/mF5SfVn+XXt5xs
        5m3T8z/+7Hyxz6Nn3HPP5mfBzte3M9k8t1V/Vl+81STf455re357HSxYffVWk5l120+ev/Vn9aVd
        j5pjn3v7ff/Fn9XXrD5X9z/rL1h/ou5/1l+x/kz1Z/0l609Vf7Y+FqL/F0yKksM=
        """),
    ]
    
    let png_test_suite_answer_search_table = [
        "s04n3p01": 0,
        "s04i3p01": 0,
        "f03n2c08": 1,
        "cm0n0g04": 2,
        "ct0n0g04": 2,
        "ct1n0g04": 2,
        "ctzn0g04": 2,
        "cm7n0g04": 2,
        "cm9n0g04": 2,
        "ccwn3p08": 3,
        "tbbn2c16": 4,
        "tbrn2c08": 4,
        "tbgn2c16": 4,
        "s37n3p04": 5,
        "s37i3p04": 5,
        "basn0g01": 6,
        "basi0g01": 6,
        "bgbn4a08": 7,
        "bgai4a08": 7,
        "basi4a08": 7,
        "basn4a08": 7,
        "f02n2c08": 8,
        "f04n2c08": 9,
        "s39i3p04": 10,
        "s39n3p04": 10,
        "s33i3p04": 11,
        "s33n3p04": 11,
        "tbbn0g04": 12,
        "tbwn0g16": 13,
        "s35i3p04": 14,
        "s35n3p04": 14,
        "ccwn2c08": 15,
        "tp0n2c08": 16,
        "f03n0g08": 17,
        "f02n0g08": 18,
        "cs5n2c08": 19,
        "cs5n3p08": 19,
        "s40n3p04": 20,
        "s40i3p04": 20,
        "cs8n3p08": 21,
        "cs8n2c08": 21,
        "cs3n3p08": 22,
        "f04n0g08": 23,
        "f00n0g08": 24,
        "f01n0g08": 25,
        "f00n2c08": 26,
        "f01n2c08": 27,
        "tp0n0g08": 28,
        "cs3n2c16": 29,
        "s09n3p02": 30,
        "s09i3p02": 30,
        "tp0n3p08": 31,
        "ps1n2c16": 32,
        "oi1n2c16": 32,
        "basn2c16": 32,
        "oi9n2c16": 32,
        "oi2n2c16": 32,
        "ps2n2c16": 32,
        "basi2c16": 32,
        "pp0n2c16": 32,
        "oi4n2c16": 32,
        "cten0g04": 33,
        "basi3p08": 34,
        "basn3p08": 34,
        "ch2n3p08": 34,
        "g07n2c08": 35,
        "basn0g02": 36,
        "basi0g02": 36,
        "g25n2c08": 37,
        "basn3p04": 38,
        "ch1n3p04": 38,
        "basi3p04": 38,
        "s08n3p02": 39,
        "s08i3p02": 39,
        "s03n3p01": 40,
        "s03i3p01": 40,
        "g10n2c08": 41,
        "g03n2c08": 42,
        "g05n2c08": 43,
        "g04n2c08": 44,
        "g05n0g16": 45,
        "cdhn2c08": 46,
        "g03n0g16": 47,
        "g10n0g16": 48,
        "g25n0g16": 49,
        "ctfn0g04": 50,
        "ctgn0g04": 51,
        "cdsn2c08": 52,
        "tbgn3p08": 53,
        "tbyn3p08": 53,
        "tbbn3p08": 53,
        "tp1n3p08": 53,
        "tbwn3p08": 53,
        "bgyn6a16": 54,
        "basn6a16": 54,
        "bgan6a16": 54,
        "basi6a16": 54,
        "basi0g08": 55,
        "ps2n0g08": 55,
        "basn0g08": 55,
        "ps1n0g08": 55,
        "basi2c08": 56,
        "basn2c08": 56,
        "pp0n6a08": 57,
        "s01i3p01": 58,
        "s01n3p01": 58,
        "bgwn6a08": 59,
        "basi6a08": 59,
        "bgan6a08": 59,
        "basn6a08": 59,
        "s05n3p02": 60,
        "s05i3p02": 60,
        "s06i3p02": 61,
        "s06n3p02": 61,
        "basn3p02": 62,
        "basi3p02": 62,
        "z03n2c08": 63,
        "z09n2c08": 63,
        "z06n2c08": 63,
        "z00n2c08": 63,
        "basn0g04": 64,
        "basi0g04": 64,
        "cdun2c08": 65,
        "basn3p01": 66,
        "basi3p01": 66,
        "s07i3p02": 67,
        "s07n3p02": 67,
        "f99n0g04": 68,
        "s38i3p04": 69,
        "s38n3p04": 69,
        "s32i3p04": 70,
        "s32n3p04": 70,
        "s36n3p04": 71,
        "s36i3p04": 71,
        "tm3n3p02": 72,
        "g03n3p04": 73,
        "g05n3p04": 74,
        "g04n3p04": 75,
        "s34i3p04": 76,
        "s34n3p04": 76,
        "g25n3p04": 77,
        "ctjn0g04": 78,
        "g10n3p04": 79,
        "cdfn2c08": 80,
        "exif2c08": 81,
        "bggn4a16": 82,
        "basn4a16": 82,
        "basi4a16": 82,
        "bgai4a16": 82,
        "g07n3p04": 83,
        "oi1n0g16": 84,
        "basn0g16": 84,
        "oi9n0g16": 84,
        "oi2n0g16": 84,
        "basi0g16": 84,
        "oi4n0g16": 84,
        "s02n3p01": 85,
        "s02i3p01": 85,
        "cthn0g04": 86,
        "g04n0g16": 87,
        "g07n0g16": 88,
        ]
}
