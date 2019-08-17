//
//  PDFContextEncoder.swift
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

extension PDFContext {
    
    public enum EncodeError : Error, CaseIterable {
        
        case unsupportedColorSpace
    }
    
    static func _write(_ array: [String], to data: inout Data, xref: inout [Int]) -> Int {
        xref.append(data.count)
        data.append(utf8: "\(xref.count) 0 obj\n[\n")
        data.append(utf8: array.lazy.map { "\($0)" }.joined(separator: "\n"))
        data.append(utf8: "\n]\nendobj\n")
        return xref.count
    }
    
    static func _write(_ obj: String, to data: inout Data, xref: inout [Int]) -> Int {
        xref.append(data.count)
        data.append(utf8: """
            \(xref.count) 0 obj
            (\(obj))
            endobj
            
            """)
        return xref.count
    }
    
    static func _write(_ obj: PDFObject, to data: inout Data, xref: inout [Int]) -> Int {
        xref.append(data.count)
        data.append(utf8: "\(xref.count) 0 obj\n")
        obj.write(to: &data)
        data.append(utf8: "\nendobj\n")
        return xref.count
    }
    
    static func _write(_ dictionary: [String: String], to data: inout Data, xref: inout [Int]) -> Int {
        xref.append(data.count)
        data.append(utf8: "\(xref.count) 0 obj\n<<\n")
        data.append(utf8: dictionary.lazy.map { "/\($0.key) \($0.value)" }.joined(separator: "\n"))
        data.append(utf8: "\n>>\nendobj\n")
        return xref.count
    }
    
    static func _write(stream: Data, _ dictionary: [String: String] = [:], to data: inout Data, xref: inout [Int]) -> Int {
        
        var dictionary = dictionary
        var stream = stream
        
        if dictionary["Filter"] == nil, let compressed = try? Deflate(windowBits: 15).process(stream) {
            stream = compressed
            dictionary["Filter"] = "/FlateDecode"
        }
        
        dictionary["Length"] = "\(stream.count)"
        
        xref.append(data.count)
        data.append(utf8: "\(xref.count) 0 obj\n")
        data.append(utf8: "<<\n")
        data.append(utf8: dictionary.lazy.map { "/\($0.key) \($0.value)" }.joined(separator: "\n"))
        data.append(utf8: "\n>>\n")
        data.append(utf8: "stream\n")
        data.append(stream)
        data.append(utf8: "\nendstream\n")
        data.append(utf8: "endobj\n")
        return xref.count
    }
    
    static func _write(stream: String, _ dictionary: [String: String] = [:], to data: inout Data, xref: inout [Int]) -> Int {
        
        var dictionary = dictionary
        
        xref.append(data.count)
        
        if dictionary["Filter"] == nil, let compressed = try? Deflate(windowBits: 15).process(stream._utf8_data) {
            
            dictionary["Filter"] = "/FlateDecode"
            dictionary["Length"] = "\(compressed.count)"
            
            data.append(utf8: "\(xref.count) 0 obj\n")
            data.append(utf8: "<<\n")
            data.append(utf8: dictionary.lazy.map { "/\($0.key) \($0.value)" }.joined(separator: "\n"))
            data.append(utf8: "\n>>\n")
            data.append(utf8: "stream\n")
            data.append(compressed)
            data.append(utf8: "\nendstream\n")
            data.append(utf8: "endobj\n")
            
        } else {
            
            dictionary["Length"] = "\(stream.utf8.count)"
            
            data.append(utf8: "\(xref.count) 0 obj\n")
            data.append(utf8: "<<\n")
            data.append(utf8: dictionary.lazy.map { "/\($0.key) \($0.value)" }.joined(separator: "\n"))
            data.append(utf8: "\n>>\n")
            data.append(utf8: "stream\n")
            data.append(utf8: stream)
            data.append(utf8: "\nendstream\n")
            data.append(utf8: "endobj\n")
        }
        
        return xref.count
    }
    
    static func _write_trailer(catalog: Int, to data: inout Data, xref: inout [Int]) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let date = PDFContext._write("D:\(dateFormatter.string(from: Date()))Z00'00'", to: &data, xref: &xref)
        let producer = PDFContext._write("Doggie PDF Generator", to: &data, xref: &xref)
        
        let info = PDFContext._write(["Producer": "\(producer) 0 R", "CreationDate": "\(date) 0 R", "ModDate": "\(date) 0 R"], to: &data, xref: &xref)
        
        let startxref = data.count
        
        data.append(utf8: """
            xref
            0 \(xref.count + 1)
            0000000000 65535 f
            
            """)
        
        for x in xref {
            data.append(utf8: "\("0000000000\(x)".suffix(10)) 00000 n \n")
        }
        
        data.append(utf8: "trailer\n")
        
        let trailer = [
            "Size": "\(xref.count + 1)",
            "Info": "\(info) 0 R",
            "Root": "\(catalog) 0 R",
        ]
        
        let _trailer = trailer.lazy.map { "/\($0.key) \($0.value)" }.joined(separator: "\n")
        data.append(utf8: """
            <<
            \(_trailer)
            >>
            
            """)
        
        data.append(utf8: """
            startxref
            \(startxref)
            %%EOF
            
            """)
    }
    
    public func data() throws -> Data {
        
        var data = Data()
        data.append(utf8: "%PDF-1.3\n")
        
        struct PageContent {
            
            var resources: Int
            var commands: Int
        }
        
        var xref: [Int] = []
        var _pages: [Int] = []
        
        let xobj_group = PDFContext._write([
            "S": "/Transparency",
            "I": "true",
            "K": "false",
            ], to: &data, xref: &xref)
        
        let mask_group = PDFContext._write([
            "S": "/Transparency",
            "CS": "/DeviceGray",
            "I": "true",
            "K": "false",
            ], to: &data, xref: &xref)
        
        let groups = PDFContext.Page.XObjectGroup(transparency_layer: xobj_group, mask: mask_group)
        
        let _pages_contents = try self.pages.map { try PageContent(
            resources: $0.write_resources(xobjectGroup: groups, to: &data, xref: &xref),
            commands: $0.write_commands(to: &data, xref: &xref))
        }
        
        let _parent = xref.count + self.pages.count + 1
        
        for (page, contents) in zip(self.pages, _pages_contents) {
            
            let _media = page.media.standardized
            let _mirrored_bleed = page._mirrored_bleed
            let _mirrored_trim = page._mirrored_trim
            let _mirrored_margin = page._mirrored_margin
            
            let media = [
                Decimal(_media.x).rounded(scale: 9),
                Decimal(_media.y).rounded(scale: 9),
                Decimal(_media.width).rounded(scale: 9),
                Decimal(_media.height).rounded(scale: 9),
            ]
            let bleed = [
                Decimal(_mirrored_bleed.x).rounded(scale: 9),
                Decimal(_mirrored_bleed.y).rounded(scale: 9),
                Decimal(_mirrored_bleed.width).rounded(scale: 9),
                Decimal(_mirrored_bleed.height).rounded(scale: 9),
            ]
            let trim = [
                Decimal(_mirrored_trim.x).rounded(scale: 9),
                Decimal(_mirrored_trim.y).rounded(scale: 9),
                Decimal(_mirrored_trim.width).rounded(scale: 9),
                Decimal(_mirrored_trim.height).rounded(scale: 9),
            ]
            let margin = [
                Decimal(_mirrored_margin.x).rounded(scale: 9),
                Decimal(_mirrored_margin.y).rounded(scale: 9),
                Decimal(_mirrored_margin.width).rounded(scale: 9),
                Decimal(_mirrored_margin.height).rounded(scale: 9),
            ]
            
            var dict = [
                "Type": "/Page",
                "Parent": "\(_parent) 0 R",
                "MediaBox": "[\(media.lazy.map { "\($0)" }.joined(separator: " "))]",
                "Resources": "\(contents.resources) 0 R",
                "Contents": "\(contents.commands) 0 R",
            ]
            
            if media != bleed {
                dict["BleedBox"] = "[\(bleed.lazy.map { "\($0)" }.joined(separator: " "))]"
            }
            if media != bleed {
                dict["TrimBox"] = "[\(trim.lazy.map { "\($0)" }.joined(separator: " "))]"
            }
            if media != bleed {
                dict["ArtBox"] = "[\(margin.lazy.map { "\($0)" }.joined(separator: " "))]"
            }
            
            _pages.append(PDFContext._write(dict, to: &data, xref: &xref))
        }
        
        let pages = PDFContext._write([
            "Type": "/Pages",
            "Count": "\(_pages.count)",
            "Kids": "[\n\(_pages.map { "\($0) 0 R" }.joined(separator: "\n"))\n]",
            ], to: &data, xref: &xref)
        
        let catalog = PDFContext._write([
            "Type": "/Catalog",
            "Pages": "\(pages) 0 R",
            ], to: &data, xref: &xref)
        
        PDFContext._write_trailer(catalog: catalog, to: &data, xref: &xref)
        
        return data
    }
}

extension PDFContext.Page {
    
    struct XObjectGroup {
        
        var transparency_layer: Int
        var mask: Int
    }
    
    func write_resources(xobjectGroup: XObjectGroup, to data: inout Data, xref: inout [Int]) throws -> Int {
        
        guard let iccData = colorSpace.iccData else { throw PDFContext.EncodeError.unsupportedColorSpace }
        
        let _rangeOfComponents = (0..<colorSpace.numberOfComponents).map { colorSpace.rangeOfComponent($0) }.flatMap { [Decimal($0.lowerBound).rounded(scale: 9), Decimal($0.upperBound).rounded(scale: 9)] }
        
        let iccBased = PDFContext._write(stream: iccData, [
            "N": "\(colorSpace.numberOfComponents)",
            "Range": "[\n\(_rangeOfComponents.lazy.map { "\($0)" }.joined(separator: "\n"))\n]",
            ], to: &data, xref: &xref)
        
        let _colorSpaceRef = PDFContext._write(["/ICCBased \(iccBased) 0 R"], to: &data, xref: &xref)
        let _colorSpace = PDFContext._write(["Cs1": "\(_colorSpaceRef) 0 R"], to: &data, xref: &xref)
        
        var shading_table: [String: String] = [:]
        
        for (shading, name) in self.shading {
            
            let _function: Int
            
            switch shading.function.type {
            case 2, 3: _function = PDFContext._write(shading.function.pdf_object, to: &data, xref: &xref)
            case 4:
                
                let _domain = shading.function.domain.flatMap { [Decimal($0.lowerBound).rounded(scale: 9), Decimal($0.upperBound).rounded(scale: 9)] }
                let _range = shading.function.range.flatMap { [Decimal($0.lowerBound).rounded(scale: 9), Decimal($0.upperBound).rounded(scale: 9)] }
                
                _function = PDFContext._write(stream: shading.function.postscript, [
                    "FunctionType": "\(shading.function.type)",
                    "Domain": "[\n\(_domain.lazy.map { "\($0)" }.joined(separator: "\n"))\n]",
                    "Range": "[\n\(_range.lazy.map { "\($0)" }.joined(separator: "\n"))\n]",
                    ], to: &data, xref: &xref)
                
            default: continue
            }
            
            let _shading: Int
            
            switch shading.type {
            case 1:
                
                _shading = PDFContext._write([
                    "ColorSpace": shading.deviceGray ? "/DeviceGray" : "\(_colorSpaceRef) 0 R",
                    "ShadingType": "\(shading.type)",
                    "Function": "\(_function) 0 R",
                    ], to: &data, xref: &xref)
                
            case 2, 3:
                
                _shading = PDFContext._write([
                    "ColorSpace": shading.deviceGray ? "/DeviceGray" : "\(_colorSpaceRef) 0 R",
                    "ShadingType": "\(shading.type)",
                    "Function": "\(_function) 0 R",
                    "Coords": "[\(shading.coords.lazy.map { "\($0)" }.joined(separator: " "))]",
                    "Extend": "[\(shading.e0) \(shading.e1)]",
                    ], to: &data, xref: &xref)
                
            default: continue
            }
            
            shading_table[name] = "\(_shading) 0 R"
        }
        
        let _shading = PDFContext._write(shading_table, to: &data, xref: &xref)
        
        var extGState_table: [String: String] = [:]
        for (gstate, name) in extGState {
            extGState_table[name] = "<</Type /ExtGState \(gstate)>>"
        }
        
        var xobject_table: [String: String] = [:]
        for (name, (var image, mask)) in image {
            
            if var mask = mask {
                
                mask.table["Type"] = "/XObject"
                mask.table["Subtype"] = "/Image"
                
                let xobj = PDFContext._write(stream: mask.data, mask.table, to: &data, xref: &xref)
                image.table["SMask"] = "\(xobj) 0 R"
            }
            
            image.table["Type"] = "/XObject"
            image.table["Subtype"] = "/Image"
            
            if image.table["ColorSpace"] == nil {
                image.table["ColorSpace"] = "\(_colorSpaceRef) 0 R"
            }
            
            let xobj = PDFContext._write(stream: image.data, image.table, to: &data, xref: &xref)
            xobject_table[name] = "\(xobj) 0 R"
        }
        
        let _resources = xref.count + 3 + transparency_layers.count + mask.count << 1
        
        let _bbox = self.media.standardized
        let bbox = [
            Decimal(_bbox.x).rounded(scale: 9),
            Decimal(_bbox.y).rounded(scale: 9),
            Decimal(_bbox.width).rounded(scale: 9),
            Decimal(_bbox.height).rounded(scale: 9),
        ]
        
        for (name, commands) in mask {
            
            let dictionary = [
                "Type": "/XObject",
                "Subtype": "/Form",
                "FormType": "1",
                "Matrix": "[1 0 0 1 0 0]",
                "BBox": "[\(bbox.lazy.map { "\($0)" }.joined(separator: " "))]",
                "Resources": "\(_resources) 0 R",
                "Group": "\(xobjectGroup.mask) 0 R",
            ]
            
            let xobj = PDFContext._write(stream: commands, dictionary, to: &data, xref: &xref)
            
            let sMask = PDFContext._write([
                "Type": "/Mask",
                "S": "/Luminosity",
                "G": "\(xobj) 0 R",
                ], to: &data, xref: &xref)
            
            extGState_table[name] = "<</Type /ExtGState /SMask \(sMask) 0 R>>"
        }
        
        let _extGState = PDFContext._write(extGState_table, to: &data, xref: &xref)
        
        for (commands, name) in transparency_layers {
            
            let dictionary = [
                "Type": "/XObject",
                "Subtype": "/Form",
                "FormType": "1",
                "Matrix": "[1 0 0 1 0 0]",
                "BBox": "[\(bbox.lazy.map { "\($0)" }.joined(separator: " "))]",
                "Resources": "\(_resources) 0 R",
                "Group": "\(xobjectGroup.transparency_layer) 0 R",
            ]
            
            let xobj = PDFContext._write(stream: commands, dictionary, to: &data, xref: &xref)
            xobject_table[name] = "\(xobj) 0 R"
        }
        
        let _xobject = PDFContext._write(xobject_table, to: &data, xref: &xref)
        
        return PDFContext._write([
            "ProcSet": "[/PDF /ImageB /ImageC /ImageI]",
            "ColorSpace": "\(_colorSpace) 0 R",
            "ExtGState": "\(_extGState) 0 R",
            "XObject": "\(_xobject) 0 R",
            "Shading": "\(_shading) 0 R",
            ], to: &data, xref: &xref)
    }
    
    func write_commands(to data: inout Data, xref: inout [Int]) throws -> Int {
        return PDFContext._write(stream: finalize(), to: &data, xref: &xref)
    }
}
