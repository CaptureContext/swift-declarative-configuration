import Foundation

/// Currently it's the only available storage
///
/// It stores configuration blocks in an internal array, this
/// strategy was selected over nested function calls to reduce
/// the depth of the call stack and potentially enable
/// stuff like Equatable/Hashable/Codable conformances in the future
public struct DefaultConfigurationStorage<Base>: ConfigurationStorage {
	internal var items: [any _ConfigurationItem]

	public init() {
		self.items = []
	}

	@_spi(Internals)
	public var configuration: _ConfigurationItems.Concat<Base> {
		.init(uncheckedItems: items)
	}

	@_spi(Internals)
	public func appending(
		_ item: any _ConfigurationItem<Base>
	) -> DefaultConfigurationStorage<Base> {
		reduce(self) { _self in
			_self.items.append(item as (any _ConfigurationItem))
		}
	}
}
