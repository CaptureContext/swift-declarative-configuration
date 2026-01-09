# swift-declarative-configuration

[![Test](https://github.com/CaptureContext/swift-declarative-configuration/actions/workflows/Test.yml/badge.svg)](https://github.com/CaptureContext/swift-declarative-configuration/actions/workflows/Test.yml) [![SwiftPM 6.2](https://img.shields.io/badge/swiftpm-6.2_|_5.10-ED523F.svg?style=flat)](https://swift.org/download/) ![Platforms](https://img.shields.io/badge/platforms-iOS_11_|_macOS_10.13_|_tvOS_11_|_watchOS_4_|_Catalyst_13-ED523F.svg?style=flat) [![@capture_context](https://img.shields.io/badge/contact-@capture__context-1DA1F2.svg?style=flat&logo=twitter)](https://twitter.com/capture_context) 

**DeclarativeConfiguration** provides a declarative, fluent way to configure objects and values in Swift. It enables expressive inline configuration, composable setup logic, and consistent configuration patterns across codebases.

## Table of Contents

- [Motivation](#motivation)
- [The Problem](#the-problem)
- [The Solution](#the-solution)
- [Usage](#usage)
  - [Inline configuration](#inline-configuration)
  - [Reusable configuration](#reusable-configuration)
  - [Composition](#composition)
  - [Application](#application)
  - [Scoped configuration](#scoped-configuration)
  - [Optionals](#optionals)
  - [Custom types](#custom-types)
  - [Builder](#builder)
  - [Known issues](known-issues)
- [Installation](#installation)
- [Migration notes](#migration-notes)
- [License](#license)

## Motivation

Configuring objects in Swift is usually done imperatively, especially in frameworks like Cocoa:

```swift
let label = UILabel()
label.text = "Hello"
label.numberOfLines = 0
label.textAlignment = .center
```

This style is simple, but it does not scale well. As configuration grows, setup code becomes verbose, repetitive, and hard to keep consistent across a codebase.

To improve ergonomics, projects often introduce fluent helpers or proxy types. These approaches can make configuration more readable, but they are difficult to generalize and maintain as APIs evolve.

Inspired by declarative APIs like SwiftUI, DeclarativeConfiguration improves the ergonomics of object configuration, focusing on expressive and consistent inline setup without per-type helper APIs.

## The Problem

Imperative configuration works well for small setups, but it gets noisy as configuration grows, and it is easy to repeat the same patterns across a codebase.

```swift
let label = UILabel()
label.text = "Title"
label.font = .preferredFont(forTextStyle: .headline)
label.textColor = .secondaryLabel
label.numberOfLines = 0
```

A common alternative is the “closure initializer” pattern, which keeps setup local, but does not help with composition or reuse.

```swift
let label: UILabel = {
  let label = UILabel()
  // configuration
  return label
}()
```

Another popular approach is using small helpers like [Then](https://github.com/devxoul/Then), which improve ergonomics, but still relies on imperative assignments and does not naturally compose configuration beyond the closure.
```swift
let label = UILabel().then {
  $0.textAlignment = .center
  $0.textColor = .black
  $0.text = "Hello, World!"
}
```

Extracting styles into functions can be a bit more composable, but may pollute types' namespaces and still rely on imperative assignments.

```swift
extension UILabel {
  func centeredMultiline() -> Self {
    self.textAlignment = .center
    self.numberOfLines = 0
    return self
  }
}
```

Finally, some projects build fluent proxy types to get a chainable API. This can look great at the call site, but it is difficult to scale because it usually requires per-type and per-property wrappers that must be kept in sync with the underlying framework. Such proxies are also rarely lazy as well as previously mentioned approaches, meaning they depend on an already instantiated object rather than representing configuration as a standalone concept.

```swift
protocol _UIViewProtocol: UIView {}
extension UIView: _UIViewProtocol {}

extension _UIViewProtocol {
  var proxy: CocoaViewProxy<Self> { .init(base: self) }
}

struct CocoaViewProxy<Base: UIView> {
  var base: Base
}

extension CocoaViewProxy where Base: UILabel {
  func text(_ value: String?) -> Self {
    base.text = value
    return self
  }
}
```

What’s missing is a generic approach that keeps configuration readable inline, enables composition when it is needed, and avoids maintaining a growing surface area of per-type helper APIs.

## The Solution

DeclarativeConfiguration provides a set of tools to address these problems. The thought process behind its design is fairly straightforward:

- Generic configuration can be represented as a sequence of `(Value) -> Value` transformations
- Function types in Swift are non-nominal, which means they can't be extended and using plain `(Value) -> Value` would greatly limit API options, that's why we need to wrap it into a wrapper type
- Wrapper type can provide convenient accessors for all configurable properties by leveraging  [`@dynamicMemberLookup` attribute](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes#dynamicMemberLookup)
- Wrapper type can help get rid of imperative assignments with [`callAsFunction` method](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/declarations/#Methods-with-Special-Names)
- Wrapper type can provide helpers for scoping values and processing optionals

## Usage

### Inline configuration

The most common way to use DeclarativeConfiguration is for inline object setup.

Instead of mutating an object step by step, configuration can be expressed as a single, readable block at the call site. Simply call your object as a function with a configuration block.

```swift
let label = UILabel() { $0
  .text("Hello")
  .textAlignment(.center)
  .textColor(.secondaryLabel)
  .numberOfLines(0)
}
```

Inline configuration works especially well for views and other objects with many configurable properties, where setup code would otherwise become noisy or repetitive.

There are also a few methods that provide imperative access to the current value:

- Mutable modification: `.intProperty.modify { $0 += 1 }`
- Immutable transformation: `.intProperty.transform { $0 + 1 }`
- Peeking: `property.peek { print($0) }`

The last one is a primary escape path for calling methods when needed:

```swift
.button.peek { $0.setTitle("Title") }
```

### Reusable configuration

Inline configuration works well for one-offs, but configurations can also be extracted and reused.

#### Declaration

A `Configurator` can be defined as a static value and applied wherever it is needed.

```swift
extension Configurator where Base: UILabel {
  @MainActor
  static var title: Self {
    .init { $0
      .font(.preferredFont(forTextStyle: .title))
      .textColor(.label)
      .numberOfLines(0)
      .textAlignment(.center)
    }
  }
}
```

You can also simplify declarations by scoping them to the exact type.

> [!NOTE]
>
> _Such configurations won't be available to subclasses_

```swift
extension Configurator<SomeFinalClassView> {
  @MainActor
  static var debugGreeting: Self {
    .init { $0
       .customTitle("Hello, World!")
       .backgroundColor(.red)
    }
  }
}
```

### Composition

Configurations can be combined to create new ones.

- Using `combined(with:)` method
- By appending configuration items directly

Application order matches the declaration order, so you can override values.

```swift
extension Configurator where Base: UILabel {
  @MainActor
  static func blackTitle(alpha: CGFloat = 1) -> Self {
    .init { $0
      .combined(with: .title)
      .textColor(.black.withAlphaComponent(alpha))
    }
  }

  @MainActor
  static func whiteTitle(alpha: CGFloat = 1) -> Self {
    .title.textColor(.white.withAlphaComponent(alpha))
  }
}
```

### Application

Configurations can be combined inside an inline block:

```swift
let label = UILabel() { $0
  .combined(with: .title)
  .text("Hello")
}
```

Or applied directly:

```swift
let label = UILabel().configured(using: .title.text("Hello"))
```

Depending on the situation, configurations can also be applied via:

- `config.configure(object)`
- `config.configured(object)`
- `config.configure(&value)`

### Scoped configuration

Some properties expose nested objects that require their own configuration. Scoped configuration allows applying configuration to such nested values without breaking the fluent style.

Instead of reaching into nested objects imperatively:

```swift
let view = UIView()
view.layer.cornerRadius = 8
view.layer.cornerCurve = .continuous
view.layer.borderWidth = 1
view.layer.borderColor = UIColor.separator.cgColor
```

You can scope configuration to a nested property:

```swift
let view = UIView() { $0
  .layer.scope { $0
    .cornerRadius(8)
    .cornerCurve(.continuous)
    .borderWidth(1)
    .borderColor(.separator)
  }
}
```

Scoped configuration keeps related configuration grouped together and avoids repeating access paths at the call site.

Scopes can also be used inside reusable configurations:

```swift
extension Configurator where Base: UIView {
  @MainActor
  static func rounded(
    radius: CGFloat,
    curve: UICornerCurve = .continuous
  ) -> Self {
    .empty.layer.scope { $0
      .cornerRadius(radius)
      .cornerCurve(curve)
    }   
  }
}
```

Scopes compose naturally with other configuration features, including reuse and conditional configuration.

### Optionals

Since the `?` operator in Swift is reserved for optional unwrapping and cannot be overloaded, optional properties in DeclarativeConfiguration are accessed by unwrapping them using the `ifLet` operator.

```swift
.optionalProperty.ifLet.subproperty(1)
```

There is also an equivalent function:

```swift
.ifLet(\.optionalProperty).subproperty(1)
```

Same applies to scoping optional properties

```swift
.optionalProperty.ifLet.scope { $0 
  .subproperty1(value1)
  .subproperty2(value2)
}
```

`ifLet` only applies trailing configuration if property value is not `nil`, if you want to specify `defaultValue` you can use `ifLet(else:)`

```swift
.optionalInt.ifLet(else: 0).modify { $0 += 1 }
```

#### Conditional application

Optional values can be applied conditionally using `.property(ifLet: value)` API

```swift
let subtitle: String? = "Hello"

let label = UILabel() { $0
  .text(ifLet: subtitle) // applied only if subtitle != nil
}
```

There is also a helper that will register value update only if current value is `nil`

```swift
.optionalInt.ifNil(0)
```

### Custom types

All APIs are already available for `NSObject` subclasses. To enable DeclarativeConfiguration for custom types, conform them to `DefaultConfigurableProtocol`.

```swift
extension CustomType: DefaultConfigurableProtocol {}
```

### Builder

`Configurator` is the primary API. Builder is provided for cases where you prefer instance-bound, imperative configuration with chaining.

```swift
let label = UILabel().builder
  .text("Hello")
  .textAlignment(.center)
  .textColor(.secondaryLabel)
  .build()
```

> `Builder` object can also be instantiated with `Base` value and `Configurator`
> 
> ```swift
> Builder(UILabel())
> Builder(initialValue: { UILabel() }, configuration: initialConfigurator)
> ```

`.builder` property is available for all NSObject subclasses, custom types must conform to `BuilderProvider` protocol

```swift
extension CustomType: BuilderProvider {}
```

`Builder` supports same scoping mechanisms as `Configurator`, and has a few additional methods since it already has access to `Base` value:

- `builder.commit()`  – Applies current configuration to a current `Base` value and returns a new builder with the updated value and empty configuration.
- `builder.apply()` – Applies current configuration to reference type `Base` without returning the value, useful for silencing _"Result of call to 'build()' is unused"_ warning.

### Known Issues

> [!WARNING]
>
> The following API won't call configuration block for some reason
> ```swift
> struct Example: DefaultConfigurableProtocol {
>   var property: Int = 0
> }
> 
> // Implicit type inference on the rhs of the expression
> let example: Example = .init() { $0
>   .property(1)
> }
> ```
>
> Workarounds:
>
> - Use explicit type on the rhs of the expression:
>
>   ```swift
>   let example = Example() { $0
>     .property(1)
>   }
>   ```
>
> - Use `.configured` or `.self` or `.callAsFunction` after initializer
>
>   ```swift
>   let example: Example = .init().configured { $0
>     .property(1)
>   }
>   ```
>
> Looks like a bug in Swift 🫠

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
  .upToNextMinor(from: "0.5.0")
)
```

or via HTTPS

```swift
.package(
  url: "https://github.com:capturecontext/swift-declarative-configuration.git", 
  .upToNextMinor(from: "0.5.0")
)
```

Do not forget about target dependencies:

```swift
.product(
  name: "DeclarativeConfiguration", 
  package: "swift-declarative-configuration"
)
```

## Migration notes

The package got major API and package structure changes in `0.4.0`,  here is a list of potential issues when migrating from `0.3.x`

> [!NOTE]
>
> _If your migration wasn't intentional you should ensure that you depend on `.upToNextMinor` version as advised in the [installation](#installation) section_

#### Package structure

Old:

- `DeclarativeConfiguration` (umbrella module)
  - `FunctionalBuilder`
  - `FunctionalConfigurator`
  - `FunctionalClosures`
  - `FunctionalModification`

New:

- `DeclarativeConfiguration`
- `DeclarativeConfigurationCore`
- Deprecated:
  - `FunctionalBuilder`
    - exports `DeclarativeConfiguration`
  - `FunctionalConfigurator`
    - exports `DeclarativeConfiguration`
  - `FunctionalModification`
    - exports `DeclarativeConfiguration`
  - `FunctionalClosures`

>  Main features of deprecated modules excluding `FunctionalClosures` are now declared right in `DeclarativeConfiguration` module.


#### Protocols

- `CustomConfigurable`

- `ConfigInitializable`

- `__ConfigInitializableNSObject`

These protocols are still available through deprecated [`FunctionalConfigurator` module](Sources/Deprecated/FunctionalConfigurator/Deprecated/Protocols), but this module is [no longer a part of `DeclarativeConfiguration` product](#package-structure) and has to be declared as a separate dependency

#### FunctionalClosures

`Delegates` < `Closures` < `Publishers/Observation/AsyncSequences`

The module was experimental at the first place and now with a new set of tools in Swift it's probably time to accept that it's not needed anymore, feel free to discuss it in [FunctionalClosures discussion](https://github.com/CaptureContext/swift-declarative-configuration/discussions/7).

It's [no longer a part of `DeclarativeConfiguration` product](#package-structure), however `FunctionalClosures` product is still available. Consider migrating to modern approaches or simply copying sources. 

#### FunctionalKeyPath

Primary goal for this module was dealing with optional keyPaths, since `writableKeyPath.appending(path: \.optionalProperty?.subproperty)` is never writable and also it may be tricky to unwrap a keyPath through an optional value. However we found a way to use `subscript`s to achieve this with native `KeyPaths` and extracted our helpers into a separate [swift-keypaths-extensions package](https://github.com/capturecontext/swift-keypaths-extensions).

It's [no longer a part of `DeclarativeConfiguration` product](#package-structure), however `FunctionalKeyPath` product is still available. Consider migrating to native keyPaths or simply copying sources.

## License

This library is released under the MIT license. See [LICENSE](./LICENSE) for details.
