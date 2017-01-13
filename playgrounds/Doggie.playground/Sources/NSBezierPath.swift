//
//  NSBezierPath.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

import AppKit
import Doggie

public extension AffineTransform {
    
    init<T: SDTransformProtocol>(_ transform: T) {
        let _transform = CGAffineTransform(transform)
        self.init(m11: _transform.a, m12: _transform.b, m21: _transform.c, m22: _transform.d, tX: _transform.tx, tY: _transform.ty)
    }
}

public extension NSBezierPath {
    
    convenience init(_ shape: SDPath) {
        self.init()
        var state = SDPath.DrawableComputeState()
        for item in shape {
            item.drawPath(self, state: &state)
        }
        self.transform(using: AffineTransform(shape.transform))
    }
}

extension SDPath : CustomPlaygroundQuickLookable {
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return .bezierPath(NSBezierPath(self))
    }
}

private extension SDPath {
    
    struct DrawableComputeState {
        
        var start : Point = Point()
        var last : Point = Point()
    }
}

private extension SDPath.Command {
    
    func drawPath(_ path: NSBezierPath, state: inout SDPath.DrawableComputeState) {
        
        switch self {
        case let .move(point):
            path.move(to: NSPoint(x: point.x, y: point.y))
            state.start = point
            state.last = point
        case let .line(point):
            path.line(to: NSPoint(x: point.x, y: point.y))
            state.last = point
        case let .quad(p1, p2):
            path.curve(to: NSPoint(x: p2.x, y: p2.y),
                       controlPoint1: NSPoint(x: (p1.x - state.last.x) * 2 / 3 + state.last.x, y: (p1.y - state.last.y) * 2 / 3 + state.last.y),
                       controlPoint2: NSPoint(x: (p1.x - p2.x) * 2 / 3 + p2.x, y: (p1.y - p2.y) * 2 / 3 + p2.y))
            state.last = p2
        case let .cubic(p1, p2, p3):
            path.curve(to: NSPoint(x: p3.x, y: p3.y), controlPoint1: NSPoint(x: p1.x, y: p1.y), controlPoint2: NSPoint(x: p2.x, y: p2.y))
            state.last = p3
        case .close:
            path.close()
            state.last = state.start
        }
    }
}
