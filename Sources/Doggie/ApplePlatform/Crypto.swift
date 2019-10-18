//
//  Crypto.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

#if canImport(CommonCrypto)

public struct Crypto {
    
}

extension Crypto {
    
    public enum CryptorAlgorithm : CaseIterable {
        
        case AES
        case DES
        case TripleDES
        case CAST
        case RC4
        case RC2
        case Blowfish
    }
    
    public struct CryptorOptions : OptionSet {
        
        public var rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let PKCS7Padding = CryptorOptions(rawValue: kCCOptionPKCS7Padding)
        public static let ECBMode = CryptorOptions(rawValue: kCCOptionECBMode)
    }
    
    public struct Error : Swift.Error {
        
        public var status: CCCryptorStatus
    }
    
    public static func encrypt<K : ContiguousBytes, D : ContiguousBytes>(_ algorithm: CryptorAlgorithm, _ options: CryptorOptions, _ key: K, _ data: D) throws -> Data {
        return try encrypt(algorithm, options, key, data, EmptyCollection())
    }
    
    public static func encrypt<K : ContiguousBytes, D : ContiguousBytes, I : ContiguousBytes>(_ algorithm: CryptorAlgorithm, _ options: CryptorOptions, _ key: K, _ data: D, _ iv: I) throws -> Data {
        
        return try key.withUnsafeBytes { key in try data.withUnsafeBytes { data in try iv.withUnsafeBytes { iv in
            
            var result = Data(count: data.count + algorithm.blockSize)
            var length = 0
            
            let status = result.withUnsafeMutableBytes { CCCrypt(CCOperation(kCCEncrypt), algorithm.rawValue, CCOptions(options.rawValue), key.baseAddress, key.count, iv.baseAddress, data.baseAddress, data.count, $0.baseAddress, $0.count, &length) }
            
            guard status == kCCSuccess else  { throw Error(status: status) }
            
            return result.prefix(length)
            
            } } }
    }
    
    public static func decrypt<K : ContiguousBytes, D : ContiguousBytes>(_ algorithm: CryptorAlgorithm, _ options: CryptorOptions, _ key: K, _ data: D) throws -> Data {
        return try decrypt(algorithm, options, key, data, EmptyCollection())
    }
    
    public static func decrypt<K : ContiguousBytes, D : ContiguousBytes, I : ContiguousBytes>(_ algorithm: CryptorAlgorithm, _ options: CryptorOptions, _ key: K, _ data: D, _ iv: I) throws -> Data {
        
        return try key.withUnsafeBytes { key in try data.withUnsafeBytes { data in try iv.withUnsafeBytes { iv in
            
            var result = Data(count: data.count + algorithm.blockSize)
            var length = 0
            
            let status = result.withUnsafeMutableBytes { CCCrypt(CCOperation(kCCDecrypt), algorithm.rawValue, CCOptions(options.rawValue), key.baseAddress, key.count, iv.baseAddress, data.baseAddress, data.count, $0.baseAddress, $0.count, &length) }
            
            guard status == kCCSuccess else  { throw Error(status: status) }
            
            return result.prefix(length)
            
            } } }
    }
}

extension Crypto.CryptorAlgorithm {
    
    fileprivate var rawValue: CCAlgorithm {
        switch self {
        case .AES: return CCAlgorithm(kCCAlgorithmAES)
        case .DES: return CCAlgorithm(kCCAlgorithmDES)
        case .TripleDES: return CCAlgorithm(kCCAlgorithm3DES)
        case .CAST: return CCAlgorithm(kCCAlgorithmCAST)
        case .RC4: return CCAlgorithm(kCCAlgorithmRC4)
        case .RC2: return CCAlgorithm(kCCAlgorithmRC2)
        case .Blowfish: return CCAlgorithm(kCCAlgorithmBlowfish)
        }
    }
    
    public var blockSize: Int {
        switch self {
        case .AES: return kCCBlockSizeAES128
        case .DES: return kCCBlockSizeDES
        case .TripleDES: return kCCBlockSize3DES
        case .CAST: return kCCBlockSizeCAST
        case .RC4: return 0
        case .RC2: return kCCBlockSizeRC2
        case .Blowfish: return kCCBlockSizeBlowfish
        }
    }
}

extension Crypto {
    
    public enum WrappingAlgorithm : CaseIterable {
        
        case AES
    }
    
    public static let rfc3394: Data = {
        let immutableReference = NSData(bytesNoCopy: UnsafeMutableRawPointer(mutating: UnsafeRawPointer(CCrfc3394_iv!)), length: CCrfc3394_ivLen, deallocator: .none)
        return Data(referencing: immutableReference)
    }()
    
    public static func symmetricKeyWrap<K : ContiguousBytes, E : ContiguousBytes>(_ algorithm: WrappingAlgorithm, _ key: K, _ encryptionKey: E) throws -> Data {
        return try symmetricKeyWrap(algorithm, key, encryptionKey, rfc3394)
    }
    
    public static func symmetricKeyWrap<K : ContiguousBytes, E : ContiguousBytes, I : ContiguousBytes>(_ algorithm: WrappingAlgorithm, _ key: K, _ encryptionKey: E, _ iv: I) throws -> Data {
        
        return try key.withUnsafeBytes { key in try encryptionKey.withUnsafeBytes { encryptionKey in try iv.withUnsafeBytes { iv in
            
            let outputSize = CCSymmetricWrappedSize(algorithm.rawValue, key.count)
            var result = Data(count: outputSize)
            
            var length = outputSize
            
            let status = result.withUnsafeMutableBufferPointer { CCSymmetricKeyWrap(algorithm.rawValue, iv.bindMemory(to: UInt8.self).baseAddress, iv.count, encryptionKey.bindMemory(to: UInt8.self).baseAddress, encryptionKey.count, key.bindMemory(to: UInt8.self).baseAddress, key.count, $0.baseAddress, &length) }
            
            guard status == kCCSuccess else  { throw Error(status: status) }
            
            return result.prefix(upTo: length)
            
            } } }
    }
    
    public static func symmetricKeyUnwrap<K : ContiguousBytes, E : ContiguousBytes>(_ algorithm: WrappingAlgorithm, _ key: K, _ encryptionKey: E) throws -> Data {
        return try symmetricKeyUnwrap(algorithm, key, encryptionKey, rfc3394)
    }
    
    public static func symmetricKeyUnwrap<K : ContiguousBytes, E : ContiguousBytes, I : ContiguousBytes>(_ algorithm: WrappingAlgorithm, _ key: K, _ encryptionKey: E, _ iv: I) throws -> Data {
        
        return try key.withUnsafeBytes { key in try encryptionKey.withUnsafeBytes { encryptionKey in try iv.withUnsafeBytes { iv in
            
            let outputSize = CCSymmetricUnwrappedSize(algorithm.rawValue, key.count)
            var result = Data(count: outputSize)
            
            var length = outputSize
            
            let status = result.withUnsafeMutableBufferPointer { CCSymmetricKeyUnwrap(algorithm.rawValue, iv.bindMemory(to: UInt8.self).baseAddress, iv.count, encryptionKey.bindMemory(to: UInt8.self).baseAddress, encryptionKey.count, key.bindMemory(to: UInt8.self).baseAddress, key.count, $0.baseAddress, &length) }
            
            guard status == kCCSuccess else  { throw Error(status: status) }
            
            return result.prefix(upTo: length)
            
            } } }
    }
}

extension Crypto.WrappingAlgorithm {
    
    fileprivate var rawValue: CCWrappingAlgorithm {
        switch self {
        case .AES: return CCWrappingAlgorithm(kCCWRAPAES)
        }
    }
}

extension Crypto {
    
    public enum PBKDFAlgorithm : CaseIterable {
        
        case PBKDF2
    }
    
    public enum PseudoRandomAlgorithm : CaseIterable {
        
        case SHA1
        case SHA224
        case SHA256
        case SHA384
        case SHA512
    }
    
    public static func CalibratePBKDF(_ algorithm: PBKDFAlgorithm, _ pseudoRandomAlgorithm: PseudoRandomAlgorithm, _ keyLength: Int, _ saltLength: Int, _ derivedKeyLength: Int, _ msec: Int) -> Int {
        return Int(CCCalibratePBKDF(algorithm.rawValue, keyLength, saltLength, pseudoRandomAlgorithm.rawValue, derivedKeyLength, UInt32(msec)))
    }
    
    public static func PBKDF<K : ContiguousBytes, S : ContiguousBytes>(_ algorithm: PBKDFAlgorithm, _ pseudoRandomAlgorithm: PseudoRandomAlgorithm, _ key: K, _ salt: S, _ derivedKeyLength: Int, _ round: Int) throws -> Data {
        
        var result = Data(count: derivedKeyLength)
        
        let status = result.withUnsafeMutableBufferPointer { result in key.withUnsafeBytes { key in salt.withUnsafeBytes { salt in
            
            CCKeyDerivationPBKDF(algorithm.rawValue, key.bindMemory(to: Int8.self).baseAddress, key.count, salt.bindMemory(to: UInt8.self).baseAddress, salt.count, pseudoRandomAlgorithm.rawValue, uint(round), result.baseAddress, result.count)
            
            } } }
        
        guard status == kCCSuccess else  { throw Error(status: status) }
        
        return result
    }
}

extension Crypto.PBKDFAlgorithm {
    
    fileprivate var rawValue: CCPBKDFAlgorithm {
        switch self {
        case .PBKDF2: return CCPBKDFAlgorithm(kCCPBKDF2)
        }
    }
}

extension Crypto.PseudoRandomAlgorithm {
    
    fileprivate var rawValue: CCPseudoRandomAlgorithm {
        switch self {
        case .SHA1: return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1)
        case .SHA224: return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA224)
        case .SHA256: return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256)
        case .SHA384: return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA384)
        case .SHA512: return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512)
        }
    }
}

extension Crypto {
    
    public enum HMACAlgorithm : CaseIterable {
        
        case MD5
        case SHA1
        case SHA224
        case SHA256
        case SHA384
        case SHA512
    }
    
    public static func HMAC(_ algorithm: HMACAlgorithm, _ key: Data, _ message: Data) -> Data {
        var result = Data(count: algorithm.digestLength)
        result.withUnsafeMutableBytes { result in key.withUnsafeBytes { key in message.withUnsafeBytes { message in CCHmac(algorithm.rawValue, key.baseAddress, key.count, message.baseAddress, message.count, result.baseAddress) } } }
        return result
    }
}

extension Crypto.HMACAlgorithm {
    
    fileprivate var rawValue: CCHmacAlgorithm {
        switch self {
        case .MD5: return CCHmacAlgorithm(kCCHmacAlgMD5)
        case .SHA1: return CCHmacAlgorithm(kCCHmacAlgSHA1)
        case .SHA224: return CCHmacAlgorithm(kCCHmacAlgSHA224)
        case .SHA256: return CCHmacAlgorithm(kCCHmacAlgSHA256)
        case .SHA384: return CCHmacAlgorithm(kCCHmacAlgSHA384)
        case .SHA512: return CCHmacAlgorithm(kCCHmacAlgSHA512)
        }
    }
    
    public var digestLength: Int {
        switch self {
        case .MD5: return Int(CC_MD5_DIGEST_LENGTH)
        case .SHA1: return Int(CC_SHA1_DIGEST_LENGTH)
        case .SHA224: return Int(CC_SHA224_DIGEST_LENGTH)
        case .SHA256: return Int(CC_SHA256_DIGEST_LENGTH)
        case .SHA384: return Int(CC_SHA384_DIGEST_LENGTH)
        case .SHA512: return Int(CC_SHA512_DIGEST_LENGTH)
        }
    }
}

extension Crypto {
    
    public static func randomData(length: Int) -> Data {
        var data = Data(count: length)
        let status = data.withUnsafeMutableBytes { CCRandomGenerateBytes($0.baseAddress, length) }
        assert(status == kCCSuccess)
        return data
    }
}

extension Crypto {
    
    public static func md5<S : ContiguousBytes>(_ data: S) -> Data {
        var digest = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        digest.withUnsafeMutableBufferPointer { digest in data.withUnsafeBytes { _ = CC_MD5($0.baseAddress, CC_LONG($0.count), digest.baseAddress) } }
        return digest
    }
    
    public static func sha1<S : ContiguousBytes>(_ data: S) -> Data {
        var digest = Data(count: Int(CC_SHA1_DIGEST_LENGTH))
        digest.withUnsafeMutableBufferPointer { digest in data.withUnsafeBytes { _ = CC_SHA1($0.baseAddress, CC_LONG($0.count), digest.baseAddress) } }
        return digest
    }
    
    public static func sha224<S : ContiguousBytes>(_ data: S) -> Data {
        var digest = Data(count: Int(CC_SHA224_DIGEST_LENGTH))
        digest.withUnsafeMutableBufferPointer { digest in data.withUnsafeBytes { _ = CC_SHA224($0.baseAddress, CC_LONG($0.count), digest.baseAddress) } }
        return digest
    }
    
    public static func sha256<S : ContiguousBytes>(_ data: S) -> Data {
        var digest = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        digest.withUnsafeMutableBufferPointer { digest in data.withUnsafeBytes { _ = CC_SHA256($0.baseAddress, CC_LONG($0.count), digest.baseAddress) } }
        return digest
    }
    
    public static func sha384<S : ContiguousBytes>(_ data: S) -> Data {
        var digest = Data(count: Int(CC_SHA384_DIGEST_LENGTH))
        digest.withUnsafeMutableBufferPointer { digest in data.withUnsafeBytes { _ = CC_SHA384($0.baseAddress, CC_LONG($0.count), digest.baseAddress) } }
        return digest
    }
    
    public static func sha512<S : ContiguousBytes>(_ data: S) -> Data {
        var digest = Data(count: Int(CC_SHA512_DIGEST_LENGTH))
        digest.withUnsafeMutableBufferPointer { digest in data.withUnsafeBytes { _ = CC_SHA512($0.baseAddress, CC_LONG($0.count), digest.baseAddress) } }
        return digest
    }
}

#endif
