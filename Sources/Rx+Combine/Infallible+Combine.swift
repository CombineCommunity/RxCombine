//
//  Infallible+Combine.swift
//  RxCombine
//
//  Created by Mathis Detourbet on 30/03/2023.
//  Copyright © 2019 Combine Community. All rights reserved.
//

#if canImport(Combine)
import Combine
import RxSwift

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension InfallibleType {
    /// An `AnyPublisher` of the underlying Infallible's Element type
    /// so the Infallible pushes events to the Publisher.
    var publisher: AnyPublisher<Element, Swift.Never> {
        RxInfallible(upstream: self).eraseToAnyPublisher()
    }

    /// Returns a `AnyPublisher` of the underlying Infallible's Element type
    /// so the Infallible pushes events to the Publisher.
    ///
    /// - returns: AnyPublisher of the underlying Infallible's Element type.
    /// - note: This is an alias for the `publisher` property.
    func asPublisher() -> AnyPublisher<Element, Swift.Never> {
        publisher
    }
}

/// A Infallible Publisher pushing RxSwift events to a Downstream Combine subscriber.
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public class RxInfallible<Upstream: InfallibleType>: Publisher {
    public typealias Output = Upstream.Element
    public typealias Failure = Swift.Never

    private let upstream: Upstream

    init(upstream: Upstream) {
        self.upstream = upstream
    }

    public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
        subscriber.receive(subscription: RxInfallibleSubscription(upstream: upstream,
                                                                  downstream: subscriber))
    }
}
#endif
