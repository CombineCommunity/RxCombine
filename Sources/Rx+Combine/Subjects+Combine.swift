//
//  Subjects+Combine.swift
//  RxCombine
//
//  Created by Shai Mishali on 11/06/2019.
//  Copyright © 2019 Combine Community. All rights reserved.
//

import Combine
import RxSwift

// MARK: - Behavior Subject as Combine Subject
extension BehaviorSubject: Combine.Subject {
    public func receive<S: Subscriber>(subscriber: S) where BehaviorSubject.Failure == S.Failure,
                                                            BehaviorSubject.Output == S.Input {
        subscriber.receive(subscription: RxSubscription(upstream: self,
                                                        downstream: subscriber))
    }

    public func send(_ value: BehaviorSubject<Element>.Output) {
        onNext(value)
    }

    public func send(completion: Subscribers.Completion<BehaviorSubject<Element>.Failure>) {
        switch completion {
        case .finished:
            onCompleted()
        case .failure(let error):
            onError(error)
        }
    }

    public func send(subscription: Subscription) {
        /// no-op: Relays don't have anything to do with a Combine subscription
    }

    public typealias Output = Element
    public typealias Failure = Swift.Error
}

// MARK: - Publish Subject as Combine Subject
extension PublishSubject: Combine.Subject {
    public func receive<S: Subscriber>(subscriber: S) where PublishSubject.Failure == S.Failure,
                                                            PublishSubject.Output == S.Input {
        subscriber.receive(subscription: RxSubscription(upstream: self,
                                                        downstream: subscriber))
    }

    public func send(_ value: PublishSubject<Element>.Output) {
        onNext(value)
    }

    public func send(completion: Subscribers.Completion<PublishSubject<Element>.Failure>) {
        switch completion {
        case .finished:
            onCompleted()
        case .failure(let error):
            onError(error)
        }
    }

    public func send(subscription: Subscription) {
        /// no-op: Relays don't have anything to do with a Combine subscription
    }

    public typealias Output = Element
    public typealias Failure = Swift.Error
}
