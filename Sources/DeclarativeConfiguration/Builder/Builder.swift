@_spi(Internals) import DeclarativeConfigurationCore

/// Configuration container over specific object
///
/// This wrapper type enables chainging API for Base value configuration.
///
/// ```swift
/// let configuredValue = Builder(value)
///   .property1(value1)
///   .property2(value2)
///   .build()
/// ```
///
/// Reference types can be configured with `apply()` instead of `build()`
/// when returning configured `object` is redundant
///
/// ```swift
/// object.builder
///   .property1(value1)
///   .property2(value2)
///   .apply()
/// ```
@dynamicMemberLookup
public struct Builder<Base>: ConfigurationContainer {
	@usableFromInline
	internal var initialValue: () -> Base

	/// Current configuration
	internal(set) public var configurator: Configurator<Base>

	/// Current value
	///
	/// - Returns: Base as it is, without applying current configuration
	@inlinable
	public var base: Base { initialValue() }

	/// Creates a new instance of builder with initial value
	///
	/// - Parameters:
	///   - initialValue: Initial value for the builder
	@inlinable
	public init(_ initialValue: @escaping @autoclosure () -> Base) {
		self.init(
			initialValue: initialValue,
			configurator: .empty
		)
	}

	/// Creates a new instance of builder with initial value and specified configuration
	///
	/// - Note: Consider using ``BuilderProvider`` protocol instead of this init when available
	///
	/// - Parameters:
	///   - initialValue: Factory for the initial value
	///   - configurator: Configuration for the builder
	public init(
		initialValue: @escaping () -> Base,
		configurator: Configurator<Base>
	) {
		self.initialValue = initialValue
		self.configurator = configurator
	}

	/// Builds the value using current configuration
	///
	/// - Returns: Base, configured using current configuration
	@inlinable
	public func build() -> Base { configurator.configured(base) }

	/// Applies current configuration without returning an object
	///
	/// - Note: Useful for silencing "Result of call to 'build()' is unused"
	@inlinable
	public func apply() where Base: AnyObject { _ = build() }

	/// Commits current configuration
	///
	/// - Returns: A new builder with freshly built value and empty configuration
	@inlinable
	public func commit() -> Builder { .init(build()) }

	/// Appends specified configuration
	///
	/// - Returns: A new builder with combined configuration
	@inlinable
	public func combined(
		with configurator: Configurator<Base>
	) -> Builder {
		Builder(
			initialValue: initialValue,
			configurator: configurator.combined(with: configurator)
		)
	}

	/// Appends transformation to the current configuration
	///
	/// - Note: It's recommended to use this method only when dynamicMemberLookup API
	///         is not available (e.g. function calls)
	///
	/// - Returns: A new builder with combined configuration
	public func transform(
		_ transform: @escaping (Base) -> Base
	) -> Builder {
		Builder(
			initialValue: initialValue,
			configurator: configurator.transform(transform)
		)
	}

	/// Appends transformation to the current configuration
	///
	/// - Note: It's recommended to use this method only when dynamicMemberLookup API
	///         is not available (e.g. function calls)
	///
	/// - Parameters:
	///   - transform: Transform to apply to 
	///
	/// - Returns: A new builder with combined configuration
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

// MARK: - ConfigurationContainer

extension Builder {
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
