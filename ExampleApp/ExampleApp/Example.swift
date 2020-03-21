//
//  Example.swift
//  RxCombine
//
//  Created by Shai Mishali on 11/06/2019.
//  Copyright © 2019 Combine Community. All rights reserved.
//

import UIKit
import Combine
import RxSwift
import RxRelay

enum Example: Int {
    case observableAsPublisher = 101
    case publisherAsObservable
    case relaysZippedInCombine

    func play(with textView: UITextView) {
        textView.text = ""
        textView.contentOffset = .zero

        switch self {
        case .observableAsPublisher:
            observableAsPublisher(with: textView)
        case .publisherAsObservable:
            publisherAsObservable(with: textView)
        case .relaysZippedInCombine:
            relaysZippedInCombine(with: textView)
        }
    }
}

private extension Example {
    func observableAsPublisher(with textView: UITextView) {
        let stream = Observable.from(Array(0...100))

        let id = "Observable as Publisher"

        textView.append(line: "🗞 \(id)")
        textView.append(line: "=====================")

        _ = stream
            .publisher
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        textView.append(line: "\(id) -> receive finished")
                        textView.append(line: "=========================\n")
                    case .failure(let error):
                        textView.append(line: "\(id) -> receive failure: \(error)")
                    }
                },
                receiveValue: { value in
                    textView.append(line: "\(id) -> receive value: \(value)")
                }
            )
    }

    func publisherAsObservable(with textView: UITextView) {
        let publisher = PassthroughSubject<Int, Swift.Error>()

        let id = "Publisher as Observable"

        textView.append(line: "👀 \(id)")
        textView.append(line: "=====================")

        _ = publisher
            .asObservable()
            .do(onDispose: {
                textView.append(line: "\(id) -> disposed")
                textView.append(line: "=========================\n")
            })
            .subscribe { event in
                switch event {
                case .next(let element):
                    textView.append(line: "\(id) -> next(\(element))")
                case .error(let error):
                    textView.append(line: "\(id) -> error(\(error))")
                case .completed:
                    textView.append(line: "\(id) -> completed")
                }
            }

        (0...100).forEach { publisher.send($0) }
        publisher.send(completion: .finished)
    }

    func relaysZippedInCombine(with textView: UITextView) {
        let relay1 = PublishRelay<Int>()
        let relay2 = BehaviorRelay<Int>(value: 0)

        let id = "Zipped Relays in Combine"

        textView.append(line: "🤐 \(id)")
        textView.append(line: "=====================")

        let subscription = Publishers.Zip(relay1.publisher, relay2.publisher)
            .dropFirst()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        textView.append(line: "\(id) -> receive finished")
                        textView.append(line: "=========================\n")
                    case .failure(let error):
                        textView.append(line: "\(id) -> receive failure: \(error)")
                    }
                },
                receiveValue: { value in
                    textView.append(line: "\(id) -> receive value: \(value)")
                }
            )

        let p1 = PassthroughSubject<Int, Swift.Error>()
        let p2 = PassthroughSubject<Int, Swift.Error>()

        _ = p1.asObservable().bind(to: relay1)
        _ = p2.asObservable().bind(to: relay2)


        (0...50).forEach { p1.send($0) }
        p1.send(completion: .finished)

        (0...50).reversed().forEach { p2.send($0) }
        p2.send(completion: .finished)
        
        subscription.cancel()
    }
}

private extension UITextView {
    func append(line: String) {
        text = text + "\n" + line
        let bottom = NSRange(location: text.count - 1, length: 1)
        scrollRangeToVisible(bottom)
    }
}
