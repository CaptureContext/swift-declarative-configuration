import Foundation

public protocol CustomConfigurable {}

extension CustomConfigurable {
  public typealias Config = Configurator<Self>

  public func configured(using configuration: (Config) -> Config) -> Self {
    configured(using: configuration(Config()))
  }

  public func configured(using configurator: Config) -> Self {
    configurator.configured(self)
  }
}

extension CustomConfigurable where Self: AnyObject {
  public func configure(using configuration: (Config) -> Config) {
    configure(using: configuration(Config()))
  }

  public func configure(using configurator: Config) {
    configurator.configure(self)
  }
}

extension NSObject: CustomConfigurable {}
