//
//  Observable+Combine.swift
//  RxCombine
//
//  Created by Shai Mishali on 11/06/2019.
//  Copyright © 2019 Shai Mishali. All rights reserved.
//

import Combine
import RxSwift

public extension ObservableConvertibleType {
    /// An `AnyPublisher` of the underlying Observable's Element type
    /// so the Observable pushes events to the Publisher.
    var publisher: AnyPublisher<Element, Swift.Error> {
        AnyPublisher<Element, Swift.Error> { subscriber in
            let disposable = SingleAssignmentDisposable()
            subscriber.receive(
                subscription: RxSubscription(disposable: disposable)
            )
            disposable.setDisposable(self.asObservable()
                                         .subscribe(subscriber.pushRxEvent))
        }
    }
    
    /// Returns a `AnyPublisher` of the underlying Observable's Element type
    /// so the Observable pushes events to the Publisher.
    ///
    /// - returns: AnyPublisher of the underlying Observable's Element type.
    /// - note: This is an alias for the `publisher` property.
    func asPublisher() -> AnyPublisher<Element, Swift.Error> {
        publisher
    }
}
