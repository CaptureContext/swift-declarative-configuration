import KeyPathsExtensions
import SwiftMarkerProtocols

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
		_ keyPath: KeyPath<Base, LocalValue>
	) -> AnyConfigurationContainer<LocalValue>
}

extension ConfigurationContainer {
	public typealias Blocks = ConfigurationBlocks<Self>
}

extension ConfigurationContainer where Base: _OptionalProtocol {
	public var ifLet: Blocks.CallableIfLet<Base.Wrapped> {
		ifLet(\._optional)
	}

	public func ifNil(_ newValue: Base) -> Self {
		_withStorage { $0
			.appending(_ConfigurationItems.Modify { base in
				guard base._optional == nil else { return }
				base = newValue
			})
		}
	}
}

extension ConfigurationContainer {
	public func ifLet<Wrapped>(
		_ keyPath: WritableKeyPath<Base, Wrapped?>
	) -> Blocks.CallableIfLet<Wrapped> {
		.init(container: self, keyPath: keyPath)
	}

	public func ifLet<Wrapped>(
		_ keyPath: KeyPath<Base, Wrapped?>
	) -> Blocks.NonCallableIfLet<Wrapped> {
		.init(container: self, keyPath: keyPath)
	}

	@inlinable
	public subscript<Value>(
		dynamicMember keyPath: WritableKeyPath<Base, Value>
	) -> Blocks.Callable<Value> {
		.init(container: self, keyPath: keyPath)
	}

	@inlinable
	public subscript<Value>(
		dynamicMember keyPath: KeyPath<Base, Value>
	) -> Blocks.NonCallable<Value> {
		.init(container: self, keyPath: keyPath)
	}

	public subscript<Wrapped, Value>(
		dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
	) -> Blocks.Callable<Value?> where Base == Wrapped? {
		.init(
			container: self,
			keyPath: keyPath.withOptionalRoot()
		)
	}

	public subscript<Wrapped, Value>(
		dynamicMember keyPath: KeyPath<Wrapped, Value>
	) -> Blocks.NonCallable<Value?> where Base == Wrapped? {
		.init(
			container: self,
			keyPath: keyPath.withOptionalRoot()
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
		_ keyPath: KeyPath<Base, LocalValue>
	) -> AnyConfigurationContainer<LocalValue> {
		underlyingContainer._scoped(keyPath)
	}
}
