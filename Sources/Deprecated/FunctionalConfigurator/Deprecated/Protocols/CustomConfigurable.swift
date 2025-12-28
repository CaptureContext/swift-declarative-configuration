import Foundation
import DeclarativeConfiguration

/// Do not use this protocol, it will be removed in future versions
///
/// It's an implementation detail used to silence implementation warnings for
/// `ConfigInitializable` protocol, however this one will
/// also be removed in favor of `CallAsFunctionConfigurableProtocol` in `1.0.0`
///
/// - Note: Use `DefaultConfigurableProtocol` instead
public protocol ___CustomConfigurableProtocol_DEPRECATED: CustomConfigurableProtocol {
	init()
}

@available(
	*, deprecated,
	message: """
	Use `DefaultConfigurableProtocol` or `CustomConfigurableProtocol` instead.
	
	FunctionalConfigurator module is deprecated and will be removed in v1.0.0
	Use `import DeclarativeConfiguration` instead
	"""
)
public typealias CustomConfigurable = ___CustomConfigurableProtocol_DEPRECATED
