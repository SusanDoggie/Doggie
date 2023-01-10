//
//  ShaderLoader.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

extension CIImageProcessorKernel {
    
    private static let lck = NSLock()
    private static var libraries: WeakDictionary<MTLDevice, MTLLibrary> = WeakDictionary()
    private static var pipelines: WeakDictionary<MTLDevice, [String: [MTLFunctionConstantValues?: MTLComputePipelineState]]> = WeakDictionary()
    
    static func make_pipeline(_ device: MTLDevice, _ name: String, _ constantValues: MTLFunctionConstantValues? = nil) -> MTLComputePipelineState? {
        
        lck.lock()
        defer { lck.unlock() }
        
        guard let library = try? libraries[device] ?? device.makeDefaultLibrary(bundle: Bundle.module) else { return nil }
        libraries[device] = library
        
        if let pipeline = pipelines[device]?[name]?[constantValues] {
            
            return pipeline
            
        } else {
            
            let function: MTLFunction
            
            if let constantValues = constantValues {
                guard let _function = try? library.makeFunction(name: name, constantValues: constantValues) else { return nil }
                function = _function
            } else {
                guard let _function = library.makeFunction(name: name) else { return nil }
                function = _function
            }
            
            guard let pipeline = try? device.makeComputePipelineState(function: function) else { return nil }
            pipelines[device, default: [:]][name, default: [:]][constantValues] = pipeline
            
            return pipeline
        }
    }
}

#endif
