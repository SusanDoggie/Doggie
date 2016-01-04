//
//  SDAspects.swift
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

public extension NSObject {
    
    static var sizeofInstance : Int {
        return class_getInstanceSize(self)
    }
    
    static var methods : [Selector] {
        var count: UInt32 = 0
        let list = class_copyMethodList(self, &count)
        let _list = [Selector]((list ..< list + Int(count)).map { return method_getName($0.memory) })
        free(list)
        return _list
    }
    
    static func exchangeInstanceMethodImplementations(from: Selector, to: Selector) {
        assert(self.instancesRespondToSelector(from), "\(self) is not responds to selector: \(from)")
        assert(self.instancesRespondToSelector(to), "\(self) is not responds to selector: \(to)")
        let _from = class_getInstanceMethod(self, from)
        let _to = class_getInstanceMethod(self, to)
        method_exchangeImplementations(_from, _to)
    }
    static func exchangeClassMethodImplementations(from: Selector, to: Selector) {
        assert(self.respondsToSelector(from), "\(self) is not responds to selector: \(from)")
        assert(self.respondsToSelector(to), "\(self) is not responds to selector: \(to)")
        let _from = class_getClassMethod(self, from)
        let _to = class_getClassMethod(self, to)
        method_exchangeImplementations(_from, _to)
    }
    
    static func setInstanceMethodImplementations(sel: Selector, block: (AnyObject) -> AnyObject) {
        
        let objcBlock : @convention(block) (AnyObject) -> AnyObject = { block($0) }
        let imp = imp_implementationWithBlock(unsafeBitCast(objcBlock, AnyObject.self))
        if self.instancesRespondToSelector(sel) {
            let method = class_getInstanceMethod(self, sel)
            method_setImplementation(method, imp)
        } else {
            class_addMethod(self, sel, imp, "@:")
        }
    }
    static func setClassMethodImplementations(sel: Selector, block: (AnyClass) -> AnyObject) {
        
        let objcBlock : @convention(block) (AnyClass) -> AnyObject = { block($0) }
        let imp = imp_implementationWithBlock(unsafeBitCast(objcBlock, AnyObject.self))
        if self.respondsToSelector(sel) {
            let method = class_getClassMethod(self, sel)
            method_setImplementation(method, imp)
        }
    }
}

