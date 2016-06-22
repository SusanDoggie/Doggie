//
//  SDStream.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

#if os(Linux)
let posix_read = Glibc.read
let posix_write = Glibc.write
#else
let posix_read = Darwin.read
let posix_write = Darwin.write
#endif

public class SDStream {
    
    private let fd: CInt
    
    public init?(path: String, option: Option = [], mode: Mode = [.ownerRead, .ownerWrite, .groupRead, .otherRead]) {
        self.fd = path.withCString { open($0, O_RDONLY | option.rawValue, mode.rawValue) }
        if fd == -1 {
            return nil
        }
    }
    
    deinit {
        close(self.fd)
    }
    
    public final func readByte() -> UInt8? {
        var byte: UInt8 = 0
        repeat {
            let size = posix_read(fd, &byte, 1)
            if size == 0 {
                return nil // EOF
            }
            if size > 0 {
                return byte
            }
        } while errno == EINTR // retry
        
        return nil // error
    }
    
    public final func writeByte(byte: UInt8) {
        var _byte = byte
        repeat {
            let size = posix_write(fd, &_byte, 1)
            if size > 0 {
                return
            }
        } while errno == EINTR // retry
    }
    
    public final func seek(offset: Int, option: Origin) -> Int {
        return Int(lseek(fd, off_t(offset), option.rawValue))
    }
}

extension SDStream {
    
    public final func wait() {
        var _pollfd = pollfd(fd: self.fd, events: Int16(POLLIN | POLLOUT), revents: 0)
        repeat {
            let ready = poll(&_pollfd, 1, -1)
            if ready >= 0 {
                return
            }
        } while errno == EINTR // retry
    }
    
    public final func wait(time: Double) -> Bool {
        var _pollfd = pollfd(fd: self.fd, events: Int16(POLLIN | POLLOUT), revents: 0)
        repeat {
            let ready = poll(&_pollfd, 1, Int32(time * 1000))
            if ready >= 0 {
                return ready > 0
            }
        } while errno == EINTR // retry
        
        return false
    }
}

extension SDStream : Streamable {
    
    public final func write<Target : OutputStream>(to target: inout Target) {
        while let byte = readByte() {
            UnicodeScalar(byte).write(to: &target)
        }
    }
}

extension SDStream : OutputStream {
    
    public final func write(_ string: String) {
        string.withCString {
            var chars = $0
            while chars.pointee != 0 {
                writeByte(byte: UInt8(bitPattern: chars.pointee))
                chars += 1
            }
        }
    }
}

extension SDStream {
    
    public enum Origin {
        case begin
        case current
        case end
    }
}

private extension SDStream.Origin {
    
    var rawValue: Int32 {
        switch self {
        case .begin: return SEEK_SET
        case .current: return SEEK_CUR
        case .end: return SEEK_END
        }
    }
}

extension SDStream {
    
    public struct Option : OptionSet {
        
        public var rawValue: Int32
        
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        public static var write: Option {
            return Option(rawValue: O_WRONLY)
        }
        public static var create: Option {
            return Option(rawValue: O_CREAT)
        }
        public static var truncate: Option {
            return Option(rawValue: O_TRUNC)
        }
    }
}

extension SDStream {
    
    public struct Mode : OptionSet {
        
        public var rawValue: UInt16
        
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        
        public static var ownerRead: Mode {
            return Mode(rawValue: S_IRUSR)
        }
        public static var ownerWrite: Mode {
            return Mode(rawValue: S_IWUSR)
        }
        public static var ownerExecute: Mode {
            return Mode(rawValue: S_IXUSR)
        }
        public static var groupRead: Mode {
            return Mode(rawValue: S_IRGRP)
        }
        public static var groupWrite: Mode {
            return Mode(rawValue: S_IWGRP)
        }
        public static var groupExecute: Mode {
            return Mode(rawValue: S_IXGRP)
        }
        public static var otherRead: Mode {
            return Mode(rawValue: S_IROTH)
        }
        public static var otherWrite: Mode {
            return Mode(rawValue: S_IWOTH)
        }
        public static var otherExecute: Mode {
            return Mode(rawValue: S_IXOTH)
        }
    }
    
}
