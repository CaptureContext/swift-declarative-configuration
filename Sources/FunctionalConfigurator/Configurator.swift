import FunctionalKeyPath
import FunctionalModification

@dynamicMemberLookup
public struct Configurator<Base> {
  @usableFromInline
  internal var _configure: (Base) -> Base

  /// Creates a new instance of configurator
  ///
  /// Newly created configurator has no modification set up.
  /// So it's `configure` function does not modify input
  public init() { self._configure = { $0 } }

  /// Creates a configurator with a configuration function
  ///
  /// Initial value passed to configuration function is an empty configurator
  @inlinable
  public init(config configuration: (Configurator) -> Configurator) {
    self = configuration(.init())
  }

  /// Modifies an object with specified configuration
  @inlinable
  public func configure(_ base: inout Base) {
    _ = _configure(base)
  }

  /// Modifies a reference-type object with specified configuration
  @inlinable
  public func configure(_ base: Base) where Base: AnyObject {
    _ = _configure(base)
  }

  /// Modifies returns modified object
  ///
  /// Note: for reference types it is usually the same object
  @inlinable
  public func configured(_ base: Base) -> Base {
    _configure(base)
  }

  /// Appends modification of stored object to stored configuration
  @inlinable
  public func set(_ transform: @escaping (inout Base) -> Void) -> Configurator {
    appendingConfiguration { base in
      reduce(_configure(base), with: transform)
    }
  }

  @inlinable
  public func combined(with configurator: Configurator) -> Configurator {
    appendingConfiguration(configurator._configure)
  }

  /// Appends modification of a new configurator to stored configuration
  @available(*, deprecated, message: "Use `combined(with:) instead`")
  @inlinable
  public func appending(_ configurator: Configurator) -> Configurator {
    appendingConfiguration(configurator._configure)
  }

  /// Appends configuration to stored configuration
  @inlinable
  public func appendingConfiguration(_ configuration: @escaping (Base) -> Base) -> Configurator {
    reduce(self) { _self in
      _self._configure = { configuration(_configure($0)) }
    }
  }

  @inlinable
  public subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Base, Value>
  ) -> CallableBlock<Value> {
    CallableBlock<Value>(
      configurator: self,
      keyPath: .init(keyPath)
    )
  }

  @inlinable
  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Base, Value>
  ) -> NonCallableBlock<Value> {
    NonCallableBlock<Value>(
      configurator: self,
      keyPath: .getonly(keyPath)
    )
  }

  @inlinable
  public subscript<Wrapped, Value>(
    dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
  ) -> CallableBlock<Value?> where Base == Wrapped? {
    CallableBlock<Value?>(
      configurator: self,
      keyPath: FunctionalKeyPath(keyPath).optional()
    )
  }

  @inlinable
  public subscript<Wrapped, Value>(
    dynamicMember keyPath: KeyPath<Wrapped, Value>
  ) -> NonCallableBlock<Value?> where Base == Wrapped? {
    NonCallableBlock<Value?>(
      configurator: self,
      keyPath: FunctionalKeyPath.getonly(keyPath).optional()
    )
  }

  @inlinable
  public static subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Base, Value>
  ) -> CallableBlock<Value> {
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
    dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
  ) -> CallableBlock<Value?> where Base == Wrapped? {
    Configurator()[dynamicMember: keyPath]
  }

  @inlinable
  public static subscript<Wrapped, Value>(
    dynamicMember keyPath: KeyPath<Wrapped, Value>
  ) -> NonCallableBlock<Value?> where Base == Wrapped? {
    Configurator()[dynamicMember: keyPath]
  }

  @inlinable
  public static func set(_ transform: @escaping (inout Base) -> Void) -> Configurator {
    Configurator().set(transform)
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
      keyPath: FunctionalKeyPath<Base, Value>
    ) {
      self._block = .init(
        configurator: configurator,
        keyPath: keyPath
      )
    }

    @inlinable
    public func callAsFunction(_ value: Value) -> Configurator {
      _block.configurator.appendingConfiguration {
        _block.keyPath.embed(value, in: $0)
      }
    }

    @inlinable
    public func set(_ transform: @escaping (inout Value) -> Void) -> Configurator {
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
      _ configuration: @escaping (Configurator<Value>) -> Configurator<Value>
    ) -> Configurator {
      _block.configurator.appendingConfiguration { base in
        _block.keyPath.embed(
          reduce(
            _block.keyPath.extract(from: base),
            with: configuration
          ),
          in: base
        )
      }
    }

    @inlinable
    public func ifLetScope<Wrapped>(
      _ configuration: @escaping (Configurator<Wrapped>) -> Configurator<Wrapped>
    ) -> Configurator where Value == Wrapped? {
      _block.configurator.appendingConfiguration { base in
        guard let value = _block.keyPath.extract(from: base)
        else { return base }

        return _block.keyPath.embed(
          reduce(value, with: configuration),
          in: base
        )
      }
    }

    @inlinable
    public subscript<LocalValue>(
      dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
    ) -> CallableBlock<LocalValue> {
      CallableBlock<LocalValue>(
        configurator: _block.configurator,
        keyPath: _block.keyPath
          .appending(path: FunctionalKeyPath(keyPath))
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
          path: FunctionalKeyPath(keyPath).optional()
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
    internal var keyPath: FunctionalKeyPath<Base, Value>

    @usableFromInline
    internal init(
      configurator: Configurator,
      keyPath: FunctionalKeyPath<Base, Value>
    ) {
      self.configurator = configurator
      self.keyPath = keyPath
    }

    @inlinable
    public func scope(
      _ configuration: @escaping (Configurator<Value>) -> Configurator<Value>
    ) -> Configurator where Value: AnyObject {
      configurator.appendingConfiguration { base in
        keyPath.embed(
          reduce(
            keyPath.extract(from: base),
            with: configuration
          ),
          in: base
        )
      }
    }

    @inlinable
    public func ifLetScope<Wrapped>(
      _ configuration: @escaping (Configurator<Wrapped>) -> Configurator<Wrapped>
    ) -> Configurator where Wrapped: AnyObject, Value == Wrapped? {
      configurator.appendingConfiguration { base in
        guard let value = keyPath.extract(from: base)
        else { return base }

        return keyPath.embed(
          reduce(value, with: configuration),
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
        keyPath: self.keyPath.appending(path: FunctionalKeyPath(keyPath))
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
        keyPath: self.keyPath.appending(path: FunctionalKeyPath(keyPath))
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
