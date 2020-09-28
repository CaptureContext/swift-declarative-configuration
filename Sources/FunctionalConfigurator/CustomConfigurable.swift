import Foundation

public protocol CustomConfigurable {}

extension CustomConfigurable {
    public typealias Config = Configurator<Self>
    
    public func configured(using configuration: (Config.Type) -> Config) -> Self {
        configured(using: configuration(Config.self))
    }
    
    public func configured(using configurator: Config) -> Self {
        configurator.configure(self)
    }
}

extension CustomConfigurable where Self: AnyObject {
    public func configure(using configuration: (Config.Type) -> Config) {
        configure(using: configuration(Config.self))
    }
    
    public func configure(using configurator: Config) {
        configurator.configure(self)
    }
}

extension NSObject: CustomConfigurable {}
