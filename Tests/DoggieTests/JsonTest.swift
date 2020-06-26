//
//  JsonTest.swift
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

class JsonTest: XCTestCase {
    
    func testJson() {
        
        do {
            
            let json = try Json(decode: """
            {
              "firstName": "John",
              "lastName": "Smith",
              "isAlive": true,
              "age": 27,
              "address": {
                "streetAddress": "21 2nd Street",
                "city": "New York",
                "state": "NY",
                "postalCode": "10021-3100"
              },
              "phoneNumbers": [
                {
                  "type": "home",
                  "number": "212 555-1234"
                },
                {
                  "type": "office",
                  "number": "646 555-4567"
                }
              ],
              "children": [],
              "spouse": null
            }
            """)
            
            XCTAssertTrue(json.isObject)
            
            XCTAssertEqual(json["firstName"].stringValue, "John")
            XCTAssertEqual(json["lastName"].stringValue, "Smith")
            XCTAssertEqual(json["isAlive"].boolValue, true)
            XCTAssertEqual(json["age"].intValue, 27)
            
            XCTAssertTrue(json["address"].isObject)
            XCTAssertEqual(json["address"]["streetAddress"], "21 2nd Street")
            XCTAssertEqual(json["address"]["city"], "New York")
            XCTAssertEqual(json["address"]["state"], "NY")
            XCTAssertEqual(json["address"]["postalCode"], "10021-3100")
            
            XCTAssertTrue(json["phoneNumbers"].isArray)
            XCTAssertEqual(json["phoneNumbers"].array?.count, 2)
            XCTAssertEqual(json["phoneNumbers"][0]["type"], "home")
            XCTAssertEqual(json["phoneNumbers"][0]["number"], "212 555-1234")
            XCTAssertEqual(json["phoneNumbers"][1]["type"], "office")
            XCTAssertEqual(json["phoneNumbers"][1]["number"], "646 555-4567")
            
            XCTAssertTrue(json["children"].isArray)
            XCTAssertEqual(json["children"].array?.count, 0)
            
            XCTAssertTrue(json["spouse"].isNil)
            
        } catch let error {
            XCTFail("XML parser error: \(error)")
        }
    }
    
}

