//
//  MIMEType.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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
public struct MIMEType: Hashable {
    
    public var type: String
    
    public var subType: String
    
    @inlinable
    public init(type: String, subType: String) {
        self.type = type
        self.subType = subType
    }
}

extension MIMEType: RawRepresentable {
    
    @inlinable
    public var rawValue: String {
        return "\(type)/\(subType)"
    }
    
    @inlinable
    public init?(rawValue: String) {
        let parts = rawValue.split(separator: "/")
        guard parts.count == 2 else { return nil }
        self.type = parts[0].trimmingCharacters(in: .whitespaces)
        self.subType = parts[1].trimmingCharacters(in: .whitespaces)
    }
}

extension MIMEType: ExpressibleByStringLiteral {
    
    @inlinable
    public init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
}

extension MIMEType {
    
    public static let bmp: MIMEType                = "image/bmp"
    public static let gif: MIMEType                = "image/gif"
    public static let heic: MIMEType               = "image/heic"
    public static let heics: MIMEType              = "image/heic-sequence"
    public static let heif: MIMEType               = "image/heif"
    public static let heifs: MIMEType              = "image/heif-sequence"
    public static let jpeg: MIMEType               = "image/jpeg"
    public static let jpeg2000: MIMEType           = "image/jp2"
    public static let png: MIMEType                = "image/png"
    public static let tiff: MIMEType               = "image/tiff"
    public static let webp: MIMEType               = "image/webp"
    
}

extension MIMEType {
    
    public static let pdf: MIMEType                = "application/pdf"
    public static let postscript: MIMEType         = "application/postscript"
    public static let svg: MIMEType                = "image/svg+xml"
    
}

extension MIMEType {
    
    public static let css: MIMEType                = "text/css"
    public static let html: MIMEType               = "text/html"
    public static let javascript: MIMEType         = "application/javascript"
    public static let json: MIMEType               = "application/json"
    public static let xml: MIMEType                = "application/xml"
    public static let xhtml: MIMEType              = "application/xhtml+xml"
    
}

extension MIMEType {
    
    public static let otf: MIMEType                = "font/otf"
    public static let ttf: MIMEType                = "font/ttf"
    public static let woff: MIMEType               = "font/woff"
    public static let woff2: MIMEType              = "font/woff2"
    
}

extension MIMEType {
    
    #if canImport(CoreServices)
    
    @inlinable
    public var _mediaTypes: [MediaType] {
        let mediaTypes = UTTypeCreateAllIdentifiersForTag(kUTTagClassMIMEType, rawValue as CFString, nil)?.takeRetainedValue() as? [String]
        return mediaTypes?.compactMap { $0.hasPrefix("dyn.") ? nil : MediaType(rawValue: $0) } ?? []
    }
    
    #endif
    
    @inlinable
    public var mediaTypes: [MediaType] {
        switch self {
        case "application/bzip": return ["public.bzip2-archive"]
        case "application/bzip2": return ["public.bzip2-archive"]
        case "application/epub+zip": return ["org.idpf.epub-container"]
        case "application/gzip": return ["org.gnu.gnu-zip-archive"]
        case "application/java-archive": return ["com.sun.java-archive"]
        case "application/json": return ["public.json"]
        case "application/msexcel": return ["com.microsoft.excel.xls", "com.microsoft.excel.xlt", "com.microsoft.excel.xlw"]
        case "application/mspowerpoint": return ["com.microsoft.powerpoint.ppt", "com.microsoft.powerpoint.pot", "com.microsoft.powerpoint.pps"]
        case "application/msword": return ["com.microsoft.word.doc", "com.microsoft.word.dot"]
        case "application/octet-stream": return ["public.data", "com.apple.rcproject"]
        case "application/pdf": return ["com.adobe.pdf"]
        case "application/php": return ["public.php-script"]
        case "application/postscript": return ["com.adobe.postscript"]
        case "application/tar": return ["public.tar-archive"]
        case "application/vnd.ms-excel": return ["com.microsoft.excel.xls", "com.microsoft.excel.xlt", "com.microsoft.excel.xlw"]
        case "application/vnd.ms-powerpoint": return ["com.microsoft.powerpoint.ppt", "com.microsoft.powerpoint.pot", "com.microsoft.powerpoint.pps"]
        case "application/vnd.oasis.opendocument.presentation": return ["org.oasis-open.opendocument.presentation"]
        case "application/vnd.oasis.opendocument.spreadsheet": return ["org.oasis-open.opendocument.spreadsheet"]
        case "application/vnd.oasis.opendocument.text": return ["org.oasis-open.opendocument.text"]
        case "application/vnd.openxmlformats-officedocument.presentationml.presentation": return ["org.openxmlformats.presentationml.presentation"]
        case "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": return ["org.openxmlformats.spreadsheetml.sheet"]
        case "application/vnd.openxmlformats-officedocument.wordprocessingml.document": return ["org.openxmlformats.wordprocessingml.document"]
        case "application/x-7z-compressed": return ["org.7-zip.7-zip-archive"]
        case "application/x-bz2": return ["public.bzip2-archive"]
        case "application/x-bzip": return ["public.bzip2-archive"]
        case "application/x-bzip2": return ["public.bzip2-archive"]
        case "application/x-gzip": return ["org.gnu.gnu-zip-archive"]
        case "application/x-tar": return ["public.tar-archive"]
        case "application/x-zip-compressed": return ["public.zip-archive"]
        case "application/xhtml+xml": return ["public.xhtml"]
        case "application/xml": return ["public.xml"]
        case "application/zip": return ["public.zip-archive"]
        case "audio/3gpp": return ["public.3gpp"]
        case "audio/3gpp2": return ["public.3gpp2"]
        case "audio/aac": return ["public.aac-audio"]
        case "audio/mp3": return ["public.mp3"]
        case "audio/mpeg": return ["public.mp3", "com.apple.music.mp2"]
        case "audio/mpeg3": return ["public.mp3"]
        case "audio/mpg": return ["public.mp3"]
        case "audio/vnd.wave": return ["com.microsoft.waveform-audio"]
        case "audio/wav": return ["com.microsoft.waveform-audio"]
        case "audio/wave": return ["com.microsoft.waveform-audio"]
        case "audio/x-aac": return ["public.aac-audio"]
        case "audio/x-mp3": return ["public.mp3"]
        case "audio/x-mpeg": return ["public.mp3", "com.apple.music.mp2"]
        case "audio/x-mpeg3": return ["public.mp3"]
        case "audio/x-mpg": return ["public.mp3"]
        case "audio/x-wav": return ["com.microsoft.waveform-audio"]
        case "font/otf": return ["public.opentype-font"]
        case "font/sfnt": return ["public.truetype-ttf-font"]
        case "font/ttf": return ["public.truetype-ttf-font"]
        case "font/woff": return ["org.w3c.woff"]
        case "font/woff2": return ["org.w3c.woff2"]
        case "image/bmp": return ["com.microsoft.bmp"]
        case "image/gif": return ["com.compuserve.gif"]
        case "image/heic": return ["public.heic"]
        case "image/heic-sequence": return ["public.heics"]
        case "image/heif": return ["public.heif"]
        case "image/heif-sequence": return ["public.heifs"]
        case "image/jp2": return ["public.jpeg-2000"]
        case "image/jpeg": return ["public.jpeg"]
        case "image/jpg": return ["public.jpeg"]
        case "image/png": return ["public.png"]
        case "image/svg+xml": return ["public.svg-image"]
        case "image/tiff": return ["public.tiff"]
        case "image/vnd.microsoft.icon": return ["com.microsoft.ico"]
        case "image/webp": return ["com.google.webp"]
        case "text/calendar": return ["com.apple.ical.ics"]
        case "text/comma-separated-values": return ["public.comma-separated-values-text"]
        case "text/css": return ["public.css"]
        case "text/csv": return ["public.comma-separated-values-text"]
        case "text/html": return ["public.html"]
        case "text/javascript": return ["com.netscape.javascript-source"]
        case "text/php": return ["public.php-script"]
        case "text/plain": return ["public.plain-text"]
        case "text/x-php-script": return ["public.php-script"]
        case "text/xml": return ["public.xml"]
        case "video/3gpp": return ["public.3gpp"]
        case "video/3gpp2": return ["public.3gpp2"]
        case "video/avi": return ["public.avi"]
        case "video/mpeg": return ["public.mpeg"]
        case "video/mpg": return ["public.mpeg"]
        case "video/msvideo": return ["public.avi"]
        case "video/x-mpeg": return ["public.mpeg"]
        case "video/x-mpg": return ["public.mpeg"]
        case "video/x-msvideo": return ["public.avi"]
        default: return []
        }
    }
    
}
