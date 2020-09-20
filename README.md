# Swift Declarative Configuration

[![Swift 5.3](https://img.shields.io/badge/swift-5.3-ED523F.svg?style=flat)](https://swift.org/download/) [![SwiftPM](https://img.shields.io/badge/SwiftPM-ED523F.svg?style=flat)](https://swift.org/package-manager/) [![@maximkrouk](https://img.shields.io/badge/contact-@maximkrouk-ED523F.svg?style=flat)](https://twitter.com/maximkrouk)

Swift Declarative Configuration (SDC, for short) is a tiny library, that enables you to configure your objects in a declarative, consistent and understandable way, with ergonomics in mind. It can be used to configure any objects on any platform, including server-side-swift.

## Products

- **[FunctionalModification](./Sources/FunctionalModification)**

  Provides modification functions for copying and modifying immutable stuff. It is useful for self-configuring objects like builder, when modificating methods should return modified `self`

- **[FunctionalKeyPath](./Sources/FunctionalKeyPath)** & **[CasePaths](https://github.com/pointfreeco/swift-case-paths)**

  KeyPath functional wrappers, one is generalized and the other is for enums. [CasePath is a dependency](https://github.com/pointfreeco/swift-case-paths).

- **[FunctionalConfigurator](./Sources/FunctionalConfigurator)**

  Funtional configurator for anything, enables you to specify modification of an object and to apply the modification later.

- **[FunctionalBuilder](./Sources/FunctionalBuilder)**

  Functional builder for anything, enables you to modify object instances in a declarative way. Also contains BuilderProvider protocol with a computed `builder` property and implements that protocol on NSObject type.

- **[DeclarativeConfiguration](./Sources/DeclarativeConfiguration)**

  Wraps and exports all the products.

## Basic Usage

### UIKit & FunctionalConfigurator

Maybe it worth to make another abstraction over configurator for UI setup, but for example I'll be using pure version.

```swift
import FunctionalConfigurator

class ImageViewController: UIViewController {
    enum StyleSheet {
        static let imageView = Configurator<UIImageView>
            .contentMode(.scaleAspectFit)
            .backgroundColor(.black)
            .layer.masksToBounds(true)
            .layer.cornerRadius(10)
    }
    
    let imageView: UIImageView = .init()
    
    override func loadView() {
        self.view = imageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StyleSheet.imageView.configure(imageView)
    }
}
```

### UIKit & FunctionalBuilder
```swift
import FunctionalBuilder

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

### Modification

```swift
import FunctionalModification

struct MyModel {
    var value1 = 0
    init() {}
}

let model_0 = MyModel()
let model_1 = modification(of: model_0) { $0.value = 1 }

import UIKit

extension UIView {
    @discardableResult
    func cornerRadius(_ value: CGFloat) -> Self {
        modification(of: self) { view in
            view.layer.cornerRadius = value
            view.layer.masksToBounds = true
        }
    }
}
```

## Installation

### Basic

You can add DeclarativeConfiguration to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Swift Packages › Add Package Dependency…**
2. Enter "https://github.com/makeupstudio/swift-declarative-configuration" into the package repository URL text field
3. Choose products you need to link them to your project.

### Recommended

If you use SwiftPM for your project, you can add DeclarativeConfiguration to your package file. Also my advice will be to use SSH.

```swift
.package(
    url: "git@github.com:makeupstudio/swift-declarative-configuration.git", 
    from: "0.0.1"
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