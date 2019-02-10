//
//  Actor.swift
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

open class Actor<Message> : Trigger {

    private let messages: AtomicQueue<(Actor) -> Void>

    public init(queue: DispatchQueue = SDDefaultDispatchQueue, qos: DispatchQoS = .unspecified, flags: DispatchWorkItemFlags = []) {
        self.messages = AtomicQueue()
        super.init(queue: queue, qos: qos, flags: flags) {
            guard let actor = $0 as? Actor else { return }
            while let message = actor.messages.next() {
                message(actor)
            }
        }
    }

    open func callback(_ message: Message) {

    }
}

extension Actor {

    public func send(_ message: Message) {
        messages.push { $0.callback(message) }
        self.signal()
    }

    public func send<OtherMessage>(to other: Actor<OtherMessage>, callback: @escaping (Actor<Message>) -> OtherMessage) {
        messages.push { other.send(callback($0)) }
        self.signal()
    }
}
