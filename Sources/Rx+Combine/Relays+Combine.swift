//
//  Relays+Combine.swift
//  RxCombine
//
//  Created by Shai Mishali on 11/06/2019.
//  Copyright © 2019 Shai Mishali. All rights reserved.
//

import Combine
import RxSwift
import RxRelay

// MARK: - Behavior Relay as Publisher
extension BehaviorRelay: Publisher {
    public typealias Output = Element
    public typealias Failure = Never

    public func receive<S: Subscriber>(subscriber: S) where BehaviorRelay.Failure == S.Failure,
                                                            BehaviorRelay.Output == S.Input {
        _ = self.subscribe(subscriber.pushRxEvent)
    }
}

// MARK: - Behavior Relay as Combine Subject
extension BehaviorRelay: Combine.Subject {
    public func send(_ value: Element) {
        accept(value)
    }

    public func send(completion: Subscribers.Completion<Never>) {
        /// no-op: Relays don't complete and can't error out
    }
}

// MARK:  - Publish Relay as Publisher
extension PublishRelay: Publisher {
    public typealias Output = Element
    public typealias Failure = Never

    public func receive<S: Subscriber>(subscriber: S) where PublishRelay.Failure == S.Failure,
                                                            PublishRelay.Output == S.Input {
        _ = self.subscribe(subscriber.pushRxEvent)
    }
}

// MARK: - Publish Relay as Combine Subject
extension PublishRelay: Combine.Subject {
    public func send(_ value: Element) {
        accept(value)
    }

    public func send(completion: Subscribers.Completion<Never>) {
        /// no-op: Relays don't complete and can't error out
    }
}
