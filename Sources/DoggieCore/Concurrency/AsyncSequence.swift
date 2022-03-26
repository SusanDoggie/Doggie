//
//  AsyncSequence.swift
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

#if compiler(>=5.5.2) && canImport(_Concurrency)

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension AsyncSequence {
    
    @inlinable
    public func parallelEach(
        _ callback: @escaping (Element) async throws -> Void
    ) async rethrows {
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            
            for try await item in self {
                group.addTask { try await callback(item) }
            }
        }
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension AsyncSequence {
    
    @inlinable
    public func parallelMap<ElementOfResult>(
        _ transform: @escaping (Element) async -> ElementOfResult
    ) async rethrows -> [ElementOfResult] {
        
        let group = self.map { element in Task { await transform(element) } }
        
        var result: [ElementOfResult] = []
        
        for try await task in group {
            await result.append(task.value)
        }
        
        return result
    }
    
    @inlinable
    public func parallelMap<ElementOfResult>(
        _ transform: @escaping (Element) async throws -> ElementOfResult
    ) async throws -> [ElementOfResult] {
        
        let group = self.map { element in Task { try await transform(element) } }
        
        var result: [ElementOfResult] = []
        
        for try await task in group {
            try await result.append(task.value)
        }
        
        return result
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension AsyncSequence {
    
    @inlinable
    public func parallelCompactMap<ElementOfResult>(
        _ transform: @escaping (Element) async -> ElementOfResult?
    ) async rethrows -> [ElementOfResult] {
        
        let group = self.map { element in Task { await transform(element) } }
        
        var result: [ElementOfResult] = []
        
        for try await task in group {
            if let value = await task.value {
                result.append(value)
            }
        }
        
        return result
    }
    
    @inlinable
    public func parallelCompactMap<ElementOfResult>(
        _ transform: @escaping (Element) async throws -> ElementOfResult?
    ) async throws -> [ElementOfResult] {
        
        let group = self.map { element in Task { try await transform(element) } }
        
        var result: [ElementOfResult] = []
        
        for try await task in group {
            if let value = try await task.value {
                result.append(value)
            }
        }
        
        return result
    }
}

#endif
