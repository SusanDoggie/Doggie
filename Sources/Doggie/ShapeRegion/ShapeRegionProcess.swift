//
//  ShapeRegionProcess.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

struct IntersectionTable {
    
    var graph: Graph<Int, [(Type, Split, Split)]> = Graph()
    var overlap: Overlap = .none
    var looping_left: [(Split, Split)] = []
    var looping_right: [(Split, Split)] = []
}

extension IntersectionTable {
    
    enum Overlap {
        case none, equal, superset, subset
    }
    enum `Type` {
        case left
        case right
    }
    
    struct Split {
        let index: Int
        let split: Double
    }
}

extension IntersectionTable.Split {
    
    func almostEqual(_ other: IntersectionTable.Split) -> Bool {
        return self.index == other.index && self.split.almostEqual(other.split)
    }
    
    func ordering(_ other: IntersectionTable.Split) -> Bool {
        return (self.index, self.split) < (other.index, other.split)
    }
}
