//
//  RxSubjectsToCombineTests.swift
//  RxCombineTests
//
//  Created by Shai Mishali on 21/03/2020.
//  Copyright © 2019 Combine Community. All rights reserved.
//

import XCTest
import RxCombine
import RxSwift
import Combine

class RxSubjectsToCombineTests: XCTestCase {
    private var subscriptions = Set<AnyCancellable>()
    private var disposeBag = DisposeBag()

    override func setUp() {
        subscriptions = .init()
        disposeBag = DisposeBag()
    }

    // MARK: - Behavior Subject
    func testBehaviorSubjectInitialReplay() {
        var completion: Subscribers.Completion<Swift.Error>?
        var values = [Int]()

        let subject = BehaviorSubject(value: 1)

        subject
            .sink(receiveCompletion: { completion = $0 },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        XCTAssertEqual(values, [1])
        XCTAssertNil(completion)
    }

    func testBehaviorSubjectsCompleted() {
        var completion: Subscribers.Completion<Swift.Error>?
        var completion2: Subscribers.Completion<Swift.Error>?
        var values = [Int]()
        var values2 = [Int]()

        let subject = BehaviorSubject(value: 1)

        subject
            .sink(receiveCompletion: { completion = $0 },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        subject.send(2)
        subject.onNext(3)


        subject
            .sink(receiveCompletion: { completion2 = $0 },
                  receiveValue: { values2.append($0) })
            .store(in: &subscriptions)

        subject.onNext(4)
        subject.onNext(5)
        subject.send(6)

        XCTAssertEqual(values, [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(values2, [3, 4, 5, 6])

        XCTAssertNil(completion)
        XCTAssertNil(completion2)

        subject.send(completion: .finished)
        XCTAssertNotNil(completion)
        XCTAssertNotNil(completion2)
    }

    func testBehaviorSubjectsError() {
        var completion: Subscribers.Completion<Swift.Error>?
        var completion2: Subscribers.Completion<Swift.Error>?
        var values = [Int]()
        var values2 = [Int]()

        let subject = BehaviorSubject(value: 1)

        subject
            .sink(receiveCompletion: { completion = $0 },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        subject.send(2)
        subject.onNext(3)

        subject
            .sink(receiveCompletion: { completion2 = $0 },
                  receiveValue: { values2.append($0) })
            .store(in: &subscriptions)

        subject.onNext(4)
        subject.onNext(5)
        subject.send(6)

        XCTAssertNil(completion)
        XCTAssertNil(completion2)

        subject.send(completion: .failure(FakeError.ohNo))

        guard case .failure(FakeError.ohNo) = completion else {
            XCTFail("Expected \(FakeError.ohNo), got \(String(describing: completion))")
            return
        }

        guard case .failure(FakeError.ohNo) = completion2 else {
            XCTFail("Expected \(FakeError.ohNo), got \(String(describing: completion))")
            return
        }

        /// These should do nothing since observable was
        /// already terminated by error
        subject.onNext(4)
        subject.onNext(4)
        subject.onNext(4)

        XCTAssertEqual(values, [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(values2, [3, 4, 5, 6])
    }

    func testBehaviorSubjectBind() {
        let combineSubject = CurrentValueSubject<Int, Swift.Error>(-1)
        let source = BehaviorSubject(value: 0)
        var completion: Subscribers.Completion<Swift.Error>?
        var values = [Int]()

        combineSubject
            .sink(receiveCompletion: { completion = $0 },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        source
            .bind(to: combineSubject)
            .disposed(by: disposeBag)

        source.onNext(1)
        source.onNext(2)
        source.onNext(3)
        source.onNext(4)

        XCTAssertNil(completion)
        source.onError(FakeError.ohNo)

        XCTAssertEqual(values, [-1, 0, 1, 2, 3, 4])
        guard case .failure(FakeError.ohNo) = completion else {
            XCTFail("Expected \(FakeError.ohNo), got \(String(describing: completion))")
            return
        }
    }

    // MARK: - Publish Relay
    func testPublishSubjectsCompleted() {
        var completion: Subscribers.Completion<Swift.Error>?
        var completion2: Subscribers.Completion<Swift.Error>?
        var values = [Int]()
        var values2 = [Int]()

        let subject = PublishSubject<Int>()

        subject
            .sink(receiveCompletion: { completion = $0 },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        subject.send(1)
        subject.send(2)
        subject.onNext(3)

        subject
            .sink(receiveCompletion: { completion2 = $0 },
                  receiveValue: { values2.append($0) })
            .store(in: &subscriptions)

        subject.onNext(4)
        subject.onNext(5)
        subject.send(6)

        XCTAssertEqual(values, [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(values2, [4, 5, 6])

        XCTAssertNil(completion)
        XCTAssertNil(completion2)

        subject.send(completion: .finished)
        XCTAssertNotNil(completion)
        XCTAssertNotNil(completion2)
    }

    func testPublishSubjectsError() {
        var completion: Subscribers.Completion<Swift.Error>?
        var completion2: Subscribers.Completion<Swift.Error>?
        var values = [Int]()
        var values2 = [Int]()

        let subject = PublishSubject<Int>()

        subject
            .sink(receiveCompletion: { completion = $0 },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        subject.send(1)
        subject.send(2)
        subject.onNext(3)

        subject
            .sink(receiveCompletion: { completion2 = $0 },
                  receiveValue: { values2.append($0) })
            .store(in: &subscriptions)

        subject.onNext(4)
        subject.onNext(5)
        subject.send(6)

        XCTAssertNil(completion)
        XCTAssertNil(completion2)

        subject.send(completion: .failure(FakeError.ohNo))

        guard case .failure(FakeError.ohNo) = completion else {
            XCTFail("Expected \(FakeError.ohNo), got \(String(describing: completion))")
            return
        }

        guard case .failure(FakeError.ohNo) = completion2 else {
            XCTFail("Expected \(FakeError.ohNo), got \(String(describing: completion))")
            return
        }

        /// These should do nothing since observable was
        /// already terminated by error
        subject.onNext(4)
        subject.onNext(4)
        subject.onNext(4)

        XCTAssertEqual(values, [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(values2, [4, 5, 6])
    }

    func testPublishSubjectBind() {
        let combineSubject = PassthroughSubject<Int, Swift.Error>()
        let source = PublishSubject<Int>()
        var completion: Subscribers.Completion<Swift.Error>?
        var values = [Int]()

        combineSubject
            .sink(receiveCompletion: { completion = $0 },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        source
            .bind(to: combineSubject)
            .disposed(by: disposeBag)

        source.onNext(1)
        source.onNext(2)
        source.onNext(3)
        source.onNext(4)

        XCTAssertNil(completion)
        source.onError(FakeError.ohNo)

        XCTAssertEqual(values, [1, 2, 3, 4])
        guard case .failure(FakeError.ohNo) = completion else {
            XCTFail("Expected \(FakeError.ohNo), got \(String(describing: completion))")
            return
        }
    }

    func testPublishSubjectBindToCurrentValue() {
        let combineSubject = CurrentValueSubject<Int, Swift.Error>(0)
        let source = PublishSubject<Int>()
        var completion: Subscribers.Completion<Swift.Error>?
        var values = [Int]()

        combineSubject
            .sink(receiveCompletion: { completion = $0 },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        source
            .bind(to: combineSubject)
            .disposed(by: disposeBag)

        source.onNext(1)
        source.onNext(2)
        source.onNext(3)
        source.onNext(4)

        XCTAssertNil(completion)
        source.onCompleted()

        XCTAssertEqual(values, [0, 1, 2, 3, 4])
        guard case .finished = completion else {
            XCTFail("Expected .finished, got \(String(describing: completion))")
            return
        }
    }
}
