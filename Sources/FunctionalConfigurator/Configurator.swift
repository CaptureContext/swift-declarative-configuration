import FunctionalKeyPath
import FunctionalModification

@dynamicMemberLookup
public struct Configurator<Base> {
  private var _configure: (Base) -> Base

  /// Creates a new instance of configurator
  ///
  /// Newly created configurator has no modification set up.
  /// So it's `configure` function does not modify input
  public init() { self._configure = { $0 } }

  /// Creates a configurator with a configuration function
  ///
  /// Initial value passed to configuration function is an empty configurator
  public init(config configuration: (Configurator) -> Configurator) {
    self = configuration(.init())
  }

  /// Modifies an object with specified configuration
  public func configure(_ base: inout Base) {
    _ = _configure(base)
  }

  /// Modifies a reference-type object with specified configuration
  public func configure(_ base: Base) where Base: AnyObject {
    _ = _configure(base)
  }

  /// Modifies returns modified object
  ///
  /// Note: for reference types it is usually the same object
  public func configured(_ base: Base) -> Base {
    _configure(base)
  }

  /// Appends modification of stored object to stored configuration
  public func set(_ transform: @escaping (inout Base) -> Void) -> Configurator {
    appendingConfiguration { base in
      modification(of: _configure(base), with: transform)
    }
  }

  public func combined(with configurator: Configurator) -> Configurator {
    appendingConfiguration(configurator._configure)
  }

  /// Appends modification of a new configurator to stored configuration
  @available(*, deprecated, message: "Use `combined(with:) instead`")
  public func appending(_ configurator: Configurator) -> Configurator {
    appendingConfiguration(configurator._configure)
  }

  /// Appends configuration to stored configuration
  public func appendingConfiguration(_ configuration: @escaping (Base) -> Base) -> Configurator {
    modification(of: self) { _self in
      _self._configure = { configuration(_configure($0)) }
    }
  }

  public subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Base, Value>
  ) -> CallableBlock<Value> {
    CallableBlock<Value>(
      configurator: self,
      keyPath: .init(keyPath)
    )
  }

  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Base, Value>
  ) -> NonCallableBlock<Value> {
    NonCallableBlock<Value>(
      configurator: self,
      keyPath: .getonly(keyPath)
    )
  }

  public subscript<Wrapped, Value>(
    dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
  ) -> CallableBlock<Value?> where Base == Wrapped? {
    CallableBlock<Value?>(
      configurator: self,
      keyPath: FunctionalKeyPath(keyPath).optional()
    )
  }

  public subscript<Wrapped, Value>(
    dynamicMember keyPath: KeyPath<Wrapped, Value>
  ) -> NonCallableBlock<Value?> where Base == Wrapped? {
    NonCallableBlock<Value?>(
      configurator: self,
      keyPath: FunctionalKeyPath.getonly(keyPath).optional()
    )
  }

  public static subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Base, Value>
  ) -> CallableBlock<Value> {
    Configurator()[dynamicMember: keyPath]
  }

  public static subscript<Value>(
    dynamicMember keyPath: KeyPath<Base, Value>
  ) -> NonCallableBlock<Value> {
    Configurator()[dynamicMember: keyPath]
  }

  public static subscript<Wrapped, Value>(
    dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
  ) -> CallableBlock<Value?> where Base == Wrapped? {
    Configurator()[dynamicMember: keyPath]
  }

  public static subscript<Wrapped, Value>(
    dynamicMember keyPath: KeyPath<Wrapped, Value>
  ) -> NonCallableBlock<Value?> where Base == Wrapped? {
    Configurator()[dynamicMember: keyPath]
  }

  public static func set(_ transform: @escaping (inout Base) -> Void) -> Configurator {
    Configurator().set(transform)
  }
}

extension Configurator {
  @dynamicMemberLookup
  public struct CallableBlock<Value> {
    var _block: NonCallableBlock<Value>

    init(
      configurator: Configurator,
      keyPath: FunctionalKeyPath<Base, Value>
    ) {
      self._block = .init(
        configurator: configurator,
        keyPath: keyPath
      )
    }

    public func callAsFunction(_ value: Value) -> Configurator {
      _block.configurator.appendingConfiguration {
        _block.keyPath.embed(value, in: $0)
      }
    }

    public func set(_ transform: @escaping (inout Value) -> Void) -> Configurator {
      _block.configurator.appendingConfiguration { base in
        _block.keyPath.embed(
          modification(
            of: _block.keyPath.extract(from: base),
            with: transform
          ),
          in: base
        )
      }
    }

    public func scope(
      _ configuration: @escaping (Configurator<Value>) -> Configurator<Value>
    ) -> Configurator {
      _block.configurator.appendingConfiguration { base in
        _block.keyPath.embed(
          _modification(
            of: _block.keyPath.extract(from: base),
            with: configuration
          ),
          in: base
        )
      }
    }

    public func ifLetScope<Wrapped>(
      _ configuration: @escaping (Configurator<Wrapped>) -> Configurator<Wrapped>
    ) -> Configurator where Value == Wrapped? {
      _block.configurator.appendingConfiguration { base in
        guard let value = _block.keyPath.extract(from: base)
        else { return base }

        return _block.keyPath.embed(
          _modification(of: value, with: configuration),
          in: base
        )
      }
    }

    public subscript<LocalValue>(
      dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
    ) -> CallableBlock<LocalValue> {
      CallableBlock<LocalValue>(
        configurator: _block.configurator,
        keyPath: _block.keyPath
          .appending(path: FunctionalKeyPath(keyPath))
      )
    }

    public subscript<LocalValue>(
      dynamicMember keyPath: KeyPath<Value, LocalValue>
    ) -> NonCallableBlock<LocalValue> {
      _block[dynamicMember: keyPath]
    }

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

    public subscript<Wrapped, LocalValue>(
      dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
    ) -> NonCallableBlock<LocalValue?> where Value == Wrapped? {
      _block[dynamicMember: keyPath]
    }
  }

  @dynamicMemberLookup
  public struct NonCallableBlock<Value> {
    var configurator: Configurator
    var keyPath: FunctionalKeyPath<Base, Value>

    public func scope(
      _ configuration: @escaping (Configurator<Value>) -> Configurator<Value>
    ) -> Configurator where Value: AnyObject {
      configurator.appendingConfiguration { base in
        keyPath.embed(
          _modification(
            of: keyPath.extract(from: base),
            with: configuration
          ),
          in: base
        )
      }
    }

    public func ifLetScope<Wrapped>(
      _ configuration: @escaping (Configurator<Wrapped>) -> Configurator<Wrapped>
    ) -> Configurator where Wrapped: AnyObject, Value == Wrapped? {
      configurator.appendingConfiguration { base in
        guard let value = keyPath.extract(from: base)
        else { return base }

        return keyPath.embed(
          _modification(of: value, with: configuration),
          in: base
        )
      }
    }

    public subscript<LocalValue>(
      dynamicMember keyPath: ReferenceWritableKeyPath<Value, LocalValue>
    ) -> CallableBlock<LocalValue> {
      .init(
        configurator: self.configurator,
        keyPath: self.keyPath.appending(path: FunctionalKeyPath(keyPath))
      )
    }

    public subscript<LocalValue>(
      dynamicMember keyPath: KeyPath<Value, LocalValue>
    ) -> NonCallableBlock<LocalValue> {
      .init(
        configurator: self.configurator,
        keyPath: self.keyPath.appending(path: .getonly(keyPath))
      )
    }

    public subscript<Wrapped, LocalValue>(
      dynamicMember keyPath: ReferenceWritableKeyPath<Wrapped, LocalValue>
    ) -> CallableBlock<LocalValue?> where Value == Wrapped? {
      CallableBlock<LocalValue?>(
        configurator: self.configurator,
        keyPath: self.keyPath.appending(path: FunctionalKeyPath(keyPath))
      )
    }

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
