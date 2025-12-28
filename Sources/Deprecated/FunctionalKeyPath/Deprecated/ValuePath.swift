/// Do not use this struct, it will be removed in future versions in favor native KeyPaths
///
/// It's an implementation detail used to silence implementation warnings for internal use.
/// Use `ValuePath` typealias, however this one will also be removed in `1.0.0`
///
/// - Note: Migrate to https://github.com/capturecontext/swift-keypaths-extensions instead
public struct __ValuePath_DEPRECATED<Root, Value> {
	@usableFromInline
	internal let _embed: (Value, Root) -> Root

	@usableFromInline
	internal let _extract: (Root) -> Value

	/// Creates a valuePath with a pair of functions.
	///
	/// - Parameters:
	///   - embed: A function that always succeeds in embedding a value in a root.
	///   - extract: A function that can optionally fail in extracting a value from a root.
	public init(
		embed: @escaping (Value, Root) -> Root,
		extract: @escaping (Root) -> Value
	) {
		self._embed = embed
		self._extract = extract
	}
}

/// A path that supports embedding a value in a root and attempting to extract a root's embedded
/// value
@available(
	*, deprecated,
	message: """
	Consider using KeyPaths or copying sources instead.
	https://github.com/capturecontext/swift-keypaths-extensions
	can help with combining optional keypaths while keeping hashability.
	https://github.com/pointfreeco/swift-case-paths can help with
	both simple optional keypaths and enum case paths (CasePaths).
	ValuePaths are likely to be removed in v1.0.0
	"""
)
public typealias ValuePath<Root, Value> = __ValuePath_DEPRECATED<Root, Value>

extension __ValuePath_DEPRECATED {
	/// Returns a root by embedding a value.
	///
	/// Note: Value will not be embed if ValuePath was initialized by default (non-writable) `KeyPath` via `getonly` function
	///
	/// - Parameter value: A value to embed.
	/// - Returns: A root that embeds `value`.
	@inlinable
	public func embed(_ value: Value, in root: Root) -> Root {
		_embed(value, root)
	}

	/// Returns a root by embedding a value.
	///
	/// Note: Value will not be embed if ValuePath was initialized by default (non-writable) `KeyPath` via `getonly` function
	///
	/// - Parameter value: A value to embed.
	/// - Returns: A root that embeds `value`.
	@inlinable
	public func embed(_ value: Value, in root: Root) where Root: AnyObject {
		_ = _embed(value, root)
	}

	/// Returns a root by embedding a value.
	///
	/// Note: Value will not be embed if ValuePath was initialized by default (non-writable) `KeyPath` via `getonly` function
	///
	/// - Parameter value: A value to embed.
	@inlinable
	public func embed(_ value: Value, in root: inout Root) {
		root = embed(value, in: root)
	}

	/// Attempts to extract a value from a root.
	///
	/// - Parameter root: A root to extract from.
	/// - Returns: A value iff it can be extracted from the given root, otherwise `nil`.
	@inlinable
	public func extract(from root: Root) -> Value {
		_extract(root)
	}

	/// Creates a valuePath with a writableKeyPath
	@inlinable
	public init(_ keyPath: WritableKeyPath<Root, Value>) {
		self.init(
			embed: { value, root in
				var root = root
				root[keyPath: keyPath] = value
				return root
			},
			extract: { root in
				root[keyPath: keyPath]
			}
		)
	}

	/// Creates a valuePath with a keyPath
	///
	/// Ignores embed function call
	@inlinable
	public static func getonly(_ keyPath: KeyPath<Root, Value>) -> __ValuePath_DEPRECATED {
		__ValuePath_DEPRECATED(
			embed: { _, root in
				root
			},
			extract: { root in
				root[keyPath: keyPath]
			}
		)
	}

	@inlinable
	public func unwrapped<Wrapped>(
		withDefaultValue defaultValue: @escaping @autoclosure () -> Wrapped
	) -> __ValuePath_DEPRECATED<Root, Wrapped> where Value == Wrapped? {
		__ValuePath_DEPRECATED<Root, Wrapped>(
			embed: { value, root in
				_embed(value, root)
			},
			extract: {
				_extract($0) ?? defaultValue()
			}
		)
	}

	/// Creates a valuePath with a writableKeyPath
	@inlinable
	public static func optional(
		_ keyPath: WritableKeyPath<Root, Value>
	) -> __ValuePath_DEPRECATED<Root, Value?> {
		__ValuePath_DEPRECATED(keyPath).optional()
	}

	/// Creates a valuePath with a writableKeyPath
	///
	/// If `unwrapWithRoot` is `true` embedding nil will result in returning existing root
	/// If `unwrapWithRoot` is `false` embedding nil will result in returning nil
	@inlinable
	public static func optional(
		unwrapWithRoot: Bool,
		_ keyPath: WritableKeyPath<Root, Value>
	) -> __ValuePath_DEPRECATED<Root?, Value?> {
		__ValuePath_DEPRECATED(keyPath).optional(unwrapWithRoot: unwrapWithRoot)
	}

	/// Makes path value optional
	@inlinable
	public func optional() -> __ValuePath_DEPRECATED<Root, Value?> {
		__ValuePath_DEPRECATED<Root, Value?>(
			embed: { value, root in
				guard let value else { return root }
				return self._embed(value, root)
			},
			extract: { root in
				return self._extract(root)
			}
		)
	}

	/// Makes path optional
	///
	/// If `unwrapWithRoot` is `true` embedding nil will result in returning existing root
	/// If `unwrapWithRoot` is `false` embedding nil will result in returning nil
	@inlinable
	public func optional(unwrapWithRoot: Bool) -> __ValuePath_DEPRECATED<Root?, Value?> {
		__ValuePath_DEPRECATED<Root?, Value?>(
			embed: { value, root in
				guard let root, let value else { return unwrapWithRoot ? root : nil }
				return self._embed(value, root)
			},
			extract: { root in
				guard let root else { return nil }
				return self._extract(root)
			}
		)
	}

	/// Returns a new valuePath created by appending the given valuePath to this one.
	///
	/// Use this method to extend this valuePath to the value type of another valuePath.
	///
	/// - Parameter path: The valuePath to append.
	/// - Returns: A valuePath from the root of this valuePath to the value type of `path`.
	@inlinable
	public func appending<AppendedValue>(
		path: __ValuePath_DEPRECATED<Value, AppendedValue>
	) -> __ValuePath_DEPRECATED<Root, AppendedValue> {
		__ValuePath_DEPRECATED<Root, AppendedValue>(
			embed: { appendedValue, root in
				self.embed(
					path.embed(
						appendedValue,
						in: self.extract(from: root)
					),
					in: root
				)
			},
			extract: { root in
				path.extract(
					from: self.extract(from: root)
				)
			}
		)
	}

	/// Returns a new valuePath created by appending the given valuePath to this one.
	///
	/// Use this method to extend this valuePath to the value type of another valuePath.
	///
	/// - Parameter path: The valuePath to append.
	/// - Returns: A valuePath from the root of this valuePath to the value type of `path`.
	@inlinable
	public func appending<Wrapped, AppendedValue>(
		path: __ValuePath_DEPRECATED<Wrapped, AppendedValue>
	) -> __ValuePath_DEPRECATED<Root, AppendedValue?> where Value == Wrapped? {
		appending(path: path.optional(unwrapWithRoot: true))
	}
}

extension __ValuePath_DEPRECATED {
	@inlinable
	public static func key<Key: Hashable, Element>(
		_ key: Key
	) -> __ValuePath_DEPRECATED where Root == [Key: Element], Value == Element? {
		__ValuePath_DEPRECATED(
			embed: { value, root in
				reduce(root) { $0[key] = value }
			},
			extract: { $0[key] }
		)
	}

	@inlinable
	public static func index(
		_ index: Root.Index
	) -> __ValuePath_DEPRECATED where Root: MutableCollection, Value == Root.Element {
		__ValuePath_DEPRECATED(
			embed: { value, root in
				reduce(root) { root in
					root[index] = value
				}
			},
			extract: { root in
				root[index]
			}
		)
	}

	@inlinable
	public static func index(
		getonly index: Root.Index
	) -> __ValuePath_DEPRECATED where Root: Collection, Value == Root.Element {
		__ValuePath_DEPRECATED(
			embed: { _, root in root },
			extract: { $0[index] }
		)
	}

	@inlinable
	public static func index(
		safe index: Root.Index
	) -> __ValuePath_DEPRECATED<Root, Value> where Root: MutableCollection, Value == Root.Element? {
		__ValuePath_DEPRECATED<Root, Value>(
			embed: { value, root in
				reduce(root) { root in
					guard
						let value = value,
						root.indices.contains(index)
					else { return }
					root[index] = value
				}
			},
			extract: { root in
				root.indices.contains(index)
				? root[index]
				: nil
			}
		)
	}
}
