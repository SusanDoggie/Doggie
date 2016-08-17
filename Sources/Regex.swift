//
//  Regex.swift
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

public struct Regex : Equatable {
    
    fileprivate let matcher: NSRegularExpression
    
    public init(pattern: String) throws {
        self.matcher = try NSRegularExpression(pattern: pattern, options: [])
    }
    
    public init(pattern: String, options: NSRegularExpression.Options) throws {
        self.matcher = try NSRegularExpression(pattern: pattern, options: options)
    }
    
    /// Returns the regular expression pattern.
    public var pattern: String {
        return matcher.pattern
    }
    
    /// Returns the options used when the regular expression option was created.
    public var options: NSRegularExpression.Options {
        return matcher.options
    }
    
    /// Returns the number of capture groups in the regular expression.
    ///
    /// A capture group consists of each possible match within a regular expression. Each capture group can then be used in a replacement template to insert that value into a replacement string.
    public var numberOfCaptureGroups: Int {
        return matcher.numberOfCaptureGroups
    }
}

extension Regex: ExpressibleByStringLiteral {
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias UnicodeScalarLiteralType = StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        try! self.init(pattern: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        try! self.init(pattern: value)
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        try! self.init(pattern: value)
    }
}

extension Regex: CustomStringConvertible {
    public var description: String {
        return pattern
    }
}

public protocol RegularExpressionMatchable {
    
    associatedtype Matching
    associatedtype Replacement
    
    /// Returns an array containing all the matches of the regular expression.
    func match(_ regex: Regex) -> [Matching]
    
    /// Returns a new string containing matching regular expressions replaced with the template.
    func replace(_ regex: Regex, template: Replacement) -> Replacement
    
    /// Returns the number of matches of the regular expression.
    func count(_ regex: Regex) -> Int
    
    /// Returns the first match of the regular expression.
    func firstMatch(_ regex: Regex) -> Matching?
    
    /// Returns true if any match of the regular expression.
    func isMatch(_ regex: Regex) -> Bool
}

public extension RegularExpressionMatchable {
    
    /// Returns the number of matches of the regular expression.
    func count(_ regex: Regex) -> Int {
        return self.match(regex).count
    }
    
    /// Returns the first match of the regular expression.
    func firstMatch(_ regex: Regex) -> Matching? {
        return self.match(regex).first
    }
    
    /// Returns true if any match of the regular expression.
    func isMatch(_ regex: Regex) -> Bool {
        return self.firstMatch(regex) != nil
    }
}

extension String: RegularExpressionMatchable {
    
    /// Returns the number of matches of the regular expression in the string.
    public func count(_ regex: Regex) -> Int {
        let nsstring = NSString(string: self)
        let range = NSRange(location: 0, length: nsstring.length)
        return regex.matcher.numberOfMatches(in: self, options: [], range: range)
    }
    
    /// Returns true if any match of the regular expression in the string.
    public func isMatch(_ regex: Regex) -> Bool {
        let nsstring = NSString(string: self)
        let range = NSRange(location: 0, length: nsstring.length)
        return regex.matcher.firstMatch(in: self, options: [], range: range) != nil
    }
    
    /// Returns the first match of the regular expression in the string.
    public func firstMatch(_ regex: Regex) -> String? {
        let nsstring = NSString(string: self)
        let range = NSRange(location: 0, length: nsstring.length)
        let match_result = regex.matcher.firstMatch(in: self, options: [], range: range)
        return match_result.map { nsstring.substring(with: $0.range) }
    }
    
    /// Returns an array containing all the matches of the regular expression in the string.
    public func match(_ regex: Regex) -> [String] {
        let nsstring = NSString(string: self)
        let range = NSRange(location: 0, length: nsstring.length)
        var match_result = [String]()
        regex.matcher.enumerateMatches(in: self, options: [], range: range) { result, _, _ in
            if let _result = result {
                match_result.append(nsstring.substring(with: _result.range))
            }
        }
        return match_result
    }
    
    /// Returns a new string containing matching regular expressions replaced with the template string.
    ///
    /// The replacement is treated as a template, with $0 being replaced by the contents of the matched range, $1 by the contents of the first capture group, and so on.
    /// Additional digits beyond the maximum required to represent the number of capture groups will be treated as ordinary characters, as will a $ not followed by digits.
    /// Backslash will escape both $ and itself.
    public func replace(_ regex: Regex, template: String) -> String {
        let nsstring = NSString(string: self)
        let range = NSRange(location: 0, length: nsstring.length)
        return regex.matcher.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: template)
    }
}

public func ~=<T: RegularExpressionMatchable> (lhs: Regex, rhs: T) -> Bool {
    return rhs.isMatch(lhs)
}

public func ==(lhs: Regex, rhs: Regex) -> Bool {
    return lhs.pattern == rhs.pattern && lhs.options == rhs.options
}
