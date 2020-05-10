//
//  PublisherAsObservableTests.swift
//  RxCombineTests
//
//  Created by Shai Mishali on 21/03/2020.
//

#if !os(watchOS)
import XCTest
import RxCombine
import RxSwift
import Combine

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
class PublisherAsObservableTests: XCTestCase {
    private var disposeBag = DisposeBag()

    override func setUp() {
        disposeBag = .init()
    }

    func testIntPublisher() {
        let source = (1...100).publisher
        var events = [RxSwift.Event<Int>]()

        source
            .asObservable()
            .subscribe { events.append($0) }
            .disposed(by: disposeBag)

        XCTAssertEqual(events,
                       (1...100).map { .next($0) } + [.completed])
    }

    func testStringPublisher() {
        let input = "Hello world I'm a RxSwift Observable".components(separatedBy: " ")
        let source = input.publisher
        var events = [RxSwift.Event<String>]()

        source
            .asObservable()
            .subscribe { events.append($0) }
            .disposed(by: disposeBag)

        XCTAssertEqual(events, input.map { .next($0) } + [.completed])
    }

    func testFailingPublisher() {
        let source = (1...100).publisher
        var events = [RxSwift.Event<Int>]()

        source
            .setFailureType(to: FakeError.self)
            .tryMap { val -> Int in
                guard val < 15 else { throw FakeError.ohNo }
                return val
            }
            .asObservable()
            .subscribe { events.append($0) }
            .disposed(by: disposeBag)


        XCTAssertEqual(events, (1...14).map { .next($0) } + [.error(FakeError.ohNo)])
    }
}


extension RxSwift.Event: Equatable where Element: Equatable {
    public static func == (lhs: Event<Element>, rhs: Event<Element>) -> Bool {
        switch (lhs, rhs) {
        case let (.next(l), .next(r)):
            return l == r
        case (.error, .error),
             (.completed, .completed):
            return true
        default:
            return false
        }
    }
}
#endif
