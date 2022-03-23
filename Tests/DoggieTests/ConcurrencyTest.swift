//
//  ConcurrencyTest.swift
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

#if compiler(>=5.5.2) && canImport(_Concurrency)

import Doggie
import XCTest

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
class ConcurrencyTest: XCTestCase {
    
    struct Dir: Hashable {
        
        var id: UUID = UUID()
        
        var parent: UUID?
        
        var name: String
        
    }
    
    struct Path: Hashable {
        
        var id: UUID
        
        var path: String
        
    }
    
    func testAsyncParallelMap() async throws {
        
        let array: [Int] = try await (0..<10).parallelMap { i in
            
            try await Task.sleep(nanoseconds: 1000)
            
            return i
        }
        
        XCTAssertEqual(array, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    }
    
    func testAsyncRecursiveMap() async {
        
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
        
        let _result: AsyncRecursiveMapSequence = list.compactMap { $0.parent == nil ? Path(id: $0.id, path: "/\($0.name)") : nil }
            .recursiveMap { parent in list.compactMap { $0.parent == parent.id ? Path(id: $0.id, path: "\(parent.path)/\($0.name)") : nil } }
        
        let result = await _result.collect()
        
        XCTAssertEqual(result, answer)
    }
    
    func testAsyncThrowingRecursiveMap() async throws {
        
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
        
        let _result: AsyncThrowingRecursiveMapSequence = list.compactMap { $0.parent == nil ? Path(id: $0.id, path: "/\($0.name)") : nil }
            .recursiveMap { parent in list.compactMap { $0.parent == parent.id ? Path(id: $0.id, path: "\(parent.path)/\($0.name)") : nil } }
        
        let result = try await _result.collect()
        
        XCTAssertEqual(result, answer)
    }
    
}

#endif
