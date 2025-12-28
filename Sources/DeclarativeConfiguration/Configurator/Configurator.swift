@_spi(Internals) import DeclarativeConfigurationCore
import SwiftMarkerProtocols

@dynamicMemberLookup
public struct Configurator<Base>: ConfigurationContainer {
	@usableFromInline
	internal var storage: any ConfigurationStorage<Base>

	public init(storage: any ConfigurationStorage<Base>) {
		self.storage = storage
	}

	/// Creates a new instance of configurator
	///
	/// Newly created configurator has no modification set up.
	/// So it's `configure` function does not modify input
	///
	/// - Note: It's usually more visually appealing to use `.empty` instead
	@inlinable
	public init() {
		self.init(storage: DefaultConfigurationStorage())
	}

	/// Creates a configurator with a configuration function
	///
	/// - Parameters:
	///   - config: Factory for the configurator, the argument is always `.empty` configurator.
	@inlinable
	public init(config configuration: (Configurator) -> Configurator) {
		self = configuration(.empty)
	}

	// MARK: - Application

	/// Modifies an inout value using stored configuration
	///
	/// - Parameters:
	///   - base: A value to configure
	@inlinable
	public func configure(_ base: inout Base) {
		base = configured(base)
	}

	/// Configures a reference-type object with specified configuration
	///
	/// - Parameters:
	///   - base: An object to configure
	public func configure(_ base: Base) where Base: AnyObject {
		_ = storage.configuration.update(base)
	}

	/// Configures a value using stored configuration
	///
	/// - Parameters:
	///   - base: A value to configure
	///
	/// - Returns: Updated value, for reference types it is usually the same object.
	public func configured(_ base: Base) -> Base {
		storage.configuration.update(base)
	}

	// MARK: - Composition

	/// Appends specified configuration
	///
	/// - Returns: A new configurator with combined configuration
	public func combined(
		with configurator: Configurator
	) -> Configurator {
		.init(storage: storage.appending(
			configurator.storage.configuration
		))
	}

	/// Appends transformation to stored configuration
	///
	/// - Note: It's recommended to use this method only when dynamicMemberLookup API
	///         is not available (e.g. function calls)
	///
	/// - Parameters:
	///   - transform: Value transform to append to stored configuration
	///
	/// - Returns: A new configurator with updated stored configuration
	public func transform(
		_ transform: @escaping (Base) -> Base
	) -> Configurator {
		self[dynamicMember: \.self].transform(transform)
	}

	/// Appends modification to stored configuration
	///
	/// - Note: It's recommended to use this method only when dynamicMemberLookup API
	///         is not available (e.g. function calls)
	///
	/// - Parameters:
	///   - transform: Value transform to append to stored configuration
	///
	/// - Returns: A new configurator with updated stored configuration
	public func modify(
		_ transform: @escaping (inout Base) -> Void
	) -> Configurator {
		self[dynamicMember: \.self].modify(transform)
	}

	// MARK: - Static factory

	/// Empty configurator
	@inlinable
	public static var empty: Configurator {
		.init(storage: DefaultConfigurationStorage())
	}

	@inlinable
	public static func modify(
		_ transform: @escaping (inout Base) -> Void
	) -> Configurator {
		empty.modify(transform)
	}

	@inlinable
	public static func transform(
		_ transform: @escaping (Base) -> Base
	) -> Configurator {
		empty.transform(transform)
	}

	@inlinable
	public static subscript<Value>(
		dynamicMember keyPath: WritableKeyPath<Base, Value>
	) -> Blocks.Callable<Value> {
		empty[dynamicMember: keyPath]
	}

	@inlinable
	public static subscript<Wrapped, Value>(
		dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
	) -> Blocks.Callable<Value?> where Base == Wrapped? {
		empty[dynamicMember: keyPath]
	}

	@inlinable
	public static subscript<Value>(
		dynamicMember keyPath: KeyPath<Base, Value>
	) -> Blocks.NonCallable<Value> {
		empty[dynamicMember: keyPath]
	}

	@inlinable
	public static subscript<Wrapped, Value>(
		dynamicMember keyPath: KeyPath<Wrapped, Value>
	) -> Blocks.NonCallable<Value?> where Base == Wrapped? {
		empty[dynamicMember: keyPath]
	}
}

// MARK: IfLet

extension Configurator where Base: _OptionalProtocol {
	/// Provides ifLet configuration block for current object
	///
	/// "`?`" operator support is not available through dynamic member lookup
	///
	/// ```swift
	/// Configurator<Object?>.?.property(value) // ❌
	/// ```
	///
	/// So this property is used instead
	///
	/// ```swift
	/// Configurator<Object?>.ifLet.property(value) // ✅
	/// ```
	public static var ifLet: Blocks.CallableIfLet<Base.Wrapped> {
		empty.ifLet
	}

	/// Registers update for the current value. Applied only if currentValue is nil
	///
	/// Example:
	/// ```swift
	/// Configuraor<Int?>.ifNil(0).modify { $0 += 1 }
	/// ```
	///
	/// For configurators it's equivalent to `ifLet(else:)`
	///
	/// ```swift
	/// Configuraor<Int?>.ifLet(else: 0).modify { $0 += 1 }
	/// ```
	///
	/// - Parameters:
	///   - value: New value to set the current one to
	///
	/// - Returns: A new container with updated stored configuration
	public static func ifNil(_ newValue: Base) -> Self {
		empty.ifNil(newValue)
	}
}

// MARK: - ConfigurationContainer

extension Configurator {
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
		_ keyPath: KeyPath<Base, LocalValue>
	) -> AnyConfigurationContainer<LocalValue> {
		AnyConfigurationContainer(Configurator<LocalValue>.empty)
	}
}

extension AnyConfigurationContainer {
	public static func config(_ config: Configurator<Base>) -> Self { .init(config) }
}
