import KeyPathsExtensions

public enum ConfigurationBlocks<Container: ConfigurationContainer> {
	@dynamicMemberLookup
	public struct Callable<Value> {
		public typealias ScopedContainer<LocalValue> = AnyConfigurationContainer<LocalValue>

		@usableFromInline
		internal var container: Container

		@usableFromInline
		internal var keyPath: WritableKeyPath<Container.Base, Value>

		@usableFromInline
		internal init(
			container: Container,
			keyPath: WritableKeyPath<Container.Base, Value>
		) {
			self.container = container
			self.keyPath = keyPath
		}

		public func modify(
			_ transform: @escaping (inout Value) -> Void
		) -> Container {
			container._withStorage { $0
				.appendingConfiguration { base in
					reduce(base) { transform(&$0[keyPath: keyPath]) }
				}
			}
		}

		public func scope(
			_ config: (ScopedContainer<Value>) -> ScopedContainer<Value>
		) -> Container where Value: AnyObject {
			let scoped = config(container._scoped(keyPath))
			return container._withStorage { $0
				.appendingConfiguration { base in
					reduce(base) {
						$0[keyPath: keyPath] = scoped._configured(base[keyPath: keyPath])
					}
				}
			}
		}

		public func ifLetScope<Wrapped>(
			_ config: @escaping (ScopedContainer<Wrapped>) -> ScopedContainer<Wrapped>
		) -> Container where Value == Wrapped? {
			return container._withStorage { $0
				.appendingConfiguration { base in
					guard let value = base[keyPath: keyPath]
					else { return base }

					let unwrappedKeyPath = keyPath.unwrapped(with: value)
					let scoped = config(container._scoped(unwrappedKeyPath))

					return reduce(base) {
						$0[keyPath: keyPath] = scoped._configured($0[keyPath: unwrappedKeyPath])
					}
				}
			}
		}

		public func callAsFunction(
			_ value: Value
		) -> Container {
			container._withStorage { $0
				.appendingConfiguration { base in
					reduce(base) { $0[keyPath: keyPath] = value }
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
			return container._withStorage { $0
				.appendingConfiguration { base in
					if let value = newValue() {
						reduce(base) { $0[keyPath: keyPath] = value }
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
			return container._withStorage { $0
				.appendingConfiguration { base in
					if condition() {
						reduce(base) { $0[keyPath: keyPath] = thenValue() }
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
			return container._withStorage { $0
				.appendingConfiguration { base in
					if condition() {
						reduce(base) { $0[keyPath: keyPath] = thenValue() }
					} else {
						reduce(base) { $0[keyPath: keyPath] = elseValue() }
					}
				}
			}
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
		) -> Callable<LocalValue> {
			Callable<LocalValue>(
				container: self.container,
				keyPath: self.keyPath.appending(path: keyPath)
			)
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: KeyPath<Value, LocalValue>
		) -> NonCallable<LocalValue> {
			NonCallable<LocalValue>(
				container: self.container,
				keyPath: self.keyPath.appending(path: keyPath)
			)
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: WritableKeyPath<Wrapped, LocalValue>
		) -> Callable<LocalValue?> where Value == Wrapped? {
			Callable<LocalValue?>(
				container: self.container,
				keyPath: self.keyPath.appending(keyPath)
			)
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
		) -> NonCallable<LocalValue?> where Value == Wrapped? {
			NonCallable<LocalValue?>(
				container: self.container,
				keyPath: self.keyPath.appending(keyPath)
			)
		}
	}

	@dynamicMemberLookup
	public struct NonCallable<Value> {
		public typealias ScopedContainer<LocalValue> = AnyConfigurationContainer<LocalValue>

		@usableFromInline
		internal var container: Container

		@usableFromInline
		internal var keyPath: KeyPath<Container.Base, Value>

		@usableFromInline
		internal init(
			container: Container,
			keyPath: KeyPath<Container.Base, Value>
		) {
			self.container = container
			self.keyPath = keyPath
		}

		public func scope(
			_ config: (ScopedContainer<Value>) -> ScopedContainer<Value>
		) -> Container where Value: AnyObject {
			let scoped = config(container._scoped(keyPath))
			return container._withStorage { $0
				.appendingConfiguration { base in
					_ = scoped._configured(base[keyPath: keyPath])
					return base
				}
			}
		}

		public func ifLetScope<Wrapped>(
			_ config: @escaping (ScopedContainer<Wrapped>) -> ScopedContainer<Wrapped>
		) -> Container where Value == Wrapped? {
			return container._withStorage { $0
				.appendingConfiguration { base in
					guard let value = base[keyPath: keyPath]
					else { return base }

					let scoped = config(container._scoped(keyPath.unwrapped(with: value)))
					_ = scoped._configured(value)
					return base
				}
			}
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: ReferenceWritableKeyPath<Value, LocalValue>
		) -> Callable<LocalValue> {
			Callable<LocalValue>(
				container: self.container,
				keyPath: self.keyPath.appending(path: keyPath)
			)
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: KeyPath<Value, LocalValue>
		) -> NonCallable<LocalValue> {
			NonCallable<LocalValue>(
				container: self.container,
				keyPath: self.keyPath.appending(path: keyPath)
			)
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: ReferenceWritableKeyPath<Wrapped, LocalValue>
		) -> Callable<LocalValue?> where Value == Wrapped? {
			Callable<LocalValue?>(
				container: self.container,
				keyPath: self.keyPath.appending(keyPath)
			)
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
		) -> NonCallable<LocalValue?> where Value == Wrapped? {
			NonCallable<LocalValue?>(
				container: self.container,
				keyPath: self.keyPath.appending(keyPath)
			)
		}
	}
}
