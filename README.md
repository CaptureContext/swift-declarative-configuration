# Swift Declarative Configuration

[![Test](https://github.com/CaptureContext/swift-declarative-configuration/actions/workflows/Test.yml/badge.svg)](https://github.com/CaptureContext/swift-declarative-configuration/actions/workflows/Test.yml) [![SwiftPM 6.0](https://img.shields.io/badge/swiftpm-6.0-ED523F.svg?style=flat)](https://swift.org/download/) ![Platforms](https://img.shields.io/badge/platforms-iOS_11_|_macOS_10.13_|_tvOS_11_|_watchOS_4_|_Catalyst_13-ED523F.svg?style=flat) [![@capture_context](https://img.shields.io/badge/contact-@capture__context-1DA1F2.svg?style=flat&logo=twitter)](https://twitter.com/capture_context) 

Swift Declarative Configuration (SDC, for short) is a tiny library, that enables you to configure your objects in a declarative, consistent and understandable way, with ergonomics in mind. It can be used to configure any objects on any platform, including server-side-swift.

## Features

- **[Configurator](./Sources/DeclarativeConfiguration/Configurator/Configurator.swift)**

Functional configurator for anything, enables you to specify modification of an object and to apply the modification later. Primary way of declaring configurations for your objects.

- **[Builder](./Sources/DeclarativeConfiguration/Configurator/Builder.swift)**

Functional builder for anything, enables you to modify object instances in a declarative way. Also contains `BuilderProvider` protocol with a computed `builder` property and implements that protocol on `NSObject` type.vBuilder-style way of declaring configurations for your objects. Suitable for instantiated objects.

## Basic Usage

> **See tests for more**

### No SDC

```swift
class ImageViewController: UIViewController {
  let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.backgroundColor = .black
    imageView.layer.masksToBounds = true
    imageView.layer.cornerRadius = 10
    return imageView
  }()
    
  override func loadView() {
    self.view = imageView
  }
}
```

### Configurator

> [!NOTE]
> _This way is **recommended**._

```swift
import DeclarativeConfiguration

class ImageViewController: UIViewController {
  let imageView = UIImageView() { $0 
    .contentMode(.scaleAspectFit)
    .backgroundColor(.black)
    .layer.scope { $0
      .masksToBounds(true)
      .cornerRadius(10)
    }
  }
    
  override func loadView() {
    self.view = imageView
  }
}
```

### Builder

```swift
import DeclarativeConfiguration

class ImageViewController: UIViewController {
  let imageView = UIImageView().builder
    .contentMode(.scaleAspectFit)
    .backgroundColor(.black)
    .layer.masksToBounds(true)
    .layer.cornerRadius(10)
    .build()
    
  override func loadView() {
    self.view = imageView
  }
}
```

### FunctionalModification

- `reduce(_:with:)`:

  ```swift
  import DeclarativeConfiguration

  struct CounterState {
    var value: Int = 0
  }
  
  let state = CounterState()
  let newState = reduce(state) {
    // $0 is a mutable copy of the first argument
    // mutated object is returned
    $0.value += 1
  }
  ```


### FunctionalClosures

> [!WARNING]
> _Deprecated_

### No SDC

**Declaration**

```swift
public class TapGestureRecognizer: UITapGestureRecognizer {
  var onTapGesture: ((TapGestureRecognizer) -> Void)?
    
  init() {
    super.init(target: nil, action: nil)
    commonInit()
  }
    
  override public init(target: Any?, action: Selector?) {
    super.init(target: target, action: action)
    commonInit()
  }
    
  private func commonInit() {
    self.addTarget(self, action: #selector(handleTap))
  }
    
  @objc private func handleTap(_ recognizer: TapGestureRecognizer) {
    onTapGesture?(recognizer)
  }
}
```

**Usage**

```swift
let tapRecognizer = TapGestureRecognizer()

// handler setup
tapRecognizer.onTapGesture = { recognizer in
	// ...
}

// call from the outside
tapRecognizer.onTapGesture?(tapRecognizer)
```

### With SDC

**Declaration**

```swift
public class TapGestureRecognizer: UITapGestureRecognizer {
  @Handler1<TapGestureRecognizer>
  var onTapGesture
    
  init() {
    super.init(target: nil, action: nil)
    commonInit()
  }
    
  override public init(target: Any?, action: Selector?) {
    super.init(target: target, action: action)
    commonInit()
  }
    
  private func commonInit() {
    self.addTarget(self, action: #selector(handleTap))
  }
    
  @objc private func handleTap(_ recognizer: TapGestureRecognizer) {
    _onTapGesture(recognizer)
  }
}
```

**Usage**

```swift
let tapRecognizer = TapGestureRecognizer()

// handler setup now called as function
tapRecognizer.onTapGesture { recognizer in
	// ...
}

// call from the outside now uses propertyWrapper projectedValue API, which is not as straitforward
// and it is nice, because:
// - handlers usually should not be called from the outside
// - you do not lose the ability to call it, but an API tells you that it's kinda private
tapRecognizer.$onTapGesture?(tapRecognizer)
```

Also you can create such an instance with `Configurator`:

```swift
let tapRecognizer = TapGestureRecognizer { $0 
  .$onTapGesture { recognizer in 
    // ...
  }
}
```

If your deployment target is iOS 17+ (or other platform with a corresponding version) you can use beta variadic generic `_Handler` type

### More

Customize any object by passing initial value to a builder

```swift
let object = Builder(Object())
  .property.subproperty(value)
  .build() // Returns modified object
```

For classes you can avoid returning a value by calling `apply` method, instead of `build`

```swift
let _class = _Class()
Builder(_class)
  .property.subproperty(value)
  .apply() // Returns Void
```

In both Builders and Configurators you can use scoping

```swift
let object = Object { $0
  .property.subproperty(value)
}
```

or batch-scoping

```swift
let object = Object { $0
  .property.scope { $0 
    .subproperty1(value)
    .subproperty2(value)
  }
}
```

```swift
let object = Object { $0
  .property.ifLetScope { $0 // if property is optional
    .subproperty1(value)
    .subproperty2(value)
  }
}
```

Conform your own types to `BuilderProvider` protocol to access builder property.

```swift
import CoreLocation
import DeclarativeConfiguration

extension CLLocationCoordinate2D: BuilderProvider {}
// Now you can access `location.builder.latitude(0).build()`
```

## Installation

### Basic

You can add DeclarativeConfiguration to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
2. Enter [`"https://github.com/capturecontext/swift-declarative-configuration"`](https://github.com/capturecontext/swift-declarative-configuration) into the package repository URL text field
3. Choose products you need to link them to your project.

### Recommended

If you use SwiftPM for your project structure, add DeclarativeConfiguration to your package file. 

```swift
.package(
  url: "git@github.com:capturecontext/swift-declarative-configuration.git",
  .upToNextMinor(from: "1.0.0-beta.1")
)
```

or via HTTPS

```swift
.package(
  url: "https://github.com:capturecontext/swift-declarative-configuration.git", 
  .upToNextMinor(from: "1.0.0-beta.1")
)
```

Do not forget about target dependencies:

```swift
.product(
  name: "DeclarativeConfiguration", 
  package: "swift-declarative-configuration"
)
```

## License

This library is released under the MIT license. See [LICENSE](./LICENSE) for details.
