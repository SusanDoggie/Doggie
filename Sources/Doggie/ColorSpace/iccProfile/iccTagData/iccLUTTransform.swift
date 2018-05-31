//
//  iccLUTTransform.swift
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
@_inlineable
func _interpolate_index(_ x: Double, _ count: Int) -> (Int, Double) {
    var _i = 0.0
    let _count = count - 1
    let m = modf(x * Double(_count), &_i)
    let i = Int(_i)
    switch i {
    case ..<0: return (0, 0)
    case _count...: return (_count, 0)
    default: return (i, m)
    }
}

@_versioned
@_inlineable
func interpolate<C : RandomAccessCollection>(_ x: Double, table: C) -> Double where C.Index == Int, C.Element == Double {
    
    let (i, m) = _interpolate_index(x, table.count)
    
    let offset = table.startIndex
    
    if i == table.count - 1 {
        return table[offset + i]
    } else {
        let a = (1 - m) * table[offset + i]
        let b = m * table[offset + i + 1]
        return a + b
    }
}

@_versioned
@_fixed_layout
enum iccLUTTransform {
    
    case LUT0(iccLUT0Transform)
    case LUT1(iccLUT1Transform)
    case LUT2(iccLUT2Transform)
    case LUT3(iccLUT3Transform)
    case LUT4(iccLUT4Transform)
}

extension iccLUTTransform : ByteDecodable {
    
    init(from data: inout Data) throws {
        
        let _data = data
        
        guard data.count > 8 else { throw AnyColorSpace.ICCError.endOfData }
        
        let type = try data.decode(iccProfile.TagType.self)
        
        data.removeFirst(4)
        
        switch type {
        case "mft1":
            
            let header = try data.decode(Lut8.self)
            
            var inputTable = [Double]()
            var clutTable = [Double]()
            var outputTable = [Double]()
            
            inputTable.reserveCapacity(header.inputTableSize)
            clutTable.reserveCapacity(header.clutTableSize)
            outputTable.reserveCapacity(header.outputTableSize)
            
            for _ in 0..<header.inputTableSize {
                inputTable.append(Double(try data.decode(UInt8.self)) / 255)
            }
            for _ in 0..<header.clutTableSize {
                clutTable.append(Double(try data.decode(UInt8.self)) / 255)
            }
            for _ in 0..<header.outputTableSize {
                outputTable.append(Double(try data.decode(UInt8.self)) / 255)
            }
            
            let input = OneDimensionalLUT(channels: Int(header.inputChannels), grid: 256, table: inputTable)
            let clut = MultiDimensionalLUT(inputChannels: Int(header.inputChannels), outputChannels: Int(header.outputChannels), grids: Array(repeating: Int(header.grids), count: Int(header.inputChannels)), table: clutTable)
            let output = OneDimensionalLUT(channels: Int(header.outputChannels), grid: 256, table: outputTable)
            
            self = .LUT0(iccLUT0Transform(matrix: header.matrix.matrix, input: input, clut: clut, output: output))
            
        case "mft2":
            
            let header = try data.decode(Lut16.self)
            
            var inputTable = [Double]()
            var clutTable = [Double]()
            var outputTable = [Double]()
            
            inputTable.reserveCapacity(header.inputTableSize)
            clutTable.reserveCapacity(header.clutTableSize)
            outputTable.reserveCapacity(header.outputTableSize)
            
            for _ in 0..<header.inputTableSize {
                inputTable.append(Double(try data.decode(BEUInt16.self).representingValue) / 65535)
            }
            for _ in 0..<header.clutTableSize {
                clutTable.append(Double(try data.decode(BEUInt16.self).representingValue) / 65535)
            }
            for _ in 0..<header.outputTableSize {
                outputTable.append(Double(try data.decode(BEUInt16.self).representingValue) / 65535)
            }
            
            let input = OneDimensionalLUT(channels: Int(header.inputChannels), grid: Int(header.inputEntries), table: inputTable)
            let clut = MultiDimensionalLUT(inputChannels: Int(header.inputChannels), outputChannels: Int(header.outputChannels), grids: Array(repeating: Int(header.grids), count: Int(header.inputChannels)), table: clutTable)
            let output = OneDimensionalLUT(channels: Int(header.outputChannels), grid: Int(header.outputEntries), table: outputTable)
            
            self = .LUT0(iccLUT0Transform(matrix: header.matrix.matrix, input: input, clut: clut, output: output))
            
        case "mAB ":
            
            let header = try data.decode(LutAtoB.self)
            
            var type: Int = 0
            
            if header.offsetM != 0 && header.offsetMatrix != 0 { type += 1 }
            if header.offsetA != 0 && header.offsetCLUT != 0 { type += 2 }
            
            guard header.outputChannels == 3 else { throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid lutA2B.") }
            
            var dataB = _data.dropFirst(Int(header.offsetB))
            let B = try iccLUTTransform.readCurves(&dataB, count: 3)
            
            switch type {
                
            case 0:
                
                self = .LUT1(iccLUT1Transform(curve: (B[0], B[1], B[2])))
                
            case 1:
                
                var dataM = _data.dropFirst(Int(header.offsetM))
                var dataMatrix = _data.dropFirst(Int(header.offsetMatrix))
                
                let M = try iccLUTTransform.readCurves(&dataM, count: 3)
                let matrix = try dataMatrix.decode(iccMatrix3x4.self)
                
                self = .LUT2(iccLUT2Transform(B: (B[0], B[1], B[2]), matrix: matrix.matrix, M: (M[0], M[1], M[2])))
                
            case 2:
                
                var dataA = _data.dropFirst(Int(header.offsetA))
                var dataCLUT = _data.dropFirst(Int(header.offsetCLUT))
                
                let A = try iccLUTTransform.readCurves(&dataA, count: Int(header.inputChannels))
                let CLUT = try iccLUTTransform.readCLUT(&dataCLUT, inputChannels: Int(header.inputChannels), outputChannels: 3)
                
                self = .LUT3(iccLUT3Transform(B: (B[0], B[1], B[2]), lut: CLUT, A: A))
                
            case 3:
                
                var dataA = _data.dropFirst(Int(header.offsetA))
                var dataCLUT = _data.dropFirst(Int(header.offsetCLUT))
                var dataM = _data.dropFirst(Int(header.offsetM))
                var dataMatrix = _data.dropFirst(Int(header.offsetMatrix))
                
                let A = try iccLUTTransform.readCurves(&dataA, count: Int(header.inputChannels))
                let CLUT = try iccLUTTransform.readCLUT(&dataCLUT, inputChannels: Int(header.inputChannels), outputChannels: 3)
                let M = try iccLUTTransform.readCurves(&dataM, count: 3)
                let matrix = try dataMatrix.decode(iccMatrix3x4.self)
                
                self = .LUT4(iccLUT4Transform(B: (B[0], B[1], B[2]), matrix: matrix.matrix, M: (M[0], M[1], M[2]), lut: CLUT, A: A))
                
            default: throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid lutA2B.")
            }
            
        case "mBA ":
            
            let header = try data.decode(LutBtoA.self)
            
            var type: Int = 0
            
            if header.offsetM != 0 && header.offsetMatrix != 0 { type += 1 }
            if header.offsetA != 0 && header.offsetCLUT != 0 { type += 2 }
            
            guard header.inputChannels == 3 else { throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid lutB2A.") }
            
            var dataB = _data.dropFirst(Int(header.offsetB))
            let B = try iccLUTTransform.readCurves(&dataB, count: 3)
            
            switch type {
                
            case 0:
                
                self = .LUT1(iccLUT1Transform(curve: (B[0], B[1], B[2])))
                
            case 1:
                
                var dataM = _data.dropFirst(Int(header.offsetM))
                var dataMatrix = _data.dropFirst(Int(header.offsetMatrix))
                
                let M = try iccLUTTransform.readCurves(&dataM, count: 3)
                let matrix = try dataMatrix.decode(iccMatrix3x4.self)
                
                self = .LUT2(iccLUT2Transform(B: (B[0], B[1], B[2]), matrix: matrix.matrix, M: (M[0], M[1], M[2])))
                
            case 2:
                
                var dataA = _data.dropFirst(Int(header.offsetA))
                var dataCLUT = _data.dropFirst(Int(header.offsetCLUT))
                
                let A = try iccLUTTransform.readCurves(&dataA, count: Int(header.outputChannels))
                let CLUT = try iccLUTTransform.readCLUT(&dataCLUT, inputChannels: Int(header.outputChannels), outputChannels: 3)
                
                self = .LUT3(iccLUT3Transform(B: (B[0], B[1], B[2]), lut: CLUT, A: A))
                
            case 3:
                
                var dataA = _data.dropFirst(Int(header.offsetA))
                var dataCLUT = _data.dropFirst(Int(header.offsetCLUT))
                var dataM = _data.dropFirst(Int(header.offsetM))
                var dataMatrix = _data.dropFirst(Int(header.offsetMatrix))
                
                let A = try iccLUTTransform.readCurves(&dataA, count: Int(header.outputChannels))
                let CLUT = try iccLUTTransform.readCLUT(&dataCLUT, inputChannels: Int(header.outputChannels), outputChannels: 3)
                let M = try iccLUTTransform.readCurves(&dataM, count: 3)
                let matrix = try dataMatrix.decode(iccMatrix3x4.self)
                
                self = .LUT4(iccLUT4Transform(B: (B[0], B[1], B[2]), matrix: matrix.matrix, M: (M[0], M[1], M[2]), lut: CLUT, A: A))
                
            default: throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid lutB2A.")
            }
            
        default: throw AnyColorSpace.ICCError.invalidFormat(message: "Unknown transform type.")
        }
    }
    
    static func readCurves(_ data: inout Data, count: Int) throws -> [iccCurve] {
        
        var result: [iccCurve] = []
        for _ in 0..<count {
            let record = data.count
            result.append(try data.decode(iccCurve.self))
            let size = record - data.count
            data = data.dropFirst(size.align(4) - size)
        }
        return result
    }
    
    static func readCLUT(_ data: inout Data, inputChannels: Int, outputChannels: Int) throws -> MultiDimensionalLUT {
        
        var header = try data.decode(iccCLUT.self)
        
        let grids = withUnsafeBytes(of: &header.grids) { $0.prefix(inputChannels).map(Int.init) }
        
        let count = grids.reduce(outputChannels, *)
        
        var table = [Double]()
        table.reserveCapacity(count)
        
        switch header.precision {
        case 1:
            for _ in 0..<count {
                table.append(Double(try data.decode(UInt8.self)) / 255)
            }
        case 2:
            for _ in 0..<count {
                table.append(Double(try data.decode(BEUInt16.self).representingValue) / 65535)
            }
        default: throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid clut precision.")
        }
        
        return MultiDimensionalLUT(inputChannels: inputChannels, outputChannels: outputChannels, grids: grids, table: table)
    }
    
    struct iccCLUT : ByteCodable {
        
        var grids: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8)
        var precision: UInt8
        var pad1: UInt8
        var pad2: UInt8
        var pad3: UInt8
        
        init(from data: inout Data) throws {
            self.grids = (try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                          try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                          try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self),
                          try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self), try data.decode(UInt8.self))
            self.precision = try data.decode(UInt8.self)
            self.pad1 = try data.decode(UInt8.self)
            self.pad2 = try data.decode(UInt8.self)
            self.pad3 = try data.decode(UInt8.self)
        }
        
        func encode(to stream: inout ByteOutputStream) {
            stream.write(grids.0, grids.1, grids.2, grids.3,
                        grids.4, grids.5, grids.6, grids.7,
                        grids.8, grids.9, grids.10, grids.11,
                        grids.12, grids.13, grids.14, grids.15)
            stream.write(precision)
            stream.write(pad1)
            stream.write(pad2)
            stream.write(pad3)
        }
    }
}

extension iccLUTTransform {
    
    struct Lut8 : ByteCodable {
        
        var inputChannels: UInt8
        var outputChannels: UInt8
        var grids: UInt8
        var padding: UInt8
        var matrix: iccMatrix3x3
        
        init(from data: inout Data) throws {
            self.inputChannels = try data.decode(UInt8.self)
            self.outputChannels = try data.decode(UInt8.self)
            self.grids = try data.decode(UInt8.self)
            self.padding = try data.decode(UInt8.self)
            self.matrix = try data.decode(iccMatrix3x3.self)
        }
        
        func encode(to stream: inout ByteOutputStream) {
            stream.write(inputChannels)
            stream.write(outputChannels)
            stream.write(grids)
            stream.write(padding)
            stream.write(matrix)
        }
        
        var inputTableSize: Int {
            return 256 * Int(inputChannels)
        }
        var outputTableSize: Int {
            return 256 * Int(outputChannels)
        }
        var clutTableSize: Int {
            return Int(pow(UInt(grids), UInt(inputChannels))) * Int(outputChannels)
        }
    }
    
    struct Lut16 : ByteCodable {
        
        var inputChannels: UInt8
        var outputChannels: UInt8
        var grids: UInt8
        var padding: UInt8
        var matrix: iccMatrix3x3
        var inputEntries: BEUInt16
        var outputEntries: BEUInt16
        
        init(from data: inout Data) throws {
            self.inputChannels = try data.decode(UInt8.self)
            self.outputChannels = try data.decode(UInt8.self)
            self.grids = try data.decode(UInt8.self)
            self.padding = try data.decode(UInt8.self)
            self.matrix = try data.decode(iccMatrix3x3.self)
            self.inputEntries = try data.decode(BEUInt16.self)
            self.outputEntries = try data.decode(BEUInt16.self)
        }
        
        func encode(to stream: inout ByteOutputStream) {
            stream.write(inputChannels)
            stream.write(outputChannels)
            stream.write(grids)
            stream.write(padding)
            stream.write(matrix)
            stream.write(inputEntries)
            stream.write(outputEntries)
        }
        
        var inputTableSize: Int {
            return Int(inputEntries) * Int(inputChannels)
        }
        var clutTableSize: Int {
            return Int(pow(UInt(grids), UInt(inputChannels))) * Int(outputChannels)
        }
        var outputTableSize: Int {
            return Int(outputEntries) * Int(outputChannels)
        }
        
    }
    
    struct LutAtoB : ByteCodable {
        
        var inputChannels: UInt8
        var outputChannels: UInt8
        var padding1: UInt8
        var padding2: UInt8
        var offsetB: BEUInt32
        var offsetMatrix: BEUInt32
        var offsetM: BEUInt32
        var offsetCLUT: BEUInt32
        var offsetA: BEUInt32
        
        init(inputChannels: UInt8, outputChannels: UInt8, offsetB: BEUInt32, offsetMatrix: BEUInt32, offsetM: BEUInt32, offsetCLUT: BEUInt32, offsetA: BEUInt32) {
            self.inputChannels = inputChannels
            self.outputChannels = outputChannels
            self.padding1 = 0
            self.padding2 = 0
            self.offsetB = offsetB
            self.offsetMatrix = offsetMatrix
            self.offsetM = offsetM
            self.offsetCLUT = offsetCLUT
            self.offsetA = offsetA
        }
        
        init(from data: inout Data) throws {
            self.inputChannels = try data.decode(UInt8.self)
            self.outputChannels = try data.decode(UInt8.self)
            self.padding1 = try data.decode(UInt8.self)
            self.padding2 = try data.decode(UInt8.self)
            self.offsetB = try data.decode(BEUInt32.self)
            self.offsetMatrix = try data.decode(BEUInt32.self)
            self.offsetM = try data.decode(BEUInt32.self)
            self.offsetCLUT = try data.decode(BEUInt32.self)
            self.offsetA = try data.decode(BEUInt32.self)
        }
        
        func encode(to stream: inout ByteOutputStream) {
            stream.write(inputChannels)
            stream.write(outputChannels)
            stream.write(padding1)
            stream.write(padding2)
            stream.write(offsetB)
            stream.write(offsetMatrix)
            stream.write(offsetM)
            stream.write(offsetCLUT)
            stream.write(offsetA)
        }
    }
    
    struct LutBtoA : ByteCodable {
        
        var inputChannels: UInt8
        var outputChannels: UInt8
        var padding1: UInt8
        var padding2: UInt8
        var offsetB: BEUInt32
        var offsetMatrix: BEUInt32
        var offsetM: BEUInt32
        var offsetCLUT: BEUInt32
        var offsetA: BEUInt32
        
        init(inputChannels: UInt8, outputChannels: UInt8, offsetB: BEUInt32, offsetMatrix: BEUInt32, offsetM: BEUInt32, offsetCLUT: BEUInt32, offsetA: BEUInt32) {
            self.inputChannels = inputChannels
            self.outputChannels = outputChannels
            self.padding1 = 0
            self.padding2 = 0
            self.offsetB = offsetB
            self.offsetMatrix = offsetMatrix
            self.offsetM = offsetM
            self.offsetCLUT = offsetCLUT
            self.offsetA = offsetA
        }
        
        init(from data: inout Data) throws {
            self.inputChannels = try data.decode(UInt8.self)
            self.outputChannels = try data.decode(UInt8.self)
            self.padding1 = try data.decode(UInt8.self)
            self.padding2 = try data.decode(UInt8.self)
            self.offsetB = try data.decode(BEUInt32.self)
            self.offsetMatrix = try data.decode(BEUInt32.self)
            self.offsetM = try data.decode(BEUInt32.self)
            self.offsetCLUT = try data.decode(BEUInt32.self)
            self.offsetA = try data.decode(BEUInt32.self)
        }
        
        func encode(to stream: inout ByteOutputStream) {
            stream.write(inputChannels)
            stream.write(outputChannels)
            stream.write(padding1)
            stream.write(padding2)
            stream.write(offsetB)
            stream.write(offsetMatrix)
            stream.write(offsetM)
            stream.write(offsetCLUT)
            stream.write(offsetA)
        }
    }
}

@_versioned
@_fixed_layout
struct OneDimensionalLUT {
    
    @_versioned
    let channels: Int
    
    @_versioned
    let grid: Int
    
    @_versioned
    let table: [Double]
    
    init(channels: Int, grid: Int, table: [Double]) {
        self.channels = channels
        self.grid = grid
        self.table = table
    }
    
    @_versioned
    @_inlineable
    func eval<Model: ColorModelProtocol>(_ color: Model) -> Model {
        
        precondition(Model.numberOfComponents == channels)
        
        var result = Model()
        
        table.withUnsafeBufferPointer { table in
            
            for i in 0..<Model.numberOfComponents {
                let offset = grid * i
                result[i] = interpolate(color[i], table: table[offset..<offset + grid])
            }
        }
        
        return result
    }
}

@_versioned
@_fixed_layout
struct MultiDimensionalLUT {
    
    @_versioned
    let inputChannels: Int
    
    @_versioned
    let outputChannels: Int
    
    @_versioned
    let grids: [Int]
    
    @_versioned
    let table: [Double]
    
    init(inputChannels: Int, outputChannels: Int, grids: [Int], table: [Double]) {
        self.inputChannels = inputChannels
        self.outputChannels = outputChannels
        self.grids = grids
        self.table = table
    }
    
    @_versioned
    @_inlineable
    func eval<Source: ColorModelProtocol, Destination: ColorModelProtocol>(_ source: Source) -> Destination {
        
        return table.withUnsafeBufferPointer { table in
            
            func _interpolate(level: Int, offset: Int) -> Destination {
                
                let _i = Source.numberOfComponents - level - 1
                let _p = _interpolate_index(source[_i], grids[_i])
                let _s = level == 0 ? Destination.numberOfComponents : grids[level - 1]
                
                if _p.1 == 0 || _p.0 == grids[level] - 1 {
                    
                    var r = Destination()
                    
                    let offset = (offset + _p.0) * _s
                    
                    if level == 0 {
                        for i in 0..<Destination.numberOfComponents {
                            r[i] = table[offset + i]
                        }
                    } else {
                        let _level = level - 1
                        r = _interpolate(level: _level, offset: offset)
                    }
                    
                    return r
                    
                } else {
                    
                    var a = Destination()
                    var b = Destination()
                    
                    let offset1 = (offset + _p.0) * _s
                    let offset2 = offset1 + _s
                    
                    if level == 0 {
                        for i in 0..<Destination.numberOfComponents {
                            a[i] = table[offset1 + i]
                            b[i] = table[offset2 + i]
                        }
                    } else {
                        let _level = level - 1
                        a = _interpolate(level: _level, offset: offset1)
                        b = _interpolate(level: _level, offset: offset2)
                    }
                    
                    return (1 - _p.1) * a + _p.1 * b
                }
            }
            
            return _interpolate(level: Source.numberOfComponents - 1, offset: 0)
        }
        
    }
}
