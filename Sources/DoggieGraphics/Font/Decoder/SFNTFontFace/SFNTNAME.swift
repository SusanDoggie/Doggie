//
//  SFNTNAME.swift
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

struct SFNTNAME: ByteDecodable, RandomAccessCollection {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    var format: BEUInt16
    var record: [Record]
    var data: Data
    
    struct Record {
        
        var platform: SFNTPlatform
        var language: BEUInt16
        var name: BEUInt16
        var length: BEUInt16
        var offset: BEUInt16
    }
    
    init(from data: inout Data) throws {
        
        let copy = data
        
        self.format = try data.decode(BEUInt16.self)
        let _count = try data.decode(BEUInt16.self)
        let _stringOffset = try data.decode(BEUInt16.self)
        
        self.data = copy.dropFirst(Int(_stringOffset))
        
        self.record = []
        self.record.reserveCapacity(Int(_count))
        
        for _ in 0..<Int(_count) {
            
            let platform = try data.decode(SFNTPlatform.self)
            let language = try data.decode(BEUInt16.self)
            let name = try data.decode(BEUInt16.self)
            let length = try data.decode(BEUInt16.self)
            let offset = try data.decode(BEUInt16.self)
            
            self.record.append(Record(platform: platform, language: language, name: name, length: length, offset: offset))
        }
    }
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return record.count
    }
    
    subscript(position: Int) -> String? {
        
        assert(0..<count ~= position, "Index out of range.")
        
        guard let encoding = self.record[position].platform.encoding else { return nil }
        
        let offset = Int(self.record[position].offset)
        let length = Int(self.record[position].length)
        
        let strData: Data = self.data.dropFirst(offset).prefix(length)
        
        guard strData.count == length else { return nil }
        
        return String(data: strData, encoding: encoding)
    }
    
}

extension SFNTNAME.Record {
    
    var iso_language: String? {
        switch platform.platform {
        case 1:
            switch language {
            case 0: return "en"
            case 1: return "fr"
            case 2: return "de"
            case 3: return "it"
            case 4: return "nl"
            case 5: return "sv"
            case 6: return "es"
            case 7: return "da"
            case 8: return "pt"
            case 9: return "nb"
            case 10: return "he"
            case 11: return "ja"
            case 12: return "ar"
            case 13: return "fi"
            case 14: return "el"
            case 15: return "is"
            case 16: return "mt"
            case 17: return "tr"
            case 18: return "hr"
            case 19: return "zh-Hant"
            case 20: return "ur"
            case 21: return "hi"
            case 22: return "th"
            case 23: return "ko"
            case 24: return "lt"
            case 25: return "pl"
            case 26: return "hu"
            case 27: return "et"
            case 28: return "lv"
            case 29: return "se"
            case 30: return "fo"
            case 31: return "fa"
            case 32: return "ru"
            case 33: return "zh-Hans"
            case 34: return "nl-BE"
            case 35: return "ga"
            case 36: return "sq"
            case 37: return "ro"
            case 38: return "cs"
            case 39: return "sk"
            case 40: return "sl"
            case 41: return "yi"
            case 42: return "sr"
            case 43: return "mk"
            case 44: return "bg"
            case 45: return "uk"
            case 46: return "be"
            case 47: return "uz"
            case 48: return "kk"
            case 49: return "az-Cyrl"
            case 50: return "az"
            case 51: return "hy"
            case 52: return "ka"
            case 53: return "mo"
            case 54: return "ky"
            case 55: return "tg"
            case 56: return "tk"
            case 57: return "mn"
            case 58: return "mn-Cyrl"
            case 59: return "ps"
            case 60: return "ku"
            case 61: return "ks"
            case 62: return "sd"
            case 63: return "bo"
            case 64: return "ne"
            case 65: return "sa"
            case 66: return "mr"
            case 67: return "bn"
            case 68: return "as"
            case 69: return "gu"
            case 70: return "pa"
            case 71: return "or"
            case 72: return "ml"
            case 73: return "kn"
            case 74: return "ta"
            case 75: return "te"
            case 76: return "si"
            case 77: return "my"
            case 78: return "km"
            case 79: return "lo"
            case 80: return "vi"
            case 81: return "id"
            case 82: return "fil"
            case 83: return "ms"
            case 84: return "ms-Arab"
            case 85: return "am"
            case 86: return "ti"
            case 88: return "so"
            case 89: return "sw"
            case 90: return "rw"
            case 91: return "rn"
            case 92: return "ny"
            case 93: return "mg"
            case 94: return "eo"
            case 128: return "cy"
            case 129: return "eu"
            case 130: return "ca"
            case 131: return "la"
            case 132: return "qu"
            case 133: return "gn"
            case 134: return "ay"
            case 135: return "tt"
            case 136: return "ug"
            case 137: return "dz"
            case 138: return "jv"
            case 139: return "su"
            case 140: return "gl"
            case 141: return "af"
            case 142: return "br"
            case 143: return "iu"
            case 144: return "gd"
            case 145: return "gv"
            case 146: return "ga"
            case 147: return "to"
            case 148: return "el"
            case 149: return "kl"
            case 150: return "az"
            default: return nil
            }
        case 3: return Locale.identifier(fromWindowsLocaleCode: Int(language))
        default: return nil
        }
    }
}
