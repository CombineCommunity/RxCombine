//
//  Subjects+Combine.swift
//  RxCombine
//
//  Created by Shai Mishali on 11/06/2019.
//  Copyright © 2019 Shai Mishali. All rights reserved.
//

import Combine
import RxSwift

// MARK: - Behavior Subject as Combine Subject
extension BehaviorSubject: Combine.Subject {
    public func send(subscription: Subscription) {
    }
    
    public func receive<S: Subscriber>(subscriber: S) where BehaviorSubject.Failure == S.Failure,
                                                            BehaviorSubject.Output == S.Input {
        _ = subscribe(subscriber.pushRxEvent)
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

    public typealias Output = Element
    public typealias Failure = Swift.Error
}

// MARK: - Publish Subject as Combine Subject
extension PublishSubject: Combine.Subject {
    public func send(subscription: Subscription) {
    }
    
    public func receive<S: Subscriber>(subscriber: S) where PublishSubject.Failure == S.Failure,
                                                            PublishSubject.Output == S.Input {
        _ = subscribe(subscriber.pushRxEvent)
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

    public typealias Output = Element
    public typealias Failure = Swift.Error
}
