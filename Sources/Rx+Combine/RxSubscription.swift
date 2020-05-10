//
//  RxSubscription.swift
//  RxCombine
//
//  Created by Shai Mishali on 21/03/2020.
//  Copyright © 2020 Combine Community. All rights reserved.
//

#if canImport(Combine)
import Combine
import RxSwift

// MARK: - Fallible
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class RxSubscription<Upstream: ObservableConvertibleType, Downstream: Subscriber>: Combine.Subscription where Downstream.Input == Upstream.Element, Downstream.Failure == Swift.Error {
    private var disposable: Disposable?
    private let buffer: DemandBuffer<Downstream>

    init(upstream: Upstream,
         downstream: Downstream) {
        buffer = DemandBuffer(subscriber: downstream)
        disposable = upstream.asObservable().subscribe(bufferRxEvents)
    }

    private func bufferRxEvents(_ event: RxSwift.Event<Upstream.Element>) {
        switch event {
        case .next(let element):
            _ = buffer.buffer(value: element)
        case .error(let error):
            buffer.complete(completion: .failure(error))
        case .completed:
            buffer.complete(completion: .finished)
        }
    }

    func request(_ demand: Subscribers.Demand) {
        _ = self.buffer.demand(demand)
    }

    func cancel() {
        disposable?.dispose()
        disposable = nil
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension RxSubscription: CustomStringConvertible {
    var description: String {
        return "RxSubscription<\(Upstream.self)>"
    }
}

// MARK: - Infallible
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class RxInfallibleSubscription<Upstream: ObservableConvertibleType, Downstream: Subscriber>: Combine.Subscription where Downstream.Input == Upstream.Element, Downstream.Failure == Never {
    private var disposable: Disposable?
    private let buffer: DemandBuffer<Downstream>

    init(upstream: Upstream,
         downstream: Downstream) {
        buffer = DemandBuffer(subscriber: downstream)
        disposable = upstream.asObservable().subscribe(bufferRxEvents)
    }

    private func bufferRxEvents(_ event: RxSwift.Event<Upstream.Element>) {
        switch event {
        case .next(let element):
            _ = buffer.buffer(value: element)
        case .error(let error):
            preconditionFailure("Your downstream cannot accept errors, as it has a `Never` failure (Got \(error))")
        case .completed:
            buffer.complete(completion: .finished)
        }
    }

    func request(_ demand: Subscribers.Demand) {
        _ = self.buffer.demand(demand)
    }

    func cancel() {
        disposable?.dispose()
        disposable = nil
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension RxInfallibleSubscription: CustomStringConvertible {
    var description: String {
        return "RxInfallibleSubscription<\(Upstream.self)>"
    }
}
#endif
