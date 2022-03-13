//
//  ColorTest.swift
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

class ColorTest: XCTestCase {
    
    func testBlendMode() {
        
        let destination = Float32ColorPixel(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1),
            opacity: 1
        )
        
        let source = Float32ColorPixel(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1),
            opacity: 1
        )
        
        func combined(_ combine: (Float, Float) -> Float) -> RGBColorModel.Float32Components {
            return source._color.combined(destination._color, combine)
        }
        
        func blended(_ blendMode: ColorBlendMode) -> RGBColorModel.Float32Components {
            return destination.blended(source: source, compositingMode: .copy, blendMode: blendMode)._color
        }
        
        XCTAssertEqual(blended(.normal), combined { s, d in s })
        XCTAssertEqual(blended(.multiply), combined { s, d in d * s })
        XCTAssertEqual(blended(.screen), combined { s, d in d + s - d * s })
        XCTAssertEqual(blended(.overlay), combined { s, d in
            if d < 0.5 {
                return 2 * d * s
            }
            return 1 - 2 * (1 - d) * (1 - s)
        })
        XCTAssertEqual(blended(.darken), combined { s, d in min(d, s) })
        XCTAssertEqual(blended(.lighten), combined { s, d in max(d, s) })
        XCTAssertEqual(blended(.colorDodge), combined { s, d in
            if s < 1 {
                return min(1, d / (1 - s))
            }
            return 1
        })
        XCTAssertEqual(blended(.colorBurn), combined { s, d in
            if s > 0 {
                return 1 - min(1, (1 - d) / s)
            }
            return 0
        })
        XCTAssertEqual(blended(.softLight), combined { s, d in
            if s < 0.5  {
                return d - (1 - 2 * s) * d * (1 - d)
            }
            let t = d < 0.25 ? ((16 * d - 12) * d + 4) * d : sqrt(d)
            return d + (2 * s - 1) * (t - d)
        })
        XCTAssertEqual(blended(.hardLight), combined { s, d in
            if d < 0.5  {
                return 2 * s * d
            }
            return 1 - 2 * (1 - s) * (1 - d)
        })
        XCTAssertEqual(blended(.difference), combined { s, d in abs(d - s) })
        XCTAssertEqual(blended(.exclusion), combined { s, d in d + s - 2 * d * s })
        XCTAssertEqual(blended(.plusDarker), combined { s, d in max(0, 1 - ((1 - d) + (1 - s))) })
        XCTAssertEqual(blended(.plusLighter), combined { s, d in min(1, d + s) })
        
    }
    
}
