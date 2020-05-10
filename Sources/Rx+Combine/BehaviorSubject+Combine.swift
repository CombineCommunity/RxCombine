//
//  BehaviorSubject+Combine.swift
//  RxCombine
//
//  Created by Shai Mishali on 11/06/2019.
//  Copyright © 2019 Combine Community. All rights reserved.
//

#if canImport(Combine)
import Combine
import RxSwift

// MARK: - Behavior Subject as Combine Subject

/// A bi-directional wrapper for a RxSwift Behavior Subject
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public final class RxCurrentValueSubject<Output>: Combine.Subject {
    private let rxSubject: BehaviorSubject<Output>
    private let subject: CurrentValueSubject<Output, Failure>
    private let subscription: AnyCancellable?

    public var value: Output {
        get { subject.value }
        set { rxSubject.onNext(newValue) }
    }

    init(rxSubject: BehaviorSubject<Output>) {
        self.rxSubject = rxSubject
        self.subject = CurrentValueSubject(try! rxSubject.value())
        subscription = rxSubject.publisher.subscribe(subject)
    }

    public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        subject.receive(subscriber: subscriber)
    }

    public func send(_ value: Output) {
        rxSubject.onNext(value)
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case .finished:
            rxSubject.onCompleted()
        case .failure(let error):
            rxSubject.onError(error)
        }
    }

    public func send(subscription: Subscription) {
        subject.send(subscription: subscription)
    }

    deinit { subscription?.cancel() }

    public typealias Failure = Swift.Error
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension BehaviorSubject {
    func toCombine() -> RxCurrentValueSubject<Element> {
        RxCurrentValueSubject(rxSubject: self)
    }
}
#endif
