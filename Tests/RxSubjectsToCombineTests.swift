//
//  RxBehaviorSubjectToCombineTests.swift
//  RxCombineTests
//
//  Created by Shai Mishali on 21/03/2020.
//  Copyright © 2019 Combine Community. All rights reserved.
//

#if !os(watchOS)
import XCTest
import RxCombine
import RxSwift
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class RxBehaviorSubjectToCombineTests: XCTestCase {
    private var subscriptions = Set<AnyCancellable>()
    private var disposeBag = DisposeBag()

    override func setUp() {
        subscriptions = .init()
        disposeBag = DisposeBag()
    }

    func testBehaviorSubjectRxCombineInterop() {
        var rxValues = [Int]()
        var combValues = [Int]()

        var rxCompletion: RxSwift.Event<Int>?
        var combCompletion = false

        let rx = BehaviorSubject(value: 1)
        let combine = rx
            .toCombine()

        combine
            .map { $0 * $0 }
            .sink(receiveCompletion: { _ in combCompletion = true },
                  receiveValue: { combValues.append($0) })
            .store(in: &subscriptions)

        rx
        .map { $0 * $0 }
        .subscribe(onNext: { rxValues.append($0) },
                   onError: { rxCompletion = .error($0) },
                   onCompleted: { rxCompletion = .completed })
        .disposed(by: disposeBag)

        combine.send(10)
        combine.send(7)
        rx.onNext(2)
        rx.onNext(5)
        combine.send(11)
        combine.value = 60

        XCTAssertNil(rxCompletion)
        XCTAssertFalse(combCompletion)

        combine.send(completion: .finished)
        XCTAssertEqual(rxCompletion, .completed)
        XCTAssertTrue(combCompletion)

        /// These should do nothing since observable was
        /// already terminated by error
        rx.onNext(4)
        rx.onNext(4)
        rx.onNext(4)
        
        XCTAssertEqual(combValues, [1, 100, 49, 4, 25, 121, 3600])
        XCTAssertEqual(combValues, rxValues)
    }

    // MARK: - Behavior Subject
    func testBehaviorSubjectInitialReplay() {
        var completion: Subscribers.Completion<Swift.Error>?
        var values = [Int]()

        let subject = BehaviorSubject(value: 1).toCombine()

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

        let rx = BehaviorSubject(value: 1)
        let comb = rx.toCombine()

        comb
            .sink(receiveCompletion: { completion = $0 },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        comb.send(2)
        rx.onNext(3)

        rx
            .subscribe(onNext: { values2.append($0) },
                       onCompleted: { completion2 = .finished })
            .disposed(by: disposeBag)

        rx.onNext(4)
        rx.onNext(5)
        comb.send(6)

        XCTAssertEqual(values, [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(values2, [3, 4, 5, 6])

        XCTAssertNil(completion)
        XCTAssertNil(completion2)

        rx.onCompleted()
        XCTAssertNotNil(completion)
        XCTAssertNotNil(completion2)
    }

    func testBehaviorSubjectsError() {
        var completion: Subscribers.Completion<Swift.Error>?
        var completion2: Subscribers.Completion<Swift.Error>?
        var values = [Int]()
        var values2 = [Int]()

        let rx = BehaviorSubject(value: 1)
        let comb = rx.toCombine()

        comb
            .sink(receiveCompletion: { completion = $0 },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        comb.send(2)
        rx.onNext(3)

        rx
        .subscribe(onNext: { values2.append($0) },
                   onError: { completion2 = .failure($0) },
                   onCompleted: { completion2 = .finished })
        .disposed(by: disposeBag)

        rx.onNext(4)
        rx.onNext(5)
        comb.send(6)

        XCTAssertNil(completion)
        XCTAssertNil(completion2)

        comb.send(completion: .failure(FakeError.ohNo))

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
        rx.onNext(4)
        rx.onNext(4)
        comb.send(4)

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
    func testPublishSubjectRxCombineInterop() {
        var rxValues = [Int]()
        var combValues = [Int]()

        var rxCompletion: RxSwift.Event<Int>?
        var combCompletion = false

        let rx = PublishSubject<Int>()
        let combine = rx.toCombine()

        combine
            .map { $0 * $0 }
            .sink(receiveCompletion: { _ in combCompletion = true },
                  receiveValue: { combValues.append($0) })
            .store(in: &subscriptions)

        rx
        .map { $0 * $0 }
        .subscribe(onNext: { rxValues.append($0) },
                   onError: { rxCompletion = .error($0) },
                   onCompleted: { rxCompletion = .completed })
        .disposed(by: disposeBag)

        combine.send(10)
        combine.send(7)
        rx.onNext(2)
        rx.onNext(5)
        combine.send(11)

        XCTAssertNil(rxCompletion)
        XCTAssertFalse(combCompletion)

        combine.send(completion: .finished)
        XCTAssertEqual(rxCompletion, .completed)
        XCTAssertTrue(combCompletion)

        /// These should do nothing since observable was
        /// already terminated by error
        rx.onNext(4)
        rx.onNext(4)
        rx.onNext(4)

        XCTAssertEqual(combValues, [100, 49, 4, 25, 121])
        XCTAssertEqual(combValues, rxValues)
    }

    func testPublishSubjectsCompleted() {
        var completion: Subscribers.Completion<Swift.Error>?
        var completion2: Subscribers.Completion<Swift.Error>?
        var values = [Int]()
        var values2 = [Int]()

        let rx = PublishSubject<Int>()
        let comb = rx.toCombine()

        comb
            .sink(receiveCompletion: { completion = $0 },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        comb.send(2)
        rx.onNext(3)

        rx
            .subscribe(onNext: { values2.append($0) },
                       onCompleted: { completion2 = .finished })
            .disposed(by: disposeBag)

        rx.onNext(4)
        rx.onNext(5)
        comb.send(6)

        XCTAssertEqual(values, [2, 3, 4, 5, 6])
        XCTAssertEqual(values2, [4, 5, 6])

        XCTAssertNil(completion)
        XCTAssertNil(completion2)

        rx.onCompleted()
        XCTAssertNotNil(completion)
        XCTAssertNotNil(completion2)
    }

    func testPublishSubjectsError() {
        var completion: Subscribers.Completion<Swift.Error>?
        var completion2: Subscribers.Completion<Swift.Error>?
        var values = [Int]()
        var values2 = [Int]()

        let rx = PublishSubject<Int>()
        let comb = rx.toCombine()

        comb
            .sink(receiveCompletion: { completion = $0 },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        comb.send(2)
        rx.onNext(3)

        rx
        .subscribe(onNext: { values2.append($0) },
                   onError: { completion2 = .failure($0) },
                   onCompleted: { completion2 = .finished })
        .disposed(by: disposeBag)

        rx.onNext(4)
        rx.onNext(5)
        comb.send(6)

        XCTAssertNil(completion)
        XCTAssertNil(completion2)

        comb.send(completion: .failure(FakeError.ohNo))

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
        rx.onNext(4)
        rx.onNext(4)
        comb.send(4)

        XCTAssertEqual(values, [2, 3, 4, 5, 6])
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
#endif
