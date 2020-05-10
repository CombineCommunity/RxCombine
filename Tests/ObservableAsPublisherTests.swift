//
//  ObservableAsPublisherTests.swift
//  RxCombine
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
class ObservableAsPublisherTests: XCTestCase {
    private var subscription: AnyCancellable!

    func testIntObservable() {
        let source = Observable.range(start: 1, count: 100)
        var values = [Int]()
        var completed = false

        subscription = source
            .asPublisher()
            .sink(receiveCompletion: { _ in completed = true },
                  receiveValue: { values.append($0) })

        XCTAssertEqual(values, Array(1...100))
        XCTAssertTrue(completed)
    }

    func testStringObservable() {
        let input = "Hello world I'm a RxSwift Observable".components(separatedBy: " ")
        let source = Observable.from(input)
        var values = [String]()
        var completed = false

        subscription = source
            .asPublisher()
            .sink(receiveCompletion: { _ in completed = true },
                  receiveValue: { values.append($0) })

        XCTAssertEqual(values, input)
        XCTAssertTrue(completed)
    }

    func testFailingObservable() {
        let source = Observable.range(start: 1, count: 100)
        var values = [Int]()
        var completion: Subscribers.Completion<Swift.Error>?

        subscription = source
            .map { val in
                guard val < 15 else { throw FakeError.ohNo }
                return val
            }
            .asPublisher()
            .sink(receiveCompletion: { completion = $0 },
                  receiveValue: { values.append($0) })

        XCTAssertEqual(values, Array(1...14))
        XCTAssertNotNil(completion)
        guard case .failure(FakeError.ohNo) = completion else {
            XCTFail("Expected .failure(FakeError.ohNo), got \(String(describing: completion))")
            return
        }
    }

    func testDelayedEmissionsObservable() {
        let expect = expectation(description: "completion")
        var values = [Int]()
        var completed = false
        let source = Observable
            .from(1...10)
            .delay(.milliseconds(200), scheduler: MainScheduler.instance)
            .do(onCompleted: { expect.fulfill() })

        subscription = source
            .asPublisher()
            .sink(receiveCompletion: { _ in completed = true },
                  receiveValue: { values.append($0) })

        wait(for: [expect], timeout: 1.5)

        XCTAssertEqual(values, Array(1...10))
        XCTAssertTrue(completed)
    }
}

enum FakeError: Swift.Error {
    case ohNo
}
#endif
