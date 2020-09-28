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
    public init(_ configuration: (Config.Type) -> Config) {
        self.init(configuration(Config.self))
    }
    
    /// Instantiates a new object with specified configuration
    ///
    /// Note: Type must implement custom intializer with no parameters, even if it inherits from NSObject
    public init(_ configurator: Config) {
        self = configurator.configure(.init())
    }
}

extension NSObject: ConfigInitializable {}
