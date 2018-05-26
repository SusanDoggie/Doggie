//
//  Data.swift
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

extension Data : ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: UInt8 ...) {
        self.init(elements)
    }
}

extension Data {
    
    public static func fileBacked(_ buffer: UnsafeRawBufferPointer) -> Data {
        
        guard let bytes = buffer.baseAddress, buffer.count != 0 else { return Data() }
        
        var fd: Int32 = 0
        var path = ""
        
        while true {
            let path_url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("com.SusanDoggie.FileBackedData.\(UUID().uuidString)")
            path = path_url.withUnsafeFileSystemRepresentation { String(cString: $0!) }
            fd = open(path, O_RDWR | O_CREAT | O_EXCL, S_IRUSR | S_IWUSR)
            guard fd == -1 && errno == EEXIST else { break }
        }
        
        guard fd != -1 else { fatalError("\(String(cString: strerror(errno))): \(path)") }
        guard flock(fd, LOCK_EX) != -1 else { fatalError(String(cString: strerror(errno))) }
        guard ftruncate(fd, off_t(buffer.count)) != -1 else { fatalError(String(cString: strerror(errno))) }
        
        let address = mmap(nil, buffer.count, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)!
        guard address != UnsafeMutableRawPointer(bitPattern: -1) else { fatalError(String(cString: strerror(errno))) }
        
        address.copyMemory(from: bytes, byteCount: buffer.count)
        
        func deallocator(address: UnsafeMutableRawPointer, mapped_size: Int) {
            munmap(address, mapped_size)
            ftruncate(fd, 0)
            flock(fd, LOCK_UN)
            close(fd)
            Foundation.remove(path)
        }
        
        return Data(bytesNoCopy: address, count: buffer.count, deallocator: .custom(deallocator))
    }
}

extension Data {
    
    public func write(to url: URL, withIntermediateDirectories createIntermediates: Bool, options: Data.WritingOptions = []) throws {
        
        let manager = FileManager.default
        
        let directory = url.deletingLastPathComponent()
        
        if !manager.fileExists(atPath: directory.path) {
            try manager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
        
        try self.write(to: url, options: options)
    }
}

