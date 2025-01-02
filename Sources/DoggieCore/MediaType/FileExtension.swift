//
//  FileExtension.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

extension MediaType {
    
    #if canImport(CoreServices)
    
    @inlinable
    public static func _mediaTypesWithFileExtension(_ ext: String) -> [MediaType] {
        let mediaTypes = UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, ext as CFString, nil)?.takeRetainedValue() as? [String]
        return mediaTypes?.compactMap { $0.hasPrefix("dyn.") ? nil : MediaType(rawValue: $0) } ?? []
    }
    
    #endif
    
    @inlinable
    public static func mediaTypesWithFileExtension(_ ext: String) -> [MediaType] {
        switch ext {
        case "3g2": return ["public.3gpp2"]
        case "3gp": return ["public.3gpp"]
        case "3gp2": return ["public.3gpp2"]
        case "3gpp": return ["public.3gpp"]
        case "7z": return ["org.7-zip.7-zip-archive"]
        case "aac": return ["public.aac-audio"]
        case "adts": return ["public.aac-audio"]
        case "avi": return ["public.avi"]
        case "bmp": return ["com.microsoft.bmp"]
        case "bwf": return ["com.microsoft.waveform-audio"]
        case "bz": return ["public.bzip2-archive"]
        case "bz2": return ["public.bzip2-archive"]
        case "css": return ["public.css"]
        case "csv": return ["public.comma-separated-values-text"]
        case "doc": return ["com.microsoft.word.doc"]
        case "docx": return ["org.openxmlformats.wordprocessingml.document"]
        case "dot": return ["com.microsoft.word.dot"]
        case "epub": return ["org.idpf.epub-container", "org.idpf.epub-folder", "com.apple.ibooks.epub"]
        case "gif": return ["com.compuserve.gif", "com.apple.private.auto-loop-gif"]
        case "gz": return ["org.gnu.gnu-zip-archive"]
        case "gzip": return ["org.gnu.gnu-zip-archive"]
        case "heic": return ["public.heic"]
        case "heics": return ["public.heics"]
        case "heif": return ["public.heif"]
        case "heifs": return ["public.heifs"]
        case "htm": return ["public.html"]
        case "html": return ["public.html"]
        case "ico": return ["com.microsoft.ico"]
        case "ics": return ["com.apple.ical.ics"]
        case "j2c": return ["public.jpeg-2000"]
        case "j2k": return ["public.jpeg-2000"]
        case "jar": return ["com.sun.java-archive"]
        case "javascript": return ["com.netscape.javascript-source"]
        case "jp2": return ["public.jpeg-2000"]
        case "jpe": return ["public.jpeg"]
        case "jpeg": return ["public.jpeg"]
        case "jpf": return ["public.jpeg-2000"]
        case "jpg": return ["public.jpeg"]
        case "jpx": return ["public.jpeg-2000"]
        case "js": return ["com.netscape.javascript-source"]
        case "jscript": return ["com.netscape.javascript-source"]
        case "json": return ["public.json"]
        case "m15": return ["public.mpeg"]
        case "m75": return ["public.mpeg"]
        case "mjs": return ["com.netscape.javascript-source"]
        case "mp2": return ["public.mp2", "com.apple.music.mp2"]
        case "mp3": return ["public.mp3"]
        case "mpe": return ["public.mpeg"]
        case "mpeg": return ["public.mpeg"]
        case "mpg": return ["public.mpeg"]
        case "mpga": return ["public.mp3"]
        case "odp": return ["org.oasis-open.opendocument.presentation"]
        case "ods": return ["org.oasis-open.opendocument.spreadsheet"]
        case "odt": return ["org.oasis-open.opendocument.text"]
        case "otc": return ["public.opentype-font"]
        case "otf": return ["public.opentype-font"]
        case "pdf": return ["com.adobe.pdf"]
        case "ph3": return ["public.php-script"]
        case "ph4": return ["public.php-script"]
        case "php": return ["public.php-script"]
        case "php3": return ["public.php-script"]
        case "php4": return ["public.php-script"]
        case "phtml": return ["public.php-script"]
        case "png": return ["public.png"]
        case "pot": return ["com.microsoft.powerpoint.pot"]
        case "pps": return ["com.microsoft.powerpoint.pps"]
        case "ppt": return ["com.microsoft.powerpoint.ppt"]
        case "pptx": return ["org.openxmlformats.presentationml.presentation"]
        case "ps": return ["com.adobe.postscript"]
        case "rcproject": return ["com.apple.rcproject"]
        case "sdv": return ["public.3gpp"]
        case "shtm": return ["public.html"]
        case "shtml": return ["public.html"]
        case "svg": return ["public.svg-image"]
        case "svgz": return ["public.svg-image"]
        case "tar": return ["public.tar-archive"]
        case "text": return ["public.plain-text", "net.daringfireball.markdown"]
        case "tif": return ["public.tiff"]
        case "tiff": return ["public.tiff"]
        case "ttc": return ["public.truetype-ttf-font"]
        case "ttf": return ["public.truetype-ttf-font"]
        case "txt": return ["public.plain-text"]
        case "vfw": return ["public.avi"]
        case "wav": return ["com.microsoft.waveform-audio"]
        case "wave": return ["com.microsoft.waveform-audio"]
        case "webp": return ["com.google.webp"]
        case "woff": return ["org.w3c.woff"]
        case "woff2": return ["org.w3c.woff2"]
        case "xht": return ["public.xhtml"]
        case "xhtm": return ["public.xhtml"]
        case "xhtml": return ["public.xhtml"]
        case "xls": return ["com.microsoft.excel.xls"]
        case "xlsx": return ["org.openxmlformats.spreadsheetml.sheet"]
        case "xlt": return ["com.microsoft.excel.xlt"]
        case "xlw": return ["com.microsoft.excel.xlw"]
        case "xml": return ["public.xml", "com.microsoft.word.wordml"]
        case "zip": return ["public.zip-archive"]
        default: return []
        }
    }
}

extension MediaType {
    
    #if canImport(CoreServices)
    
    @inlinable
    public var _fileExtension: [String] {
        return UTTypeCopyAllTagsWithClass(rawValue as CFString, kUTTagClassFilenameExtension)?.takeRetainedValue() as? [String] ?? []
    }
    
    #endif
    
    @inlinable
    public var fileExtension: [String] {
        switch self {
        case "com.adobe.pdf": return ["pdf"]
        case "com.adobe.postscript": return ["ps"]
        case "com.apple.ical.ics": return ["ics"]
        case "com.apple.music.mp2": return ["mp2"]
        case "com.apple.rcproject": return ["rcproject"]
        case "com.compuserve.gif": return ["gif"]
        case "com.google.webp": return ["webp"]
        case "com.microsoft.bmp": return ["bmp"]
        case "com.microsoft.excel.xls": return ["xls"]
        case "com.microsoft.excel.xlt": return ["xlt"]
        case "com.microsoft.excel.xlw": return ["xlw"]
        case "com.microsoft.ico": return ["ico"]
        case "com.microsoft.powerpoint.pot": return ["pot"]
        case "com.microsoft.powerpoint.pps": return ["pps"]
        case "com.microsoft.powerpoint.ppt": return ["ppt"]
        case "com.microsoft.waveform-audio": return ["wav", "wave", "bwf"]
        case "com.microsoft.word.doc": return ["doc"]
        case "com.microsoft.word.dot": return ["dot"]
        case "com.netscape.javascript-source": return ["js", "jscript", "javascript", "mjs"]
        case "com.sun.java-archive": return ["jar"]
        case "org.7-zip.7-zip-archive": return ["7z"]
        case "org.gnu.gnu-zip-archive": return ["gz", "gzip"]
        case "org.idpf.epub-container": return ["epub"]
        case "org.oasis-open.opendocument.presentation": return ["odp"]
        case "org.oasis-open.opendocument.spreadsheet": return ["ods"]
        case "org.oasis-open.opendocument.text": return ["odt"]
        case "org.openxmlformats.presentationml.presentation": return ["pptx"]
        case "org.openxmlformats.spreadsheetml.sheet": return ["xlsx"]
        case "org.openxmlformats.wordprocessingml.document": return ["docx"]
        case "org.w3c.woff": return ["woff"]
        case "org.w3c.woff2": return ["woff2"]
        case "public.3gpp": return ["3gp", "3gpp", "sdv"]
        case "public.3gpp2": return ["3g2", "3gp2"]
        case "public.aac-audio": return ["aac", "adts"]
        case "public.avi": return ["avi", "vfw"]
        case "public.bzip2-archive": return ["bz2", "bz"]
        case "public.comma-separated-values-text": return ["csv"]
        case "public.css": return ["css"]
        case "public.heic": return ["heic"]
        case "public.heics": return ["heics"]
        case "public.heif": return ["heif"]
        case "public.heifs": return ["heifs"]
        case "public.html": return ["html", "htm", "shtml", "shtm"]
        case "public.jpeg": return ["jpeg", "jpg", "jpe"]
        case "public.jpeg-2000": return ["jp2", "jpf", "jpx", "j2k", "j2c"]
        case "public.json": return ["json"]
        case "public.mp3": return ["mp3", "mpga"]
        case "public.mpeg": return ["mpg", "mpeg", "mpe", "m75", "m15"]
        case "public.opentype-font": return ["otf", "otc"]
        case "public.php-script": return ["php", "php3", "php4", "ph3", "ph4", "phtml"]
        case "public.plain-text": return ["txt", "text"]
        case "public.png": return ["png"]
        case "public.svg-image": return ["svg", "svgz"]
        case "public.tar-archive": return ["tar"]
        case "public.tiff": return ["tiff", "tif"]
        case "public.truetype-ttf-font": return ["ttf", "ttc"]
        case "public.xhtml": return ["xhtml", "xhtm", "xht"]
        case "public.xml": return ["xml"]
        case "public.zip-archive": return ["zip"]
        default: return []
        }
    }
}

extension MIMEType {
    
    #if canImport(CoreServices)
    
    @inlinable
    public static func _mimeTypesWithFileExtension(_ ext: String) -> [MIMEType] {
        return MediaType._mediaTypesWithFileExtension(ext).flatMap { $0._mimeTypes }
    }
    
    #endif
    
    @inlinable
    public static func mimeTypesWithFileExtension(_ ext: String) -> [MIMEType] {
        return MediaType.mediaTypesWithFileExtension(ext).flatMap { $0.mimeTypes }
    }
}

extension MIMEType {
    
    #if canImport(CoreServices)
    
    @inlinable
    public var _fileExtension: [String] {
        return self._mediaTypes.flatMap { $0._fileExtension }
    }
    
    #endif
    
    @inlinable
    public var fileExtension: [String] {
        return self.mediaTypes.flatMap { $0.fileExtension }
    }
}
