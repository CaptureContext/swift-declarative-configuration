import FunctionalConfigurator
import FunctionalKeyPath
import FunctionalModification

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

//  /// Applies modification to a new builder, created with a built object.
//  @inlinable
//  public func reinforce(
//    _ transform: @escaping (inout Base) -> Void
//  ) -> Builder {
//    Builder(build()).set(transform)
//  }

  /// Applies modification to a new builder, created with a built object, also passes leading parameters to transform function.
  @inlinable
  public func reinforce<each Arg>(
    _ args: repeat each Arg,
    transform: @escaping (inout Base, repeat each Arg) -> Void
  ) -> Builder {
    Builder(build()).set { base in transform(&base, repeat each args) }
  }

//  /// Applies modification to a new builder, created with a built object, also passes leading parameters to transform function.
//  @inlinable
//  public func reinforce<T0, T1>(
//    _ t0: T0,
//    t1: T1,
//    _ transform: @escaping (inout Base, T0, T1) -> Void
//  ) -> Builder {
//    reinforce { base in transform(&base, t0, t1) }
//  }
//
//  /// Applies modification to a new builder, created with a built object, also passes leading parameters to transform function.
//  @inlinable
//  public func reinforce<T0, T1, T2>(
//    _ t0: T0,
//    _ t1: T1,
//    _ t2: T2,
//    _ transform: @escaping (inout Base, T0, T1, T2) -> Void
//  ) -> Builder {
//    reinforce { base in transform(&base, t0, t1, t2) }
//  }

  @inlinable
  public func combined(with builder: Builder) -> Builder {
    Builder(
      _initialValue,
      _configurator.combined(with: builder._configurator)
    )
  }

  @inlinable
  public func combined(with configurator: Configurator<Base>) -> Builder {
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
  public func set(
    _ transform: @escaping (inout Base) -> Void
  ) -> Builder {
    Builder(
      _initialValue,
      _configurator.set(transform)
    )
  }

  @inlinable
  public subscript<Value>(
    dynamicMember keyPath: WritableKeyPath<Base, Value>
  ) -> CallableBlock<Value> {
    CallableBlock<Value>(
      builder: self,
      keyPath: FunctionalKeyPath(keyPath)
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
    dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
  ) -> CallableBlock<Value?> where Base == Wrapped? {
    CallableBlock<Value?>(
      builder: self,
      keyPath: FunctionalKeyPath(keyPath).optional()
    )
  }

  @inlinable
  public subscript<Wrapped, Value>(
    dynamicMember keyPath: KeyPath<Wrapped, Value>
  ) -> NonCallableBlock<Value?> where Base == Wrapped? {
    NonCallableBlock<Value?>(
      builder: self,
      keyPath: FunctionalKeyPath.getonly(keyPath).optional()
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
      keyPath: FunctionalKeyPath<Base, Value>
    ) {
      self._block = .init(
        builder: builder,
        keyPath: keyPath
      )
    }

    @inlinable
    public func callAsFunction(
      if condition: Bool,
      then thenValue: @escaping @autoclosure () -> Value
    ) -> Builder {
      Builder(
        _block.builder._initialValue,
        _block.builder._configurator.appendingConfiguration { base in
          if condition {
            return _block.keyPath.embed(thenValue(), in: base)
          } else {
            return base
          }
        }
      )
    }

    @inlinable
    public func scope(_ builder: @escaping (Builder<Value>) -> Builder<Value>) -> Builder {
      Builder(
        _block.builder._initialValue,
        _block.builder._configurator.appendingConfiguration { base in
          _block.keyPath.embed(
            builder(.init(_block.keyPath.extract(from: base))).build(),
            in: base
          )
        }
      )
    }

    @inlinable
    public func ifLetScope<Wrapped>(
      _ builder: @escaping (Builder<Wrapped>) -> Builder<Wrapped>
    ) -> Builder where Value == Wrapped? {
      Builder(
        _block.builder._initialValue,
        _block.builder._configurator.appendingConfiguration { base in
          guard let value = _block.keyPath.extract(from: base) else { return base }
          return _block.keyPath.embed(
            builder(.init(value)).build(),
            in: base
          )
        }
      )
    }

    @inlinable
    public func callAsFunction(
      if condition: Bool,
      then thenValue: @escaping @autoclosure () -> Value,
      else elseValue: (() -> Value)? = nil
    ) -> Builder {
      Builder(
        _block.builder._initialValue,
        _block.builder._configurator.appendingConfiguration { base in
          if condition {
            return _block.keyPath.embed(thenValue(), in: base)
          } else if let value = elseValue?() {
            return _block.keyPath.embed(value, in: base)
          } else {
            return base
          }
        }
      )
    }

    @inlinable
    public func callAsFunction(_ value: @escaping @autoclosure () -> Value) -> Builder {
      Builder(
        _block.builder._initialValue,
        _block.builder._configurator.appendingConfiguration { base in
          _block.keyPath.embed(value(), in: base)
        }
      )
    }

    @inlinable
    public func set(_ transform: @escaping (inout Value) -> Void) -> Builder {
      Builder(
        _block.builder._initialValue,
        _block.builder._configurator.appendingConfiguration { base in
          _block.keyPath.embed(
            reduce(_block.keyPath.extract(from: base), with: transform),
            in: base
          )
        }
      )
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
        builder: _block.builder,
        keyPath: _block.keyPath.appending(
          path: FunctionalKeyPath(keyPath).optional()
        )
      )
    }

    @inlinable
    public subscript<Wrapped, LocalValue>(
      dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
    ) -> NonCallableBlock<LocalValue?> where Value == Wrapped? {
      NonCallableBlock<LocalValue?>(
        builder: _block.builder,
        keyPath: _block.keyPath.appending(
          path: FunctionalKeyPath.getonly(keyPath).optional()
        )
      )
    }
  }

  @dynamicMemberLookup
  public struct NonCallableBlock<Value> {
    @usableFromInline
    internal var builder: Builder

    @usableFromInline
    internal var keyPath: FunctionalKeyPath<Base, Value>

    @usableFromInline
    internal init(
      builder: Builder,
      keyPath: FunctionalKeyPath<Base, Value>
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
      dynamicMember keyPath: ReferenceWritableKeyPath<Wrapped, LocalValue>
    ) -> CallableBlock<LocalValue?> where Value == Wrapped? {
      CallableBlock<LocalValue?>(
        builder: self.builder,
        keyPath: self.keyPath.appending(
          path: FunctionalKeyPath(keyPath).optional()
        )
      )
    }

    @inlinable
    public subscript<Wrapped, LocalValue>(
      dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
    ) -> NonCallableBlock<LocalValue?> where Value == Wrapped? {
      NonCallableBlock<LocalValue?>(
        builder: self.builder,
        keyPath: self.keyPath.appending(
          path: FunctionalKeyPath.getonly(keyPath).optional()
        )
      )
    }
  }
}
