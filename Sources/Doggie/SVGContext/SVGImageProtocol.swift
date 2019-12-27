//
//  SVGImageProtocol.swift
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

protocol SVGImageProtocol {
    
    func url_data(using storageType: MediaType, properties: [ImageRep.PropertyKey : Any]) -> String?
}

extension MediaType {
    
    fileprivate var media_type_string: String? {
        switch self {
        case .bmp: return "image/bmp"
        case .gif: return "image/gif"
        case .heic: return "image/heic"
        case .heif: return "image/heif"
        case .jpeg: return "image/jpeg"
        case .jpeg2000: return "image/jp2"
        case .png: return "image/png"
        case .tiff: return "image/tiff"
        default: return nil
        }
    }
}

extension Image: SVGImageProtocol {
    
    func url_data(using storageType: MediaType, properties: [ImageRep.PropertyKey : Any]) -> String? {
        guard let mediaType = storageType.media_type_string else { return nil }
        guard let data = self.representation(using: storageType, properties: properties) else { return nil }
        return "data:\(mediaType);base64," + data.base64EncodedString()
    }
}

extension AnyImage: SVGImageProtocol {
    
    func url_data(using storageType: MediaType, properties: [ImageRep.PropertyKey : Any]) -> String? {
        guard let mediaType = storageType.media_type_string else { return nil }
        guard let data = self.representation(using: storageType, properties: properties) else { return nil }
        return "data:\(mediaType);base64," + data.base64EncodedString()
    }
}

extension ImageRep: SVGImageProtocol {
    
    func url_data(using storageType: MediaType, properties: [ImageRep.PropertyKey : Any]) -> String? {
        guard let mediaType = self.mediaType?.media_type_string else { return nil }
        guard let data = self.originalData else { return AnyImage(imageRep: self, fileBacked: true).url_data(using: storageType, properties: properties) }
        return "data:\(mediaType);base64," + data.base64EncodedString()
    }
}

extension SVGContext : SVGImageProtocol {
    
    func url_data(using storageType: MediaType, properties: [ImageRep.PropertyKey : Any]) -> String? {
        guard storageType == .svg else { return nil }
        return "data:image/svg+xml;utf8," + self.document.xml(prettyPrinted: false)
    }
}
