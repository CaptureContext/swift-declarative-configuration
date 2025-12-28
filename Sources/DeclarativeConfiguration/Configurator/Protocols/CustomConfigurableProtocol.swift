import Foundation

public protocol CustomConfigurableProtocol: _BaseConfigurableProtocol {}

extension CustomConfigurableProtocol {
	@inlinable
	public func configured(
		using configuration: (Config) -> Config
	) -> Self {
		configured(using: configuration(.empty))
	}
	
	@inlinable
	public func configured(
		using configurator: Config
	) -> Self {
		configurator.configured(self)
	}

	@inlinable
	public mutating func configure(
		using configuration: (Config) -> Config
	) {
		self = configured(using: configuration(.empty))
	}

	@inlinable
	public mutating func configure(
		using configurator: Config
	) {
		self = configured(using: configurator)
	}
}

extension CustomConfigurableProtocol where Self: AnyObject {
	@inlinable
	public func configure(
		using configuration: (Config) -> Config
	) {
		configure(using: configuration(.empty))
	}
	
	@inlinable
	public func configure(
		using configurator: Config
	) {
		configurator.configure(self)
	}
}
