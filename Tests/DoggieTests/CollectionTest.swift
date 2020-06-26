//
//  CollectionTest.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Doggie
import XCTest

class CollectionTest: XCTestCase {
    
    struct Dir: Hashable {
        
        var id: UUID = UUID()
        
        var parent: UUID?
        
        var name: String
        
    }
    
    struct Path: Hashable {
        
        var id: UUID
        
        var path: String
        
    }
    
    var sample: Image<ARGB32ColorPixel> = {
        
        let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.sRGB)
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
        
        context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
        
        context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
        
        return context.image
    }()
    
    func testCollectionRangeOf() {
        
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        
        XCTAssertEqual(array.range(of: [1, 2, 3]), 0..<3)
        XCTAssertEqual(array.range(of: [7, 8, 9]), 6..<9)
        XCTAssertEqual(array.range(of: [3, 4, 5]), 2..<5)
        XCTAssertEqual(array.range(of: [1, 4, 5]), nil)
    }
    
    func testNextPermute1() {
        
        var array = [1, 2, 3]
        
        let answer = [
            [1, 2, 3],
            [1, 3, 2],
            [2, 1, 3],
            [2, 3, 1],
            [3, 1, 2],
            [3, 2, 1],
        ]
        
        for _answer in answer {
            
            XCTAssertEqual(array, _answer)
            
            array.nextPermute()
        }
    }
    
    func testNextPermute2() {
        
        var array = [1, 2, 2, 3, 3]
        
        let answer = [
            [1, 2, 2, 3, 3],
            [1, 2, 3, 2, 3],
            [1, 2, 3, 3, 2],
            [1, 3, 2, 2, 3],
            [1, 3, 2, 3, 2],
            [1, 3, 3, 2, 2],
            [2, 1, 2, 3, 3],
            [2, 1, 3, 2, 3],
            [2, 1, 3, 3, 2],
            [2, 2, 1, 3, 3],
            [2, 2, 3, 1, 3],
            [2, 2, 3, 3, 1],
            [2, 3, 1, 2, 3],
            [2, 3, 1, 3, 2],
            [2, 3, 2, 1, 3],
            [2, 3, 2, 3, 1],
            [2, 3, 3, 1, 2],
            [2, 3, 3, 2, 1],
            [3, 1, 2, 2, 3],
            [3, 1, 2, 3, 2],
            [3, 1, 3, 2, 2],
            [3, 2, 1, 2, 3],
            [3, 2, 1, 3, 2],
            [3, 2, 2, 1, 3],
            [3, 2, 2, 3, 1],
            [3, 2, 3, 1, 2],
            [3, 2, 3, 2, 1],
            [3, 3, 1, 2, 2],
            [3, 3, 2, 1, 2],
            [3, 3, 2, 2, 1],
        ]
        
        for _answer in answer {
            
            XCTAssertEqual(array, _answer)
            
            array.nextPermute()
        }
    }
    
    func testIndexedCollection() {
        
        let a = [1, 2, 3, 4, 5, 6, 7, 8, 9][1..<6]
        
        let result = a.indexed()
        let answer = [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]
        
        XCTAssert(result.elementsEqual(answer) { $0.0 == $1.0 && $0.1 == $1.1 })
    }
    
    func testConcatCollection() {
        
        let a = [1, 2, 3]
        let b = [4, 5, 6]
        
        let result = a.concat(b)
        let answer = a + b
        
        XCTAssert(result.elementsEqual(answer))
        XCTAssertEqual(Array(result), answer)
    }
    
    func testRecursiveMap() {
        
        var list: [Dir] = []
        list.append(Dir(name: "root"))
        list.append(Dir(parent: list[0].id, name: "images"))
        list.append(Dir(parent: list[0].id, name: "Users"))
        list.append(Dir(parent: list[2].id, name: "Susan"))
        list.append(Dir(parent: list[3].id, name: "Desktop"))
        list.append(Dir(parent: list[1].id, name: "test.jpg"))
        
        let answer = [
            Path(id: list[0].id, path: "/root"),
            Path(id: list[1].id, path: "/root/images"),
            Path(id: list[2].id, path: "/root/Users"),
            Path(id: list[5].id, path: "/root/images/test.jpg"),
            Path(id: list[3].id, path: "/root/Users/Susan"),
            Path(id: list[4].id, path: "/root/Users/Susan/Desktop"),
        ]
        
        let result = list.compactMap { $0.parent == nil ? Path(id: $0.id, path: "/\($0.name)") : nil }
            .recursiveMap { parent in list.compactMap { $0.parent == parent.id ? Path(id: $0.id, path: "\(parent.path)/\($0.name)") : nil } }
        
        XCTAssertEqual(result, answer)
    }
    
    func testLazyRecursiveMap() {
        
        var list: [Dir] = []
        list.append(Dir(name: "root"))
        list.append(Dir(parent: list[0].id, name: "images"))
        list.append(Dir(parent: list[0].id, name: "Users"))
        list.append(Dir(parent: list[2].id, name: "Susan"))
        list.append(Dir(parent: list[3].id, name: "Desktop"))
        list.append(Dir(parent: list[1].id, name: "test.jpg"))
        
        let answer = [
            Path(id: list[0].id, path: "/root"),
            Path(id: list[1].id, path: "/root/images"),
            Path(id: list[2].id, path: "/root/Users"),
            Path(id: list[5].id, path: "/root/images/test.jpg"),
            Path(id: list[3].id, path: "/root/Users/Susan"),
            Path(id: list[4].id, path: "/root/Users/Susan/Desktop"),
        ]
        
        let result = list.compactMap { $0.parent == nil ? Path(id: $0.id, path: "/\($0.name)") : nil }
            .lazy.recursiveMap { parent in list.compactMap { $0.parent == parent.id ? Path(id: $0.id, path: "\(parent.path)/\($0.name)") : nil } }
        
        XCTAssertEqual(Array(result), answer)
    }
    
    func testOptionOneCollection1() {
        
        let c = OptionOneCollection<Int>(nil)
        
        XCTAssertEqual(c.count, 0)
        
        XCTAssert(c.elementsEqual([]))
        XCTAssertEqual(Array(c), [])
    }
    
    func testOptionOneCollection2() {
        
        let c = OptionOneCollection(42)
        
        XCTAssertEqual(c.count, 1)
        
        for value in c {
            XCTAssertEqual(value, 42)
        }
        
        XCTAssert(c.elementsEqual([42]))
        XCTAssertEqual(Array(c), [42])
    }
    
    func testSequenceScan() {
        
        let result = (1..<6).scan(0, +)
        let answer = [0, 1, 3, 6, 10, 15]
        
        XCTAssertEqual(result, answer)
    }
    
    func testLazySequenceScan() {
        
        let result = (1..<6).lazy.scan(0, +)
        let answer = [0, 1, 3, 6, 10, 15]
        
        XCTAssert(result.elementsEqual(answer))
        XCTAssertEqual(Array(result), answer)
    }
    
    func testSequenceStorageEqual() {
        
        let a = [1, 2, 3, 4, 5, 6]
        let b = a[0...]
        
        XCTAssertEqual(a.isStorageEqual(b), true)
    }
    
    func testSequenceStorageEqual2() {
        
        let a = [1, 2, 3, 4, 5, 6]
        var b = a[0...]
        
        b[0] = 1
        
        XCTAssertEqual(a.isStorageEqual(b), false)
    }
    
    func testSequenceStorageEqual3() {
        
        let a = sample
        let b = sample
        
        XCTAssertEqual(a.isStorageEqual(b), true)
    }
    
    func testSequenceStorageEqual4() {
        
        let a = sample
        var b = sample
        
        b[0, 0] = b[0, 0]
        
        XCTAssertEqual(a.isStorageEqual(b), false)
    }
    
}
