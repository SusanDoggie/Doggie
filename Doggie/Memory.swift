//
//  Memory.swift
//
//  The MIT License
//  Copyright (c) 2015 Susan Cheng. All rights reserved.
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

import Foundation

public let PAGESIZE = sysconf(_SC_PAGESIZE)
public let PAGEMASK = PAGESIZE - 1

public func align(x: Int) -> Int {
    return x.align(PAGESIZE)
}

public func vm_page_align(x: vm_size_t) -> vm_size_t {
    return (x + vm_page_mask) & ~vm_page_mask
}

private func lastErr() -> String? {
    let errorCode = errno
    return String.fromCString(strerror(errorCode))
}

private func lastErr(domain: String, reason: String) -> NSError {
    let errorCode = errno
    if let errorText = String.fromCString(strerror(errorCode)) {
        return NSError(domain: domain, code: Int(errorCode), userInfo: [NSLocalizedFailureReasonErrorKey : reason, NSLocalizedDescriptionKey : errorText])
    }
    return NSError(domain: domain, code: Int(errorCode), userInfo: nil)
}

public class SDFile {
    
    private let path: String
    private let fd: Int32
    private let lck = SDLock()
    private let cond = SDCondition()
    
    private var lock_table: [HalfOpenInterval<Int64>] = []
    
    private init(path: String, descriptor: Int32) {
        self.path = path
        self.fd = descriptor
    }
    
    public init(path: String, mode: Mode) throws {
        self.path = path
        self.fd = open(path, O_RDWR, mode.rawValue)
        if fd == -1 {
            throw lastErr("SDFile", reason: "open call failed.")
        }
    }
    
    public static func create(path path: String, size: Int, mode: Mode) throws -> SDFile {
        let fd = open(path, O_CREAT | O_EXCL | O_RDWR, mode.rawValue)
        if fd == -1 {
            throw lastErr("SDFile.create", reason: "open call failed.")
        }
        ftruncate(fd, Int64(size))
        return SDFile(path: path, descriptor: fd)
    }
    
    deinit {
        if fd != -1 {
            close(fd)
        }
    }
}

extension SDFile {
    
    public struct Mode : OptionSetType {
        
        public var rawValue: UInt16
        
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        
        public static var OwnerRead: Mode {
            return Mode(rawValue: S_IRUSR)
        }
        public static var OwnerWrite: Mode {
            return Mode(rawValue: S_IWUSR)
        }
        public static var OwnerExecute: Mode {
            return Mode(rawValue: S_IXUSR)
        }
        public static var GroupRead: Mode {
            return Mode(rawValue: S_IRGRP)
        }
        public static var GroupWrite: Mode {
            return Mode(rawValue: S_IWGRP)
        }
        public static var GroupExecute: Mode {
            return Mode(rawValue: S_IXGRP)
        }
        public static var OthersRead: Mode {
            return Mode(rawValue: S_IROTH)
        }
        public static var OthersWrite: Mode {
            return Mode(rawValue: S_IWOTH)
        }
        public static var OthersExecute: Mode {
            return Mode(rawValue: S_IXOTH)
        }
    }
}

extension SDFile {
    
    public var size: Int! {
        var stbuf = stat()
        if fstat(fd, &stbuf) != 0 || stbuf.st_mode & S_IFMT != S_IFREG {
            /* Handle error */
            return nil
        }
        return Int(stbuf.st_size)
    }
    
    public func truncate(size: Int) {
        ftruncate(fd, Int64(size))
    }
}

extension SDFile {
    
    public static var defaultMode: Mode {
        return [.OwnerRead, .OwnerWrite, .GroupRead, .OthersRead]
    }
    
    public convenience init(path: String) throws {
        try self.init(path: path, mode: SDFile.defaultMode)
    }
    
    public static func create(path path: String, size: Int) throws -> SDFile {
        return try create(path: path, size: size, mode: defaultMode)
    }
}

extension SDFile: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        return "SDFile(\(path))"
    }
    public var debugDescription: String {
        return "SDFile(\(path))"
    }
}

extension SDFile {
    
    public func view(offset offset: Int, size: Int) throws -> View {
        if offset + size > self.size {
            throw lastErr("SDFile.view", reason: "not enough space.")
        }
        return try View(parent: self, offset: offset, size: size)
    }
    
    public class View {
        
        private let parent: SDFile
        
        private var ptr: UnsafeMutablePointer<Void> = nil
        private let ptr_offset: Int
        private let ptr_length: Int
        private let lck_offset: Int64
        private let lck_length: Int64
        
        private init(parent: SDFile, offset: Int, size: Int) throws {
            self.parent = parent
            
            let _offset = offset & PAGEMASK
            self.ptr_length = size + _offset
            self.ptr_offset = _offset
            self.lck_offset = Int64(offset)
            self.lck_length = Int64(size)
            
            ptr = mmap(nil, ptr_length, PROT_READ | PROT_WRITE, MAP_SHARED, parent.fd, Int64(offset & ~PAGEMASK))
            if unsafeBitCast(ptr, Int.self) == -1 {
                throw lastErr("SDFile.View", reason: "shmat call failed.")
            }
        }
        
        deinit {
            if ptr != nil && unsafeBitCast(ptr, Int.self) != -1 {
                munmap(ptr, ptr_length)
            }
        }
    }
}

extension SDFile.View: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "SDFile(\(parent.path)).View(\(lck_offset)..<\(lck_offset + lck_length))"
    }
    public var debugDescription: String {
        return "SDFile(\(parent.path)).View(\(lck_offset)..<\(lck_offset + lck_length)"
    }
}

extension SDFile.View {
    
    public func synchronize() {
        if ptr != nil && unsafeBitCast(ptr, Int.self) != -1 {
            msync(ptr, ptr_length, MS_SYNC)
        }
    }
    
    public var address: UnsafeMutablePointer<Void> {
        if ptr == nil || unsafeBitCast(ptr, Int.self) == -1 {
            return nil
        }
        return UnsafeMutablePointer(UnsafeMutablePointer<Int8>(ptr) + ptr_offset)
    }
    
}

extension SDFile.View : Lockable {
    
    private var lockRange: HalfOpenInterval<Int64> {
        return HalfOpenInterval(lck_offset, lck_offset + lck_length)
    }
    
    public func lock() {
        func __trylock() -> Bool {
            if !parent.lock_table.contains({ $0.overlaps(lockRange) }) {
                lseek(parent.fd, lck_offset, SEEK_SET)
                return lockf(parent.fd, F_TLOCK, lck_length) == 0
            }
            return false
        }
        parent.lck.lock()
        while true {
            if parent.cond.wait_for(parent.lck, time: 0.0005, predicate: __trylock()) {
                parent.lock_table.append(lockRange)
                parent.lck.unlock()
                return
            }
        }
    }
    
    public func unlock() {
        parent.lck.lock()
        lseek(parent.fd, lck_offset, SEEK_SET)
        lockf(parent.fd, F_ULOCK, lck_length)
        parent.lock_table.removeAtIndex(parent.lock_table.indexOf(lockRange)!)
        parent.cond.signal()
        parent.lck.unlock()
    }
    
    public func trylock() -> Bool {
        if parent.lck.trylock() {
            if !parent.lock_table.contains({ $0.overlaps(lockRange) }) {
                lseek(parent.fd, lck_offset, SEEK_SET)
                if lockf(parent.fd, F_TLOCK, lck_length) == 0 {
                    parent.lock_table.append(lockRange)
                    parent.lck.unlock()
                    return true
                }
            }
            parent.lck.unlock()
        }
        return false
    }
    
}

// MARK: Shared Memory

public class SharedMemory {
    
    private let shmid: Int32
    private var ptr: UnsafeMutablePointer<Void> = nil
    
    private static func key(identify: Int32) -> key_t {
        return ftok(".", identify)
    }
    
    public init(identify: Int32, size: Int) throws {
        shmid = shmget(SharedMemory.key(identify), size, IPC_CREAT | IPC_R | IPC_W | IPC_M)
        if shmid == -1 {
            throw lastErr("SharedMenory", reason: "shmget call failed.")
        }
        ptr = shmat(shmid, nil, 0)
        if unsafeBitCast(ptr, Int.self) == -1 {
            throw lastErr("SharedMenory", reason: "shmat call failed.")
        }
    }
    
    public var buffer: UnsafeMutablePointer<Void> {
        if ptr == nil || unsafeBitCast(ptr, Int.self) == -1 {
            return nil
        }
        return ptr
    }
    
    public var sharedCount: UInt16 {
        if shmid != -1 {
            var _ds = __shmid_ds_new()
            shmctl(shmid, IPC_STAT, &_ds)
            return _ds.shm_nattch
        }
        return 0
    }
    
    deinit {
        if ptr != nil && unsafeBitCast(ptr, Int.self) != -1 {
            shmdt(ptr)
        }
        if sharedCount == 1 {
            shmctl(shmid, IPC_RMID, nil)
        }
    }
    
}
