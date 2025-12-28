@_spi(Internals) import DeclarativeConfigurationCore

@dynamicMemberLookup
public struct Builder<Base> {
	@usableFromInline
	internal var initialValue: () -> Base

	@usableFromInline
	internal var configurator: Configurator<Base>

	@inlinable
	public var base: Base { initialValue() }

	@inlinable
	public func build() -> Base { configurator.configured(base) }

	@inlinable
	public func apply() where Base: AnyObject { _ = build() }

	@inlinable
	public func reinforce() -> Builder { .init(build()) }

	@inlinable
	public func combined(
		with builder: Builder
	) -> Builder {
		combined(with: builder.configurator)
	}

	@inlinable
	public func combined(
		with configurator: Configurator<Base>
	) -> Builder {
		Builder(
			initialValue: initialValue,
			configurator: configurator.combined(with: configurator)
		)
	}

	/// Creates a new instance of builder with initial value
	@inlinable
	public init(_ initialValue: @escaping @autoclosure () -> Base) {
		self.init(
			initialValue: initialValue,
			configurator: .empty
		)
	}

	@usableFromInline
	internal init(
		initialValue: @escaping () -> Base,
		configurator: Configurator<Base>
	) {
		self.initialValue = initialValue
		self.configurator = configurator
	}

	/// Appends transformation to current configuration
	@inlinable
	public func modify(
		_ transform: @escaping (inout Base) -> Void
	) -> Builder {
		Builder(
			initialValue: initialValue,
			configurator: configurator.modify(transform)
		)
	}
}

extension Builder: ConfigurationContainer {
	@_spi(Internals)
	public func _configured(_ base: Base) -> Base {
		configurator._configured(base)
	}

	@_spi(Internals)
	public func _withStorage(
		_ modification: (any ConfigurationStorage<Base>) -> any ConfigurationStorage<Base>
	) -> Self {
		Builder(
			initialValue: initialValue,
			configurator: configurator._withStorage(modification)
		)
	}

	@_spi(Internals)
	public func _scoped<LocalValue>(
		_ keyPath: KeyPath<Base, LocalValue>
	) -> AnyConfigurationContainer<LocalValue> {
		AnyConfigurationContainer(Builder<LocalValue>(
			initialValue: { initialValue()[keyPath: keyPath] },
			configurator: .empty
		))
	}
}
