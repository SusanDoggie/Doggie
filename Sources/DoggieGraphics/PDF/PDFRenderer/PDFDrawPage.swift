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
    
    func render(_ page: PDFPage) {
        
        guard let contents = page.contents?.decode() else { return }
        guard let mediaBox = page.mediaBox else { return }
        
        self.concatenate(.reflectY(mediaBox.midY))
        
        let resources = page.resources
        self._render(contents, resources, false)
    }
    
    private func _render(_ stream: Data, _ resources: PDFObject, _ drawing_clip: Bool) {
        
        let extGState = resources["ExtGState"]
        let colorSpaces = resources["ColorSpace"].dictionary?.compactMapValues { PDFColorSpace($0) } ?? [:]
        let shading = resources["Shading"]
        let xobject = resources["XObject"]
        
        var stack: [PDFCommand] = []
        
        var stream = stream
        while !stream.isEmpty {
            
            guard let command = PDFCommand.decode_command(&stream) else { continue }
            
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
                        
                        switch mask["S"]?.name {
                            
                        case "Alpha":
                            
                            guard let group = mask["G"]?.stream else { break }
                            guard let mask_data = group.decode() else { break }
                            
                            self.drawClip(alphaMask: true) { renderer in
                                
                                let transform = group["Matrix"].transform ?? SDTransform.identity
                                let resources = group["Resources"] == nil ? resources : resources.merging(group["Resources"]) { _, rhs in rhs }
                                
                                renderer.concatenate(transform)
                                
                                renderer._render(mask_data, resources, true)
                            }
                            
                        case "Luminosity":
                            
                            guard let group = mask["G"]?.stream else { break }
                            guard let mask_data = group.decode() else { break }
                            
                            self.drawClip(alphaMask: false) { renderer in
                                
                                if let colorSpace = PDFColorSpace(group["CS"]) {
                                    renderer.setFillColorSpace(colorSpace)
                                    renderer.setStrokeColorSpace(colorSpace)
                                }
                                
                                let transform = group["Matrix"].transform ?? SDTransform.identity
                                let resources = group["Resources"] == nil ? resources : resources.merging(group["Resources"]) { _, rhs in rhs }
                                
                                renderer.concatenate(transform)
                                
                                renderer._render(mask_data, resources, true)
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
                if let name = _name, let shading = shading[name].dictionary {
                    
                    guard let _colorSpace = shading["ColorSpace"], let colorSpace = PDFColorSpace(_colorSpace) else { break }
                    
                    switch shading["ShadingType"]?.intValue {
                        
                    case 2:
                        
                        var startSpread = GradientSpreadMode.none
                        var endSpread = GradientSpreadMode.none
                        
                        if let extend = shading["Extend"]?.array?.compactMap({ $0.boolValue }), extend.count == 2 {
                            if extend[0] { startSpread = .pad }
                            if extend[1] { endSpread = .pad }
                        }
                        
                        let domain = shading["Domain"]?.array?.compactMap { $0.doubleValue } ?? [0, 1]
                        guard domain.count == 2 else { break }
                        
                        guard let coords = shading["Coords"]?.array?.compactMap({ $0.doubleValue }), coords.count == 4 else { break }
                        
                        let x1 = coords[0]
                        let y1 = coords[1]
                        let x2 = coords[2]
                        let y2 = coords[3]
                        
                        guard let _function = shading["Function"], let function = PDFFunction(_function) else { break }
                        
                        self.drawLinearGradient(function: function, colorSpace: colorSpace, start: Point(x: x1, y: y1), end: Point(x: x2, y: y2), startSpread: startSpread, endSpread: endSpread)
                        
                    case 3:
                        
                        var startSpread = GradientSpreadMode.none
                        var endSpread = GradientSpreadMode.none
                        
                        if let extend = shading["Extend"]?.array?.compactMap({ $0.boolValue }), extend.count == 2 {
                            if extend[0] { startSpread = .pad }
                            if extend[1] { endSpread = .pad }
                        }
                        
                        let domain = shading["Domain"]?.array?.compactMap { $0.doubleValue } ?? [0, 1]
                        guard domain.count == 2 else { break }
                        
                        guard let coords = shading["Coords"]?.array?.compactMap({ $0.doubleValue }), coords.count == 6 else { break }
                        
                        let x1 = coords[0]
                        let y1 = coords[1]
                        let r1 = coords[2]
                        let x2 = coords[3]
                        let y2 = coords[4]
                        let r2 = coords[5]
                        
                        guard let _function = shading["Function"], let function = PDFFunction(_function) else { break }
                        
                        self.drawRadialGradient(function: function, colorSpace: colorSpace, start: Point(x: x1, y: y1), startRadius: r1, end: Point(x: x2, y: y2), endRadius: r2, startSpread: startSpread, endSpread: endSpread)
                        
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
                
                if let image_data = self.decode_image(filters, &stream) {
                    
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
                        
                        self.beginTransparencyLayer()
                        self.concatenate(transform)
                        
                        self._render(contents, resources, drawing_clip)
                        
                        self.endTransparencyLayer()
                        
                    case "Image":
                        
                        let filters = xobject["Filter"].filters ?? []
                        
                        let cache = xobject.cache
                        
                        var image: AnyImage?
                        var mask: AnyImage?
                        
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
                            
                            let has_mask = self.hasMask
                            
                            if has_mask {
                                self.beginTransparencyLayer()
                            } else {
                                self.saveGraphicState()
                            }
                            
                            if let mask = mask {
                                self.drawClip(alphaMask: false) { $0.drawImage(image: mask) }
                            }
                            
                            self.path = Shape(rect: Rect(x: 0, y: 0, width: 1, height: 1))
                            self.draw(winding: .nonZero)
                            
                            if has_mask {
                                self.endTransparencyLayer()
                            } else {
                                self.restoreGraphicState()
                            }
                            
                        } else if let image = image, let mask = mask {
                            
                            let has_mask = self.hasMask
                            
                            if has_mask {
                                self.beginTransparencyLayer()
                            } else {
                                self.saveGraphicState()
                            }
                            
                            self.drawClip(alphaMask: false) { $0.drawImage(image: mask) }
                            
                            self.drawImage(image: image)
                            
                            if has_mask {
                                self.endTransparencyLayer()
                            } else {
                                self.restoreGraphicState()
                            }
                            
                        } else if let image = image {
                            
                            self.drawImage(image: image)
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
    
    private func decode_image(_ filters: [PDFName], _ stream: inout Data) -> Data? {
        
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
                
            default: return nil
            }
        }
        
        return data.flatMap { self.decode_image(filters, $0) }
    }
    
    private func decode_image(_ filters: [PDFName], _ stream: Data) -> Data? {
        
        return filters.reduce(stream) { data, filter in
            
            data.flatMap { data in
                
                switch filter {
                    
                case "ASCIIHexDecode", "AHx":
                    
                    var data = data
                    return ASCIIHexFilter.decode(&data)
                    
                case "ASCII85Decode", "A85":
                    
                    var data = data
                    return ASCII85Filter.decode(&data)
                    
                case "LZWDecode", "LZW":
                    
                    return nil
                    
                case "FlateDecode", "Fl":
                    
                    return try? Inflate().process(data)
                    
                case "RunLengthDecode", "RL":
                    
                    return nil
                    
                case "CCITTFaxDecode", "CCF":
                    
                    return nil
                    
                case "DCTDecode", "DCT":
                    
                    return nil
                    
                default: return nil
                }
            }
        }
    }
    
    private func draw_image(_ table: [PDFName: PDFObject], _ colorSpaces: [PDFName: PDFColorSpace], _ drawing_clip: Bool, _ data: Data, _ cache: PDFStream.Cache?) {
        
        guard let width = table["Width"]?.intValue ?? table["W"]?.intValue else { return }
        guard let height = table["Height"]?.intValue ?? table["H"]?.intValue else { return }
        guard let bitsPerComponent = table["BitsPerComponent"]?.intValue ?? table["BPC"]?.intValue else { return }
        
        let decodeParms = table["DecodeParms"]?.dictionary ?? table["DP"]?.dictionary ?? [:]
        
        var _colorSpace: PDFColorSpace?
        
        if let name = table["ColorSpace"]?.name ?? table["CS"]?.name {
            
            _colorSpace = colorSpaces[name]
            
        } else if let obj = table["ColorSpace"] ?? table["CS"] {
            
            _colorSpace = PDFColorSpace(obj, colorSpaces)
        }
        
        if drawing_clip {
            _colorSpace = _colorSpace ?? .deviceGray
        }
        
        guard let colorSpace = _colorSpace else { return }
        
        guard let color = PDFBitmap(width: width, height: height, bitsPerComponent: bitsPerComponent, colorSpace: colorSpace, decodeParms: decodeParms, data: data) else { return }
        
        if let _mask = table["SMask"]?.stream,
            let mask_width = _mask["Width"].intValue,
            let mask_height = _mask["Height"].intValue,
            let mask_bitsPerComponent = _mask["BitsPerComponent"].intValue,
            let mask_data = self.decode_image(_mask["Filter"].filters ?? [], _mask.data) {
            
            if let mask_colorSpace = PDFColorSpace(_mask["ColorSpace"]) ?? PDFColorSpace(_mask["CS"]) {
                guard mask_colorSpace == .deviceGray else { return }
            }
            
            let mask_decodeParms = _mask["DecodeParms"].dictionary  ?? [:]
            
            let mask = PDFBitmap(width: mask_width, height: mask_height, bitsPerComponent: mask_bitsPerComponent, colorSpace: .deviceGray, decodeParms: mask_decodeParms, data: mask_data)
            
            if self.alphaMask {
                
                let has_mask = self.hasMask
                
                if has_mask {
                    self.beginTransparencyLayer()
                } else {
                    self.saveGraphicState()
                }
                
                if let mask = mask {
                    
                    self.drawClip(alphaMask: false) {
                        
                        if let mask = $0.createImage(color: mask, mask: nil) {
                            $0.drawImage(image: mask)
                            cache?.mask = mask
                        }
                    }
                }
                
                self.path = Shape(rect: Rect(x: 0, y: 0, width: 1, height: 1))
                self.draw(winding: .nonZero)
                
                if has_mask {
                    self.endTransparencyLayer()
                } else {
                    self.restoreGraphicState()
                }
                
            } else if width == mask_width && height == mask_height {
                
                if let image = self.createImage(color: color, mask: mask) {
                    self.drawImage(image: image)
                    cache?.image = image
                }
                
            } else if let mask = mask {
                
                let has_mask = self.hasMask
                
                if has_mask {
                    self.beginTransparencyLayer()
                } else {
                    self.saveGraphicState()
                }
                
                self.drawClip(alphaMask: false) {
                    
                    if let mask = $0.createImage(color: mask, mask: nil) {
                        $0.drawImage(image: mask)
                        cache?.mask = mask
                    }
                }
                
                if let image = self.createImage(color: color, mask: nil) {
                    self.drawImage(image: image)
                    cache?.image = image
                }
                
                if has_mask {
                    self.endTransparencyLayer()
                } else {
                    self.restoreGraphicState()
                }
                
            } else {
                
                if let image = self.createImage(color: color, mask: nil) {
                    self.drawImage(image: image)
                    cache?.image = image
                }
            }
            
        } else {
            
            if let image = self.createImage(color: color, mask: nil) {
                self.drawImage(image: image)
                cache?.image = image
            }
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
        case 0x2B, 0x2D, 0x2E, 0x30...0x39:
            
            guard let number = PDFNumber(&data) else { return nil }
            return .number(number)
            
        case 0x28, 0x3C:
            
            guard let string = PDFString(&data) else { return nil }
            return .string(string)
            
        default: return decode_string(&data)
        }
    }
    
    static func decode_string(_ data: inout Data) -> PDFCommand? {
        
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
    
    static func decode_array(_ data: inout Data) -> PDFCommand? {
        
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
