# RxCombine

<p align="center">
<img src="Resources/logo.png" width="220-">
<br /><br />
<a href="https://cocoapods.org/pods/RxCombine" target="_blank"><img src="https://img.shields.io/cocoapods/v/RxCombine.svg"></a>
<a href="https://github.com/apple/swift-package-manager" target="_blank"><img src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg"></a><br />
<img src="https://img.shields.io/badge/platforms-iOS%20%7C%20macOS%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-333333.svg" />


</p>

RxCombine provides bi-directional type bridging between [RxSwift](https://github.com/ReactiveX/RxSwift.git) and Apple's [Combine](https://developer.apple.com/documentation/combine) framework.

**Note**: This is highly experimental, and basically just a quickly-put-together MVP. I gladly except PRs, ideas, opinions, or improvements. Thank you ! :)

# I want to ...

## Use RxSwift in my Combine code

RxCombine provides several helpers and conversions to help you bridge your existing RxSwift types to Combine.

* `Observable` (and other `ObservableConvertibleType`s) have a  `publisher` property which which returns a `AnyPublisher<Element, Swift.Error>` mirroring the underlying `Observable`.

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


## Use Combine types in my RxSwift code

RxCombine provides several helpers and conversions to help you bridge Combine code and types into your existing RxSwift codebase.

* `Publisher`s have a `asObservable()` method, providing an `Observable<Output>` mirroring the underlying `Publisher`.
```swift

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
let relay = PublishRelay<Int>()

// Convert a RxSwift Observable to a AnyPubliser<Int, Swift.Error>
// and bind it back to a PublishRelay<Int> 🤯🤯🤯
publisher.asObservable()
         .bind(to: relay) // Disposable

publisher.asObservable()
         .susbcribe(to: relay.asAnyObserver()) // Disposable
```

# Future ideas

* Add CI / Tests
* Bridge SwiftUI with RxCocoa/RxSwift
* Partial Backpressure support, perhaps?
* ... your ideas? :)

# License

MIT, of course ;-) See the [LICENSE](LICENSE) file. 

The Apple logo and the Combine framework are property of Apple Inc.