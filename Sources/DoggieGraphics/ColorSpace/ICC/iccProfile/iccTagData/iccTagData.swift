//
//  iccTagData.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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

extension iccProfile {
    
    @frozen
    @usableFromInline
    struct TagData {
        
        let rawData: Data
        
        init(rawData: Data) {
            self.rawData = rawData
        }
        
        var type: TagType {
            return rawData.load(as: TagType.self)
        }
        
        var data: Data {
            return rawData.dropFirst(8)
        }
    }
}

extension iccProfile.TagData {
    
    private var _obj: Any? {
        
        switch type {
        case .uInt16Array: return uInt16Array
        case .uInt32Array: return uInt32Array
        case .uInt64Array: return uInt64Array
        case .uInt8Array: return uInt8Array
        case .s15Fixed16Array: return s15Fixed16Array
        case .u16Fixed16Array: return u16Fixed16Array
        case .XYZArray: return XYZArray
        case .curve, .parametricCurve: return curve
        case .namedColor2: return namedColor
        case .text: return text
        case .multiLocalizedUnicode: return multiLocalizedUnicode
        case .lut8, .lut16, .lutAtoB, .lutBtoA: return transform
        default: return nil
        }
    }
}

extension iccProfile.TagData {
    
    var uInt16Array: [BEUInt16]? {
        return type == .uInt16Array ? Array(data.typed(as: BEUInt16.self)) : nil
    }
    
    var uInt32Array: [BEUInt32]? {
        return type == .uInt32Array ? Array(data.typed(as: BEUInt32.self)) : nil
    }
    
    var uInt64Array: [BEUInt64]? {
        return type == .uInt64Array ? Array(data.typed(as: BEUInt64.self)) : nil
    }
    
    var uInt8Array: [UInt8]? {
        return type == .uInt8Array ? Array(data) : nil
    }
}

extension iccProfile.TagData {
    
    var s15Fixed16Array: [Fixed16Number<BEInt32>]? {
        return type == .s15Fixed16Array ? Array(data.typed(as: Fixed16Number<BEInt32>.self)) : nil
    }
    
    var u16Fixed16Array: [Fixed16Number<BEUInt32>]? {
        return type == .u16Fixed16Array ? Array(data.typed(as: Fixed16Number<BEUInt32>.self)) : nil
    }
}

extension iccProfile.TagData {
    
    var XYZArray: [iccXYZNumber]? {
        return type == .XYZArray ? Array(data.typed(as: iccXYZNumber.self)) : nil
    }
}

extension iccProfile.TagData {
    
    var multiLocalizedUnicode: iccMultiLocalizedUnicode? {
        return type == .multiLocalizedUnicode ? try? iccMultiLocalizedUnicode(self.rawData) : nil
    }
}

extension iccProfile.TagData {
    
    var curve: iccCurve? {
        return type == .curve || type == .parametricCurve ? try? iccCurve(self.rawData) : nil
    }
}

extension iccProfile.TagData {
    
    var namedColor: iccNamedColor? {
        return type == .namedColor2 ? try? iccNamedColor(self.rawData) : nil
    }
}

extension iccProfile.TagData {
    
    var transform: iccLUTTransform? {
        return type == .lut8 || type == .lut16 || type == .lutAtoB || type == .lutBtoA ? try? iccLUTTransform(self.rawData) : nil
    }
}

extension iccProfile.TagData {
    
    var text: String? {
        
        return type == .text ? String(bytes: data, encoding: .ascii) : nil
    }
}

extension iccProfile.TagData {
    
    var textDescription: iccTextDescription? {
        return type == .textDescription ? try? iccTextDescription(self.rawData) : nil
    }
}

