//
//  PDFDrawPage.swift
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

extension DrawableContext {
    
    public func draw(_ page: PDFPage) {
        PDFRenderer(context: self).render(page)
    }
}

extension PDFRenderer {
    
    private struct PageInfo: Hashable {
        
        let contents: Data
        let resources: PDFObject
    }
    
    func render(_ page: PDFPage) {
        
        guard let contents = page.contents?.decode() else { return }
        guard let mediaBox = page.mediaBox else { return }
        
        self.concatenate(.reflectY(mediaBox.midY))
        
        let resources = page.resources
        self._render(PageInfo(contents: contents, resources: resources), false, [])
        
        self.makeBalance()
    }
    
    private func _render(_ info: PageInfo, _ drawing_clip: Bool, _ render_stack: Set<PageInfo>) {
        
        guard !render_stack.contains(info) else { return }
        
        var render_stack = render_stack
        render_stack.insert(info)
        
        var stream = info.contents
        let resources = info.resources
        
        let extGState = resources["ExtGState"]
        let colorSpaces = resources["ColorSpace"].dictionary?.compactMapValues { PDFColorSpace($0) } ?? [:]
        let shading = resources["Shading"]
        let xobject = resources["XObject"]
        
        var stack: [PDFCommand] = []
        
        while let command = PDFCommand.decode_command(&stream) {
            
            switch command.command {
                
            case "w": self.strokeWidth = stack.popLast()?.doubleValue ?? 0
                
            case "J":
                
                let lineCap = stack.popLast()?.intValue
                switch lineCap {
                case 0: self.strokeCap = .butt
                case 1: self.strokeCap = .round
                case 2: self.strokeCap = .square
                default: break
                }
                
            case "j":
                
                let lineJoin = stack.popLast()?.intValue
                switch lineJoin {
                case 0: self.strokeJoin = .miter
                case 1: self.strokeJoin = .round
                case 2: self.strokeJoin = .bevel
                default: break
                }
                
            case "M": self.miterLimit = stack.popLast()?.doubleValue ?? 4
                
            case "d":
                
                self.dashPhase = stack.popLast()?.doubleValue ?? 0
                self.dashArray = stack.popLast()?.array?.compactMap { $0.doubleValue } ?? []
                
            case "ri":
                
                let intent = stack.popLast()?.name
                switch intent {
                case "AbsoluteColorimetric": self.renderingIntent = .absoluteColorimetric
                case "RelativeColorimetric": self.renderingIntent = .relativeColorimetric
                case "Perceptual": self.renderingIntent = .perceptual
                default: break
                }
                
            case "gs":
                
                let _name = stack.popLast()?.name
                if let name = _name, let gatste = extGState[name].dictionary, gatste["Type"]?.name == "ExtGState" || gatste["Type"] == nil {
                    
                    if let lineWidth = gatste["LW"]?.doubleValue {
                        self.strokeWidth = lineWidth
                    }
                    if let lineCap = gatste["LC"]?.intValue {
                        switch lineCap {
                        case 0: self.strokeCap = .butt
                        case 1: self.strokeCap = .round
                        case 2: self.strokeCap = .square
                        default: break
                        }
                    }
                    if let lineJoin = gatste["LJ"]?.intValue {
                        switch lineJoin {
                        case 0: self.strokeJoin = .miter
                        case 1: self.strokeJoin = .round
                        case 2: self.strokeJoin = .bevel
                        default: break
                        }
                    }
                    if let miterLimit = gatste["ML"]?.doubleValue {
                        self.miterLimit = miterLimit
                    }
                    if let dash = gatste["D"]?.array, dash.count == 2,
                        let dashArray = dash[0].array?.compactMap({ $0.doubleValue }),
                        let dashPhase = dash[1].doubleValue {
                        self.dashArray = dashArray
                        self.dashPhase = dashPhase
                    }
                    if let intent = gatste["RI"]?.name {
                        switch intent {
                        case "AbsoluteColorimetric": self.renderingIntent = .absoluteColorimetric
                        case "RelativeColorimetric": self.renderingIntent = .relativeColorimetric
                        case "Perceptual": self.renderingIntent = .perceptual
                        default: break
                        }
                    }
                    if let blend = gatste["BM"]?.name ?? gatste["BM"]?.array?.first?.name {
                        switch blend {
                        case "Normal", "Compatible": self.blendMode = .normal
                        case "Multiply": self.blendMode = .multiply
                        case "Screen": self.blendMode = .screen
                        case "Overlay": self.blendMode = .overlay
                        case "Darken": self.blendMode = .darken
                        case "Lighten": self.blendMode = .lighten
                        case "ColorDodge": self.blendMode = .colorDodge
                        case "ColorBurn": self.blendMode = .colorBurn
                        case "HardLight": self.blendMode = .hardLight
                        case "SoftLight": self.blendMode = .softLight
                        case "Difference": self.blendMode = .difference
                        case "Exclusion": self.blendMode = .exclusion
                        default: break
                        }
                    }
                    if gatste["SMask"]?.name == "None" {
                        
                        self.resetMask()
                        
                    } else if let mask = gatste["SMask"]?.dictionary {
                        
                        guard let group = mask["G"]?.stream else { break }
                        guard let mask_data = group.decode() else { break }
                        
                        let transform = group["Matrix"].transform ?? SDTransform.identity
                        let resources = group["Resources"] == nil ? resources : resources.merging(group["Resources"]) { _, rhs in rhs }
                        
                        switch mask["S"]?.name {
                            
                        case "Alpha":
                            
                            self.clipToDrawing(alphaMask: true) { renderer in
                                
                                renderer.concatenate(transform)
                                
                                renderer._render(PageInfo(contents: mask_data, resources: resources), true, render_stack)
                            }
                            
                        case "Luminosity":
                            
                            self.clipToDrawing(alphaMask: false) { renderer in
                                
                                renderer.concatenate(transform)
                                
                                renderer._render(PageInfo(contents: mask_data, resources: resources), true, render_stack)
                            }
                            
                        default: break
                        }
                    }
                    if let strokeOpacity = gatste["CA"]?.doubleValue {
                        self.strokeOpacity = strokeOpacity
                    }
                    if let fillOpacity = gatste["ca"]?.doubleValue {
                        self.opacity = fillOpacity
                    }
                }
                
            case "q": self.saveGraphicState()
            case "Q": self.restoreGraphicState()
                
            case "cm":
                
                let f = stack.popLast()?.doubleValue ?? 0
                let e = stack.popLast()?.doubleValue ?? 0
                let d = stack.popLast()?.doubleValue ?? 0
                let c = stack.popLast()?.doubleValue ?? 0
                let b = stack.popLast()?.doubleValue ?? 0
                let a = stack.popLast()?.doubleValue ?? 0
                
                self.concatenate(SDTransform(a: a, b: c, c: e, d: b, e: d, f: f))
                
            case "m":
                
                let y = stack.popLast()?.doubleValue ?? 0
                let x = stack.popLast()?.doubleValue ?? 0
                
                self.path.move(to: Point(x: x, y: y))
                
            case "l":
                
                let y = stack.popLast()?.doubleValue ?? 0
                let x = stack.popLast()?.doubleValue ?? 0
                
                self.path.line(to: Point(x: x, y: y))
                
            case "c":
                
                let y3 = stack.popLast()?.doubleValue ?? 0
                let x3 = stack.popLast()?.doubleValue ?? 0
                let y2 = stack.popLast()?.doubleValue ?? 0
                let x2 = stack.popLast()?.doubleValue ?? 0
                let y1 = stack.popLast()?.doubleValue ?? 0
                let x1 = stack.popLast()?.doubleValue ?? 0
                
                self.path.curve(to: Point(x: x3, y: y3), control1: Point(x: x1, y: y1), control2: Point(x: x2, y: y2))
                
            case "v":
                
                let y3 = stack.popLast()?.doubleValue ?? 0
                let x3 = stack.popLast()?.doubleValue ?? 0
                let y2 = stack.popLast()?.doubleValue ?? 0
                let x2 = stack.popLast()?.doubleValue ?? 0
                
                self.path.curve(to: Point(x: x3, y: y3), control1: self.path.currentPoint, control2: Point(x: x2, y: y2))
                
            case "y":
                
                let y3 = stack.popLast()?.doubleValue ?? 0
                let x3 = stack.popLast()?.doubleValue ?? 0
                let y1 = stack.popLast()?.doubleValue ?? 0
                let x1 = stack.popLast()?.doubleValue ?? 0
                
                self.path.curve(to: Point(x: x3, y: y3), control1: Point(x: x1, y: y1), control2: Point(x: x3, y: y3))
                
            case "h": self.path.close()
                
            case "re":
                
                let height = stack.popLast()?.doubleValue ?? 0
                let width = stack.popLast()?.doubleValue ?? 0
                let y = stack.popLast()?.doubleValue ?? 0
                let x = stack.popLast()?.doubleValue ?? 0
                
                self.path.append(Shape.Component(rect: Rect(x: x, y: y, width: width, height: height)))
                
            case "S": self.drawStroke()
                
            case "s":
                
                self.path.close()
                self.drawStroke()
                
            case "f", "F": self.draw(winding: .nonZero)
            case "f*": self.draw(winding: .evenOdd)
                
            case "B":
                
                let path = self.path
                self.draw(winding: .nonZero)
                self.path = path
                self.drawStroke()
                
            case "B*":
                
                let path = self.path
                self.draw(winding: .evenOdd)
                self.path = path
                self.drawStroke()
                
            case "b":
                
                self.path.close()
                let path = self.path
                self.draw(winding: .nonZero)
                self.path = path
                self.drawStroke()
                
            case "b*":
                
                self.path.close()
                let path = self.path
                self.draw(winding: .evenOdd)
                self.path = path
                self.drawStroke()
                
            case "n": self.path = Shape()
            case "W": self.clip(winding: .nonZero)
            case "W*": self.clip(winding: .evenOdd)
                
            case "CS":
                
                let _colorSpace = stack.popLast()?.name
                switch _colorSpace {
                case "DeviceGray": self.setStrokeColorSpace(.deviceGray)
                case "DeviceRGB": self.setStrokeColorSpace(.deviceRGB)
                case "DeviceCMYK": self.setStrokeColorSpace(.deviceCMYK)
                default:
                    if let name = _colorSpace, let colorSpace = colorSpaces[name] {
                        self.setStrokeColorSpace(colorSpace)
                    }
                }
                
            case "cs":
                
                let _colorSpace = stack.popLast()?.name
                switch _colorSpace {
                case "DeviceGray": self.setFillColorSpace(.deviceGray)
                case "DeviceRGB": self.setFillColorSpace(.deviceRGB)
                case "DeviceCMYK": self.setFillColorSpace(.deviceCMYK)
                default:
                    if let name = _colorSpace, let colorSpace = colorSpaces[name] {
                        self.setFillColorSpace(colorSpace)
                    }
                }
                
            case "SC", "SCN":
                
                var color: [PDFNumber] = []
                
                for _ in 0..<self.strokeColorSpace.numberOfComponents {
                    color.append(stack.popLast()?.number ?? 0)
                }
                
                color.reverse()
                
                self.setStrokeColor(color)
                
            case "sc", "scn":
                
                var color: [PDFNumber] = []
                
                for _ in 0..<self.fillColorSpace.numberOfComponents {
                    color.append(stack.popLast()?.number ?? 0)
                }
                
                color.reverse()
                
                self.setFillColor(color)
                
            case "G":
                
                let gray = stack.popLast()?.number ?? 0
                
                self.setStrokeColorSpace(.deviceGray)
                self.setStrokeColor([gray])
                
            case "g":
                
                let gray = stack.popLast()?.number ?? 0
                
                self.setFillColorSpace(.deviceGray)
                self.setFillColor([gray])
                
            case "RG":
                
                let blue = stack.popLast()?.number ?? 0
                let green = stack.popLast()?.number ?? 0
                let red = stack.popLast()?.number ?? 0
                
                self.setStrokeColorSpace(.deviceRGB)
                self.setStrokeColor([red, green, blue])
                
            case "rg":
                
                let blue = stack.popLast()?.number ?? 0
                let green = stack.popLast()?.number ?? 0
                let red = stack.popLast()?.number ?? 0
                
                self.setFillColorSpace(.deviceRGB)
                self.setFillColor([red, green, blue])
                
            case "K":
                
                let black = stack.popLast()?.number ?? 0
                let yellow = stack.popLast()?.number ?? 0
                let magenta = stack.popLast()?.number ?? 0
                let cyan = stack.popLast()?.number ?? 0
                
                self.setStrokeColorSpace(.deviceCMYK)
                self.setStrokeColor([cyan, magenta, yellow, black])
                
            case "k":
                
                let black = stack.popLast()?.number ?? 0
                let yellow = stack.popLast()?.number ?? 0
                let magenta = stack.popLast()?.number ?? 0
                let cyan = stack.popLast()?.number ?? 0
                
                self.setFillColorSpace(.deviceCMYK)
                self.setFillColor([cyan, magenta, yellow, black])
                
            case "sh":
                
                let _name = stack.popLast()?.name
                if let name = _name, let _shading = shading[name].dictionary {
                    
                    guard let _colorSpace = _shading["ColorSpace"], let colorSpace = PDFColorSpace(_colorSpace) else { break }
                    
                    switch _shading["ShadingType"]?.intValue {
                        
                    case 2:
                        
                        var startSpread = GradientSpreadMode.none
                        var endSpread = GradientSpreadMode.none
                        
                        if let extend = _shading["Extend"]?.array?.compactMap({ $0.boolValue }), extend.count == 2 {
                            if extend[0] { startSpread = .pad }
                            if extend[1] { endSpread = .pad }
                        }
                        
                        let domain = _shading["Domain"]?.array?.compactMap { $0.doubleValue } ?? [0, 1]
                        guard domain.count == 2 else { break }
                        
                        guard let coords = _shading["Coords"]?.array?.compactMap({ $0.doubleValue }), coords.count == 4 else { break }
                        
                        let x1 = coords[0]
                        let y1 = coords[1]
                        let x2 = coords[2]
                        let y2 = coords[3]
                        
                        guard let _function = _shading["Function"], let function = PDFFunction(_function) else { break }
                        guard function.numberOfInputs == 1 && function.numberOfOutputs == colorSpace.numberOfComponents else { break }
                        
                        self.drawLinearGradient(function: function, colorSpace: colorSpace, start: Point(x: x1, y: y1), end: Point(x: x2, y: y2), startSpread: startSpread, endSpread: endSpread)
                        
                    case 3:
                        
                        var startSpread = GradientSpreadMode.none
                        var endSpread = GradientSpreadMode.none
                        
                        if let extend = _shading["Extend"]?.array?.compactMap({ $0.boolValue }), extend.count == 2 {
                            if extend[0] { startSpread = .pad }
                            if extend[1] { endSpread = .pad }
                        }
                        
                        let domain = _shading["Domain"]?.array?.compactMap { $0.doubleValue } ?? [0, 1]
                        guard domain.count == 2 else { break }
                        
                        guard let coords = _shading["Coords"]?.array?.compactMap({ $0.doubleValue }), coords.count == 6 else { break }
                        
                        let x1 = coords[0]
                        let y1 = coords[1]
                        let r1 = coords[2]
                        let x2 = coords[3]
                        let y2 = coords[4]
                        let r2 = coords[5]
                        
                        guard let _function = _shading["Function"], let function = PDFFunction(_function) else { break }
                        guard function.numberOfInputs == 1 && function.numberOfOutputs == colorSpace.numberOfComponents else { break }
                        
                        self.drawRadialGradient(function: function, colorSpace: colorSpace, start: Point(x: x1, y: y1), startRadius: r1, end: Point(x: x2, y: y2), endRadius: r2, startSpread: startSpread, endSpread: endSpread)
                        
                    case 6, 7:
                        
                        guard let bitsPerCoordinate = _shading["BitsPerCoordinate"]?.intValue else { break }
                        guard let bitsPerComponent = _shading["BitsPerComponent"]?.intValue else { break }
                        guard let bitsPerFlag = _shading["BitsPerFlag"]?.intValue else { break }
                        guard let decode = _shading["Decode"]?.array?.compactMap({ $0.doubleValue }) else { break }
                        guard let data = shading[name].stream?.decode() else { break }
                        
                        let isCoonsPatch = _shading["ShadingType"]?.intValue == 6
                        
                        if let _function = _shading["Function"] {
                            
                            guard decode.count == 6 else { break }
                            
                            if let functions = _function.array?.compactMap({ PDFFunction($0) }) {
                                
                                guard functions.count == colorSpace.numberOfComponents else { break }
                                guard functions.allSatisfy({ $0.numberOfInputs == 1 && $0.numberOfOutputs == 1 }) else { break }
                                
                                self.drawMeshGradient(functions: functions, colorSpace: colorSpace, isCoonsPatch: isCoonsPatch, bitsPerCoordinate: bitsPerCoordinate, bitsPerComponent: bitsPerComponent, bitsPerFlag: bitsPerFlag, decode: decode, data: data)
                                
                            } else if let function = PDFFunction(_function) {
                                
                                guard function.numberOfInputs == 1 && function.numberOfOutputs == colorSpace.numberOfComponents else { break }
                                
                                self.drawMeshGradient(functions: [function], colorSpace: colorSpace, isCoonsPatch: isCoonsPatch, bitsPerCoordinate: bitsPerCoordinate, bitsPerComponent: bitsPerComponent, bitsPerFlag: bitsPerFlag, decode: decode, data: data)
                            }
                            
                        } else {
                            
                            guard decode.count == 4 + colorSpace.numberOfComponents * 2 else { break }
                            
                            self.drawMeshGradient(functions: [], colorSpace: colorSpace, isCoonsPatch: isCoonsPatch, bitsPerCoordinate: bitsPerCoordinate, bitsPerComponent: bitsPerComponent, bitsPerFlag: bitsPerFlag, decode: decode, data: data)
                        }
                        
                    default: break
                    }
                }
                
            case "BI":
                
                var table: [PDFName: PDFObject] = [:]
                
                while let command = PDFCommand.decode_command(&stream) {
                    
                    guard command.command != "ID" else { break }
                    
                    guard let name = command.name else { continue }
                    guard let value = PDFObject(&stream) else { continue }
                    
                    table[name] = value
                }
                
                stream = stream.dropFirst()
                
                let filters = table["Filter"]?.filters ?? table["F"]?.filters ?? []
                
                if let image_data = self.decode_inline_image(filters, &stream) {
                    
                    self.draw_image(table, colorSpaces, drawing_clip, image_data, nil)
                }
                
                while let command = PDFCommand.decode_command(&stream) {
                    guard command.command != "EI" else { break }
                }
                
            case "Do":
                
                let _name = stack.popLast()?.name
                if let name = _name, let xobject = xobject[name].stream, xobject["Type"].name == "XObject" || xobject["Type"] == nil {
                    
                    switch xobject["Subtype"].name {
                        
                    case "Form":
                        
                        let transform = xobject["Matrix"].transform ?? SDTransform.identity
                        let resources = xobject["Resources"] == nil ? resources : resources.merging(xobject["Resources"]) { _, rhs in rhs }
                        
                        guard let contents = xobject.decode() else { break }
                        
                        if self.should_isolate || (xobject["Group"]["S"].name == "Transparency" && xobject["Group"]["I"] == true) {
                            
                            self.beginTransparencyLayer()
                            self.concatenate(transform)
                            
                            self._render(PageInfo(contents: contents, resources: resources), drawing_clip, render_stack)
                            
                            self.endTransparencyLayer()
                            
                        } else {
                            
                            self.saveGraphicState()
                            self.concatenate(transform)
                            
                            self._render(PageInfo(contents: contents, resources: resources), drawing_clip, render_stack)
                            
                            self.restoreGraphicState()
                        }
                        
                    case "Image":
                        
                        let filters = xobject["Filter"].filters ?? []
                        
                        let cache = xobject.cache
                        
                        if xobject["SMask"].isStream {
                            self.saveGraphicState()
                            self.resetMask()
                        }
                        
                        var image: ImageRep?
                        var mask: ImageRep?
                        
                        cache.lck.synchronized {
                            
                            if self.alphaMask {
                                
                                if let _mask = cache.mask {
                                    
                                    mask = _mask
                                    
                                } else if let image_data = self.decode_image(filters, xobject.data) {
                                    
                                    self.draw_image(xobject.dictionary, colorSpaces, drawing_clip, image_data, cache)
                                }
                                
                            } else if let _image = cache.image {
                                
                                image = _image
                                mask = cache.mask
                                
                            } else if let image_data = self.decode_image(filters, xobject.data) {
                                
                                self.draw_image(xobject.dictionary, colorSpaces, drawing_clip, image_data, cache)
                            }
                        }
                        
                        if self.alphaMask {
                            
                            if let mask = mask {
                                self.clipToDrawing(alphaMask: false) { $0.drawImage(image: mask) }
                            }
                            
                            self.path = Shape(rect: Rect(x: 0, y: 0, width: 1, height: 1))
                            self.draw(winding: .nonZero)
                            
                        } else if let image = image, let mask = mask {
                            
                            self.clipToDrawing(alphaMask: false) { $0.drawImage(image: mask) }
                            
                            self.drawImage(image: image)
                            
                        } else if let image = image {
                            
                            self.drawImage(image: image)
                        }
                        
                        if xobject["SMask"].isStream {
                            self.restoreGraphicState()
                        }
                        
                    default: break
                    }
                }
                
            default:
                
                switch command {
                case .name: stack.append(command)
                case .string: stack.append(command)
                case .number: stack.append(command)
                case .array: stack.append(command)
                default: break
                }
            }
        }
    }
    
    private enum ImageData {
        
        case data(Data)
        
        case image(ImageRep)
    }
    
    private func decode_inline_image(_ filters: [PDFName], _ stream: inout Data) -> ImageData? {
        
        var filters = filters
        var data: Data?
        
        if let filter = filters.first {
            
            switch filter {
                
            case "ASCIIHexDecode", "AHx":
                
                filters.removeFirst()
                
                data = ASCIIHexFilter.decode(&stream)
                
                if data != nil && stream.first == 0x3E {
                    stream = stream.dropFirst()
                }
                
            case "ASCII85Decode", "A85":
                
                filters.removeFirst()
                
                data = ASCII85Filter.decode(&stream)
                
            case "LZWDecode", "LZW":
                
                filters.removeFirst()
                
                data = try? TIFFLZWDecoder.decode(&stream)
                
            case "RunLengthDecode", "RL":
                
                filters.removeFirst()
                
                data = try? TIFFPackBitsDecoder.decode(&stream)
                
            default: return nil
            }
        }
        
        return data.flatMap { self.decode_image(filters, $0) }
    }
    
    private func decode_image(_ filters: [PDFName], _ stream: Data) -> ImageData? {
        
        return filters.reduce(.data(stream)) { data, filter in
            
            switch data {
                
            case let .data(data):
                
                switch filter {
                case "ASCIIHexDecode", "AHx": return ASCIIHexFilter.decode(data).map { .data($0) }
                case "ASCII85Decode", "A85": return ASCII85Filter.decode(data).map { .data($0) }
                case "LZWDecode", "LZW": return try? .data(TIFFLZWDecoder.decode(data))
                case "FlateDecode", "Fl": return try? .data(Inflate().process(data))
                case "RunLengthDecode", "RL": return try? .data(TIFFPackBitsDecoder.decode(data))
                case "CCITTFaxDecode", "CCF": return nil
                case "DCTDecode", "DCT": return try? .image(ImageRep(data: data))
                default: return nil
                }
                
            default: return data
            }
        }
    }
    
    private func draw_image(_ table: [PDFName: PDFObject], _ colorSpaces: [PDFName: PDFColorSpace], _ drawing_clip: Bool, _ data: ImageData, _ cache: PDFStream.Cache?) {
        
        guard let width = table["Width"]?.intValue ?? table["W"]?.intValue else { return }
        guard let height = table["Height"]?.intValue ?? table["H"]?.intValue else { return }
        
        var colorSpace: PDFColorSpace = .deviceRGB
        
        if let name = table["ColorSpace"]?.name ?? table["CS"]?.name {
            
            colorSpace = colorSpaces[name] ?? colorSpace
            
        } else if let obj = table["ColorSpace"] ?? table["CS"] {
            
            colorSpace = PDFColorSpace(obj, colorSpaces) ?? colorSpace
        }
        
        if drawing_clip {
            colorSpace = .deviceGray
        }
        
        func create_image(mask: PDFBitmap?, _ context_colorspace: AnyColorSpace?) -> ImageRep? {
            
            switch data {
                
            case let .data(data):
                
                guard let bitmap = PDFBitmap(info: table, colorSpace: colorSpace, data: data) else { return nil }
                
                return bitmap.create_image(mask: mask, device: context_colorspace).map { ImageRep(image: $0) }
                
            case let .image(image): return image
            }
        }
        
        if let _mask = table["SMask"]?.stream,
            let mask_width = _mask["Width"].intValue,
            let mask_height = _mask["Height"].intValue,
            let mask_data = self.decode_image(_mask["Filter"].filters ?? [], _mask.data) {
            
            if let mask_colorSpace = PDFColorSpace(_mask["ColorSpace"]) ?? PDFColorSpace(_mask["CS"]) {
                guard mask_colorSpace == .deviceGray else { return }
            }
            
            func create_mask_bitmap() -> PDFBitmap? {
                
                switch mask_data {
                    
                case let .data(data):
                    
                    return PDFBitmap(info: _mask.dictionary, colorSpace: .deviceGray, data: data)
                    
                case .image: return nil
                }
            }
            
            func create_mask_image(_ context_colorspace: AnyColorSpace?) -> ImageRep? {
                
                switch mask_data {
                    
                case let .data(data):
                    
                    guard let bitmap = PDFBitmap(info: _mask.dictionary, colorSpace: .deviceGray, data: data) else { return nil }
                    
                    return bitmap.create_image(mask: nil, device: context_colorspace).map { ImageRep(image: $0) }
                    
                case let .image(image): return image
                }
            }
            
            if self.alphaMask {
                
                self.clipToDrawing(alphaMask: false) {
                    
                    if let mask = create_mask_image($0.context_colorspace) {
                        $0.drawImage(image: mask)
                        cache?.mask = mask
                    }
                }
                
                self.path = Shape(rect: Rect(x: 0, y: 0, width: 1, height: 1))
                self.draw(winding: .nonZero)
                
            } else if width == mask_width && height == mask_height, let mask = create_mask_bitmap() {
                
                if let image = create_image(mask: mask, context_colorspace) {
                    
                    self.drawImage(image: image)
                    cache?.image = image
                }
                
            } else {
                
                self.clipToDrawing(alphaMask: false) {
                    
                    if let mask = create_mask_image($0.context_colorspace) {
                        
                        $0.drawImage(image: mask)
                        cache?.mask = mask
                    }
                }
                
                if let image = create_image(mask: nil, context_colorspace) {
                    
                    self.drawImage(image: image)
                    cache?.image = image
                }
            }
            
        } else if let image = create_image(mask: nil, context_colorspace) {
            
            self.drawImage(image: image)
            cache?.image = image
        }
    }
}

extension PDFCommand {
    
    static func decode_command(_ data: inout Data) -> PDFCommand? {
        
        data.pdf_remove_whitespaces()
        
        while data.first == 0x25 {
            
            while data.first != 0x0A && data.first != 0x0D {
                data = data.dropFirst()
            }
            
            data.pdf_remove_whitespaces()
        }
        
        switch data.first ?? 0 {
            
        case 0x2F:
            
            guard let name = PDFName(&data) else { return nil }
            return .name(name)
            
        case 0x5B: return decode_array(&data)
            
        case 0x3C:
            
            if data.dropFirst().first == 0x3C {
                
                return decode_dictionary(&data)
                
            } else {
                
                guard let string = PDFString(&data) else { return nil }
                return .string(string)
            }
            
        case 0x28:
            
            guard let string = PDFString(&data) else { return nil }
            return .string(string)
            
        case 0x2B, 0x2D, 0x2E, 0x30...0x39:
            
            guard let number = PDFNumber(&data) else { return nil }
            return .number(number)
            
        default: return decode_string(&data)
        }
    }
    
    private static func decode_string(_ data: inout Data) -> PDFCommand? {
        
        var copy = data
        
        var chars = Data()
        
        loop: while let char = copy.first {
            switch char {
            case 0x00, 0x09, 0x0A, 0x0C, 0x0D, 0x20: break loop
            case 0x28, 0x29, 0x3C, 0x3E, 0x5B, 0x5D, 0x7B, 0x7D, 0x2F, 0x25: break loop
            default: chars.append(char)
            }
            copy = copy.dropFirst()
        }
        
        guard !chars.isEmpty else { return nil }
        
        data = copy
        return .command(chars.pdf_string())
    }
    
    private static func decode_dictionary(_ data: inout Data) -> PDFCommand? {
        
        var copy = data
        
        guard copy.popFirst() == 0x3C else { return nil }
        guard copy.popFirst() == 0x3C else { return nil }
        
        copy.pdf_remove_whitespaces_and_comment()
        
        var dictionary: [PDFName: PDFCommand] = [:]
        
        while copy.first != 0x3E, let name = PDFName(&copy) {
            
            guard let value = decode_command(&copy) else { return nil }
            dictionary[name] = value
            
            copy.pdf_remove_whitespaces_and_comment()
        }
        
        guard copy.popFirst() == 0x3E else { return nil }
        guard copy.popFirst() == 0x3E else { return nil }
        
        data = copy
        return .dictionary(dictionary)
    }
    
    private static func decode_array(_ data: inout Data) -> PDFCommand? {
        
        var copy = data
        
        guard copy.popFirst() == 0x5B else { return nil }
        
        copy.pdf_remove_whitespaces()
        
        var array: [PDFCommand] = []
        
        while copy.first != 0x5D, let obj = decode_command(&copy) {
            
            array.append(obj)
            copy.pdf_remove_whitespaces()
        }
        
        guard copy.popFirst() == 0x5D else { return nil }
        
        data = copy
        return .array(array)
    }
    
    static func is_number(_ char: UInt8) -> Bool {
        return 0x30...0x39 ~= char || char == 0x2B || char == 0x2D || char == 0x2E
    }
}
