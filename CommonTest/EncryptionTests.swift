//
//  EncryptionTests.swift
//
//  The MIT License
//  Copyright (c) 2015 Susan Cheng. All rights reserved.
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

import Foundation
import XCTest

class EncryptionTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMD5() {
        // This is an example of a functional test case.
        
        let answer = "9e107d9d372bb6826bd81d3542a419d6"
        let result = md5("The quick brown fox jumps over the lazy dog")
        
        XCTAssertEqual(answer, byteString(result))
    }
    func testSHA1() {
        // This is an example of a functional test case.
        
        let answer = "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12"
        let result = sha1("The quick brown fox jumps over the lazy dog")
        
        XCTAssertEqual(answer, byteString(result))
    }
    func testSHA224() {
        // This is an example of a functional test case.
        
        let answer = "730e109bd7a8a32b1cb9d9a09aa2325d2430587ddbc0c38bad911525"
        let result = sha224("The quick brown fox jumps over the lazy dog")
        
        XCTAssertEqual(answer, byteString(result))
    }
    func testSHA256() {
        // This is an example of a functional test case.
        
        let answer = "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"
        let result = sha256("The quick brown fox jumps over the lazy dog")
        
        XCTAssertEqual(answer, byteString(result))
    }
    func testSHA384() {
        // This is an example of a functional test case.
        
        let answer = "ca737f1014a48f4c0b6dd43cb177b0afd9e5169367544c494011e3317dbf9a509cb1e5dc1e85a941bbee3d7f2afbc9b1"
        let result = sha384("The quick brown fox jumps over the lazy dog")
        
        XCTAssertEqual(answer, byteString(result))
    }
    func testSHA512() {
        // This is an example of a functional test case.
        
        let answer = "07e547d9586f6a73f73fbac0435ed76951218fb7d0c8d788a309d785436bbb642e93a252a954f23912547d1e8a3b5ed6e1bfd7097821233fa0538f3db854fee6"
        let result = sha512("The quick brown fox jumps over the lazy dog")
        
        XCTAssertEqual(answer, byteString(result))
    }
    func testHMACMD5() {
        // This is an example of a functional test case.
        
        let answer = "80070713463e7749b90c2dc24911e275"
        let result = hmac_md5("key", "The quick brown fox jumps over the lazy dog")
        
        XCTAssertEqual(answer, byteString(result))
    }
    func testHMACSHA1() {
        // This is an example of a functional test case.
        
        let answer = "de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9"
        let result = hmac_sha1("key", "The quick brown fox jumps over the lazy dog")
        
        XCTAssertEqual(answer, byteString(result))
    }
    func testHMACSHA256() {
        // This is an example of a functional test case.
        
        let answer = "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8"
        let result = hmac_sha256("key", "The quick brown fox jumps over the lazy dog")
        
        XCTAssertEqual(answer, byteString(result))
    }
}

func byteString(bytes: [UInt8]) -> String {
    return bytes.map { String(format: "%02x", arguments: [$0]) }.joinWithSeparator("")
}