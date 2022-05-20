//
//  Infallible+Combine.swift
//  RxCombine

#if canImport(Combine)
import Combine
import RxSwift

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Infallible {
    /// An `AnyPublisher` of the underlying Observable's Element type
    /// so the Infallible pushes events to the Publisher.
    var publisher: AnyPublisher<Element, Swift.Never> {
        asObservable()
            .asPublisher()
            .assertNoFailure("Infallible should not fail")
            .eraseToAnyPublisher()
    }
    
    /// Returns a `AnyPublisher` of the underlying Observable's Element type
    /// so the Infallible pushes events to the Publisher.
    ///
    /// - returns: AnyPublisher of the underlying Observable's Element type.
    /// - note: This is an alias for the `publisher` property.
    func asPublisher() -> AnyPublisher<Element, Swift.Never> {
        publisher
    }
}

#endif
