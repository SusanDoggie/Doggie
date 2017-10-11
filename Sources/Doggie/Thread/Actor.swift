//
//  Actor.swift
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

import Foundation
import Dispatch

open class Actor<Message> : Trigger {
    
    private enum Action {
        case message(Message)
        case request((Actor) -> Void)
    }
    
    private let messages: AtomicQueue<Action>
    
    public init(queue: DispatchQueue = SDDefaultDispatchQueue, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = []) {
        self.messages = AtomicQueue()
        super.init(queue: queue, qos: qos, flags: flags) {
            guard let actor = $0 as? Actor else { return }
            while let message = actor.messages.next() {
                switch message {
                case let .message(message): actor.callback(message)
                case let .request(request): request(actor)
                }
            }
        }
    }
    
    open func callback(_ message: Message) {
        
    }
}

extension Actor {
    
    public func send(_ message: Message) {
        messages.push(.message(message))
        self.signal()
    }
    
    public func request<OtherMessage>(from other: Actor<OtherMessage>, callback: @escaping (Actor<OtherMessage>) -> Message) {
        other.messages.push(.request { self.send(callback($0)) })
    }
}
