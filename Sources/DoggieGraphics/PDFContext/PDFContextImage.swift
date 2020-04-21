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
        
        let name: String
        
        if let _name = imageTable[key] {
            
            name = _name
            
        } else {
            
            guard var stream = image.pdf_data(properties: properties) else { return }
            
            stream.0.table["DecodeParms"] = """
            <<
            \(stream.0.table.lazy.map { "/\($0.key) \($0.value)" }.joined(separator: "\n"))
            >>
            """
            stream.0.table["Width"] = "\(image.width)"
            stream.0.table["Height"] = "\(image.height)"
            stream.0.table["Interpolate"] = "true"
            
            if state.is_clip {
                stream.0.table["ColorSpace"] = "/DeviceGray"
            }
            
            if var mask = stream.1 {
                
                mask.table["DecodeParms"] = """
                <<
                \(mask.table.lazy.map { "/\($0.key) \($0.value)" }.joined(separator: "\n"))
                >>
                """
                mask.table["Width"] = "\(image.width)"
                mask.table["Height"] = "\(image.height)"
                mask.table["Interpolate"] = "true"
                mask.table["ColorSpace"] = "/DeviceGray"
                
                stream.1 = mask
            }
            
            name = "Im\(imageTable.count + 1)"
            current_layer.imageTable[key] = name
            current_layer.image[name] = stream
        }
        
        let transform = .reflectY(0.5) * .scale(x: image.width, y: image.height) * transform * _mirrored_transform
        let _transform = [
            "\(Decimal(transform.a).rounded(scale: 9))",
            "\(Decimal(transform.d).rounded(scale: 9))",
            "\(Decimal(transform.b).rounded(scale: 9))",
            "\(Decimal(transform.e).rounded(scale: 9))",
            "\(Decimal(transform.c).rounded(scale: 9))",
            "\(Decimal(transform.f).rounded(scale: 9))",
        ]
        
        current_layer.state.commands += "q\n"
        
        set_blendmode()
        set_opacity(self.opacity)
        
        current_layer.state.commands += "\(_transform.joined(separator: " ")) cm\n"
        current_layer.state.commands += "/\(name) Do\n"
        current_layer.state.commands += "Q\n"
    }
}

private protocol PDFImageProtocol {
    
    var width: Int { get }
    var height: Int { get }
    
    var imageTableKey: PDFContext.ImageTableKey { get }
    
    func pdf_data(properties: [PDFContext.PropertyKey: Any]) -> (PDFContext.ImageStream, PDFContext.ImageStream?)?
}

extension AnyImage: PDFImageProtocol {
    
    fileprivate var imageTableKey: PDFContext.ImageTableKey {
        return PDFContext.ImageTableKey(self)
    }
    
    fileprivate func pdf_data(properties: [PDFContext.PropertyKey: Any]) -> (PDFContext.ImageStream, PDFContext.ImageStream?)? {
        
        let compression = properties[.compression] as? PDFContext.CompressionScheme ?? .noPrediction
        
        var table: [String: String] = ["Columns": "\(width)", "Colors": "\(colorSpace.numberOfComponents)"]
        let color: Data
        var mask: Data?
        
        var bitsPerChannel = 0
        
        switch compression {
        case .noPrediction:
            
            guard let _stream = self.tiff_predictor(predictor: 1, true, &bitsPerChannel) else { return nil }
            color = _stream.data
            
            if !self.isOpaque {
                guard let _stream = self.tiff_predictor(predictor: 1, false, &bitsPerChannel) else { return nil }
                mask = _stream.data
            }
            
            table["Predictor"] = "1"
            table["BitsPerComponent"] = "\(bitsPerChannel)"
            
        case .tiffPrediction:
            
            guard let _stream = self.tiff_predictor(predictor: 2, true, &bitsPerChannel) else { return nil }
            color = _stream.data
            
            if !self.isOpaque {
                guard let _stream = self.tiff_predictor(predictor: 2, false, &bitsPerChannel) else { return nil }
                mask = _stream.data
            }
            
            table["Predictor"] = "2"
            table["BitsPerComponent"] = "\(bitsPerChannel)"
        }
        
        var mask_table = table
        mask_table["Colors"] = "1"
        
        return (PDFContext.ImageStream(table: table, data: color), mask.map { PDFContext.ImageStream(table: mask_table, data: $0) })
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
