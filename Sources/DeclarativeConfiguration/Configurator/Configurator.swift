import DeclarativeConfigurationCore

@dynamicMemberLookup
public struct Configurator<Base> {
	@usableFromInline
	internal var storage: any ConfigurationStorage<Base>

	public init(storage: any ConfigurationStorage<Base>) {
		self.storage = storage
	}

	/// Creates a new instance of configurator
	///
	/// Newly created configurator has no modification set up.
	/// So it's `configure` function does not modify input
	@inlinable
	public init() {
		self.init(storage: DefaultConfigurationStorage())
	}

	/// Creates a configurator with a configuration function
	///
	/// Initial value passed to configuration function is an empty configurator
	@inlinable
	public init(config configuration: (Configurator) -> Configurator) {
		self = configuration(.empty)
	}

	/// Modifies an object with specified configuration
	@inlinable
	public func configure(_ base: inout Base) {
		base = configured(base)
	}

	/// Modifies a reference-type object with specified configuration
	@inlinable
	public func configure(_ base: Base) where Base: AnyObject {
		_ = storage.configuration(base)
	}

	/// Modifies returns modified object
	///
	/// Note: for reference types it is usually the same object
	@inlinable
	public func configured(_ base: Base) -> Base {
		storage.configuration(base)
	}

	/// Appends modification of stored object to stored configuration
	@inlinable
	public func modify(
		_ transform: @escaping (inout Base) -> Void
	) -> Configurator {
		appendingConfiguration { base in
			reduce(storage.configuration(base), with: transform)
		}
	}

	@inlinable
	public func combined(
		with configurator: Configurator
	) -> Configurator {
		appendingConfiguration(configurator.storage.configuration)
	}

	/// Appends configuration to stored configuration
	@inlinable
	public func appendingConfiguration(
		_ configuration: @escaping (Base) -> Base
	) -> Configurator {
		.init(storage: storage.appendingConfiguration(configuration))
	}

	/// Minimizes call stack by collecting changes in array instead of nested closures
	@inlinable
	public func flatten(_ config: (Configurator) -> Configurator) -> Configurator {
		combined(with: config(.flat))
	}

	@inlinable
	public static var empty: Configurator {
		.init(storage: DefaultConfigurationStorage())
	}

	/// Minimizes call stack by collecting changes in array instead of nested closures
	@inlinable
	public static var flat: Configurator {
		.init(storage: FlatConfigurationStorage())
	}

	@inlinable
	public static func process(
		_ configuration: @escaping (Base) -> Base
	) -> Configurator {
		Configurator(storage: DefaultConfigurationStorage(configuration))
	}

	@inlinable
	public static func modify(
		_ transform: @escaping (inout Base) -> Void
	) -> Configurator {
		Configurator().modify(transform)
	}

	@inlinable
	public static subscript<Value>(
		dynamicMember keyPath: WritableKeyPath<Base, Value>
	) -> CallableBlock<Value> {
		Configurator()[dynamicMember: keyPath]
	}

	@inlinable
	public static subscript<Wrapped, Value>(
		dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
	) -> CallableBlock<Value?> where Base == Wrapped? {
		Configurator()[dynamicMember: keyPath]
	}

	@inlinable
	public static subscript<Value>(
		dynamicMember keyPath: KeyPath<Base, Value>
	) -> NonCallableBlock<Value> {
		Configurator()[dynamicMember: keyPath]
	}

	@inlinable
	public static subscript<Wrapped, Value>(
		dynamicMember keyPath: KeyPath<Wrapped, Value>
	) -> NonCallableBlock<Value?> where Base == Wrapped? {
		Configurator()[dynamicMember: keyPath]
	}
}

extension Configurator: ConfigurationContainer {
	@_spi(Internals)
	public func _configured(_ base: Base) -> Base {
		configured(base)
	}

	@_spi(Internals)
	public func _withStorage(
		_ modification: (any ConfigurationStorage<Base>) -> any ConfigurationStorage<Base>
	) -> Self {
		Configurator(storage: modification(storage))
	}

	@_spi(Internals)
	public func _scoped<LocalValue>(
		_ valuePath: ValuePath<Base, LocalValue>
	) -> AnyConfigurationContainer<LocalValue> {
		AnyConfigurationContainer(Configurator<LocalValue>.empty)
	}
}
