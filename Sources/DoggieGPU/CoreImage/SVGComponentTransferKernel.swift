//
//  SVGComponentTransferKernel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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

#if canImport(CoreImage)

extension CIImage {
    
    private class SVGComponentTransferKernel: CIImageProcessorKernel {
        
        enum TransferFunctionType: String, CaseIterable {
            
            case identity
            case table
            case discrete
            case gamma
        }
        
        static let function_constants: [String: MTLFunctionConstantValues] = {
            
            var function_constants: [String: MTLFunctionConstantValues] = [:]
            
            for alpha in TransferFunctionType.allCases {
                
                for blue in TransferFunctionType.allCases {
                    
                    for green in TransferFunctionType.allCases {
                        
                        for red in TransferFunctionType.allCases {
                            
                            let constants = MTLFunctionConstantValues()
                            
                            withUnsafeBytes(of: red == .table || red == .discrete) { constants.setConstantValue($0.baseAddress!, type: .bool, withName: "has_red_channel_table") }
                            withUnsafeBytes(of: red == .discrete) { constants.setConstantValue($0.baseAddress!, type: .bool, withName: "is_red_channel_discrete") }
                            withUnsafeBytes(of: red == .gamma) { constants.setConstantValue($0.baseAddress!, type: .bool, withName: "has_red_channel_gamma") }
                            
                            withUnsafeBytes(of: green == .table || green == .discrete) { constants.setConstantValue($0.baseAddress!, type: .bool, withName: "has_green_channel_table") }
                            withUnsafeBytes(of: green == .discrete) { constants.setConstantValue($0.baseAddress!, type: .bool, withName: "is_green_channel_discrete") }
                            withUnsafeBytes(of: green == .gamma) { constants.setConstantValue($0.baseAddress!, type: .bool, withName: "has_green_channel_gamma") }
                            
                            withUnsafeBytes(of: blue == .table || blue == .discrete) { constants.setConstantValue($0.baseAddress!, type: .bool, withName: "has_blue_channel_table") }
                            withUnsafeBytes(of: blue == .discrete) { constants.setConstantValue($0.baseAddress!, type: .bool, withName: "is_blue_channel_discrete") }
                            withUnsafeBytes(of: blue == .gamma) { constants.setConstantValue($0.baseAddress!, type: .bool, withName: "has_blue_channel_gamma") }
                            
                            withUnsafeBytes(of: alpha == .table || alpha == .discrete) { constants.setConstantValue($0.baseAddress!, type: .bool, withName: "has_alpha_channel_table") }
                            withUnsafeBytes(of: alpha == .discrete) { constants.setConstantValue($0.baseAddress!, type: .bool, withName: "is_alpha_channel_discrete") }
                            withUnsafeBytes(of: alpha == .gamma) { constants.setConstantValue($0.baseAddress!, type: .bool, withName: "has_alpha_channel_gamma") }
                            
                            function_constants["_\(red.rawValue)_\(green.rawValue)_\(blue.rawValue)_\(alpha.rawValue)"] = constants
                        }
                    }
                }
            }
            
            return function_constants
        }()
        
        override class var synchronizeInputs: Bool {
            return false
        }
        
        override class func process(with inputs: [CIImageProcessorInput]?, arguments: [String: Any]?, output: CIImageProcessorOutput) throws {
            
            guard let commandBuffer = output.metalCommandBuffer else { return }
            guard let source = inputs?[0].metalTexture else { return }
            guard let output_texture = output.metalTexture else { return }
            guard let red = arguments?["red"] as? SVGComponentTransferEffect.TransferFunction else { return }
            guard let green = arguments?["green"] as? SVGComponentTransferEffect.TransferFunction else { return }
            guard let blue = arguments?["blue"] as? SVGComponentTransferEffect.TransferFunction else { return }
            guard let alpha = arguments?["alpha"] as? SVGComponentTransferEffect.TransferFunction else { return }
            
            let _red: String
            switch red {
            case .identity: _red = "_identity"
            case .table: _red = "_table"
            case .discrete: _red = "_discrete"
            case .gamma: _red = "_gamma"
            }
            
            let _green: String
            switch green {
            case .identity: _green = "_identity"
            case .table: _green = "_table"
            case .discrete: _green = "_discrete"
            case .gamma: _green = "_gamma"
            }
            
            let _blue: String
            switch blue {
            case .identity: _blue = "_identity"
            case .table: _blue = "_table"
            case .discrete: _blue = "_discrete"
            case .gamma: _blue = "_gamma"
            }
            
            let _alpha: String
            switch alpha {
            case .identity: _alpha = "_identity"
            case .table: _alpha = "_table"
            case .discrete: _alpha = "_discrete"
            case .gamma: _alpha = "_gamma"
            }
            
            guard let function_constant = function_constants["\(_red)\(_green)\(_blue)\(_alpha)"] else { return }
            guard let pipeline = self.make_pipeline(commandBuffer.device, "svg_component_transfer", function_constant) else { return }
            
            guard let encoder = commandBuffer.makeComputeCommandEncoder() else { return }
            
            encoder.setComputePipelineState(pipeline)
            
            encoder.setTexture(source, index: 0)
            encoder.setTexture(output_texture , index: 1)
            
            switch red {
            case .identity: break
            case let .table(table):
                withUnsafeBytes(of: Int32(table.count)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 2) }
                table.map { Float($0) }.withUnsafeBytes { encoder.setBytes($0.baseAddress!, length: $0.count, index: 6) }
            case let .discrete(table):
                withUnsafeBytes(of: Int32(table.count)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 2) }
                table.map { Float($0) }.withUnsafeBytes { encoder.setBytes($0.baseAddress!, length: $0.count, index: 6) }
            case let .gamma(amplitude, exponent, offset):
                withUnsafeBytes(of: (Float(amplitude), Float(exponent), Float(offset))) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 2) }
            }
            
            switch green {
            case .identity: break
            case let .table(table):
                withUnsafeBytes(of: Int32(table.count)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 3) }
                table.map { Float($0) }.withUnsafeBytes { encoder.setBytes($0.baseAddress!, length: $0.count, index: 7) }
            case let .discrete(table):
                withUnsafeBytes(of: Int32(table.count)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 3) }
                table.map { Float($0) }.withUnsafeBytes { encoder.setBytes($0.baseAddress!, length: $0.count, index: 7) }
            case let .gamma(amplitude, exponent, offset):
                withUnsafeBytes(of: (Float(amplitude), Float(exponent), Float(offset))) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 3) }
            }
            
            switch blue {
            case .identity: break
            case let .table(table):
                withUnsafeBytes(of: Int32(table.count)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 4) }
                table.map { Float($0) }.withUnsafeBytes { encoder.setBytes($0.baseAddress!, length: $0.count, index: 8) }
            case let .discrete(table):
                withUnsafeBytes(of: Int32(table.count)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 4) }
                table.map { Float($0) }.withUnsafeBytes { encoder.setBytes($0.baseAddress!, length: $0.count, index: 8) }
            case let .gamma(amplitude, exponent, offset):
                withUnsafeBytes(of: (Float(amplitude), Float(exponent), Float(offset))) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 4) }
            }
            
            switch alpha {
            case .identity: break
            case let .table(table):
                withUnsafeBytes(of: Int32(table.count)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 5) }
                table.map { Float($0) }.withUnsafeBytes { encoder.setBytes($0.baseAddress!, length: $0.count, index: 9) }
            case let .discrete(table):
                withUnsafeBytes(of: Int32(table.count)) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 5) }
                table.map { Float($0) }.withUnsafeBytes { encoder.setBytes($0.baseAddress!, length: $0.count, index: 9) }
            case let .gamma(amplitude, exponent, offset):
                withUnsafeBytes(of: (Float(amplitude), Float(exponent), Float(offset))) { encoder.setBytes($0.baseAddress!, length: $0.count, index: 5) }
            }
            
            let group_width = max(1, pipeline.threadExecutionWidth)
            let group_height = max(1, pipeline.maxTotalThreadsPerThreadgroup / group_width)
            
            let threadsPerThreadgroup = MTLSize(width: group_width, height: group_height, depth: 1)
            let threadgroupsPerGrid = MTLSize(width: (output_texture.width + group_width - 1) / group_width, height: (output_texture.height + group_height - 1) / group_height, depth: 1)
            
            encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
            encoder.endEncoding()
        }
    }
    
    public func componentTransfer(red: SVGComponentTransferEffect.TransferFunction,
                                green: SVGComponentTransferEffect.TransferFunction,
                                blue: SVGComponentTransferEffect.TransferFunction,
                                alpha: SVGComponentTransferEffect.TransferFunction) -> CIImage {
        
        if extent.isEmpty { return .empty() }
        
        if red == .identity && green == .identity && blue == .identity && alpha == .identity {
            return self
        }
        
        switch red {
        case let .table(table): guard !table.isEmpty else  { return .empty() }
        case let .discrete(table): guard !table.isEmpty else  { return .empty() }
        default: break
        }
        
        switch green {
        case let .table(table): guard !table.isEmpty else  { return .empty() }
        case let .discrete(table): guard !table.isEmpty else  { return .empty() }
        default: break
        }
        
        switch blue {
        case let .table(table): guard !table.isEmpty else  { return .empty() }
        case let .discrete(table): guard !table.isEmpty else  { return .empty() }
        default: break
        }
        
        switch alpha {
        case let .table(table): guard !table.isEmpty else  { return .empty() }
        case let .discrete(table): guard !table.isEmpty else  { return .empty() }
        default: break
        }
        
        let _extent = extent.isInfinite ? extent : extent.insetBy(dx: .random(in: -0.4..<0), dy: .random(in: -0.4..<0))
        
        var rendered = try? SVGComponentTransferKernel.apply(withExtent: _extent, inputs: [self.unpremultiplyingAlpha()], arguments: ["red": red, "green": green, "blue": blue, "alpha": alpha]).premultiplyingAlpha()
        
        if !extent.isInfinite {
            rendered = rendered?.cropped(to: extent)
        }
        
        return rendered ?? .empty()
    }
}

#endif
