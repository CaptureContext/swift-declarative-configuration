import Foundation

/// Allows to intialize a new object without parameters or with configuration
public protocol ConfigInitializable {
  init()
}

extension ConfigInitializable {
  public typealias Config = Configurator<Self>

  /// Instantiates a new object with specified configuration
  ///
  /// Note: Type must implement custom intializer with no parameters, even if it inherits from NSObject
  @inlinable
  public init(config configuration: (Config) -> Config) {
    self.init(config: configuration(Config()))
  }

  /// Instantiates a new object with specified configuration
  ///
  /// Note: Type must implement custom intializer with no parameters, even if it inherits from NSObject
  public init(config configurator: Config) {
    self = configurator.configured(.init())
  }
}

public protocol ConfigInitializableNSObject: NSObjectProtocol {}
extension ConfigInitializableNSObject where Self: NSObject {
  public typealias Config = Configurator<Self>

  /// Instantiates a new object with specified configuration
  ///
  /// Note: Type must implement custom intializer with no parameters, even if it inherits from NSObject
  @inlinable
  public init(config configuration: (Config) -> Config) {
    self.init(config: configuration(Config()))
  }

  /// Instantiates a new object with specified configuration
  ///
  /// Note: Type must implement custom intializer with no parameters, even if it inherits from NSObject
  @inlinable
  public init(config configurator: Config) {
    self.init()
    configurator.configure(self)
  }
}

extension NSObject: ConfigInitializableNSObject {}
