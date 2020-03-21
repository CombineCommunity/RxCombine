//
//  RxRelaysToCombineTests.swift
//  RxCombineTests
//
//  Created by Shai Mishali on 21/03/2020.
//

import XCTest
import RxCombine
import RxSwift
import RxRelay
import Combine

class RxRelaysToCombineTests: XCTestCase {
    private var subscriptions = Set<AnyCancellable>()
    private var disposeBag = DisposeBag()

    override func setUp() {
        subscriptions = .init()
        disposeBag = DisposeBag()
    }

    // MARK: - Behavior Subject
    func testBehaviorRelayInitialReplay() {
        var completed = false
        var values = [Int]()

        let relay = BehaviorRelay(value: 1)

        relay
            .sink(receiveCompletion: { _ in completed = true },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        XCTAssertEqual(values, [1])
        XCTAssertFalse(completed)
    }

    func testBehaviorRelaysIgnoresCompletion() {
        var completed = false
        var completed2 = false
        var values = [Int]()
        var values2 = [Int]()

        let relay = BehaviorRelay(value: 1)

        relay
            .sink(receiveCompletion: { _ in completed = true },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        relay.send(2)
        relay.accept(3)

        relay
            .sink(receiveCompletion: { _ in completed2 = true },
                  receiveValue: { values2.append($0) })
            .store(in: &subscriptions)

        relay.accept(4)
        relay.send(5)
        relay.accept(6)

        XCTAssertEqual(values, [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(values2, [3, 4, 5, 6])

        XCTAssertFalse(completed)
        XCTAssertFalse(completed2)

        /// These should still emit as relays don't complete
        relay.send(4)
        relay.accept(4)
        relay.accept(4)

        XCTAssertEqual(values, [1, 2, 3, 4, 5, 6, 4, 4, 4])
        XCTAssertEqual(values2, [3, 4, 5, 6, 4, 4, 4])
    }

    func testBehaviorRelayBind() {
        let combineSubject = CurrentValueSubject<Int, Swift.Error>(-1)
        let source = BehaviorRelay(value: 0)
        var completed = false
        var values = [Int]()

        combineSubject
            .sink(receiveCompletion: { _ in completed = true },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        source
            .bind(to: combineSubject)
            .disposed(by: disposeBag)

        source.send(1)
        source.accept(2)
        source.accept(3)
        source.send(4)

        XCTAssertFalse(completed)

        XCTAssertEqual(values, [-1, 0, 1, 2, 3, 4])
    }

    // MARK: - Publish Relay
    func testPublishRelays() {
        var completed = false
        var completed2 = false
        var values = [Int]()
        var values2 = [Int]()

        let relay = PublishRelay<Int>()

        relay
            .sink(receiveCompletion: { _ in completed = true },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        relay.accept(1)
        relay.accept(2)
        relay.send(3)

        relay
            .sink(receiveCompletion: { _ in completed2 = true },
                  receiveValue: { values2.append($0) })
            .store(in: &subscriptions)

        relay.accept(4)
        relay.send(5)
        relay.accept(6)

        XCTAssertEqual(values, [1, 2, 3, 4, 5, 6])
        XCTAssertEqual(values2, [4, 5, 6])

        XCTAssertFalse(completed)
        XCTAssertFalse(completed2)
    }

    func testPublishRelayBind() {
        let combineSubject = PassthroughSubject<Int, Swift.Error>()
        let source = PublishRelay<Int>()
        var completed = false
        var values = [Int]()

        combineSubject
            .sink(receiveCompletion: { _ in completed = true },
                  receiveValue: { values.append($0) })
            .store(in: &subscriptions)

        source
            .bind(to: combineSubject)
            .disposed(by: disposeBag)

        source.accept(1)
        source.accept(2)
        source.send(3)
        source.accept(4)

        XCTAssertFalse(completed)
        XCTAssertEqual(values, [1, 2, 3, 4])
    }
}

