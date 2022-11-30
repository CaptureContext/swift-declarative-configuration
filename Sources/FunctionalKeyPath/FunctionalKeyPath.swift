import FunctionalModification

/// A path that supports embedding a value in a root and attempting to extract a root's embedded
/// value.
///
/// This type defines key path-like semantics for enum cases.
public struct FunctionalKeyPath<Root, Value> {
  private let _embed: (Value, Root) -> Root
  private let _extract: (Root) -> Value

  /// Creates a functional keyPath with a pair of functions.
  ///
  /// - Parameters:
  ///   - embed: A function that always succeeds in embedding a value in a root.
  ///   - extract: A function that can optionally fail in extracting a value from a root.
  public init(embed: @escaping (Value, Root) -> Root, extract: @escaping (Root) -> Value) {
    self._embed = embed
    self._extract = extract
  }

  /// Creates a functional keyPath with a writableKeyPath
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

  /// Creates a functional keyPath with a writableKeyPath
  @inlinable
  public static func optional(
    _ keyPath: WritableKeyPath<Root, Value>
  ) -> FunctionalKeyPath<Root?, Value?> {
    FunctionalKeyPath(keyPath).optional()
  }

  /// Creates a functional keyPath with a keyPath
  ///
  /// Ignores embed function call
  @inlinable
  public static func getonly(_ keyPath: KeyPath<Root, Value>) -> FunctionalKeyPath {
    FunctionalKeyPath(
      embed: { _, root in
        root
      },
      extract: { root in
        root[keyPath: keyPath]
      }
    )
  }

  /// Makes path optional
  public func optional() -> FunctionalKeyPath<Root?, Value?> {
    FunctionalKeyPath<Root?, Value?>(
      embed: { value, root in
        guard let root = root, let value = value else { return nil }
        return self._embed(value, root)
      },
      extract: { root in
        guard let root = root else { return nil }
        return self._extract(root)
      }
    )
  }

  /// Returns a root by embedding a value.
  ///
  /// Note: Value will not be embed if FunctionalKeyPath was initialized by default (non-writable) `KeyPath` via `getonly` function
  ///
  /// - Parameter value: A value to embed.
  /// - Returns: A root that embeds `value`.
  public func embed(_ value: Value, in root: Root) -> Root {
    _embed(value, root)
  }

  /// Returns a root by embedding a value.
  ///
  /// Note: Value will not be embed if FunctionalKeyPath was initialized by default (non-writable) `KeyPath` via `getonly` function
  ///
  /// - Parameter value: A value to embed.
  public func embed(_ value: Value, in root: inout Root) {
    root = embed(value, in: root)
  }

  /// Attempts to extract a value from a root.
  ///
  /// - Parameter root: A root to extract from.
  /// - Returns: A value iff it can be extracted from the given root, otherwise `nil`.
  public func extract(from root: Root) -> Value {
    _extract(root)
  }

  /// Returns a new functional keyPath created by appending the given functional keyPath to this one.
  ///
  /// Use this method to extend this functional keyPath to the value type of another functional keyPath.
  ///
  /// - Parameter path: The functional keyPath to append.
  /// - Returns: A functional keyPath from the root of this functional keyPath to the value type of `path`.
  @inlinable
  public func appending<AppendedValue>(path: FunctionalKeyPath<Value, AppendedValue>)
    -> FunctionalKeyPath<Root, AppendedValue>
  {
    FunctionalKeyPath<Root, AppendedValue>(
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

  /// Returns a new functional keyPath created by appending the given functional keyPath to this one.
  ///
  /// Use this method to extend this functional keyPath to the value type of another functional keyPath.
  ///
  /// - Parameter path: The functional keyPath to append.
  /// - Returns: A functional keyPath from the root of this functional keyPath to the value type of `path`.
  @inlinable
  public func appending<Wrapped, AppendedValue>(
    path: FunctionalKeyPath<Wrapped, AppendedValue>
  ) -> FunctionalKeyPath<Root, AppendedValue?> where Value == Wrapped? {
    appending(path: path.optional())
  }
}

extension FunctionalKeyPath {
  public static func key<Key: Hashable, _Value>(
    _ key: Key
  ) -> FunctionalKeyPath
    where Root == [Key: _Value], Value == _Value?
  {
    FunctionalKeyPath(
      embed: { value, root in
        modification(of: root) { $0[key] = value }
      },
      extract: { $0[key] }
    )
  }

  public static func index(_ index: Root.Index) -> FunctionalKeyPath
    where Root: MutableCollection, Value == Root.Element
  {
    FunctionalKeyPath(
      embed: { value, root in
        modification(of: root) { root in
          root[index] = value
        }
      },
      extract: { root in
        root[index]
      }
    )
  }

  public static func getonlyIndex(_ index: Root.Index) -> FunctionalKeyPath
    where Root: Collection, Value == Root.Element
  {
    FunctionalKeyPath(
      embed: { _, root in root },
      extract: { $0[index] }
    )
  }

  public static func safeIndex(_ index: Root.Index) -> FunctionalKeyPath<Root, Value?>
    where Root == [Value]
  {
    FunctionalKeyPath<Root, Value?>(
      embed: { value, root in
        modification(of: root) { root in
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
