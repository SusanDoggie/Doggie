
extension Strideable where Stride : SignedInteger {
    
    @_inlineable
    public func clamped(to range: CountableRange<Self>) -> Self {
        return self.clamped(to: ClosedRange(range))
    }
    @_inlineable
    public func clamped(to range: CountableClosedRange<Self>) -> Self {
        return self.clamped(to: ClosedRange(range))
    }
}

extension Range: Sequence where Bound: Strideable, Bound.Stride : SignedInteger {
    
    public typealias Element = Bound
    
    public typealias Iterator = IndexingIterator<Range<Bound>>
    
}

extension Range: Collection, BidirectionalCollection, RandomAccessCollection where Bound : Strideable, Bound.Stride : SignedInteger {
    
    public typealias Index = Bound
    
    public typealias Indices = Range<Bound>
    
    public typealias SubSequence = Range<Bound>
    
    @_inlineable
    public var startIndex: Index {
        return lowerBound
    }
    
    @_inlineable
    public var endIndex: Index {
        return upperBound
    }
    
    @_inlineable
    public func index(after i: Index) -> Index {
        _failEarlyRangeCheck(i, bounds: startIndex..<endIndex)
        return i.advanced(by: 1)
    }
    
    @_inlineable
    public func index(before i: Index) -> Index {
        _precondition(i > lowerBound)
        _precondition(i <= upperBound)
        return i.advanced(by: -1)
    }
    
    @_inlineable
    public func index(_ i: Index, offsetBy n: Int) -> Index {
        let r = i.advanced(by: numericCast(n))
        _precondition(r >= lowerBound)
        _precondition(r <= upperBound)
        return r
    }
    
    @_inlineable
    public func distance(from start: Index, to end: Index) -> Int {
        return numericCast(start.distance(to: end))
    }
    
    @_inlineable
    public subscript(bounds: Range<Index>) -> Range<Bound> {
        return bounds
    }
    
    @_inlineable
    public var indices: Indices {
        return self
    }
    
    @_inlineable
    public func _customContainsEquatableElement(_ element: Element) -> Bool? {
        return lowerBound <= element && element < upperBound
    }
    
    @_inlineable
    public func _customIndexOfEquatableElement(_ element: Bound) -> Index?? {
        return lowerBound <= element && element < upperBound ? element : nil
    }
    
    @_inlineable
    public subscript(position: Index) -> Element {
        _debugPrecondition(self.contains(position), "Index out of range")
        return position
    }
}

extension ClosedRange: Sequence where Bound: Strideable, Bound.Stride: SignedInteger {
    
    public typealias Element = Bound
    
    public typealias Iterator = IndexingIterator<ClosedRange<Bound>>
    
}

extension ClosedRange where Bound : Strideable, Bound.Stride : SignedInteger {
    
    public enum Index {
        case pastEnd
        case inRange(Bound)
    }
}

extension ClosedRange.Index : Comparable {
    
    @_inlineable
    public static func == (lhs: ClosedRange<Bound>.Index, rhs: ClosedRange<Bound>.Index) -> Bool {
        switch (lhs, rhs) {
        case (.inRange(let l), .inRange(let r)): return l == r
        case (.pastEnd, .pastEnd): return true
        default: return false
        }
    }
    
    @_inlineable
    public static func < (lhs: ClosedRange<Bound>.Index, rhs: ClosedRange<Bound>.Index) -> Bool {
        switch (lhs, rhs) {
        case (.inRange(let l), .inRange(let r)): return l < r
        case (.inRange(_), .pastEnd): return true
        default: return false
        }
    }
}

extension ClosedRange.Index: Hashable where Bound: Strideable, Bound.Stride: SignedInteger, Bound: Hashable {
    
    public var hashValue: Int {
        switch self {
        case .inRange(let value): return value.hashValue
        case .pastEnd: return .max
        }
    }
}

extension ClosedRange: Collection, BidirectionalCollection, RandomAccessCollection where Bound : Strideable, Bound.Stride : SignedInteger {
    
    public typealias SubSequence = Slice<ClosedRange<Bound>>
    
    @_inlineable
    public var startIndex: Index {
        return .inRange(lowerBound)
    }
    
    @_inlineable
    public var endIndex: Index {
        return .pastEnd
    }
    
    @_inlineable
    public func index(after i: Index) -> Index {
        switch i {
        case .inRange(let x): return x == upperBound ? .pastEnd : .inRange(x.advanced(by: 1))
        case .pastEnd: _preconditionFailure("Incrementing past end index")
        }
    }
    
    @_inlineable
    public func index(before i: Index) -> Index {
        switch i {
        case .inRange(let x):
            _precondition(x > lowerBound, "Incrementing past start index")
            return .inRange(x.advanced(by: -1))
        case .pastEnd:
            _precondition(upperBound >= lowerBound, "Incrementing past start index")
            return .inRange(upperBound)
        }
    }
    
    @_inlineable
    public func index(_ i: Index, offsetBy n: Int) -> Index {
        switch i {
        case .inRange(let x):
            let d = x.distance(to: upperBound)
            if n <= d {
                let newPosition = x.advanced(by: numericCast(n))
                _precondition(newPosition >= lowerBound, "Advancing past start index")
                return .inRange(newPosition)
            }
            if d - -1 == n { return .pastEnd }
            _preconditionFailure("Advancing past end index")
        case .pastEnd:
            if n == 0 {
                return i
            }
            if n < 0 {
                return index(.inRange(upperBound), offsetBy: numericCast(n + 1))
            }
            _preconditionFailure("Advancing past end index")
        }
    }
    
    @_inlineable
    public func distance(from start: Index, to end: Index) -> Int {
        switch (start, end) {
        case let (.inRange(left), .inRange(right)): return numericCast(left.distance(to: right))
        case let (.inRange(left), .pastEnd): return numericCast(1 + left.distance(to: upperBound))
        case let (.pastEnd, .inRange(right)): return numericCast(upperBound.distance(to: right) - 1)
        case (.pastEnd, .pastEnd): return 0
        }
    }
    
    @_inlineable
    public subscript(position: Index) -> Bound {
        switch position {
        case .inRange(let x): return x
        case .pastEnd: _preconditionFailure("Index out of range")
        }
    }
    
    @_inlineable
    public subscript(bounds: Range<Index>) -> Slice<ClosedRange<Bound>> {
            return Slice(base: self, bounds: bounds)
    }
    
    @_inlineable
    public func _customContainsEquatableElement(_ element: Bound) -> Bool? {
        return lowerBound <= element && element <= upperBound
    }
    
    @_inlineable
    public func _customIndexOfEquatableElement(_ element: Bound) -> Index?? {
        return lowerBound <= element && element <= upperBound ? .inRange(element) : nil
    }
}

extension RandomAccessCollection where Index : Strideable, Index.Stride == Int, Indices == Range<Index> {
    
    @_inlineable
    public var indices: Range<Index> {
        return startIndex..<endIndex
    }
    
    @_inlineable
    public func index(after i: Index) -> Index {
        _failEarlyRangeCheck(i, bounds: Range(uncheckedBounds: (startIndex, endIndex)))
        return i.advanced(by: 1)
    }
    
    @_inlineable
    public func index(before i: Index) -> Index {
        let result = i.advanced(by: -1)
        _failEarlyRangeCheck(result, bounds: Range(uncheckedBounds: (startIndex, endIndex)))
        return result
    }
    
    @_inlineable
    public func index(_ i: Index, offsetBy n: Index.Stride) -> Index {
        let result = i.advanced(by: n)
        _failEarlyRangeCheck(result, bounds: ClosedRange(uncheckedBounds: (startIndex, endIndex)))
        return result
    }
    
    @_inlineable
    public func distance(from start: Index, to end: Index) -> Index.Stride {
        _failEarlyRangeCheck(start, bounds: ClosedRange(uncheckedBounds: (startIndex, endIndex)))
        _failEarlyRangeCheck(end, bounds: ClosedRange(uncheckedBounds: (startIndex, endIndex)))
        return start.distance(to: end)
    }
}
