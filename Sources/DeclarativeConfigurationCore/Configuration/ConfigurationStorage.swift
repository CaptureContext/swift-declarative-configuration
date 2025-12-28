public protocol ConfigurationStorage<Base> {
	associatedtype Base

	var configuration: (Base) -> Base { get }

	/// Appends configuration to stored configuration
	func appendingConfiguration(
		_ configuration: @escaping (Base) -> Base
	) -> Self
}

public struct DefaultConfigurationStorage<Base>: ConfigurationStorage {
	@usableFromInline
	internal var _configuration: (Base) -> Base

	public init(_ configuration: @escaping (Base) -> Base = { $0 }) {
		self._configuration = configuration
	}

	@inlinable
	public var configuration: (Base) -> Base { _configuration }

	/// Appends configuration to stored configuration
	@inlinable
	public func appendingConfiguration(
		_ configuration: @escaping (Base) -> Base
	) -> Self {
		reduce(self) { _self in
			_self._configuration = { [_configuration] in
				configuration(_configuration($0))
			}
		}
	}
}

public struct FlatConfigurationStorage<Base>: ConfigurationStorage {
	@usableFromInline
	internal var _configurations: [(Base) -> Base]

	public init(_ configurations: [(Base) -> Base] = []) {
		self._configurations = configurations
	}

	@inlinable
	public var configuration: (Base) -> Base {
		return { base in
			reduce(base) { base in
				for configuration in _configurations {
					base = configuration(base)
				}
			}
		}
	}

	/// Appends configuration to stored configuration
	@inlinable
	public func appendingConfiguration(
		_ configuration: @escaping (Base) -> Base
	) -> Self {
		reduce(self) { _self in
			_self._configurations.append(configuration)
		}
	}
}
