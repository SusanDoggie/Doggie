//
//  PredefinedColor.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

extension AnyColor {
    
    @inlinable
    public static var black: AnyColor  {
        return AnyColor(white: 0.0)
    }
    
    @inlinable
    public static var blue: AnyColor  {
        return AnyColor(red: 0.0, green: 0.0, blue: 1.0)
    }
    
    @inlinable
    public static var brown: AnyColor  {
        return AnyColor(red: 0.6, green: 0.4, blue: 0.2)
    }
    
    @inlinable
    public static var clear: AnyColor  {
        return AnyColor(white: 0.0, opacity: 0.0)
    }
    
    @inlinable
    public static var cyan: AnyColor  {
        return AnyColor(red: 0.0, green: 1.0, blue: 1.0)
    }
    
    @inlinable
    public static var darkGray: AnyColor  {
        return AnyColor(white: 1.0 / 3.0)
    }
    
    @inlinable
    public static var gray: AnyColor  {
        return AnyColor(white: 0.5)
    }
    
    @inlinable
    public static var green: AnyColor  {
        return AnyColor(red: 0.0, green: 1.0, blue: 0.0)
    }
    
    @inlinable
    public static var lightGray: AnyColor  {
        return AnyColor(white: 2.0 / 3.0)
    }
    
    @inlinable
    public static var magenta: AnyColor  {
        return AnyColor(red: 1.0, green: 0.0, blue: 1.0)
    }
    
    @inlinable
    public static var orange: AnyColor  {
        return AnyColor(red: 1.0, green: 0.5, blue: 0.0)
    }
    
    @inlinable
    public static var purple: AnyColor  {
        return AnyColor(red: 0.5, green: 0.0, blue: 0.5)
    }
    
    @inlinable
    public static var red: AnyColor  {
        return AnyColor(red: 1.0, green: 0.0, blue: 0.0)
    }
    
    @inlinable
    public static var white: AnyColor  {
        return AnyColor(white: 1.0)
    }
    
    @inlinable
    public static var yellow: AnyColor  {
        return AnyColor(red: 1.0, green: 1.0, blue: 0.0)
    }
}
