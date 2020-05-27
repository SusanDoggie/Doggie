//
//  PDFContextImage.swift
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

extension PDFContext.Page {
    
    func _draw(image: AnyImage, transform: SDTransform, properties: [PDFContext.PropertyKey: Any]) {
        
        let key = image.imageTableKey
        
        let name: PDFName
        
        if let _name = imageTable[key] {
            
            name = _name
            
        } else {
            
            guard var (color, mask) = image.pdf_data(properties: properties) else { return }
            
            color["DecodeParms"] = PDFObject(color.dictionary)
            color["Width"] = PDFObject(image.width)
            color["Height"] = PDFObject(image.height)
            color["Interpolate"] = true
            
            if state.is_clip {
                color["ColorSpace"] = PDFObject("DeviceGray" as PDFName)
            }
            
            if var _mask = mask {
                
                _mask["DecodeParms"] = PDFObject(_mask.dictionary)
                _mask["Width"] = PDFObject(image.width)
                _mask["Height"] = PDFObject(image.height)
                _mask["Interpolate"] = true
                _mask["ColorSpace"] = PDFObject("DeviceGray" as PDFName)
                
                mask = _mask
            }
            
            name = PDFName("Im\(imageTable.count + 1)")
            current_layer.imageTable[key] = name
            current_layer.image[name] = (color, mask)
        }
        
        let transform = .reflectY(0.5) * .scale(x: image.width, y: image.height) * transform * _mirrored_transform
        let _transform = [
            transform.a,
            transform.d,
            transform.b,
            transform.e,
            transform.c,
            transform.f,
        ]
        
        current_layer.state.commands.append(.command("q"))
        
        set_blendmode()
        set_opacity(self.opacity)
        
        current_layer.state.commands.append(contentsOf: _transform.map { PDFCommand($0) })
        current_layer.state.commands.append(.command("cm"))
        current_layer.state.commands.append(.name(name))
        current_layer.state.commands.append(.command("Do"))
        current_layer.state.commands.append(.command("Q"))
    }
}

private protocol PDFImageProtocol {
    
    var width: Int { get }
    var height: Int { get }
    
    var imageTableKey: PDFContext.ImageTableKey { get }
    
    func pdf_data(properties: [PDFContext.PropertyKey: Any]) -> (PDFStream, PDFStream?)?
}

extension AnyImage: PDFImageProtocol {
    
    fileprivate var imageTableKey: PDFContext.ImageTableKey {
        return PDFContext.ImageTableKey(self)
    }
    
    fileprivate func pdf_data(properties: [PDFContext.PropertyKey: Any]) -> (PDFStream, PDFStream?)? {
        
        let compression = properties[.compression] as? PDFContext.CompressionScheme ?? .noPrediction
        
        var color = PDFStream(dictionary: [
            "Columns": PDFObject(width),
            "Colors": PDFObject(colorSpace.numberOfComponents),
        ])
        var mask: PDFStream?
        
        var bitsPerChannel = 0
        
        switch compression {
        case .noPrediction:
            
            guard let stream = self.tiff_predictor(predictor: 1, true, &bitsPerChannel) else { return nil }
            color.data = stream.data
            
            if !self.isOpaque {
                guard let stream = self.tiff_predictor(predictor: 1, false, &bitsPerChannel) else { return nil }
                mask = PDFStream(data: stream.data)
            }
            
            color["Predictor"] = 1
            color["BitsPerComponent"] = PDFObject(bitsPerChannel)
            
        case .tiffPrediction:
            
            guard let stream = self.tiff_predictor(predictor: 2, true, &bitsPerChannel) else { return nil }
            color.data = stream.data
            
            if !self.isOpaque {
                guard let stream = self.tiff_predictor(predictor: 2, false, &bitsPerChannel) else { return nil }
                mask = PDFStream(data: stream.data)
            }
            
            color["Predictor"] = 2
            color["BitsPerComponent"] = PDFObject(bitsPerChannel)
        }
        
        mask?.dictionary = color.dictionary
        mask?["Colors"] = 1
        
        return (color, mask)
    }
}

extension AnyImage {
    
    private func tiff_predictor(predictor: Int, _ color: Bool, _ bitsPerChannel: inout Int) -> MappedBuffer<UInt8>? {
        
        switch self.base {
        case let image as Image<ARGB32ColorPixel>:
            
            bitsPerChannel = 8
            
            return color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        case let image as Image<ARGB64ColorPixel>:
            
            bitsPerChannel = 16
            
            return color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        case let image as Image<RGBA32ColorPixel>:
            
            bitsPerChannel = 8
            
            return color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        case let image as Image<RGBA64ColorPixel>:
            
            bitsPerChannel = 16
            
            return color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        case let image as Image<ABGR32ColorPixel>:
            
            bitsPerChannel = 8
            
            return color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        case let image as Image<BGRA32ColorPixel>:
            
            bitsPerChannel = 8
            
            return color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        case let image as Image<Gray16ColorPixel>:
            
            bitsPerChannel = 8
            
            return color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        case let image as Image<Gray32ColorPixel>:
            
            bitsPerChannel = 16
            
            return color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        default:
            
            bitsPerChannel = 16
            
            guard let image = self.base as? TIFFRawRepresentable else { return nil }
            return color ? image.tiff_color_data(predictor, true) : image.tiff_opacity_data(predictor)
        }
    }
}
