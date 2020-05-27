//
//  PDFColorSpace.swift
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

indirect enum PDFColorSpace: Hashable {
    
    case deviceGray
    case deviceRGB
    case deviceCMYK
    case indexed(PDFColorSpace, [Data])
    case colorSpace(AnyColorSpace)
    
    init(_ colorSpace: AnyColorSpace) {
        self = .colorSpace(colorSpace)
    }
}

extension PDFColorSpace {
    
    var numberOfComponents: Int {
        switch self {
        case .deviceGray: return 1
        case .deviceRGB: return 3
        case .deviceCMYK: return 4
        case .indexed: return 1
        case let .colorSpace(colorSpace): return colorSpace.numberOfComponents
        }
    }
    
    var black: [Double]? {
        switch self {
        case .deviceGray: return [0]
        case .deviceRGB: return [0, 0, 0]
        case .deviceCMYK: return [0, 0, 0, 1]
        case .indexed: return nil
        case let .colorSpace(colorSpace):
            switch colorSpace.base {
            case is ColorSpace<GrayColorModel>: return [0]
            case is ColorSpace<RGBColorModel>: return [0, 0, 0]
            case is ColorSpace<CMYColorModel>: return [1, 1, 1]
            case is ColorSpace<CMYKColorModel>: return [0, 0, 0, 1]
            default: return Array(repeating: 0, count: colorSpace.numberOfComponents)
            }
        }
    }
}

extension PDFColorSpace {
    
    init?(_ object: PDFObject, _ colorSpaces: [PDFName: PDFColorSpace] = [:]) {
        
        switch object.name ?? object.array?.first?.name {
            
        case "DeviceGray", "G": self = .deviceGray
        case "DeviceRGB", "RGB": self = .deviceRGB
        case "DeviceCMYK", "CMYK": self = .deviceCMYK
            
        case "CalGray":
            
            guard let parameter = object.array?.dropFirst().first else { return nil }
            guard let white = parameter["WhitePoint"].vector else { return nil }
            
            let black = parameter["BlackPoint"].vector ?? Vector()
            let gamma = parameter["Gamma"].doubleValue ?? 1
            
            let _white = XYZColorModel(x: white.x, y: white.y, z: white.z)
            let _black = XYZColorModel(x: black.x, y: black.y, z: black.z)
            
            self.init(.calibratedGray(white: _white, black: _black, gamma: gamma))
            
        case "CalRGB":
            
            guard let parameter = object.array?.dropFirst().first else { return nil }
            guard let white = parameter["WhitePoint"].vector else { return nil }
            
            let black = parameter["BlackPoint"].vector ?? Vector()
            let gamma = parameter["Gamma"].vector ?? Vector(x: 1, y: 1, z: 1)
            let matrix = parameter["Matrix"].matrix ?? [1, 0, 0, 0, 1, 0, 0, 0, 1]
            
            let _white = XYZColorModel(x: white.x, y: white.y, z: white.z)
            let _black = XYZColorModel(x: black.x, y: black.y, z: black.z)
            
            let red = XYZColorModel(x: matrix[0], y: 0, z: 0)
            let green = XYZColorModel(x: 0, y: matrix[4], z: 0)
            let blue = XYZColorModel(x: 0, y: 0, z: matrix[8])
            
            self.init(.calibratedRGB(white: _white, black: _black, red: red.point, green: green.point, blue: blue.point, gamma: (gamma.x, gamma.y, gamma.z)))
            
        case "Lab":
            
            guard let parameter = object.array?.dropFirst().first else { return nil }
            guard let white = parameter["WhitePoint"].vector else { return nil }
            
            let black = parameter["BlackPoint"].vector ?? Vector()
            
            let _white = XYZColorModel(x: white.x, y: white.y, z: white.z)
            let _black = XYZColorModel(x: black.x, y: black.y, z: black.z)
            
            self.init(.cieLab(white: _white, black: _black))
            
        case "ICCBased":
            
            guard let parameter = object.array?.dropFirst().first else { return nil }
            guard let iccData = parameter.stream?.decode() else { return nil }
            
            guard let colorSpace = try? AnyColorSpace(iccData: iccData) else { return nil }
            
            self.init(colorSpace)
            
        case "Indexed", "I":
            
            guard let array = object.array else { return nil }
            
            guard array.count >= 4 else { return nil }
            guard let base = PDFColorSpace(array[1], colorSpaces) else { return nil }
            guard let hival = array[2].intValue else { return nil }
            
            guard let data = array[3].string?.data ?? array[3].stream?.decode() else { return nil }
                
            guard (hival + 1) * base.numberOfComponents <= data.count else { return nil }
            
            let table = data.chunked(by: base.numberOfComponents).prefix(hival + 1)
            
            self = .indexed(base, Array(table))
            
        default: return nil
        }
    }
}

extension PDFColorSpace {
    
    func create_color(_ color: [PDFNumber], device colorSpace: AnyColorSpace?) -> AnyColor? {
        
        switch self {
        case .deviceGray:
            
            let color = color.map { $0.doubleValue ?? 0 }
            
            switch colorSpace?.base {
                
            case let colorSpace as ColorSpace<GrayColorModel>:
                
                return AnyColor(colorSpace: AnyColorSpace(colorSpace), components: color)
                
            case let colorSpace as ColorSpace<RGBColorModel>:
                
                return AnyColor(colorSpace: AnyColorSpace(colorSpace), components: [color[0], color[0], color[0]])
                
            case let colorSpace as ColorSpace<CMYKColorModel>:
                
                return AnyColor(colorSpace: AnyColorSpace(colorSpace), components: [0, 0, 0, 1 - color[0]])
                
            default: return nil
            }
            
        case .deviceRGB:
            
            let color = color.map { $0.doubleValue ?? 0 }
            
            switch colorSpace?.base {
                
            case let colorSpace as ColorSpace<GrayColorModel>:
                
                let gray = 0.3 * color[0] + 0.59 * color[1] + 0.11 * color[2]
                
                return AnyColor(colorSpace: AnyColorSpace(colorSpace), components: [gray])
                
            case let colorSpace as ColorSpace<RGBColorModel>:
                
                return AnyColor(colorSpace: AnyColorSpace(colorSpace), components: color)
                
            case let colorSpace as ColorSpace<CMYKColorModel>:
                
                let rgb = RGBColorModel(red: color[0], green: color[1], blue: color[2])
                
                return AnyColor(colorSpace: AnyColorSpace(colorSpace), components: CMYKColorModel(rgb))
                
            default: return nil
            }
            
        case .deviceCMYK:
            
            let color = color.map { $0.doubleValue ?? 0 }
            
            switch colorSpace?.base {
                
            case let colorSpace as ColorSpace<GrayColorModel>:
                
                let gray = 1 - min(1, 0.3 * color[0] + 0.59 * color[1] + 0.11 * color[2] + color[3])
                
                return AnyColor(colorSpace: AnyColorSpace(colorSpace), components: [gray])
                
            case let colorSpace as ColorSpace<RGBColorModel>:
                
                let cmyk = CMYKColorModel(cyan: color[0], magenta: color[1], yellow: color[2], black: color[3])
                
                return AnyColor(colorSpace: AnyColorSpace(colorSpace), components: RGBColorModel(cmyk))
                
            case let colorSpace as ColorSpace<CMYKColorModel>:
                
                return AnyColor(colorSpace: AnyColorSpace(colorSpace), components: color)
                
            default: return nil
            }
            
        case let .indexed(base, table):
            
            guard let index = color[0].int64Value else { return nil }
            
            let _color = table[Int(index)].map { PDFNumber(Double($0) / 255) }
            
            return 0..<table.count ~= Int(index) ? base.create_color(_color, device: colorSpace) : nil
            
        case let .colorSpace(colorSpace): return AnyColor(colorSpace: colorSpace, components: color.map { $0.doubleValue ?? 0 })
        }
    }
}
