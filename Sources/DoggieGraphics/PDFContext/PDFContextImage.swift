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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

extension PDFContext.Page {
    
    func _draw(image: AnyImage, transform: SDTransform, properties: [PDFContext.PropertyKey: Any]) {
        
        guard !self.transform.determinant.almostZero() else { return }
        
        let key = image.imageTableKey
        
        let name: PDFName
        
        if let _name = resources.imageTable[key] {
            
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
            
            name = PDFName("Im\(resources.imageTable.count + 1)")
            resources.imageTable[key] = name
            resources.image[name] = (color, mask)
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
        
        let compression = properties[.compression] as? PDFContext.CompressionScheme ?? .deflate
        let deflate_level = properties[.deflateLevel] as? Deflate.Level ?? .default
        
        var predictor: PDFContext.CompressionPrediction = .none
        var png_predictor: PNGPrediction = .all
        
        if compression != .none && (compression != .deflate || deflate_level != .none) {
            
            switch properties[.predictor] {
                
            case let prediction as TIFFPrediction:
                
                switch prediction {
                case .none: predictor = .none
                case .subtract: predictor = .tiff
                }
                
            case let prediction as PNGPrediction:
                
                predictor = .png
                png_predictor = prediction
                
            case let prediction as PDFContext.CompressionPrediction:
                
                predictor = prediction
                
            default: predictor = .png
            }
        }
        
        var color: PDFStream
        var mask: PDFStream?
        
        switch predictor {
        case .none:
            
            guard let stream = self.tiff_prediction(predictor: .none, true) else { return nil }
            color = stream
            
            if !self.isOpaque {
                guard let stream = self.tiff_prediction(predictor: .none, false) else { return nil }
                mask = stream
                
                mask?["Predictor"] = 1
            }
            
            color["Predictor"] = 1
            
        case .tiff:
            
            guard let stream = self.tiff_prediction(predictor: .subtract, true) else { return nil }
            color = stream
            
            if !self.isOpaque {
                guard let stream = self.tiff_prediction(predictor: .subtract, false) else { return nil }
                mask = stream
                
                mask?["Predictor"] = 2
            }
            
            color["Predictor"] = 2
            
        case .png:
            
            guard let stream = self.tiff_prediction(predictor: .none, true), let bitsPerChannel = stream["BitsPerComponent"].intValue else { return nil }
            color = stream
            
            let bitsPerPixel = bitsPerChannel * colorSpace.numberOfComponents
            let bytesPerPixel = bitsPerPixel >> 3
            let bytesPerRow = bytesPerPixel * width
            
            var png_filter0 = png_filter0_encoder(row_length: bytesPerRow, bitsPerPixel: UInt8(bitsPerPixel), methods: png_predictor)
            color.data = png_filter0.process(stream.data)
            
            if !self.isOpaque {
                
                guard let stream = self.tiff_prediction(predictor: .none, false), let bitsPerChannel = stream["BitsPerComponent"].intValue else { return nil }
                mask = stream
                
                let bitsPerPixel = bitsPerChannel
                let bytesPerPixel = bitsPerChannel >> 3
                let bytesPerRow = bytesPerPixel * width
                
                var png_filter0 = png_filter0_encoder(row_length: bytesPerRow, bitsPerPixel: UInt8(bitsPerPixel), methods: png_predictor)
                mask?.data = png_filter0.process(stream.data)
                
                switch png_predictor {
                case .none: mask?["Predictor"] = 10
                case .subtract: mask?["Predictor"] = 11
                case .up: mask?["Predictor"] = 12
                case .average: mask?["Predictor"] = 13
                case .paeth: mask?["Predictor"] = 14
                default: mask?["Predictor"] = 15
                }
            }
            
            switch png_predictor {
            case .none: color["Predictor"] = 10
            case .subtract: color["Predictor"] = 11
            case .up: color["Predictor"] = 12
            case .average: color["Predictor"] = 13
            case .paeth: color["Predictor"] = 14
            default: color["Predictor"] = 15
            }
        }
        
        return (color.compressed(properties), mask?.compressed(properties))
    }
}

extension AnyImage {
    
    private func tiff_prediction(predictor: TIFFPrediction, _ color: Bool) -> PDFStream? {
        
        let bitsPerChannel: Int
        let data: MappedBuffer<UInt8>
        
        switch self.base {
        case let image as Image<ARGB32ColorPixel>:
            
            bitsPerChannel = 8
            
            data = color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        case let image as Image<ARGB64ColorPixel>:
            
            bitsPerChannel = 16
            
            data = color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        case let image as Image<RGBA32ColorPixel>:
            
            bitsPerChannel = 8
            
            data = color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        case let image as Image<RGBA64ColorPixel>:
            
            bitsPerChannel = 16
            
            data = color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        case let image as Image<ABGR32ColorPixel>:
            
            bitsPerChannel = 8
            
            data = color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        case let image as Image<BGRA32ColorPixel>:
            
            bitsPerChannel = 8
            
            data = color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        case let image as Image<Gray16ColorPixel>:
            
            bitsPerChannel = 8
            
            data = color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        case let image as Image<Gray32ColorPixel>:
            
            bitsPerChannel = 16
            
            data = color ? tiff_color_data(image, predictor, true) : tiff_opacity_data(image, predictor)
            
        default:
            
            bitsPerChannel = 16
            
            guard let image = self.base as? TIFFRawRepresentable else { return nil }
            data = color ? image.tiff_color_data(predictor, true) : image.tiff_opacity_data(predictor)
        }
        
        return PDFStream(dictionary: [
            "Columns": PDFObject(self.width),
            "Colors": color ? PDFObject(colorSpace.numberOfComponents) : 1,
            "BitsPerComponent": PDFObject(bitsPerChannel),
        ], data: data.data)
    }
}
