//
//  iccTransform.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

@_versioned
protocol iccTransform {
    
    func normalize(_ xyz: XYZColorModel) -> XYZColorModel
    
    func denormalize(_ xyz: XYZColorModel) -> XYZColorModel
    
    func convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model
    
    func convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model
    
    func convertLinearToConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: Model) -> PCSColor
    
    func convertLinearFromConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: PCSColor) -> Model
}

@_versioned
@_fixed_layout
struct iccMonochromeTransform : iccTransform {
    
    @_versioned
    var curve: iccCurve
    
    @_versioned
    @inline(__always)
    func normalize(_ xyz: XYZColorModel) -> XYZColorModel {
        
        var color = xyz
        
        color.x *= 2
        color.z *= 2
        
        return color
    }
    
    @_versioned
    @inline(__always)
    func denormalize(_ xyz: XYZColorModel) -> XYZColorModel {
        
        var color = xyz
        
        color.x *= 0.5
        color.z *= 0.5
        
        return color
    }
    
    @_versioned
    @inline(__always)
    func convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        result[0] = curve.eval(color[0])
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        result[0] = curve.eval(color[0])
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertLinearToConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: Model) -> PCSColor {
        
        var result = PCSColor()
        
        result.luminance = color[0]
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertLinearFromConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: PCSColor) -> Model {
        
        var result = Model()
        
        result[0] = color.luminance
        
        return result
    }
}

@_versioned
@_fixed_layout
struct iccMatrixTransform : iccTransform {
    
    @_versioned
    var matrix: Matrix
    
    @_versioned
    var curve: (iccCurve, iccCurve, iccCurve)
    
    @_versioned
    @inline(__always)
    func normalize(_ xyz: XYZColorModel) -> XYZColorModel {
        
        var color = xyz
        
        color.x *= 2
        color.z *= 2
        
        return color
    }
    
    @_versioned
    @inline(__always)
    func denormalize(_ xyz: XYZColorModel) -> XYZColorModel {
        
        var color = xyz
        
        color.x *= 0.5
        color.z *= 0.5
        
        return color
    }
    
    @_versioned
    @inline(__always)
    func convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        result[0] = curve.0.eval(color[0])
        result[1] = curve.1.eval(color[1])
        result[2] = curve.2.eval(color[2])
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        result[0] = curve.0.eval(color[0])
        result[1] = curve.1.eval(color[1])
        result[2] = curve.2.eval(color[2])
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertLinearToConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: Model) -> PCSColor {
        
        var result = PCSColor()
        
        result[0] = color[0]
        result[1] = color[1]
        result[2] = color[2]
        
        result *= matrix
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertLinearFromConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: PCSColor) -> Model {
        
        var result = Model()
        var color = color
        
        color *= matrix
        
        result[0] = color[0]
        result[1] = color[1]
        result[2] = color[2]
        
        return result
    }
}

@_versioned
@_fixed_layout
struct iccLUT0Transform : iccTransform {
    
    @_versioned
    var matrix: Matrix
    
    @_versioned
    var input: OneDimensionalLUT
    
    @_versioned
    var clut: MultiDimensionalLUT
    
    @_versioned
    var output: OneDimensionalLUT
    
    @_versioned
    @inline(__always)
    func normalize(_ xyz: XYZColorModel) -> XYZColorModel {
        
        var color = xyz
        
        color.x *= 2
        color.z *= 2
        
        return color
    }
    
    @_versioned
    @inline(__always)
    func denormalize(_ xyz: XYZColorModel) -> XYZColorModel {
        
        var color = xyz
        
        color.x *= 0.5
        color.z *= 0.5
        
        return color
    }
    
    @_versioned
    @inline(__always)
    func convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        result = input.eval(color)
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        result = output.eval(color)
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertLinearToConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: Model) -> PCSColor {
        
        var result = PCSColor()
        
        result = clut.eval(color)
        
        result = output.eval(result)
        
        if result is XYZColorModel {
            result *= matrix
        }
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertLinearFromConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: PCSColor) -> Model {
        
        var result = Model()
        var color = color
        
        if color is XYZColorModel {
            color *= matrix
        }
        
        color = input.eval(color)
        
        result = clut.eval(color)
        
        return result
    }
}

@_versioned
@_fixed_layout
struct iccLUT1Transform : iccTransform {
    
    @_versioned
    var curve: (iccCurve, iccCurve, iccCurve)
    
    @_versioned
    @inline(__always)
    func normalize(_ xyz: XYZColorModel) -> XYZColorModel {
        
        var color = xyz
        
        color.y *= 0.5
        
        return color
    }
    
    @_versioned
    @inline(__always)
    func denormalize(_ xyz: XYZColorModel) -> XYZColorModel {
        
        var color = xyz
        
        color.y *= 2
        
        return color
    }
    
    @_versioned
    @inline(__always)
    func convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        result[0] = curve.0.eval(color[0])
        result[1] = curve.1.eval(color[1])
        result[2] = curve.2.eval(color[2])
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        result[0] = curve.0.eval(color[0])
        result[1] = curve.1.eval(color[1])
        result[2] = curve.2.eval(color[2])
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertLinearToConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: Model) -> PCSColor {
        
        var result = PCSColor()
        
        result[0] = color[0]
        result[1] = color[1]
        result[2] = color[2]
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertLinearFromConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: PCSColor) -> Model {
        
        var result = Model()
        
        result[0] = color[0]
        result[1] = color[1]
        result[2] = color[2]
        
        return result
    }
}

@_versioned
@_fixed_layout
struct iccLUT2Transform : iccTransform {
    
    @_versioned
    var B: (iccCurve, iccCurve, iccCurve)
    
    @_versioned
    var matrix: Matrix
    
    @_versioned
    var M: (iccCurve, iccCurve, iccCurve)
    
    @_versioned
    @inline(__always)
    func normalize(_ xyz: XYZColorModel) -> XYZColorModel {
        
        var color = xyz
        
        color.y *= 0.5
        
        return color
    }
    
    @_versioned
    @inline(__always)
    func denormalize(_ xyz: XYZColorModel) -> XYZColorModel {
        
        var color = xyz
        
        color.y *= 2
        
        return color
    }
    
    @_versioned
    @inline(__always)
    func convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        result[0] = M.0.eval(color[0])
        result[1] = M.1.eval(color[1])
        result[2] = M.2.eval(color[2])
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        result[0] = M.0.eval(color[0])
        result[1] = M.1.eval(color[1])
        result[2] = M.2.eval(color[2])
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertLinearToConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: Model) -> PCSColor {
        
        var result = PCSColor()
        
        result[0] = color[0]
        result[1] = color[1]
        result[2] = color[2]
        
        result *= matrix
        
        result[0] = B.0.eval(result[0])
        result[1] = B.1.eval(result[1])
        result[2] = B.2.eval(result[2])
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertLinearFromConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: PCSColor) -> Model {
        
        var result = Model()
        var color = color
        
        color[0] = B.0.eval(color[0])
        color[1] = B.1.eval(color[1])
        color[2] = B.2.eval(color[2])
        
        color *= matrix
        
        result[0] = color[0]
        result[1] = color[1]
        result[2] = color[2]
        
        return result
    }
}

@_versioned
@_fixed_layout
struct iccLUT3Transform : iccTransform {
    
    @_versioned
    var B: (iccCurve, iccCurve, iccCurve)
    
    @_versioned
    var lut: MultiDimensionalLUT
    
    @_versioned
    var A: [iccCurve]
    
    @_versioned
    @inline(__always)
    func normalize(_ xyz: XYZColorModel) -> XYZColorModel {
        
        var color = xyz
        
        color.y *= 0.5
        
        return color
    }
    
    @_versioned
    @inline(__always)
    func denormalize(_ xyz: XYZColorModel) -> XYZColorModel {
        
        var color = xyz
        
        color.y *= 2
        
        return color
    }
    
    @_versioned
    @inline(__always)
    func convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        for i in 0..<Model.numberOfComponents {
            result[i] = A[i].eval(color[i])
        }
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        for i in 0..<Model.numberOfComponents {
            result[i] = A[i].eval(color[i])
        }
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertLinearToConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: Model) -> PCSColor {
        
        var result = PCSColor()
        
        result = lut.eval(color)
        
        result[0] = B.0.eval(result[0])
        result[1] = B.1.eval(result[1])
        result[2] = B.2.eval(result[2])
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertLinearFromConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: PCSColor) -> Model {
        
        var result = Model()
        var color = color
        
        color[0] = B.0.eval(color[0])
        color[1] = B.1.eval(color[1])
        color[2] = B.2.eval(color[2])
        
        result = lut.eval(color)
        
        return result
    }
}

@_versioned
@_fixed_layout
struct iccLUT4Transform : iccTransform {
    
    @_versioned
    var B: (iccCurve, iccCurve, iccCurve)
    
    @_versioned
    var matrix: Matrix
    
    @_versioned
    var M: (iccCurve, iccCurve, iccCurve)
    
    @_versioned
    var lut: MultiDimensionalLUT
    
    @_versioned
    var A: [iccCurve]
    
    @_versioned
    @inline(__always)
    func normalize(_ xyz: XYZColorModel) -> XYZColorModel {
        
        var color = xyz
        
        color.y *= 0.5
        
        return color
    }
    
    @_versioned
    @inline(__always)
    func denormalize(_ xyz: XYZColorModel) -> XYZColorModel {
        
        var color = xyz
        
        color.y *= 2
        
        return color
    }
    
    @_versioned
    @inline(__always)
    func convertToLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        for i in 0..<Model.numberOfComponents {
            result[i] = A[i].eval(color[i])
        }
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertFromLinear<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        var result = Model()
        
        for i in 0..<Model.numberOfComponents {
            result[i] = A[i].eval(color[i])
        }
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertLinearToConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: Model) -> PCSColor {
        
        var result = PCSColor()
        
        result = lut.eval(color)
        
        result[0] = M.0.eval(result[0])
        result[1] = M.1.eval(result[1])
        result[2] = M.2.eval(result[2])
        
        result *= matrix
        
        result[0] = B.0.eval(result[0])
        result[1] = B.1.eval(result[1])
        result[2] = B.2.eval(result[2])
        
        return result
    }
    
    @_versioned
    @inline(__always)
    func convertLinearFromConnection<Model: ColorModelProtocol, PCSColor: PCSColorModel>(_ color: PCSColor) -> Model {
        
        var result = Model()
        var color = color
        
        color[0] = B.0.eval(color[0])
        color[1] = B.1.eval(color[1])
        color[2] = B.2.eval(color[2])
        
        color *= matrix
        
        color[0] = M.0.eval(color[0])
        color[1] = M.1.eval(color[1])
        color[2] = M.2.eval(color[2])
        
        result = lut.eval(color)
        
        return result
    }
}
