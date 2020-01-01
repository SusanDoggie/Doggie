//
//  XMLTest.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Doggie
import XCTest

class XMLTest: XCTestCase {
    
    func testXMLA() {
        
        let xmlString = """
        <?xml version="1.0" encoding="utf-8" standalone="yes"?>
        <D:propfind xmlns:D="DAV:">
            <D:prop>
                <D:getlastmodified></D:getlastmodified>
                <D:getcontentlength></D:getcontentlength>
                <D:creationdate></D:creationdate>
                <D:resourcetype></D:resourcetype>
            </D:prop>
        </D:propfind>
        """
        
        do {
            
            let doc = try SDXMLDocument(xml: xmlString)
            
            XCTAssertEqual(doc.count, 1)
            
            XCTAssertEqual(doc[0].name, "propfind")
            XCTAssertEqual(doc[0].namespace, "DAV:")
            XCTAssertEqual(doc[0].count, 1)
            
            XCTAssertEqual(doc[0][0].name, "prop")
            XCTAssertEqual(doc[0][0].namespace, "DAV:")
            XCTAssertEqual(doc[0][0].count, 4)
            
            XCTAssertEqual(doc[0][0][0].name, "getlastmodified")
            XCTAssertEqual(doc[0][0][0].namespace, "DAV:")
            XCTAssertEqual(doc[0][0][0].count, 0)
            
            XCTAssertEqual(doc[0][0][1].name, "getcontentlength")
            XCTAssertEqual(doc[0][0][1].namespace, "DAV:")
            XCTAssertEqual(doc[0][0][1].count, 0)
            
            XCTAssertEqual(doc[0][0][2].name, "creationdate")
            XCTAssertEqual(doc[0][0][2].namespace, "DAV:")
            XCTAssertEqual(doc[0][0][2].count, 0)
            
            XCTAssertEqual(doc[0][0][3].name, "resourcetype")
            XCTAssertEqual(doc[0][0][3].namespace, "DAV:")
            XCTAssertEqual(doc[0][0][3].count, 0)
            
        } catch let error {
            XCTFail("XML parser error: \(error)")
        }
    }
    
}
