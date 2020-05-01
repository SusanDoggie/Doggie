//
//  MIMEType.swift
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

extension MIMEType {
    
    @inlinable
    public var description: String {
        return serialize()
    }
}

extension MIMEType {
    
    @inlinable
    public func serialize() -> String {
        return "\(type)/\(subType)"
    }
}

extension MIMEType {
    
    public static let bmp: MIMEType                = MIMEType(type: "image", subType: "bmp")
    public static let gif: MIMEType                = MIMEType(type: "image", subType: "gif")
    public static let heic: MIMEType               = MIMEType(type: "image", subType: "heic")
    public static let heif: MIMEType               = MIMEType(type: "image", subType: "heif")
    public static let jpeg: MIMEType               = MIMEType(type: "image", subType: "jpeg")
    public static let jpeg2000: MIMEType           = MIMEType(type: "image", subType: "jp2")
    public static let png: MIMEType                = MIMEType(type: "image", subType: "png")
    public static let tiff: MIMEType               = MIMEType(type: "image", subType: "tiff")
    public static let webp: MIMEType               = MIMEType(type: "image", subType: "webp")
    
}

extension MIMEType {
    
    public static let svg: MIMEType                = MIMEType(type: "image", subType: "svg+xml")
    public static let pdf: MIMEType                = MIMEType(type: "application", subType: "pdf")
    public static let postscript: MIMEType         = MIMEType(type: "application", subType: "postscript")
    
}

extension MIMEType {
    
    public static let html: MIMEType               = MIMEType(type: "text", subType: "html")
    public static let css: MIMEType                = MIMEType(type: "text", subType: "css")
    public static let xml: MIMEType                = MIMEType(type: "application", subType: "xml")
    public static let xhtml: MIMEType              = MIMEType(type: "application", subType: "xhtml+xml")
    public static let javascript: MIMEType         = MIMEType(type: "application", subType: "javascript")
    public static let json: MIMEType               = MIMEType(type: "application", subType: "json")
    
}

extension MIMEType {
    
    public static let ttf: MIMEType                = MIMEType(type: "font", subType: "ttf")
    public static let otf: MIMEType                = MIMEType(type: "font", subType: "otf")
    public static let woff: MIMEType               = MIMEType(type: "font", subType: "woff")
    
}

extension MIMEType {
    
    @inlinable
    public static func fileExtension(_ ext: String) -> MIMEType? {
        switch ext {
        case "aac": return MIMEType(type: "audio", subType: "aac")
        case "abw": return MIMEType(type: "application", subType: "x-abiword")
        case "arc": return MIMEType(type: "application", subType: "x-freearc")
        case "avi": return MIMEType(type: "video", subType: "x-msvideo")
        case "azw": return MIMEType(type: "application", subType: "vnd.amazon.ebook")
        case "bin": return MIMEType(type: "application", subType: "octet-stream")
        case "bmp": return MIMEType(type: "image", subType: "bmp")
        case "bz": return MIMEType(type: "application", subType: "x-bzip")
        case "bz2": return MIMEType(type: "application", subType: "x-bzip2")
        case "csh": return MIMEType(type: "application", subType: "x-csh")
        case "css": return MIMEType(type: "text", subType: "css")
        case "csv": return MIMEType(type: "text", subType: "csv")
        case "doc": return MIMEType(type: "application", subType: "msword")
        case "docx": return MIMEType(type: "application", subType: "vnd.openxmlformats-officedocument.wordprocessingml.document")
        case "eot": return MIMEType(type: "application", subType: "vnd.ms-fontobject")
        case "epub": return MIMEType(type: "application", subType: "epub+zip")
        case "gz": return MIMEType(type: "application", subType: "gzip")
        case "gif": return MIMEType(type: "image", subType: "gif")
        case "heic": return MIMEType(type: "image", subType: "heic")
        case "heif": return MIMEType(type: "image", subType: "heif")
        case "htm": return MIMEType(type: "text", subType: "html")
        case "html": return MIMEType(type: "text", subType: "html")
        case "ico": return MIMEType(type: "image", subType: "vnd.microsoft.icon")
        case "ics": return MIMEType(type: "text", subType: "calendar")
        case "jar": return MIMEType(type: "application", subType: "java-archive")
        case "jpeg": return MIMEType(type: "image", subType: "jpeg")
        case "jpg": return MIMEType(type: "image", subType: "jpeg")
        case "jpg2": return MIMEType(type: "image", subType: "jp2")
        case "jp2": return MIMEType(type: "image", subType: "jp2")
        case "j2c": return MIMEType(type: "image", subType: "jp2")
        case "js": return MIMEType(type: "text", subType: "javascript")
        case "json": return MIMEType(type: "application", subType: "json")
        case "jsonld": return MIMEType(type: "application", subType: "ld+json")
        case "mid": return MIMEType(type: "audio", subType: "midi audio/x-midi")
        case "midi": return MIMEType(type: "audio", subType: "midi audio/x-midi")
        case "mjs": return MIMEType(type: "text", subType: "javascript")
        case "mp3": return MIMEType(type: "audio", subType: "mpeg")
        case "mpeg": return MIMEType(type: "video", subType: "mpeg")
        case "mpkg": return MIMEType(type: "application", subType: "vnd.apple.installer+xml")
        case "odp": return MIMEType(type: "application", subType: "vnd.oasis.opendocument.presentation")
        case "ods": return MIMEType(type: "application", subType: "vnd.oasis.opendocument.spreadsheet")
        case "odt": return MIMEType(type: "application", subType: "vnd.oasis.opendocument.text")
        case "oga": return MIMEType(type: "audio", subType: "ogg")
        case "ogv": return MIMEType(type: "video", subType: "ogg")
        case "ogx": return MIMEType(type: "application", subType: "ogg")
        case "opus": return MIMEType(type: "audio", subType: "opus")
        case "otf": return MIMEType(type: "font", subType: "otf")
        case "png": return MIMEType(type: "image", subType: "png")
        case "pdf": return MIMEType(type: "application", subType: "pdf")
        case "php": return MIMEType(type: "application", subType: "php")
        case "ppt": return MIMEType(type: "application", subType: "vnd.ms-powerpoint")
        case "pptx": return MIMEType(type: "application", subType: "vnd.openxmlformats-officedocument.presentationml.presentation")
        case "ps": return MIMEType(type: "application", subType: "postscript")
        case "rar": return MIMEType(type: "application", subType: "vnd.rar")
        case "rtf": return MIMEType(type: "application", subType: "rtf")
        case "sh": return MIMEType(type: "application", subType: "x-sh")
        case "svg": return MIMEType(type: "image", subType: "svg+xml")
        case "swf": return MIMEType(type: "application", subType: "x-shockwave-flash")
        case "tar": return MIMEType(type: "application", subType: "x-tar")
        case "tif": return MIMEType(type: "image", subType: "tiff")
        case "tiff": return MIMEType(type: "image", subType: "tiff")
        case "ts": return MIMEType(type: "video", subType: "mp2t")
        case "ttf": return MIMEType(type: "font", subType: "ttf")
        case "txt": return MIMEType(type: "text", subType: "plain")
        case "vsd": return MIMEType(type: "application", subType: "vnd.visio")
        case "wav": return MIMEType(type: "audio", subType: "wav")
        case "weba": return MIMEType(type: "audio", subType: "webm")
        case "webm": return MIMEType(type: "video", subType: "webm")
        case "webp": return MIMEType(type: "image", subType: "webp")
        case "woff": return MIMEType(type: "font", subType: "woff")
        case "woff2": return MIMEType(type: "font", subType: "woff2")
        case "xhtml": return MIMEType(type: "application", subType: "xhtml+xml")
        case "xls": return MIMEType(type: "application", subType: "vnd.ms-excel")
        case "xlsx": return MIMEType(type: "application", subType: "vnd.openxmlformats-officedocument.spreadsheetml.sheet")
        case "xml": return MIMEType(type: "application", subType: "xml")
        case "xul": return MIMEType(type: "application", subType: "vnd.mozilla.xul+xml")
        case "zip": return MIMEType(type: "application", subType: "zip")
        case "3gp": return MIMEType(type: "video", subType: "3gpp")
        case "3g2": return MIMEType(type: "video", subType: "3gpp2")
        case "7z": return MIMEType(type: "application", subType: "x-7z-compressed")
        default: return nil
        }
    }
}
