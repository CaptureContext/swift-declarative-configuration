import DeclarativeConfigurationCore

@dynamicMemberLookup
public struct Builder<Base> {
	@usableFromInline
	internal var _initialValue: () -> Base

	@usableFromInline
	internal var _configurator: Configurator<Base>

	@inlinable
	public var base: Base { _initialValue() }

	@inlinable
	public func build() -> Base { _configurator.configured(base) }

	@inlinable
	public func apply() where Base: AnyObject { _ = build() }

	@inlinable
	public func reinforce() -> Builder { .init(build()) }

	@inlinable
	public func combined(
		with builder: Builder
	) -> Builder {
		combined(with: builder._configurator)
	}

	@inlinable
	public func combined(
		with configurator: Configurator<Base>
	) -> Builder {
		Builder(
			_initialValue,
			_configurator.combined(with: configurator)
		)
	}

	/// Creates a new instance of builder with initial value
	@inlinable
	public init(_ initialValue: @escaping @autoclosure () -> Base) {
		self.init(
			initialValue,
			Configurator<Base>()
		)
	}

	@usableFromInline
	internal init(
		_ initialValue: @escaping () -> Base,
		_ configurator: Configurator<Base>
	) {
		self._initialValue = initialValue
		self._configurator = configurator
	}

	/// Appends transformation to current configuration
	@inlinable
	public func modify(
		_ transform: @escaping (inout Base) -> Void
	) -> Builder {
		Builder(
			_initialValue,
			_configurator.modify(transform)
		)
	}

	@inlinable
	public subscript<Value>(
		dynamicMember keyPath: WritableKeyPath<Base, Value>
	) -> CallableBlock<Value> {
		CallableBlock<Value>(
			builder: self,
			keyPath: ValuePath(keyPath)
		)
	}

	@inlinable
	public subscript<Wrapped, Value>(
		dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
	) -> CallableBlock<Value?> where Base == Wrapped? {
		CallableBlock<Value?>(
			builder: self,
			keyPath: ValuePath(keyPath).optional()
		)
	}

	@inlinable
	public subscript<Value>(
		dynamicMember keyPath: KeyPath<Base, Value>
	) -> NonCallableBlock<Value> {
		NonCallableBlock<Value>(
			builder: self,
			keyPath: .getonly(keyPath)
		)
	}

	@inlinable
	public subscript<Wrapped, Value>(
		dynamicMember keyPath: KeyPath<Wrapped, Value>
	) -> NonCallableBlock<Value?> where Base == Wrapped? {
		NonCallableBlock<Value?>(
			builder: self,
			keyPath: ValuePath.getonly(keyPath).optional()
		)
	}
}

extension Builder {
	@dynamicMemberLookup
	public struct CallableBlock<Value> {
		@usableFromInline
		internal var _block: NonCallableBlock<Value>

		@usableFromInline
		internal init(
			builder: Builder,
			keyPath: ValuePath<Base, Value>
		) {
			self._block = .init(
				builder: builder,
				keyPath: keyPath
			)
		}

		@inlinable
		public func modify(
			_ transform: @escaping (inout Value) -> Void
		) -> Builder {
			_block.builder.combined(with: .process { base in
				_block.keyPath.embed(
					 reduce(_block.keyPath.extract(from: base), with: transform),
					 in: base
				 )
			})
		}

		@inlinable
		public func scope(
			_ config: (Configurator<Value>) -> Configurator<Value>
		) -> Builder {
			let config = config(.init())
			return _block.builder.combined(with: .process { base in
				_block.keyPath.embed(
					config.configured(_block.keyPath.extract(from: base)),
					in: base
				)
			})
		}

		@inlinable
		public func ifLetScope<Wrapped>(
			_ builder: @escaping (Configurator<Wrapped>) -> Configurator<Wrapped>
		) -> Builder where Value == Wrapped? {
			_block.builder.combined(with: .process { base in
				guard let value = _block.keyPath.extract(from: base) else { return base }
				return _block.keyPath.embed(
					builder(.empty).configured(value),
					in: base
				)
			})
		}

		@inlinable
		public func callAsFunction(
			_ value: Value
		) -> Builder {
			self.callAsFunction({ value })
		}

		@inlinable
		public func callAsFunction(
			_ value: @escaping () -> Value
		) -> Builder {
			_block.builder.combined(with: .process { base in
				_block.keyPath.embed(value(), in: base)
			})
		}

		@inlinable
		public func callAsFunction(
			ifLet newValue: Value?,
			then builder: @escaping (Builder<Value>) -> Builder<Value> = { $0 }
		) -> Builder {
			self.callAsFunction(
				ifLet: { newValue },
				then: builder
			)
		}

		@inlinable
		public func callAsFunction(
			ifLet newValue: @escaping () -> Value?,
			then builder: @escaping (Builder<Value>) -> Builder<Value> = { $0 }
		) -> Builder {
			_block.builder.combined(with: .process { base in
				if let value = newValue() {
					let builder = builder(.init(value))
					return _block.keyPath.embed(builder.build(), in: base)
				} else {
					return base
				}
			})
		}

		@inlinable
		public func callAsFunction(
			if condition: Bool,
			then thenValue: Value
		) -> Builder {
			self.callAsFunction(
				if: { condition },
				then: { thenValue }
			)
		}

		@inlinable
		public func callAsFunction(
			if condition: @escaping () -> Bool,
			then thenValue: @escaping () -> Value
		) -> Builder {
			_block.builder.combined(with: .process { base in
				if condition() {
					_block.keyPath.embed(thenValue(), in: base)
				} else {
					base
				}
			})
		}

		@inlinable
		public func callAsFunction(
			if condition: Bool,
			then thenValue: Value,
			else elseValue: Value
		) -> Builder {
			self.callAsFunction(
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
		) -> Builder {
			_block.builder.combined(with: .process { base in
				if condition() {
					_block.keyPath.embed(thenValue(), in: base)
				} else {
					_block.keyPath.embed(elseValue(), in: base)
				}
			})
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
		) -> CallableBlock<LocalValue> {
			CallableBlock<LocalValue>(
				builder: _block.builder,
				keyPath: _block.keyPath.appending(path: .init(keyPath))
			)
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: WritableKeyPath<Wrapped, LocalValue>
		) -> CallableBlock<LocalValue?> where Value == Wrapped? {
			CallableBlock<LocalValue?>(
				builder: _block.builder,
				keyPath: _block.keyPath.appending(
					path: ValuePath(keyPath).optional()
				)
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
			dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
		) -> NonCallableBlock<LocalValue?> where Value == Wrapped? {
			_block[dynamicMember: keyPath]
		}
	}

	@dynamicMemberLookup
	public struct NonCallableBlock<Value> {
		@usableFromInline
		internal var builder: Builder

		@usableFromInline
		internal var keyPath: ValuePath<Base, Value>

		@usableFromInline
		internal init(
			builder: Builder,
			keyPath: ValuePath<Base, Value>
		) {
			self.builder = builder
			self.keyPath = keyPath
		}

		@inlinable
		public func scope(
			_ builder: @escaping (Builder<Value>) -> Builder<Value>
		) -> Builder where Value: AnyObject {
			Builder(
				self.builder._initialValue,
				self.builder._configurator.appendingConfiguration { base in
					keyPath.embed(
						builder(.init(keyPath.extract(from: base))).build(),
						in: base
					)
				}
			)
		}

		@inlinable
		public func ifLetScope<Wrapped>(
			_ builder: @escaping (Builder<Wrapped>) -> Builder<Wrapped>
		) -> Builder where Wrapped: AnyObject, Value == Wrapped? {
			Builder(
				self.builder._initialValue,
				self.builder._configurator.appendingConfiguration { base in
					guard let value = keyPath.extract(from: base) else { return base }
					return keyPath.embed(
						builder(.init(value)).build(),
						in: base
					)
				}
			)
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: ReferenceWritableKeyPath<Value, LocalValue>
		) -> CallableBlock<LocalValue> {
			CallableBlock<LocalValue>(
				builder: self.builder,
				keyPath: self.keyPath.appending(path: .init(keyPath))
			)
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: ReferenceWritableKeyPath<Wrapped, LocalValue>
		) -> CallableBlock<LocalValue?> where Value == Wrapped? {
			CallableBlock<LocalValue?>(
				builder: self.builder,
				keyPath: self.keyPath.appending(
					path: ValuePath(keyPath).optional()
				)
			)
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: KeyPath<Value, LocalValue>
		) -> NonCallableBlock<LocalValue> {
			NonCallableBlock<LocalValue>(
				builder: self.builder,
				keyPath: self.keyPath.appending(path: .getonly(keyPath))
			)
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
		) -> NonCallableBlock<LocalValue?> where Value == Wrapped? {
			NonCallableBlock<LocalValue?>(
				builder: self.builder,
				keyPath: self.keyPath.appending(
					path: ValuePath.getonly(keyPath).optional()
				)
			)
		}
	}
}
