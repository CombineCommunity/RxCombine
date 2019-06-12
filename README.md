# RxCombine

<p align="center">
<img src="https://github.com/freak4pc/RxCombine/raw/master/Resources/logo.png" width="220">
<br /><br />
<a href="https://cocoapods.org/pods/RxCombine" target="_blank"><img src="https://img.shields.io/cocoapods/v/RxCombine.svg?1"></a>
<a href="https://github.com/apple/swift-package-manager" target="_blank"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg"></a><br />
<img src="https://img.shields.io/badge/platforms-iOS%2013.0%20%7C%20macOS%2010.15%20%7C%20tvOS%2013.0%20%7C%20watchOS%206%20%7C%20Linux-333333.svg" />
</p>

RxCombine provides bi-directional type bridging between [RxSwift](https://github.com/ReactiveX/RxSwift.git) and Apple's [Combine](https://developer.apple.com/documentation/combine) framework.

**Note**: This is highly experimental, and basically just a quickly-put-together PoC. I gladly except PRs, ideas, opinions, or improvements. Thank you ! :)

## Basic Examples

Check out the Example App in the **ExampleApp** folder. Run `pod install` before opening the project.

<p align="center"><img src="https://github.com/freak4pc/RxCombine/raw/master/Resources/example.gif" width="400"></p>

## Installation

### CocoaPods

Add the following line to your **Podfile**:

```rb
pod 'RxCombine'
```

### Swift Package Manager

Add the following dependency to your **Package.swift** file:

```swift
.package(url: "https://github.com/freak4pc/RxCombine.git", from: "1.0.0")
```

### Carthage

No Carthage support yet. I hope to have the time to take care of it soon. 

Feel free to open a PR ! 

## I want to ...

### Use RxSwift in my Combine code

RxCombine provides several helpers and conversions to help you bridge your existing RxSwift types to Combine.

**Note**: If you want to learn more about the parallel operators in Combine from RxSwift, check out my [RxSwift to Combine Cheat Sheet](https://medium.com/gett-engineering/rxswift-to-apples-combine-cheat-sheet-e9ce32b14c5b) *(or on [GitHub](https://github.com/freak4pc/rxswift-to-combine-cheatsheet))*.

* `Observable` (and other `ObservableConvertibleType`s) have a  `publisher` property which returns a `AnyPublisher<Element, Swift.Error>` mirroring the underlying `Observable`.

```swift
let observable = Observable.just("Hello, Combine!")

observable
    .publisher // AnyPublisher<String, Swift.Error>
    .sink(receiveValue: { value in ... })
```

* `Relays` and `Subjects` conform to `Combine.Subject`, so you can use them as if they are regular Combine Subjects.

```swift
let relay = BehaviorRelay<Int>(value: 0)

// Use `sink` on RxSwift relay
relay
    .sink(receiveValue: { value in ... })

// Use `send(value:)` on RxSwift relay
relay.send(1)
relay.send(2)
relay.send(3)
```

### Use Combine in my RxSwift code

RxCombine provides several helpers and conversions to help you bridge Combine code and types into your existing RxSwift codebase.

* `Publisher`s have a `asObservable()` method, providing an `Observable<Output>` mirroring the underlying `Publisher`.
```swift
// A publisher publishing numbers from 0 to 100.
let publisher = AnyPublisher<Int, Swift.Error> { subscriber in
    (0...100).forEach { _ = subscriber.receive($0) }
    subscriber.receive(completion: .finished)
}

publisher
    .asObservable() // Observable<Int>
    .subscribe(onNext: { num in ... })
```

* `PassthroughSubject` and `CurrentValueSubject` both have a `asAnyObserver()` method which returns a `AnyObserver<Output>`. Binding to it from your RxSwift code pushes the events to the underlying Combine Subject.

```swift
// Combine Subject
let subject = PassthroughSubject<Int, Swift.Error>()

// A publisher publishing numbers from 0 to 100.
let publisher = AnyPublisher<Int, Swift.Error> { subscriber in
    (0...100).forEach { _ = subscriber.receive($0) }
    subscriber.receive(completion: .finished)
}

// Convert a Publisher to an Observable and bind it
// back to a Combine Subject 🤯🤯🤯
publisher.asObservable()
         .bind(to: subject)

Observable.of(10, 5, 7, 4, 1,  6)
          .subscribe(subject.asAnyObserver())
```

## Future ideas 

* Add CI / Tests
* Carthage Support
* Bridge SwiftUI with RxCocoa/RxSwift
* Partial Backpressure support, perhaps?
* ... your ideas? :)

## License

MIT, of course ;-) See the [LICENSE](LICENSE) file. 

The Apple logo and the Combine framework are property of Apple Inc.