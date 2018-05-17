//
//  PNGInterlace.swift
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

let png_interlace_starting_row = [0, 0, 4, 0, 2, 0, 1]
let png_interlace_starting_col = [0, 4, 0, 2, 0, 1, 0]
let png_interlace_row_increment = [8, 8, 8, 4, 4, 2, 2]
let png_interlace_col_increment = [8, 8, 4, 4, 2, 2, 1]
let png_interlace_block_height = [8, 8, 4, 4, 2, 2, 1]
let png_interlace_block_width = [8, 4, 4, 2, 2, 1, 1]

struct png_interlace_state {
    
    let width: Int
    let height: Int
    let bitsPerPixel: UInt8
    
    private(set) var pass = -1
    
    private(set) var starting_row = 0
    private(set) var starting_col = 0
    private(set) var row_increment = 0
    private(set) var col_increment = 0
    private(set) var block_height = 0
    private(set) var block_width = 0
    
    private(set) var scanline_size = 0
    private(set) var scanline_offset = 0
    
    private(set) var current_row = 0
    
    init(width: Int, height: Int, bitsPerPixel: UInt8) {
        self.width = width
        self.height = height
        self.bitsPerPixel = bitsPerPixel
        self.current_row = height
        print("bitsPerPixel:", bitsPerPixel)
    }
}

extension png_interlace_state {
    
    mutating func scan(_ source: UnsafeBufferPointer<UInt8>, _ callback: (png_interlace_state, UnsafeBufferPointer<UInt8>) throws -> Void) rethrows {
        
        guard pass < 7 else { return }
        
        var source = source
        
        while source.count != 0 {
            
            if current_row >= height {
                
                while true {
                    
                    pass += 1
                    guard pass < 7 else { return }
                    
                    starting_row = png_interlace_starting_row[pass]
                    starting_col = png_interlace_starting_col[pass]
                    row_increment = png_interlace_row_increment[pass]
                    col_increment = png_interlace_col_increment[pass]
                    block_height = png_interlace_block_height[pass]
                    block_width = png_interlace_block_width[pass]
                    
                    guard width > starting_col else { continue }
                    guard height > starting_row else { continue }
                    
                    let scanline_count = (width - starting_col + (col_increment - 1)) / col_increment
                    scanline_size = (Int(bitsPerPixel) * scanline_count + 7) >> 3
                    scanline_offset = 0
                    
                    current_row = starting_row
                    
                    break
                }
            }
            
            let _scanline_size = scanline_size + 1
            let scanline_remain = _scanline_size - scanline_offset
            
            try callback(self, UnsafeBufferPointer(rebasing: source.prefix(scanline_remain)))
            source = UnsafeBufferPointer(rebasing: source.dropFirst(scanline_remain))
            
            scanline_offset += scanline_remain
            
            if scanline_offset >= _scanline_size {
                scanline_offset = 0
                current_row += row_increment
            }
        }
    }
}
