//
//  Regex.swift
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

@frozen
public struct Regex {
    
    public let nsRegex: NSRegularExpression
    
    @inlinable
    public init(_ regex: NSRegularExpression) {
        self.nsRegex = regex
    }
    
    @inlinable
    public init(pattern: String, options: NSRegularExpression.Options = []) throws {
        self.nsRegex = try NSRegularExpression(pattern: pattern, options: options)
    }
    
    /// Returns the regular expression pattern.
    @inlinable
    public var pattern: String {
        return nsRegex.pattern
    }
    
    /// Returns the options used when the regular expression option was created.
    @inlinable
    public var options: NSRegularExpression.Options {
        return nsRegex.options
    }
    
    /// Returns the number of capture groups in the regular expression.
    ///
    /// A capture group consists of each possible match within a regular expression. Each capture group can then be used in a replacement template to insert that value into a replacement string.
    @inlinable
    public var numberOfCaptureGroups: Int {
        return nsRegex.numberOfCaptureGroups
    }
}

extension Regex: ExpressibleByStringInterpolation {
    
    @inlinable
    public init(stringLiteral value: StringLiteralType) {
        try! self.init(pattern: value)
    }
    
    @inlinable
    public init(stringInterpolation: String.StringInterpolation) {
        try! self.init(pattern: String(stringInterpolation: stringInterpolation))
    }
}

extension Regex: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return pattern
    }
}

extension Regex: Hashable {
    
    @inlinable
    public static func == (lhs: Regex, rhs: Regex) -> Bool {
        return lhs.pattern == rhs.pattern && lhs.options == rhs.options
    }
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.pattern)
        hasher.combine(self.options.rawValue)
    }
}

public protocol RegularExpressionMatchable: Collection {
    
    associatedtype Matching
    associatedtype Replacement
    
    /// Returns an array containing all the matches of the regular expression.
    func match(regex: Regex) -> [Matching]
    
    /// Returns a new string containing matching regular expressions replaced with the template.
    func replace(regex: Regex, template: Replacement) -> Replacement
    
    /// Returns the number of matches of the regular expression.
    func count(regex: Regex) -> Int
    
    /// Returns the first match of the regular expression.
    func firstMatch(regex: Regex) -> Matching?
    
    /// Returns true if any match of the regular expression.
    func isMatch(regex: Regex) -> Bool
    
    func split(separator: Regex) -> [Matching]
}

extension RegularExpressionMatchable {
    
    /// Returns the number of matches of the regular expression.
    @inlinable
    public func count(regex: Regex) -> Int {
        return self.match(regex: regex).count
    }
    
    /// Returns the first match of the regular expression.
    @inlinable
    public func firstMatch(regex: Regex) -> Matching? {
        return self.match(regex: regex).first
    }
    
    /// Returns true if any match of the regular expression.
    @inlinable
    public func isMatch(regex: Regex) -> Bool {
        return self.firstMatch(regex: regex) != nil
    }
}

extension NSString {
    
    open func components(separatedBy separator: NSRegularExpression) -> [String] {
        let len = length
        var lrange = separator.rangeOfFirstMatch(in: self as String, range: NSRange(location: 0, length: len))
        if lrange.length == 0 {
            return [self as String]
        } else {
            var array = [String]()
            var srange = NSRange(location: 0, length: len)
            while true {
                let trange = NSRange(location: srange.location, length: lrange.location - srange.location)
                array.append(substring(with: trange))
                srange.location = lrange.location + lrange.length
                srange.length = len - srange.location
                lrange = separator.rangeOfFirstMatch(in: self as String, range:srange)
                if lrange.length == 0 {
                    break
                }
            }
            array.append(substring(with: srange))
            return array
        }
    }
}

extension String: RegularExpressionMatchable {
    
    /// Returns the number of matches of the regular expression in the string.
    @inlinable
    public func count(regex: Regex) -> Int {
        let nsstring = NSString(string: self)
        let range = NSRange(location: 0, length: nsstring.length)
        return regex.nsRegex.numberOfMatches(in: self, options: [], range: range)
    }
    
    /// Returns true if any match of the regular expression in the string.
    @inlinable
    public func isMatch(regex: Regex) -> Bool {
        let nsstring = NSString(string: self)
        let range = NSRange(location: 0, length: nsstring.length)
        return regex.nsRegex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    /// Returns the first match of the regular expression in the string.
    @inlinable
    public func firstMatch(regex: Regex) -> String? {
        let nsstring = NSString(string: self)
        let range = NSRange(location: 0, length: nsstring.length)
        let match_result = regex.nsRegex.firstMatch(in: self, options: [], range: range)
        return match_result.map { nsstring.substring(with: $0.range) }
    }
    
    /// Returns an array containing all the matches of the regular expression in the string.
    @inlinable
    public func match(regex: Regex) -> [String] {
        let nsstring = NSString(string: self)
        let range = NSRange(location: 0, length: nsstring.length)
        var match_result = [String]()
        regex.nsRegex.enumerateMatches(in: self, options: [], range: range) { result, _, _ in
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
    @inlinable
    public func replace(regex: Regex, template: String) -> String {
        let nsstring = NSString(string: self)
        let range = NSRange(location: 0, length: nsstring.length)
        return regex.nsRegex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: template)
    }
    
    @inlinable
    public func split(separator: Regex) -> [String] {
        let nsstring = NSString(string: self)
        return nsstring.components(separatedBy: separator.nsRegex)
    }
}

@inlinable
public func ~=<T: RegularExpressionMatchable> (lhs: Regex, rhs: T) -> Bool {
    return rhs.isMatch(regex: lhs)
}

@inlinable
public func =~<T: RegularExpressionMatchable> (lhs: T, rhs: Regex) -> Bool {
    return lhs.isMatch(regex: rhs)
}
