//
//  MediaType.swift
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

#if canImport(CoreServices)

import CoreServices

#endif

#if canImport(MobileCoreServices)

import MobileCoreServices

#endif

@frozen
public struct MediaType: RawRepresentable, Hashable, ExpressibleByStringLiteral {
    
    public var rawValue: String
    
    @inlinable
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    @inlinable
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

extension MediaType {
    
    public static let bmp: MediaType                = "com.microsoft.bmp"
    public static let gif: MediaType                = "com.compuserve.gif"
    public static let heic: MediaType               = "public.heic"
    public static let heics: MediaType              = "public.heics"
    public static let heif: MediaType               = "public.heif"
    public static let heifs: MediaType              = "public.heifs"
    public static let jpeg: MediaType               = "public.jpeg"
    public static let jpeg2000: MediaType           = "public.jpeg-2000"
    public static let png: MediaType                = "public.png"
    public static let tiff: MediaType               = "public.tiff"
    public static let webp: MediaType               = "com.google.webp"
    
}

extension MediaType {
    
    public static let pdf: MediaType                = "com.adobe.pdf"
    public static let postscript: MediaType         = "com.adobe.postscript"
    public static let svg: MediaType                = "public.svg-image"
    
}

extension MediaType {
    
    public static let css: MIMEType                 = "public.css"
    public static let html: MediaType               = "public.html"
    public static let javascript: MIMEType          = "com.netscape.javascript-source"
    public static let json: MIMEType                = "public.json"
    public static let xml: MediaType                = "public.xml"
    public static let xhtml: MediaType              = "public.xhtml"
    
}

extension MediaType {
    
    public static let otf: MediaType                = "public.opentype-font"
    public static let ttf: MediaType                = "public.truetype-ttf-font"
    public static let woff: MediaType               = "org.w3c.woff"
    public static let woff2: MediaType              = "org.w3c.woff2"
    
}

extension MediaType {
    
    #if canImport(CoreServices)
    
    @inlinable
    public var _mimeTypes: [MIMEType] {
        let mimeType = UTTypeCopyAllTagsWithClass(rawValue as CFString, kUTTagClassMIMEType)?.takeRetainedValue() as? [String]
        return mimeType?.compactMap { MIMEType(rawValue: $0) } ?? []
    }
    
    #endif
    
    @inlinable
    public var mimeTypes: [MIMEType] {
        switch self {
        case "com.adobe.pdf": return ["application/pdf"]
        case "com.adobe.postscript": return ["application/postscript"]
        case "com.apple.ical.ics": return ["text/calendar"]
        case "com.apple.music.mp2": return ["audio/mpeg", "audio/x-mpeg"]
        case "com.apple.rcproject": return ["application/octet-stream"]
        case "com.compuserve.gif": return ["image/gif"]
        case "com.google.webp": return ["image/webp"]
        case "com.microsoft.bmp": return ["image/bmp"]
        case "com.microsoft.excel.xls": return ["application/vnd.ms-excel", "application/msexcel"]
        case "com.microsoft.excel.xlt": return ["application/vnd.ms-excel", "application/msexcel"]
        case "com.microsoft.excel.xlw": return ["application/vnd.ms-excel", "application/msexcel"]
        case "com.microsoft.ico": return ["image/vnd.microsoft.icon"]
        case "com.microsoft.powerpoint.pot": return ["application/vnd.ms-powerpoint", "application/mspowerpoint"]
        case "com.microsoft.powerpoint.pps": return ["application/vnd.ms-powerpoint", "application/mspowerpoint"]
        case "com.microsoft.powerpoint.ppt": return ["application/vnd.ms-powerpoint", "application/mspowerpoint"]
        case "com.microsoft.waveform-audio": return ["audio/vnd.wave", "audio/wav", "audio/wave", "audio/x-wav"]
        case "com.microsoft.word.doc": return ["application/msword"]
        case "com.microsoft.word.dot": return ["application/msword"]
        case "com.netscape.javascript-source": return ["text/javascript"]
        case "com.sun.java-archive": return ["application/java-archive"]
        case "org.7-zip.7-zip-archive": return ["application/x-7z-compressed"]
        case "org.gnu.gnu-zip-archive": return ["application/x-gzip", "application/gzip"]
        case "org.idpf.epub-container": return ["application/epub+zip"]
        case "org.oasis-open.opendocument.presentation": return ["application/vnd.oasis.opendocument.presentation"]
        case "org.oasis-open.opendocument.spreadsheet": return ["application/vnd.oasis.opendocument.spreadsheet"]
        case "org.oasis-open.opendocument.text": return ["application/vnd.oasis.opendocument.text"]
        case "org.openxmlformats.presentationml.presentation": return ["application/vnd.openxmlformats-officedocument.presentationml.presentation"]
        case "org.openxmlformats.spreadsheetml.sheet": return ["application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"]
        case "org.openxmlformats.wordprocessingml.document": return ["application/vnd.openxmlformats-officedocument.wordprocessingml.document"]
        case "org.w3c.woff": return ["font/woff"]
        case "org.w3c.woff2": return ["font/woff2"]
        case "public.3gpp": return ["video/3gpp", "audio/3gpp"]
        case "public.3gpp2": return ["video/3gpp2", "audio/3gpp2"]
        case "public.aac-audio": return ["audio/aac", "audio/x-aac"]
        case "public.avi": return ["video/avi", "video/msvideo", "video/x-msvideo"]
        case "public.bzip2-archive": return ["application/x-bzip2", "application/x-bzip", "application/bzip2", "application/bzip", "application/x-bz2"]
        case "public.comma-separated-values-text": return ["text/csv", "text/comma-separated-values"]
        case "public.css": return ["text/css"]
        case "public.data": return ["application/octet-stream"]
        case "public.heic": return ["image/heic"]
        case "public.heics": return ["image/heic-sequence"]
        case "public.heif": return ["image/heif"]
        case "public.heifs": return ["image/heif-sequence"]
        case "public.html": return ["text/html"]
        case "public.jpeg": return ["image/jpeg", "image/jpg"]
        case "public.jpeg-2000": return ["image/jp2"]
        case "public.json": return ["application/json"]
        case "public.mp3": return ["audio/mpeg", "audio/mpeg3", "audio/mpg", "audio/mp3", "audio/x-mpeg", "audio/x-mpeg3", "audio/x-mpg", "audio/x-mp3"]
        case "public.mpeg": return ["video/mpeg", "video/mpg", "video/x-mpeg", "video/x-mpg"]
        case "public.opentype-font": return ["font/otf"]
        case "public.php-script": return ["text/php", "text/x-php-script", "application/php"]
        case "public.plain-text": return ["text/plain"]
        case "public.png": return ["image/png"]
        case "public.svg-image": return ["image/svg+xml"]
        case "public.tar-archive": return ["application/x-tar", "application/tar"]
        case "public.tiff": return ["image/tiff"]
        case "public.truetype-ttf-font": return ["font/ttf", "font/sfnt"]
        case "public.xhtml": return ["application/xhtml+xml"]
        case "public.xml": return ["application/xml", "text/xml"]
        case "public.zip-archive": return ["application/zip", "application/x-zip-compressed"]
        default: return []
        }
    }
}
