//
//  MediaType.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

@frozen
public struct MediaType : RawRepresentable, Hashable, ExpressibleByStringLiteral {
    
    public var rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}
    
extension MediaType {
    
    public static let bmp: MediaType                = "com.microsoft.bmp"
    public static let gif: MediaType                = "com.compuserve.gif"
    public static let heic: MediaType               = "public.heic"
    public static let heif: MediaType               = "public.heif"
    public static let jpeg: MediaType               = "public.jpeg"
    public static let jpeg2000: MediaType           = "public.jpeg-2000"
    public static let png: MediaType                = "public.png"
    public static let tiff: MediaType               = "public.tiff"
    
}

extension MediaType {
    
    public static let svg: MediaType                = "public.svg-image"
    public static let pdf: MediaType                = "com.adobe.pdf"
    public static let postscript: MediaType         = "com.adobe.postscript"
    
}

extension MediaType {
    
    public static let html: MediaType               = "public.html"
    public static let xml: MediaType                = "public.xml"
    public static let xhtml: MediaType              = "public.xhtml"
    
}

extension MediaType {
    
    public static let ttf: MediaType                = "public.truetype-ttf-font"
    public static let otf: MediaType                = "public.opentype-font"
    public static let woff: MediaType               = "org.w3c.woff"
    
}
