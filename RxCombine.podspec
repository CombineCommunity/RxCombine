Pod::Spec.new do |s|
    s.name             = "RxCombine"
    s.version          = "2.0.1"
    s.summary          = "RxSwift is a Swift implementation of Reactive Extensions"
    s.description      = <<-DESC
  Bi-directional type conversions between RxSwift and Apple's Combine framework.
  ```
                          DESC
    s.homepage         = "https://github.com/freak4pc/RxCombine"
    s.license          = 'MIT'
    s.author           = { "Shai Mishali" => "freak4pc@gmail.com" }
    s.source           = { :git => "https://github.com/freak4pc/RxCombine.git", :tag => s.version.to_s }
  
    s.requires_arc     = true
  
    s.ios.deployment_target     = '9.0'
    s.osx.deployment_target     = '10.9'
    s.watchos.deployment_target = '3.0'
    s.tvos.deployment_target    = '9.0'
    
    s.source_files = 'Sources/**/*.swift'
    s.frameworks   = ['Combine']
    s.dependency 'RxSwift', '~> 6'
    s.dependency 'RxRelay', '~> 6'

    s.swift_version = '5.2'
  end