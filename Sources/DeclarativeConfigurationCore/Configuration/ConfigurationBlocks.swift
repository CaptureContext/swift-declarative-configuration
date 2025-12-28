public enum ConfigurationBlocks<Container: ConfigurationContainer> {
	@dynamicMemberLookup
	public struct Callable<Value> {
		public typealias ScopedContainer<LocalValue> = AnyConfigurationContainer<LocalValue>

		@usableFromInline
		internal var block: NonCallable<Value>

		@usableFromInline
		internal init(
			container: Container,
			valuePath: ValuePath<Container.Base, Value>
		) {
			self.block = .init(
				container: container,
				valuePath: valuePath
			)
		}

		public func modify(
			_ transform: @escaping (inout Value) -> Void
		) -> Container {
			block.container._withStorage { $0
				.appendingConfiguration { base in
					block.valuePath.embed(
						reduce(
							block.valuePath.extract(from: base),
							with: transform
						),
						in: base
					)
				}
			}
		}

		public func scope(
			_ config: (ScopedContainer<Value>) -> ScopedContainer<Value>
		) -> Container {
			block.scope(config)
		}

		public func ifLetScope<Wrapped>(
			_ config: @escaping (ScopedContainer<Wrapped>) -> ScopedContainer<Wrapped>
		) -> Container where Value == Wrapped? {
			block.ifLetScope(config)
		}

		public func callAsFunction(
			_ value: Value
		) -> Container {
			block.container._withStorage { $0
				.appendingConfiguration {
					block.valuePath.embed(value, in: $0)
				}
			}
		}

		@inlinable
		public func callAsFunction(
			ifLet newValue: Value?,
			then config: (ScopedContainer<Value>) -> ScopedContainer<Value> = { $0 }
		) -> Container {
			self.callAsFunction(
				ifLet: { newValue },
				then: config
			)
		}

		public func callAsFunction(
			ifLet newValue: @escaping () -> Value?,
			then config: (ScopedContainer<Value>) -> ScopedContainer<Value> = { $0 }
		) -> Container {
			let scoped = block.container._scoped(block.valuePath)
			return block.container._withStorage { $0
				.appendingConfiguration { base in
					if let value = newValue() {
						block.valuePath.embed(scoped._configured(value), in: base)
					} else {
						base
					}
				}
			}
		}

		@inlinable
		public func callAsFunction(
			if condition: Bool,
			then thenValue: Value
		) -> Container {
			self.callAsFunction(
				if: { condition },
				then: { thenValue }
			)
		}

		public func callAsFunction(
			if condition: @escaping () -> Bool,
			then thenValue: @escaping () -> Value
		) -> Container {
			block.container._withStorage { $0
				.appendingConfiguration { base in
					if condition() {
						block.valuePath.embed(thenValue(), in: base)
					} else {
						base
					}
				}
			}
		}

		@inlinable
		public func callAsFunction(
			if condition: Bool,
			then thenValue: Value,
			else elseValue: Value
		) -> Container {
			callAsFunction(
				if: { condition },
				then: { thenValue },
				else: { elseValue }
			)
		}

		public func callAsFunction(
			if condition: @escaping () -> Bool,
			then thenValue: @escaping () -> Value,
			else elseValue: @escaping () -> Value
		) -> Container {
			block.container._withStorage { $0
				.appendingConfiguration { base in
					if condition() {
						block.valuePath.embed(thenValue(), in: base)
					} else {
						block.valuePath.embed(elseValue(), in: base)
					}
				}
			}
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
		) -> Callable<LocalValue> {
			Callable<LocalValue>(
				container: block.container,
				valuePath: block.valuePath
					.appending(path: ValuePath(keyPath))
			)
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: KeyPath<Value, LocalValue>
		) -> NonCallable<LocalValue> {
			block[dynamicMember: keyPath]
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: WritableKeyPath<Wrapped, LocalValue>
		) -> Callable<LocalValue?> where Value == Wrapped? {
			Callable<LocalValue?>(
				container: block.container,
				valuePath: block.valuePath.appending(
					path: ValuePath(keyPath).optional(unwrapWithRoot: true)
				)
			)
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
		) -> NonCallable<LocalValue?> where Value == Wrapped? {
			block[dynamicMember: keyPath]
		}
	}

	@dynamicMemberLookup
	public struct NonCallable<Value> {
		public typealias ScopedContainer<LocalValue> = AnyConfigurationContainer<LocalValue>

		@usableFromInline
		internal var container: Container

		@usableFromInline
		internal var valuePath: ValuePath<Container.Base, Value>

		@usableFromInline
		internal init(
			container: Container,
			valuePath: ValuePath<Container.Base, Value>
		) {
			self.container = container
			self.valuePath = valuePath
		}

		public func scope(
			_ config: (ScopedContainer<Value>) -> ScopedContainer<Value>
		) -> Container {
			let scoped = config(container._scoped(valuePath))
			return container._withStorage { $0
				.appendingConfiguration { base in
					valuePath.embed(
						scoped._configured(valuePath.extract(from: base)),
						in: base
					)
				}
			}
		}

		public func ifLetScope<Wrapped>(
			_ config: @escaping (ScopedContainer<Wrapped>) -> ScopedContainer<Wrapped>
		) -> Container where Value == Wrapped? {
			return container._withStorage { $0
				.appendingConfiguration { base in
					guard let value = valuePath.extract(from: base)
					else { return base }

					let scoped = container._scoped(valuePath.unwrapped(withDefaultValue: value))
					return valuePath.embed(
						config(scoped)._configured(value),
						in: base
					)
				}
			}
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: ReferenceWritableKeyPath<Value, LocalValue>
		) -> Callable<LocalValue> {
			Callable<LocalValue>(
				container: self.container,
				valuePath: self.valuePath.appending(path: ValuePath(keyPath))
			)
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: KeyPath<Value, LocalValue>
		) -> NonCallable<LocalValue> {
			NonCallable<LocalValue>(
				container: self.container,
				valuePath: self.valuePath.appending(path: .getonly(keyPath))
			)
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: ReferenceWritableKeyPath<Wrapped, LocalValue>
		) -> Callable<LocalValue?> where Value == Wrapped? {
			Callable<LocalValue?>(
				container: self.container,
				valuePath: self.valuePath.appending(path: ValuePath(keyPath))
			)
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
		) -> NonCallable<LocalValue?> where Value == Wrapped? {
			NonCallable<LocalValue?>(
				container: self.container,
				valuePath: self.valuePath.appending(path: .getonly(keyPath))
			)
		}
	}
}
