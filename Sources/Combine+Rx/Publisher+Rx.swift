//
//  Publisher+Rx.swift
//  RxCombine
//
//  Created by Shai Mishali on 11/06/2019.
//  Copyright © 2019 Combine Community. All rights reserved.
//

#if canImport(Combine)
import Combine
import RxSwift

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher {
    /// Returns an Observable<Output> representing the underlying
    /// Publisher. Upon subscription, the Publisher's sink pushes
    /// events into the Observable. Upon disposing of the subscription,
    /// the sink is cancelled.
    ///
    /// - returns: Observable<Output>
    func asObservable() -> Observable<Output> {
        Observable<Output>.create { observer in
            let cancellable = self.sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                },
                receiveValue: { value in
                    observer.onNext(value)
                })
            
            return Disposables.create { cancellable.cancel() }
        }
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Publisher where Failure == Never {
    /// Returns an Observable<Output> representing the underlying
    /// Publisher. Upon subscription, the Publisher's sink pushes
    /// events into the Observable. Upon disposing of the subscription,
    /// the sink is cancelled.
    ///
    /// - returns: Observable<Output>
    func asInfallible() -> Infallible<Output> {
        Infallible<Output>.create { observer in
            let cancellable = self.sink(
                receiveCompletion: { completion in
                    observer(.completed)
                },
                receiveValue: { value in
                    observer(.next(value))
                })
            
            return Disposables.create { cancellable.cancel() }
        }
    }
}
#endif
