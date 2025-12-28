import Foundation

public protocol ConfigurationStorage<Base> {
	associatedtype Base

	@_spi(Internals)
	var configuration: _ConfigurationItems.Concat<Base> { get }

	/// Appends configuration to stored configuration
	@_spi(Internals)
	func appending(_ item: any _ConfigurationItem<Base>) -> Self
}

extension ConfigurationStorage {
	func appendingConfiguration(_ transform: @escaping (Base) -> Base) -> Self {
		appending(_ConfigurationItems.Update(transform))
	}
}
