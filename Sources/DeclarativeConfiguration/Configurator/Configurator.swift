import DeclarativeConfigurationCore

@dynamicMemberLookup
public struct Configurator<Base> {
	@usableFromInline
	internal var _configuration: (Base) -> Base

	@usableFromInline
	internal init(configuration: @escaping (Base) -> Base) {
		self._configuration = configuration
	}

	/// Creates a new instance of configurator
	///
	/// Newly created configurator has no modification set up.
	/// So it's `configure` function does not modify input
	public init() { self = .empty }

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
		base = _configuration(base)
	}

	/// Modifies a reference-type object with specified configuration
	@inlinable
	public func configure(_ base: Base) where Base: AnyObject {
		_ = _configuration(base)
	}

	/// Modifies returns modified object
	///
	/// Note: for reference types it is usually the same object
	@inlinable
	public func configured(_ base: Base) -> Base {
		_configuration(base)
	}

	/// Appends modification of stored object to stored configuration
	@inlinable
	public func modify(
		_ transform: @escaping (inout Base) -> Void
	) -> Configurator {
		appendingConfiguration { base in
			reduce(_configuration(base), with: transform)
		}
	}

	@inlinable
	public func combined(
		with configurator: Configurator
	) -> Configurator {
		appendingConfiguration(configurator._configuration)
	}

	/// Appends configuration to stored configuration
	@inlinable
	public func appendingConfiguration(
		_ configuration: @escaping (Base) -> Base
	) -> Configurator {
		reduce(self) { _self in
			_self._configuration = { [_configuration] in
				configuration(_configuration($0))
			}
		}
	}

	@usableFromInline
	internal func appendingConfiguration<LocalValue>(
		reinforcing child: (Configurator<LocalValue>) -> Configurator<LocalValue>,
		_ appendedConfiguration: @escaping (Base, Configurator<LocalValue>) -> Base
	) -> Configurator {
		let child = child(.empty)
		return appendingConfiguration { base in
			appendedConfiguration(base, child)
		}
	}

	@inlinable
	public subscript<Value>(
		dynamicMember keyPath: WritableKeyPath<Base, Value>
	) -> CallableBlock<Value> {
		CallableBlock<Value>(
			configurator: self,
			keyPath: ValuePath(keyPath)
		)
	}

	@inlinable
	public subscript<Wrapped, Value>(
		dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
	) -> CallableBlock<Value?> where Base == Wrapped? {
		CallableBlock<Value?>(
			configurator: self,
			keyPath: ValuePath(keyPath).optional()
		)
	}

	@inlinable
	public subscript<Value>(
		dynamicMember keyPath: KeyPath<Base, Value>
	) -> NonCallableBlock<Value> {
		NonCallableBlock<Value>(
			configurator: self,
			keyPath: ValuePath.getonly(keyPath)
		)
	}

	@inlinable
	public subscript<Wrapped, Value>(
		dynamicMember keyPath: KeyPath<Wrapped, Value>
	) -> NonCallableBlock<Value?> where Base == Wrapped? {
		NonCallableBlock<Value?>(
			configurator: self,
			keyPath: ValuePath.getonly(keyPath).optional()
		)
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

	@inlinable
	public static var empty: Configurator {
		.process { $0 }
	}

	@inlinable
	public static func process(
		_ configuration: @escaping (Base) -> Base
	) -> Configurator {
		Configurator(configuration: configuration)
	}

	@inlinable
	public static func modify(
		_ transform: @escaping (inout Base) -> Void
	) -> Configurator {
		Configurator().modify(transform)
	}
}

extension Configurator {
	@dynamicMemberLookup
	public struct CallableBlock<Value> {
		@usableFromInline
		internal var _block: NonCallableBlock<Value>

		@usableFromInline
		internal init(
			configurator: Configurator,
			keyPath: ValuePath<Base, Value>
		) {
			self._block = .init(
				configurator: configurator,
				keyPath: keyPath
			)
		}

		@inlinable
		public func modify(
			_ transform: @escaping (inout Value) -> Void
		) -> Configurator {
			_block.configurator.appendingConfiguration { base in
				_block.keyPath.embed(
					reduce(
						_block.keyPath.extract(from: base),
						with: transform
					),
					in: base
				)
			}
		}

		@inlinable
		public func scope(
			_ config: (Configurator<Value>) -> Configurator<Value>
		) -> Configurator {
			_block.configurator.appendingConfiguration(reinforcing: config) { base, config in
				_block.keyPath.embed(
					config.configured(_block.keyPath.extract(from: base)),
					in: base
				)
			}
		}

		@inlinable
		public func ifLetScope<Wrapped>(
			_ config: (Configurator<Wrapped>) -> Configurator<Wrapped>
		) -> Configurator where Value == Wrapped? {
			_block.configurator.appendingConfiguration(reinforcing: config) { base, config in
				guard let value = _block.keyPath.extract(from: base)
				else { return base }

				return _block.keyPath.embed(
					config.configured(value),
					in: base
				)
			}
		}

		@inlinable
		public func callAsFunction(
			_ value: Value
		) -> Configurator {
			_block.configurator.appendingConfiguration {
				_block.keyPath.embed(value, in: $0)
			}
		}

		@inlinable
		public func callAsFunction(
			ifLet newValue: Value?,
			then config: (Configurator<Value>) -> Configurator<Value> = { $0 }
		) -> Configurator {
			self.callAsFunction(
				ifLet: { newValue },
				then: config
			)
		}

		@inlinable
		public func callAsFunction(
			ifLet newValue: @escaping () -> Value?,
			then config: (Configurator<Value>) -> Configurator<Value> = { $0 }
		) -> Configurator {
			_block.configurator.appendingConfiguration(reinforcing: config) { base, config in
				if let value = newValue() {
					_block.keyPath.embed(config.configured(value), in: base)
				} else {
					base
				}
			}
		}

		@inlinable
		public func callAsFunction(
			if condition: Bool,
			then thenValue: Value
		) -> Configurator {
			self.callAsFunction(
				if: { condition },
				then: { thenValue }
			)
		}

		@inlinable
		public func callAsFunction(
			if condition: @escaping () -> Bool,
			then thenValue: @escaping () -> Value
		) -> Configurator {
			_block.configurator.appendingConfiguration { base in
				if condition() {
					_block.keyPath.embed(thenValue(), in: base)
				} else {
					base
				}
			}
		}

		@inlinable
		public func callAsFunction(
			if condition: Bool,
			then thenValue: Value,
			else elseValue: Value
		) -> Configurator {
			callAsFunction(
				if: { condition },
				then: { thenValue },
				else: { elseValue }
			)
		}

		@inlinable
		public func callAsFunction(
			if condition: @escaping () -> Bool,
			then thenValue: @escaping () -> Value,
			else elseValue: @escaping () -> Value
		) -> Configurator {
			_block.configurator.appendingConfiguration { base in
				if condition() {
					_block.keyPath.embed(thenValue(), in: base)
				} else {
					_block.keyPath.embed(elseValue(), in: base)
				}
			}
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
		) -> CallableBlock<LocalValue> {
			CallableBlock<LocalValue>(
				configurator: _block.configurator,
				keyPath: _block.keyPath
					.appending(path: ValuePath(keyPath))
			)
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: KeyPath<Value, LocalValue>
		) -> NonCallableBlock<LocalValue> {
			_block[dynamicMember: keyPath]
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: WritableKeyPath<Wrapped, LocalValue>
		) -> CallableBlock<LocalValue?> where Value == Wrapped? {
			CallableBlock<LocalValue?>(
				configurator: _block.configurator,
				keyPath: _block.keyPath.appending(
					path: ValuePath(keyPath).optional()
				)
			)
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
		) -> NonCallableBlock<LocalValue?> where Value == Wrapped? {
			_block[dynamicMember: keyPath]
		}
	}

	@dynamicMemberLookup
	public struct NonCallableBlock<Value> {
		@usableFromInline
		internal var configurator: Configurator

		@usableFromInline
		internal var keyPath: ValuePath<Base, Value>

		@usableFromInline
		internal init(
			configurator: Configurator,
			keyPath: ValuePath<Base, Value>
		) {
			self.configurator = configurator
			self.keyPath = keyPath
		}

		@inlinable
		public func scope(
			_ config: (Configurator<Value>) -> Configurator<Value>
		) -> Configurator where Value: AnyObject {
			configurator.appendingConfiguration(reinforcing: config) { base, config in
				keyPath.embed(
					config.configured(keyPath.extract(from: base)),
					in: base
				)
			}
		}

		@inlinable
		public func ifLetScope<Wrapped>(
			_ config: (Configurator<Wrapped>) -> Configurator<Wrapped>
		) -> Configurator where Wrapped: AnyObject, Value == Wrapped? {
			configurator.appendingConfiguration(reinforcing: config) { base, config in
				guard let value = keyPath.extract(from: base)
				else { return base }

				return keyPath.embed(
					config.configured(value),
					in: base
				)
			}
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: ReferenceWritableKeyPath<Value, LocalValue>
		) -> CallableBlock<LocalValue> {
			.init(
				configurator: self.configurator,
				keyPath: self.keyPath.appending(path: ValuePath(keyPath))
			)
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: KeyPath<Value, LocalValue>
		) -> NonCallableBlock<LocalValue> {
			.init(
				configurator: self.configurator,
				keyPath: self.keyPath.appending(path: .getonly(keyPath))
			)
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: ReferenceWritableKeyPath<Wrapped, LocalValue>
		) -> CallableBlock<LocalValue?> where Value == Wrapped? {
			CallableBlock<LocalValue?>(
				configurator: self.configurator,
				keyPath: self.keyPath.appending(path: ValuePath(keyPath))
			)
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
		) -> NonCallableBlock<LocalValue?> where Value == Wrapped? {
			NonCallableBlock<LocalValue?>(
				configurator: self.configurator,
				keyPath: self.keyPath.appending(path: .getonly(keyPath))
			)
		}
	}
}
