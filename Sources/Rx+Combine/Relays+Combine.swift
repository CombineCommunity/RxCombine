//
//  Relays+Combine.swift
//  RxCombine
//
//  Created by Shai Mishali on 11/06/2019.
//  Copyright © 2019 Combine Community. All rights reserved.
//

#if canImport(Combine)
import Combine
import RxSwift
import RxRelay

// MARK: - Behavior Relay as Publisher
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension BehaviorRelay {
    /// An `AnyPublisher` of the underlying Relay's Element type
    /// so the relay pushes events to the Publisher.
    var publisher: AnyPublisher<Element, Never> {
        RxPublisher(upstream: self).assertNoFailure().eraseToAnyPublisher()
    }

    /// An `AnyPublisher` of the underlying Relay's Element type
    /// so the relay pushes events to the Publisher.
    ///
    /// - returns: AnyPublisher of the underlying Relay's Element type.
    /// - note: This is an alias for the `publisher` property.
    func asPublisher() -> AnyPublisher<Element, Never> {
        publisher
    }
}

// MARK: - Publish Relay as Publisher
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension PublishRelay {
    /// An `AnyPublisher` of the underlying Relay's Element type
    /// so the relay pushes events to the Publisher.
    var publisher: AnyPublisher<Element, Never> {
        RxPublisher(upstream: self).assertNoFailure().eraseToAnyPublisher()
    }

    /// An `AnyPublisher` of the underlying Relay's Element type
    /// so the relay pushes events to the Publisher.
    ///
    /// - returns: AnyPublisher of the underlying Relay's Element type.
    /// - note: This is an alias for the `publisher` property.
    func asPublisher() -> AnyPublisher<Element, Never> {
        publisher
    }
}
#endif
