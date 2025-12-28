public protocol ConfigurationContainer<Base> {
	associatedtype Base

	@_spi(Internals)
	func _configured(_ base: Base) -> Base

	@_spi(Internals)
	func _withStorage(
		_ modification: (any ConfigurationStorage<Base>) -> any ConfigurationStorage<Base>
	) -> Self

	@_spi(Internals)
	func _scoped<LocalValue>(
		_ valuePath: ValuePath<Base, LocalValue>
	) -> AnyConfigurationContainer<LocalValue>
}

extension ConfigurationContainer {
	public typealias CallableBlock<Value> = ConfigurationBlocks<Self>.Callable<Value>
	public typealias NonCallableBlock<Value> = ConfigurationBlocks<Self>.NonCallable<Value>
}

extension ConfigurationContainer {
	@inlinable
	public subscript<Value>(
		dynamicMember keyPath: WritableKeyPath<Base, Value>
	) -> CallableBlock<Value> {
		CallableBlock<Value>(
			container: self,
			valuePath: ValuePath(keyPath)
		)
	}

	@inlinable
	public subscript<Wrapped, Value>(
		dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
	) -> CallableBlock<Value?> where Base == Wrapped? {
		CallableBlock<Value?>(
			container: self,
			valuePath: ValuePath(keyPath).optional(unwrapWithRoot: true)
		)
	}

	@inlinable
	public subscript<Value>(
		dynamicMember keyPath: KeyPath<Base, Value>
	) -> NonCallableBlock<Value> {
		NonCallableBlock<Value>(
			container: self,
			valuePath: .getonly(keyPath)
		)
	}

	@inlinable
	public subscript<Wrapped, Value>(
		dynamicMember keyPath: KeyPath<Wrapped, Value>
	) -> NonCallableBlock<Value?> where Base == Wrapped? {
		NonCallableBlock<Value?>(
			container: self,
			valuePath: ValuePath.getonly(keyPath).optional(unwrapWithRoot: true)
		)
	}
}

@dynamicMemberLookup
public struct AnyConfigurationContainer<Base>: ConfigurationContainer {
	let underlyingContainer: any ConfigurationContainer<Base>

	public init(_ underlyingContainer: any ConfigurationContainer<Base>) {
		self.underlyingContainer = underlyingContainer
	}

	@_spi(Internals)
	public func _configured(_ base: Base) -> Base {
		underlyingContainer._configured(base)
	}

	@_spi(Internals)
	public func _withStorage(
		_ modification: (any ConfigurationStorage<Base>) -> any ConfigurationStorage<Base>
	) -> Self {
		.init(underlyingContainer._withStorage(modification))
	}

	@_spi(Internals)
	public func _scoped<LocalValue>(
		_ valuePath: ValuePath<Base, LocalValue>
	) -> AnyConfigurationContainer<LocalValue> {
		underlyingContainer._scoped(valuePath)
	}
}
