import KeyPathsExtensions
@_spi(Internals) import SwiftMarkerProtocols

/// Typed namespace for generic configuration blocks.
public enum ConfigurationBlocks<Container: ConfigurationContainer> {

	// MARK: - Callable

	/// A configuration block for writable key paths that supports `@dynamicMemberLookup`
	/// and is callable.
	///
	/// This generic block exposes nested properties using `@dynamicMemberLookup` and
	/// provides a callable API to set or modify the value at the underlying writable
	/// key path. Instances are produced by configuration containers via `@dynamicMemberLookup`.
	///
	/// Examples:
	/// ```swift
	/// .title("Hello")            // callable sets the value
	/// .layer.cornerRadius(8)      // dynamic member then callable
	/// ```
	@dynamicMemberLookup
	public struct Callable<Value> {
		public typealias Blocks = ConfigurationBlocks<Container>
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

		@_spi(Internals)
		public func __accessInternals<T>(
			perform operation: (Container, WritableKeyPath<Container.Base, Value>) -> T
		) -> T {
			operation(container, keyPath)
		}

		/// Appends peek operation to stored configuration.
		///
		/// - Note: Useful for function calls on on reference types or logging.
		///
		/// Example:
		/// ```swift
		/// .button.peek { $0.setTitle("Tap") } // method call
		/// .button.titleLabel.peek { print($0?.text ?? "no-title") } // simple log
		/// ```
		///
		/// - Parameters:
		///   - operation: Peek operation that accepts current value.
		///
		/// - Returns: A new container with updated stored configuration.
		public func peek(
			_ operation: @escaping (Value) -> Void
		) -> Container {
			container._withStorage { $0
				.appending(_ConfigurationItems.Peek {
					operation($0[keyPath: keyPath])
				})
			}
		}

		// MARK: Callable

		/// Appends transformation to stored configuration.
		///
		/// - Note: It's recommended to use this method only when dynamicMemberLookup API
		///         is not available (e.g. function calls).
		///         For reference types or when no transformation is applied, consider using `peek`instead
		///
		/// Example:
		/// ```swift
		/// .intValue.transform { $0 + 1 }
		/// ```
		///
		/// - Parameters:
		///   - transform: Value transform to append to stored configuration.
		///
		/// - Returns: A new container with updated stored configuration.
		public func transform(
			_ transform: @escaping (Value) -> Value
		) -> Container {
			container._withStorage { $0
				.appending(_ConfigurationItems.Modify {
					$0[keyPath: keyPath] = transform($0[keyPath: keyPath])
				})
			}
		}

		/// Appends in-place modification to stored configuration.
		///
		/// - Note: It's recommended to use this method only when dynamicMemberLookup API
		///         is not available (e.g. function calls).
		///         For reference types or when no transformation is applied, consider using `peek`instead
		///
		/// Example:
		/// ```swift
		/// .intValue.modify { $0 += 1 }
		/// ```
		///
		/// - Parameters:
		///   - transform: A closure that receives the current value `inout` so it can be modified.
		///
		/// - Returns: A new container with updated stored configuration.
		public func modify(
			_ transform: @escaping (inout Value) -> Void
		) -> Container {
			container._withStorage { $0
				.appending(_ConfigurationItems.Modify { transform(&$0[keyPath: keyPath]) })
			}
		}

		/// Registers update for the current value.
		///
		/// Example:
		/// ```swift
		/// .intValue(0)
		/// ```
		///
		/// - Parameters:
		///   - value: New value to set the current one to
		///
		/// - Returns: A new container with updated stored configuration
		public func callAsFunction(
			_ value: Value
		) -> Container {
			container._withStorage { $0
				.appending(_ConfigurationItems.SetValue(value, to: keyPath))
			}
		}

		// MARK: Scope

		/// Appends scoped configuration to stored configuration
		///
		/// Example:
		/// ```swift
		/// .layer.scope { $0
		///   .cornerRadius(12)
		///   .cornerCurve(.continuous)
		/// }
		/// ```
		///
		/// - Parameters:
		///   - config: A closure that receives scoped configuration container and returns configured scoped configuration.
		///
		/// - Returns: A new container with scoped configuration appended to its storage.
		public func scope(
			_ config: (ScopedContainer<Value>) -> ScopedContainer<Value>
		) -> Container {
			return configure(using: config(container._scoped(keyPath)))
		}

		/// Appends scoped configuration to stored configuration
		///
		/// Example:
		/// ```swift
		/// // Note: `.config(_:)` is only available when using
		/// // import DeclarativeConfiguration
		/// // `.customLayerConfig` is custom reusable `Configurator`
		/// .layer.configure(using: .config(.customLayerConfig))
		/// ```
		///
		/// - Parameters:
		///   - config: Erased scoped configuration for the current value.
		///
		/// - Returns: A new container with scoped configuration appended to its storage.
		public func configure(
			using config: ScopedContainer<Value>
		) -> Container{
			let scoped = config
			return container._withStorage { $0
				.appending(_ConfigurationItems.Modify { base in
					base[keyPath: keyPath] = scoped._configured(base[keyPath: keyPath])
				})
			}
		}

		@available(*, deprecated, message: "Use `.ifLet.scope` instead.")
		public func ifLetScope<Wrapped>(
			_ config: @escaping (ScopedContainer<Wrapped>) -> ScopedContainer<Wrapped>
		) -> Container where Value == Wrapped? {
			ifLet.scope(config)
		}

		// MARK: DynamicMember

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
	}

	/// A configuration block for optional writable key paths that supports `@dynamicMemberLookup`
	/// and is callable when the optional is present.
	///
	/// `CallableIfLet` is used for key paths whose value is an optional. It exposes the same
	/// `@dynamicMemberLookup` and callable APIs as `Callable`, but operations are performed
	/// only when the optional is non-`nil`. It also offers helpers to provide default values
	/// (via `callAsFunction(else:)`) and to scope/configure the unwrapped value. Instances
	/// are produced by configuration containers via `@dynamicMemberLookup`.
	///
	/// Examples:
	/// ```swift
	/// .optionalTitle.ifLet.peek { $0.setTitle("Tap") }
	/// .optionalInt.ifLet(else: 0).modify { $0 += 1 }
	/// ```
	@dynamicMemberLookup
	public struct CallableIfLet<Wrapped> {
		public typealias Value = Wrapped?
		public typealias Blocks = ConfigurationBlocks<Container>
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

		@_spi(Internals)
		public func __accessInternals<T>(
			perform operation: (Container, WritableKeyPath<Container.Base, Value>) -> T
		) -> T {
			operation(container, keyPath)
		}

		/// Appends peek operation to stored configuration.
		///
		/// - Note: Useful for function calls on on reference types or logging.
		///
		/// Example:
		/// ```swift
		/// .optionalButton.ifLet.peek { $0.setTitle("Tap") } // method call
		/// .button.titleLabel.ifLet.text.peek { print($0 ?? "") } // simple log
		/// ```
		///
		/// - Parameters:
		///   - operation: Peek operation that accepts current value.
		///
		/// - Returns: A new container with updated stored configuration.
		public func peek(
			_ operation: @escaping (Wrapped) -> Void
		) -> Container {
			container._withStorage { $0
				.appending(_ConfigurationItems.Peek {
					guard let wrapped = $0[keyPath: keyPath] else { return }
					operation(wrapped)
				})
			}
		}

		// MARK: Callable

		/// Appends transformation to stored configuration.
		///
		/// - Note: It's recommended to use this method only when dynamicMemberLookup API
		///         is not available (e.g. function calls).
		///         For reference types or when no transformation is applied, consider using `peek`instead
		///
		/// Example:
		/// ```swift
		/// .optionalIntValue.ifLet.transform { $0 + 1 }
		/// ```
		///
		/// - Parameters:
		///   - transform: Value transform to append to stored configuration.
		///
		/// - Returns: A new container with updated stored configuration.
		public func transform(
			_ transform: @escaping (Wrapped) -> Wrapped
		) -> Container {
			container._withStorage { $0
				.appending(_ConfigurationItems.Modify {
					guard let wrapped = $0[keyPath: keyPath] else { return }
					$0[keyPath: keyPath] = transform(wrapped)
				})
			}
		}

		/// Appends in-place modification to stored configuration.
		///
		/// - Note: It's recommended to use this method only when dynamicMemberLookup API
		///         is not available (e.g. function calls).
		///         For reference types or when no transformation is applied, consider using `peek`instead
		///
		/// Example:
		/// ```swift
		/// .optionalIntValue.ifLet.modify { $0 += 1 }
		/// ```
		///
		/// - Parameters:
		///   - transform: A closure that receives the current value `inout` so it can be modified.
		///
		/// - Returns: A new container with updated stored configuration.
		public func modify(
			_ transform: @escaping (inout Wrapped) -> Void
		) -> Container {
			container._withStorage { $0
				.appending(_ConfigurationItems.Modify {
					guard let wrapped = $0[keyPath: keyPath] else { return }
					$0[keyPath: keyPath] = reduce(wrapped, with: transform)
				})
			}
		}

		/// Registers update for the current value.
		///
		/// Example:
		/// ```swift
		/// .optionalIntValue.ifLet(0)
		/// ```
		///
		/// - Parameters:
		///   - value: New value to set the current one to
		///
		/// - Returns: A new container with updated stored configuration
		public func callAsFunction(
			_ newValue: Wrapped
		) -> Container {
			container._withStorage { $0
				.appending(_ConfigurationItems.Modify {
					guard $0[keyPath: keyPath] != nil else { return }
					$0[keyPath: keyPath] = newValue
				})
			}
		}

		/// Unwraps value with defaultValue
		///
		/// Example:
		/// ```swift
		/// .optionalIntValue.ifLet(else: 0).modify { $0 += 1 }
		/// ```
		///
		/// - Parameters:
		///   - defaultValue: Default value. Will be set if currentValue is `nil`.
		///
		/// - Returns: A new container with updated stored configuration
		public func callAsFunction(
			else defaultValue: Wrapped
		) -> Blocks.Callable<Wrapped> {
			.init(
				container: container._withStorage { $0
					.appending(_ConfigurationItems.Update { base in
						reduce(base) { base in
							if base[keyPath: keyPath] != nil { return }
							base[keyPath: keyPath] = defaultValue
						}
					})
				},
				keyPath: keyPath.unwrapped(
					with: defaultValue,
					aggressive: true
				)
			)
		}

		// MARK: Scope

		/// Appends scoped configuration to stored configuration
		///
		/// Example:
		/// ```swift
		/// .optionalLayer.ifLet.scope { $0
		///   .cornerRadius(12)
		///   .cornerCurve(.continuous)
		/// }
		/// ```
		///
		/// - Parameters:
		///   - config: A closure that receives scoped configuration container and returns configured scoped configuration.
		///
		/// - Returns: A new container with scoped configuration appended to its storage.
		public func scope(
			_ config: @escaping (ScopedContainer<Wrapped>) -> ScopedContainer<Wrapped>
		) -> Container {
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


		/// Appends scoped configuration to stored configuration
		///
		/// Example:
		/// ```swift
		/// // Note: `.config(_:)` is only available when using
		/// // import DeclarativeConfiguration
		/// // `.customLayerConfig` is custom reusable `Configurator`
		/// .optionalLayer.ifLet.configure(using: .config(.customLayerConfig))
		/// ```
		///
		/// - Parameters:
		///   - config: Erased scoped configuration for the current value.
		///
		/// - Returns: A new container with scoped configuration appended to its storage.
		public func configure(
			using config: ScopedContainer<Wrapped>
		) -> Container {
			return container._withStorage { $0
				.appendingConfiguration { base in
					guard let value = base[keyPath: keyPath]
					else { return base }

					return reduce(base) {
						$0[keyPath: keyPath] = config._configured(value)
					}
				}
			}
		}

		// MARK: DynamicMember

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: WritableKeyPath<Wrapped, LocalValue>
		) -> CallableIfLet<LocalValue> {
			CallableIfLet<LocalValue>(
				container: self.container,
				keyPath: self.keyPath.appending(path: keyPath)
			)
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
		) -> NonCallableIfLet<LocalValue> {
			NonCallableIfLet<LocalValue>(
				container: self.container,
				keyPath: self.keyPath.appending(path: keyPath)
			)
		}
	}


	// MARK: - NonCallable

	/// A configuration block for non-writable (read-only) key paths that supports `@dynamicMemberLookup`.
	///
	/// `NonCallable` is used when the underlying key path is not writable (a `KeyPath`). It
	/// provides read-only operations such as `peek` and scoping for reference types, but is
	/// intentionally not callable because the value cannot be set via the key path. Instances
	/// are produced by configuration containers via `@dynamicMemberLookup`.
	///
	/// Examples:
	/// ```swift
	/// .button.titleLabel.peek { print($0.text) }
	/// .layersCollection.scope { $0.fillLayer... }
	/// ```
	@dynamicMemberLookup
	public struct NonCallable<Value> {
		public typealias Blocks = ConfigurationBlocks<Container>
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

		@_spi(Internals)
		public func __accessInternals<T>(
			perform operation: (Container, KeyPath<Container.Base, Value>) -> T
		) -> T {
			operation(container, keyPath)
		}

		/// Appends peek operation to stored configuration.
		///
		/// - Note: Useful for function calls on on reference types or logging.
		///
		/// Example:
		/// ```swift
		/// .button.peek { $0.setTitle("Tap") } // method call
		/// .button.titleLabel.peek { print($0.text) } // simple log
		/// ```
		///
		/// - Parameters:
		///   - operation: Peek operation that accepts current value.
		///
		/// - Returns: A new container with updated stored configuration.
		public func peek(
			_ operation: @escaping (Value) -> Void
		) -> Container {
			container._withStorage { $0
				.appending(_ConfigurationItems.Peek {
					operation($0[keyPath: keyPath])
				})
			}
		}

		// MARK: Scope

		/// Appends scoped configuration to stored configuration
		///
		/// - Warning: Current keyPath is not writable. This method only
		///            makes sense for modifying reference types (including nested ones).
		///
		/// Examples:
		/// - _Reference type_
		/// ```swift
		/// .layer.scope { $0
		///   .cornerRadius(12)
		///   .cornerCurve(.continuous)
		/// }
		/// ```
		/// - _Nested reference types_
		/// ```swift
		/// struct LayersCollection {
		///   let fillLayer: CAShapeLayer
		///   let strokeLayer: CAShapeLayer
		/// }
		///
		/// layersCollection.scope { $0
		///   .fillLayer.fillColor(UIColor.red.cgColor)
		///   .strokeLayer.strokeColor(UIColor.white.cgColor
		/// }
		/// ```
		///
		/// - Parameters:
		///   - config: A closure that receives scoped configuration container and returns configured scoped configuration.
		///
		/// - Returns: A new container with scoped configuration appended to its storage.
		public func scope(
			_ config: (ScopedContainer<Value>) -> ScopedContainer<Value>
		) -> Container {
			configure(using: config(container._scoped(keyPath)))
		}

		/// Appends scoped configuration to stored configuration
		///
		/// - Warning: Current keyPath is not writable. This method only
		///            makes sense for modifying reference types (including nested ones).
		///
		/// Examples:
		/// - _Reference type_
		/// ```swift
		/// // Note: `.config(_:)` is only available when using
		/// // import DeclarativeConfiguration
		/// // `.customLayerConfig` is custom reusable `Configurator`
		/// .layer.configure(using: .config(.customLayerConfig))
		/// ```
		/// - _Nested reference types_
		/// ```swift
		/// struct LayersCollection {
		///   let fillLayer: CAShapeLayer
		///   let strokeLayer: CAShapeLayer
		/// }
		///
		/// // Note: `.config(_:)` is only available when using
		/// // import DeclarativeConfiguration
		/// // `.redWithWhiteOutline` is custom reusable `Configurator<LayersCollection>`
		/// .layersCollection.configure(using: .config(.redWithWhiteOutline))
		/// ```
		///
		/// - Parameters:
		///   - config: Erased scoped configuration for the current value.
		///
		/// - Returns: A new container with scoped configuration appended to its storage.
		public func configure(
			using config: ScopedContainer<Value>
		) -> Container {
			return container._withStorage { $0
				.appending(_ConfigurationItems.Modify { base in
					_ = config._configured(base[keyPath: keyPath])
				})
			}
		}

		@available(*, deprecated, message: "Use `.ifLet.scope` instead.")
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

		// MARK: DynamicMember

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
				keyPath: self.keyPath.appending(path: keyPath)
			)
		}

		@inlinable
		public subscript<Wrapped, LocalValue>(
			dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
		) -> NonCallable<LocalValue?> where Value == Wrapped? {
			NonCallable<LocalValue?>(
				container: self.container,
				keyPath: self.keyPath.appending(path: keyPath)
			)
		}
	}

	/// A configuration block for optional non-writable key paths that supports `@dynamicMemberLookup`.
	///
	/// `NonCallableIfLet` represents optional read-only key paths. It allows peeking and
	/// scoping of the wrapped value when present, but does not provide a callable API since the
	/// key path is not writable. Instances are produced by configuration containers via
	/// `@dynamicMemberLookup`.
	///
	/// Examples:
	/// ```swift
	/// .optionalLabel.ifLet.peek { print($0.text) }
	/// .optionalLayers.ifLet.scope { $0.fillLayer... }
	/// ```
	@dynamicMemberLookup
	public struct NonCallableIfLet<Wrapped> {
		public typealias Value = Wrapped?
		public typealias Blocks = ConfigurationBlocks<Container>
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

		@_spi(Internals)
		public func __accessInternals<T>(
			perform operation: (Container, KeyPath<Container.Base, Value>) -> T
		) -> T {
			operation(container, keyPath)
		}

		/// Appends peek operation to stored configuration.
		///
		/// - Note: Useful for function calls on on reference types or logging.
		///
		/// Example:
		/// ```swift
		/// .button.peek { $0.setTitle("Tap") } // method call
		/// .button.titleLabel.peek { print($0.text) } // simple log
		/// ```
		///
		/// - Parameters:
		///   - operation: Peek operation that accepts current value.
		///
		/// - Returns: A new container with updated stored configuration.
		public func peek(
			_ operation: @escaping (Value) -> Void
		) -> Container {
			container._withStorage { $0
				.appending(_ConfigurationItems.Peek {
					operation($0[keyPath: keyPath])
				})
			}
		}

		// Default implementation is present to explain the reason for unavailability
		/// Not available for non-writable key path
		@available(*, unavailable, message: "Not available for non-writable key path")
		public func callAsFunction(
			else defaultValue: Wrapped
		) -> Blocks.NonCallable<Wrapped> {
			.init(
				container: container,
				keyPath: keyPath.unwrapped(with: defaultValue)
			)
		}

		// MARK: Scope

		/// Appends scoped configuration to stored configuration
		///
		/// - Warning: Current keyPath is not writable. This method only
		///            makes sense for modifying reference types (including nested ones).
		///
		/// Examples:
		/// - _Reference type_
		/// ```swift
		/// .optionalLayer.ifLet.scope { $0
		///   .cornerRadius(12)
		///   .cornerCurve(.continuous)
		/// }
		/// ```
		/// - _Nested reference types_
		/// ```swift
		/// struct LayersCollection {
		///   let fillLayer: CAShapeLayer
		///   let strokeLayer: CAShapeLayer
		/// }
		///
		/// optionalLayersCollection.ifLet.scope { $0
		///   .fillLayer.fillColor(UIColor.red.cgColor)
		///   .strokeLayer.strokeColor(UIColor.white.cgColor
		/// }
		/// ```
		///
		/// - Parameters:
		///   - config: A closure that receives scoped configuration container and returns configured scoped configuration.
		///
		/// - Returns: A new container with scoped configuration appended to its storage.
		public func scope(
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

		/// Appends scoped configuration to stored configuration
		///
		/// - Warning: Current keyPath is not writable. This method only
		///            makes sense for modifying reference types (including nested ones).
		///
		/// Examples:
		/// - _Reference type_
		/// ```swift
		/// // Note: `.config(_:)` is only available when using
		/// // import DeclarativeConfiguration
		/// // `.customLayerConfig` is custom reusable `Configurator`
		/// .optionalLayer.ifLet.configure(using: .config(.customLayerConfig))
		/// ```
		/// - _Nested reference types_
		/// ```swift
		/// struct LayersCollection {
		///   let fillLayer: CAShapeLayer
		///   let strokeLayer: CAShapeLayer
		/// }
		///
		/// // Note: `.config(_:)` is only available when using
		/// // import DeclarativeConfiguration
		/// // `.redWithWhiteOutline` is custom reusable `Configurator<LayersCollection>`
		/// .optionalLayersCollection.ifLet.configure(using: .config(.redWithWhiteOutline))
		/// ```
		///
		/// - Parameters:
		///   - config: Erased scoped configuration for the current value.
		///
		/// - Returns: A new container with scoped configuration appended to its storage.
		public func configured(
			using config: ScopedContainer<Wrapped>
		) -> Container {
			return container._withStorage { $0
				.appendingConfiguration { base in
					guard let value = base[keyPath: keyPath]
					else { return base }

					_ = config._configured(value)
					return base
				}
			}
		}

		// MARK: DynamicMember

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: ReferenceWritableKeyPath<Wrapped, LocalValue>
		) -> CallableIfLet<LocalValue> {
			CallableIfLet<LocalValue>(
				container: self.container,
				keyPath: self.keyPath.appending(path: keyPath)
			)
		}

		@inlinable
		public subscript<LocalValue>(
			dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
		) -> NonCallableIfLet<LocalValue> {
			NonCallableIfLet<LocalValue>(
				container: self.container,
				keyPath: self.keyPath.appending(path: keyPath)
			)
		}
	}
}

// MARK: - IfLet

extension ConfigurationBlocks.Callable where Value: _OptionalProtocol {
	/// Provides ifLet configuration block for current keyPath
	///
	/// "`?`" operator support is not available through dynamic member lookup
	///
	/// ```swift
	/// .optionalProperty?.subproperty(value) // ❌
	/// ```
	///
	/// So this property is used instead
	///
	/// ```swift
	/// .optionalProperty.ifLet.subproperty(value) // ✅
	/// .ifLet(\.optionalProperty).subproperty(value) // ✅ this also works
	/// ```
	public var ifLet: ConfigurationBlocks<Container>.CallableIfLet<Value.Wrapped> {
		.init(container: container, keyPath: keyPath.appending(path: \.__marker_value))
	}

	/// Registers update for the current value. Applied only if currentValue is nil
	///
	/// Example:
	/// ```swift
	/// .optionalIntValue.ifNil(0)
	/// ```
	///
	/// If you need to proceed with further configuration use `ifLet(else:)`
	///
	/// ```swift
	/// .optionalIntValue.ifLet(else: 0).modify { $0 += 1 }
	/// ```
	///
	/// - Parameters:
	///   - value: New value to set the current one to
	///
	/// - Returns: A new container with updated stored configuration
	public func ifNil(_ value: Value) -> Container {
		container._withStorage { $0
			.appending(_ConfigurationItems.Modify { base in
				guard base[keyPath: keyPath].__marker_value == nil else { return }
				base[keyPath: keyPath] = value
			})
		}
	}
}

extension ConfigurationBlocks.NonCallable where Value: _OptionalProtocol {
	/// Provides ifLet configuration block for current keyPath
	///
	/// "`?`" operator support is not available through dynamic member lookup
	///
	/// ```swift
	/// .optionalProperty?.subproperty(value) // ❌
	/// ```
	///
	/// So this property is used instead
	///
	/// ```swift
	/// .optionalProperty.ifLet.subproperty(value) // ✅
	/// .ifLet(\.optionalProperty).subproperty(value) // ✅ this also works
	/// ```
	public var ifLet: ConfigurationBlocks<Container>.NonCallableIfLet<Value.Wrapped> {
		.init(container: container, keyPath: keyPath.appending(path: \.__marker_value))
	}
}

extension ConfigurationBlocks.CallableIfLet where Wrapped: _OptionalProtocol {
	/// Provides ifLet configuration block for current keyPath
	///
	/// "`?`" operator support is not available through dynamic member lookup
	///
	/// ```swift
	/// .optionalProperty?.subproperty(value) // ❌
	/// ```
	///
	/// So this property is used instead
	///
	/// ```swift
	/// .optionalProperty.ifLet.subproperty(value) // ✅
	/// .ifLet(\.optionalProperty).subproperty(value) // ✅ this also works
	/// ```
	public var ifLet: Blocks.CallableIfLet<Wrapped.Wrapped> {
		.init(
			container: container,
			keyPath: keyPath.appending(path: \.__flattened_non_aggressive_marker_value)
		)
	}

	/// Registers update for the current value. Applied only if currentValue is nil
	///
	/// Example:
	/// ```swift
	/// .optionalIntValue.ifNil(0)
	/// ```
	///
	/// If you need to proceed with further configuration use `ifLet(else:)`
	///
	/// ```swift
	/// .optionalIntValue.ifLet(else: 0).modify { $0 += 1 }
	/// ```
	///
	/// - Parameters:
	///   - value: New value to set the current one to
	///
	/// - Returns: A new container with updated stored configuration
	public func ifNil(_ value: Value) -> Container {
		container._withStorage { $0
			.appending(_ConfigurationItems.Modify { base in
				guard
					let currentValue = base[keyPath: keyPath].__marker_value,
					currentValue.__marker_value == nil
				else { return }
				base[keyPath: keyPath] = value
			})
		}
	}
}

extension ConfigurationBlocks.NonCallableIfLet where Wrapped: _OptionalProtocol {
	/// Provides ifLet configuration block for current keyPath
	///
	/// "`?`" operator support is not available through dynamic member lookup
	///
	/// ```swift
	/// .optionalProperty?.subproperty(value) // ❌
	/// ```
	///
	/// So this property is used instead
	///
	/// ```swift
	/// .optionalProperty.ifLet.subproperty(value) // ✅
	/// .ifLet(\.optionalProperty).subproperty(value) // ✅ this also works
	/// ```
	public var ifLet: ConfigurationBlocks<Container>.NonCallableIfLet<Wrapped.Wrapped> {
		.init(
			container: container,
			keyPath: keyPath.appending(path: \.__flattened_non_aggressive_marker_value)
		)
	}
}

// MARK: Derived

extension ConfigurationBlocks.Callable {
	/// Provides ifLet configuration block for specified keyPath
	///
	/// "`?`" operator support is not available through dynamic member lookup
	///
	/// ```swift
	/// .optionalProperty?.subproperty(value) // ❌
	/// ```
	///
	/// So this function is used instead
	///
	/// ```swift
	/// .ifLet(\.optionalProperty).subproperty(value) // ✅
	/// .optionalProperty.ifLet.subproperty(value) // ✅ this also works
	/// ```
	public func ifLet<Wrapped>(
		_ keyPath: WritableKeyPath<Value, Wrapped?>
	) -> Blocks.CallableIfLet<Wrapped> {
		self[dynamicMember: keyPath].ifLet
	}

	/// Provides ifLet configuration block for specified keyPath
	///
	/// "`?`" operator support is not available through dynamic member lookup
	///
	/// ```swift
	/// .optionalProperty?.subproperty(value) // ❌
	/// ```
	///
	/// So this function is used instead
	///
	/// ```swift
	/// .ifLet(\.optionalProperty).subproperty(value) // ✅
	/// .optionalProperty.ifLet.subproperty(value) // ✅ this also works
	/// ```
	public func ifLet<Wrapped>(
		_ keyPath: KeyPath<Value, Wrapped?>
	) -> Blocks.NonCallableIfLet<Wrapped> {
		self[dynamicMember: keyPath].ifLet
	}
}

extension ConfigurationBlocks.NonCallable {
	/// Provides ifLet configuration block for specified keyPath
	///
	/// "`?`" operator support is not available through dynamic member lookup
	///
	/// ```swift
	/// .optionalProperty?.subproperty(value) // ❌
	/// ```
	///
	/// So this function is used instead
	///
	/// ```swift
	/// .ifLet(\.optionalProperty).subproperty(value) // ✅
	/// .optionalProperty.ifLet.subproperty(value) // ✅ this also works
	/// ```
	public func ifLet<Wrapped>(
		_ keyPath: ReferenceWritableKeyPath<Value, Wrapped?>
	) -> Blocks.CallableIfLet<Wrapped> {
		self[dynamicMember: keyPath].ifLet
	}

	/// Provides ifLet configuration block for specified keyPath
	///
	/// "`?`" operator support is not available through dynamic member lookup
	///
	/// ```swift
	/// .optionalProperty?.subproperty(value) // ❌
	/// ```
	///
	/// So this function is used instead
	///
	/// ```swift
	/// .ifLet(\.optionalProperty).subproperty(value) // ✅
	/// .optionalProperty.ifLet.subproperty(value) // ✅ this also works
	/// ```
	public func ifLet<Wrapped>(
		_ keyPath: KeyPath<Value, Wrapped?>
	) -> Blocks.NonCallableIfLet<Wrapped> {
		self[dynamicMember: keyPath].ifLet
	}
}

extension ConfigurationBlocks.CallableIfLet {
	/// Provides ifLet configuration block for specified keyPath
	///
	/// "`?`" operator support is not available through dynamic member lookup
	///
	/// ```swift
	/// .optionalProperty?.subproperty(value) // ❌
	/// ```
	///
	/// So this function is used instead
	///
	/// ```swift
	/// .ifLet(\.optionalProperty).subproperty(value) // ✅
	/// .optionalProperty.ifLet.subproperty(value) // ✅ this also works
	/// ```
	public func ifLet<LocalWrapped>(
		_ keyPath: WritableKeyPath<Wrapped, LocalWrapped?>
	) -> Blocks.CallableIfLet<LocalWrapped> {
		return self[dynamicMember: keyPath].ifLet
	}

	/// Provides ifLet configuration block for specified keyPath
	///
	/// "`?`" operator support is not available through dynamic member lookup
	///
	/// ```swift
	/// .optionalProperty?.subproperty(value) // ❌
	/// ```
	///
	/// So this function is used instead
	///
	/// ```swift
	/// .ifLet(\.optionalProperty).subproperty(value) // ✅
	/// .optionalProperty.ifLet.subproperty(value) // ✅ this also works
	/// ```
	public func ifLet<LocalWrapped>(
		_ keyPath: KeyPath<Wrapped, LocalWrapped?>
	) -> Blocks.NonCallableIfLet<LocalWrapped> {
		return self[dynamicMember: keyPath].ifLet
	}
}

extension ConfigurationBlocks.NonCallableIfLet {
	/// Provides ifLet configuration block for specified keyPath
	///
	/// "`?`" operator support is not available through dynamic member lookup
	///
	/// ```swift
	/// .optionalProperty?.subproperty(value) // ❌
	/// ```
	///
	/// So this function is used instead
	///
	/// ```swift
	/// .ifLet(\.optionalProperty).subproperty(value) // ✅
	/// .optionalProperty.ifLet.subproperty(value) // ✅ this also works
	/// ```
	public func ifLet<LocalWrapped>(
		_ keyPath: ReferenceWritableKeyPath<Wrapped, LocalWrapped?>
	) -> Blocks.CallableIfLet<LocalWrapped> {
		return self[dynamicMember: keyPath].ifLet
	}

	/// Provides ifLet configuration block for specified keyPath
	///
	/// "`?`" operator support is not available through dynamic member lookup
	///
	/// ```swift
	/// .optionalProperty?.subproperty(value) // ❌
	/// ```
	///
	/// So this function is used instead
	///
	/// ```swift
	/// .ifLet(\.optionalProperty).subproperty(value) // ✅
	/// .optionalProperty.ifLet.subproperty(value) // ✅ this also works
	/// ```
	public func ifLet<LocalWrapped>(
		_ keyPath: KeyPath<Wrapped, LocalWrapped?>
	) -> Blocks.NonCallableIfLet<LocalWrapped> {
		return self[dynamicMember: keyPath].ifLet
	}
}

extension Optional where Wrapped: _OptionalProtocol {
	var __flattened_non_aggressive_marker_value: Wrapped.Wrapped? {
		get { self.flatMap(\.__marker_value) }
		set {
			guard var wrapped = self else { return }
			wrapped.__marker_value = newValue
			self = wrapped
		}
	}
}

// MARK: - Conditional application

extension ConfigurationBlocks.Callable {
	/// Registers an update that applies only when the provided optional is non-`nil`.
	///
	/// Example:
	/// ```swift
	/// .title(ifLet: optionalTitle)
	/// ```
	///
	/// - Parameters:
	///   - ifLet: Optional new value. If non-`nil`, the value will be applied.
	///
	/// - Returns: A new container with the update appended to its stored configuration.
	public func callAsFunction(
		ifLet newValue: Value?
	) -> Container {
		return container._withStorage { $0
			.appending(_ConfigurationItems.Modify { base in
				guard let newValue else { return }
				base[keyPath: keyPath] = newValue
			})
		}
	}
}

extension ConfigurationBlocks.CallableIfLet {
	/// Registers an update that applies only when the provided optional is non-`nil`.
	///
	/// Example:
	/// ```swift
	/// .title(ifLet: optionalTitle)
	/// ```
	///
	/// - Parameters:
	///   - ifLet: Optional new value. If non-`nil`, the value will be applied.
	///
	/// - Returns: A new container with the update appended to its stored configuration.
	public func callAsFunction(
		ifLet newValue: Value?
	) -> Container {
		return container._withStorage { $0
			.appending(_ConfigurationItems.Modify { base in
				guard let newValue, base[keyPath: keyPath] != nil else { return }
				base[keyPath: keyPath] = newValue
			})
		}
	}
}
