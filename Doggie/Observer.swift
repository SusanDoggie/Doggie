//
//  Observer.swift
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

public class Observer<T> : NSObject {
    
    public let sink = Sink<T>()
    
    private let object: NSObject
    private let keyPath: String
    private var token = 0
    
    private init(object: NSObject, keyPath: String, options: NSKeyValueObservingOptions) {
        self.object = object
        self.keyPath = keyPath
        super.init()
        object.addObserver(self, forKeyPath: keyPath, options: options, context: &token)
    }
    
    deinit {
        object.removeObserver(self, forKeyPath: keyPath, context: &token)
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &token {
            if change != nil {
                self.put(change!)
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    private func put(change: [String : AnyObject]) {
        
    }
}

public extension NSObject {
    
    public func observe(keyPath: String) -> Observer<[String : AnyObject]> {
        
        class ChangeObserver : Observer<[String : AnyObject]> {
            
            init(object: NSObject, keyPath: String) {
                super.init(object: object, keyPath: keyPath, options: [.New, .Old, .Initial, .Prior])
            }
            
            override func put(change: [String : AnyObject]) {
                self.sink.put(change)
            }
        }
        
        return ChangeObserver(object: self, keyPath: keyPath)
    }
    
    public func willSet(keyPath: String) -> Observer<AnyObject> {
        
        class WillSetObserver : Observer<AnyObject> {
            
            init(object: NSObject, keyPath: String) {
                super.init(object: object, keyPath: keyPath, options: .Prior)
            }
            
            override func put(change: [String : AnyObject]) {
                if let old = change[NSKeyValueChangeOldKey] {
                    self.sink.put(old)
                }
            }
        }
        
        return WillSetObserver(object: self, keyPath: keyPath)
    }
    
    public func didSet(keyPath: String) -> Observer<(old: AnyObject, new: AnyObject)> {
        
        class DidSetObserver : Observer<(old: AnyObject, new: AnyObject)> {
            
            init(object: NSObject, keyPath: String) {
                super.init(object: object, keyPath: keyPath, options: [.New, .Old])
            }
            
            override func put(change: [String : AnyObject]) {
                if let old = change[NSKeyValueChangeOldKey], new = change[NSKeyValueChangeNewKey] {
                    self.sink.put(old: old, new: new)
                }
            }
        }
        
        return DidSetObserver(object: self, keyPath: keyPath)
    }
}
