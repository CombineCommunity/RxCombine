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
    func asPublisher() -> AnyPublisher<Element, Swift.Error> {
        return AnyPublisher<Element, Swift.Error> { subscriber in
            subscriber.receive(subscription: RxSubscription(disposable: self.asObservable()
                                                                            .subscribe(subscriber.pushRxEvent)))
        }
    }
}
