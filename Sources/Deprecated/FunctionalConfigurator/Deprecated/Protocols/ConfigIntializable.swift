import Foundation
import DeclarativeConfiguration

/// Do not use this protocol, it will be removed in future versions
///
/// It's an implementation detail used to silence implementation warnings for
/// `ConfigInitializable` protocol, however this one will
/// also be removed in favor of `CallAsFunctionConfigurableProtocol` in `1.0.0`
///
/// - Note: Use `DefaultConfigurableProtocol` instead
public protocol ___ConfigInitializableProtocol_DEPRECATED: CallAsFunctionConfigurableProtocol {
	init()
}

@available(
	*, deprecated,
	message: """
	Use `DefaultConfigurableProtocol` instead.
	
	FunctionalConfigurator module is deprecated and will be removed in v1.0.0
	Use `import DeclarativeConfiguration` instead
	"""
)
public typealias ConfigInitializable = ___ConfigInitializableProtocol_DEPRECATED

extension ___ConfigInitializableProtocol_DEPRECATED {
	@available(
	*, deprecated,
	message: """
	Use `.init().configured(using: config) instead
	
	FunctionalConfigurator module is deprecated and will be removed in v1.0.0
	Use `import DeclarativeConfiguration` instead
	"""
	)
	/// Instantiates a new object with specified configuration
	///
	/// Note: Type must implement custom intializer with no parameters, even if it inherits from NSObject
	public init(config configurator: Config) {
		self = configurator.configured(.init())
	}
}
