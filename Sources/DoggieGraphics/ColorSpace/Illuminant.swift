//
//  Illuminant.swift
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

public protocol Illuminant: RawRepresentable, Hashable where RawValue == Point {
    
}

@frozen
public struct CIE1931: Illuminant {
    
    public var rawValue: Point
    
    public init(rawValue: Point) {
        self.rawValue = rawValue
    }
    
    public static let A          = CIE1931(rawValue: Point(x: 0.44757, y: 0.40745))
    
    public static let B          = CIE1931(rawValue: Point(x: 0.34842, y: 0.35161))
    
    public static let C          = CIE1931(rawValue: Point(x: 0.31006, y: 0.31616))
    
    public static let D50        = CIE1931(rawValue: Point(x: 0.34567, y: 0.35850))
    public static let D55        = CIE1931(rawValue: Point(x: 0.33242, y: 0.34743))
    public static let D65        = CIE1931(rawValue: Point(x: 0.31271, y: 0.32902))
    public static let D75        = CIE1931(rawValue: Point(x: 0.29902, y: 0.31485))
    
    public static let E          = CIE1931(rawValue: Point(x: 1.0/3.0, y: 1.0/3.0))
    
    public static let F1         = CIE1931(rawValue: Point(x: 0.31310, y: 0.33727))
    public static let F2         = CIE1931(rawValue: Point(x: 0.37208, y: 0.37529))
    public static let F3         = CIE1931(rawValue: Point(x: 0.40910, y: 0.39430))
    public static let F4         = CIE1931(rawValue: Point(x: 0.44018, y: 0.40329))
    public static let F5         = CIE1931(rawValue: Point(x: 0.31379, y: 0.34531))
    public static let F6         = CIE1931(rawValue: Point(x: 0.37790, y: 0.38835))
    public static let F7         = CIE1931(rawValue: Point(x: 0.31292, y: 0.32933))
    public static let F8         = CIE1931(rawValue: Point(x: 0.34588, y: 0.35875))
    public static let F9         = CIE1931(rawValue: Point(x: 0.37417, y: 0.37281))
    public static let F10        = CIE1931(rawValue: Point(x: 0.34609, y: 0.35986))
    public static let F11        = CIE1931(rawValue: Point(x: 0.38052, y: 0.37713))
    public static let F12        = CIE1931(rawValue: Point(x: 0.43695, y: 0.40441))
    
    public static let LEDB1      = CIE1931(rawValue: Point(x: 0.4560, y: 0.4078))
    public static let LEDB2      = CIE1931(rawValue: Point(x: 0.4357, y: 0.4012))
    public static let LEDB3      = CIE1931(rawValue: Point(x: 0.3756, y: 0.3723))
    public static let LEDB4      = CIE1931(rawValue: Point(x: 0.3422, y: 0.3502))
    public static let LEDB5      = CIE1931(rawValue: Point(x: 0.3118, y: 0.3236))
    public static let LEDBH1     = CIE1931(rawValue: Point(x: 0.4474, y: 0.4066))
    public static let LEDRGB1    = CIE1931(rawValue: Point(x: 0.4557, y: 0.4211))
    public static let LEDV1      = CIE1931(rawValue: Point(x: 0.4560, y: 0.4548))
    public static let LEDV2      = CIE1931(rawValue: Point(x: 0.3781, y: 0.3775))
}

extension CIE1931: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        switch self {
        case .A: return "CIE1931 A"
        case .B: return "CIE1931 B"
        case .C: return "CIE1931 C"
        case .D50: return "CIE1931 D50"
        case .D55: return "CIE1931 D55"
        case .D65: return "CIE1931 D65"
        case .D75: return "CIE1931 D75"
        case .E: return "CIE1931 E"
        case .F1: return "CIE1931 F1"
        case .F2: return "CIE1931 F2"
        case .F3: return "CIE1931 F3"
        case .F4: return "CIE1931 F4"
        case .F5: return "CIE1931 F5"
        case .F6: return "CIE1931 F6"
        case .F7: return "CIE1931 F7"
        case .F8: return "CIE1931 F8"
        case .F9: return "CIE1931 F9"
        case .F10: return "CIE1931 F10"
        case .F11: return "CIE1931 F11"
        case .F12: return "CIE1931 F12"
        case .LEDB1: return "CIE1931 LEDB1"
        case .LEDB2: return "CIE1931 LEDB2"
        case .LEDB3: return "CIE1931 LEDB3"
        case .LEDB4: return "CIE1931 LEDB4"
        case .LEDB5: return "CIE1931 LEDB5"
        case .LEDBH1: return "CIE1931 LEDBH1"
        case .LEDRGB1: return "CIE1931 LEDRGB1"
        case .LEDV1: return "CIE1931 LEDV1"
        case .LEDV2: return "CIE1931 LEDV2"
        default: return "CIE1931(x: \(Decimal(rawValue.x).rounded(scale: 9)), y: \(Decimal(rawValue.y).rounded(scale: 9)))"
        }
    }
}

@frozen
public struct CIE1964: Illuminant {
    
    public var rawValue: Point
    
    public init(rawValue: Point) {
        self.rawValue = rawValue
    }
    
    public static let A          = CIE1964(rawValue: Point(x: 0.45117, y: 0.40594))
    
    public static let B          = CIE1964(rawValue: Point(x: 0.34980, y: 0.35270))
    
    public static let C          = CIE1964(rawValue: Point(x: 0.31039, y: 0.31905))
    
    public static let D50        = CIE1964(rawValue: Point(x: 0.34773, y: 0.35952))
    public static let D55        = CIE1964(rawValue: Point(x: 0.33411, y: 0.34877))
    public static let D65        = CIE1964(rawValue: Point(x: 0.31382, y: 0.33100))
    public static let D75        = CIE1964(rawValue: Point(x: 0.29968, y: 0.31740))
    
    public static let E          = CIE1964(rawValue: Point(x: 1.0/3.0, y: 1.0/3.0))
    
    public static let F1         = CIE1964(rawValue: Point(x: 0.31811, y: 0.33559))
    public static let F2         = CIE1964(rawValue: Point(x: 0.37925, y: 0.36733))
    public static let F3         = CIE1964(rawValue: Point(x: 0.41761, y: 0.38324))
    public static let F4         = CIE1964(rawValue: Point(x: 0.44920, y: 0.39074))
    public static let F5         = CIE1964(rawValue: Point(x: 0.31975, y: 0.34246))
    public static let F6         = CIE1964(rawValue: Point(x: 0.38660, y: 0.37847))
    public static let F7         = CIE1964(rawValue: Point(x: 0.31569, y: 0.32960))
    public static let F8         = CIE1964(rawValue: Point(x: 0.34902, y: 0.35939))
    public static let F9         = CIE1964(rawValue: Point(x: 0.37829, y: 0.37045))
    public static let F10        = CIE1964(rawValue: Point(x: 0.35090, y: 0.35444))
    public static let F11        = CIE1964(rawValue: Point(x: 0.38541, y: 0.37123))
    public static let F12        = CIE1964(rawValue: Point(x: 0.44256, y: 0.39717))
    
}

extension CIE1964: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        switch self {
        case .A: return "CIE1964 A"
        case .B: return "CIE1964 B"
        case .C: return "CIE1964 C"
        case .D50: return "CIE1964 D50"
        case .D55: return "CIE1964 D55"
        case .D65: return "CIE1964 D65"
        case .D75: return "CIE1964 D75"
        case .E: return "CIE1964 E"
        case .F1: return "CIE1964 F1"
        case .F2: return "CIE1964 F2"
        case .F3: return "CIE1964 F3"
        case .F4: return "CIE1964 F4"
        case .F5: return "CIE1964 F5"
        case .F6: return "CIE1964 F6"
        case .F7: return "CIE1964 F7"
        case .F8: return "CIE1964 F8"
        case .F9: return "CIE1964 F9"
        case .F10: return "CIE1964 F10"
        case .F11: return "CIE1964 F11"
        case .F12: return "CIE1964 F12"
        default: return "CIE1964(x: \(Decimal(rawValue.x).rounded(scale: 9)), y: \(Decimal(rawValue.y).rounded(scale: 9)))"
        }
    }
}
