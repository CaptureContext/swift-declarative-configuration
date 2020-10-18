import FunctionalConfigurator
import FunctionalKeyPath

@dynamicMemberLookup
public struct Builder<Base> {
    private var _initialValue: () -> Base
    private var _configurator: Configurator<Base>
    
    public func build() -> Base { _configurator.configured(_initialValue()) }
    
    @inlinable
    public func apply() where Base: AnyObject { _ = build() }
    
    @inlinable
    public func reinforce(
        _ transform: @escaping (inout Base) -> Void
    ) -> Builder {
        Builder(build()).set(transform)
    }
    
    @inlinable
    public func reinforce<T0>(
        _ t0: T0,
        _ transform: @escaping (inout Base, T0) -> Void
    ) -> Builder {
        reinforce { base in transform(&base, t0) }
    }
    
    @inlinable
    public func reinforce<T0, T1>(
        _ t0: T0, t1: T1,
        _ transform: @escaping (inout Base, T0, T1) -> Void
    ) -> Builder {
        reinforce { base in transform(&base, t0, t1) }
    }
    
    @inlinable
    public func reinforce<T0, T1, T2>(
        _ t0: T0, _ t1: T1, _ t2: T2,
        _ transform: @escaping (inout Base, T0, T1, T2) -> Void
    ) -> Builder {
        reinforce { base in transform(&base, t0, t1, t2) }
    }
    
    public init(_ initialValue: @escaping @autoclosure () -> Base) {
        self.init(
            initialValue,
            Configurator<Base>()
        )
    }
    
    private init(
        _ initialValue: @escaping () -> Base,
        _ configurator: Configurator<Base>
    ) {
        _initialValue = initialValue
        _configurator = configurator
    }
        
    public func set(
        _ transform: @escaping (inout Base) -> Void
    ) -> Builder {
        Builder(
            _initialValue,
            _configurator.set(transform)
        )
    }
    
    public subscript<Value>(
        dynamicMember keyPath: WritableKeyPath<Base, Value>
    ) -> CallableBlock<Value> {
        CallableBlock<Value>(
            builder: self,
            keyPath: FunctionalKeyPath(keyPath)
        )
    }
    
    public subscript<Value>(
        dynamicMember keyPath: KeyPath<Base, Value>
    ) -> NonCallableBlock<Value> {
        NonCallableBlock<Value>(
            builder: self,
            keyPath: .getonly(keyPath)
        )
    }
    
    public subscript<Wrapped, Value>(
        dynamicMember keyPath: WritableKeyPath<Wrapped, Value>
    ) -> CallableBlock<Value?> where Base == Optional<Wrapped> {
        CallableBlock<Value?>(
            builder: self,
            keyPath: FunctionalKeyPath(keyPath).optional()
        )
    }
    
    public subscript<Wrapped, Value>(
        dynamicMember keyPath: KeyPath<Wrapped, Value>
    ) -> NonCallableBlock<Value?> where Base == Optional<Wrapped> {
        NonCallableBlock<Value?>(
            builder: self,
            keyPath: FunctionalKeyPath.getonly(keyPath).optional()
        )
    }
    
}

extension Builder {
    @dynamicMemberLookup
    public struct CallableBlock<Value> {
        private var _block: NonCallableBlock<Value>
        
        init(
            builder: Builder,
            keyPath: FunctionalKeyPath<Base, Value>
        ) {
            self._block = .init(
                builder: builder,
                keyPath: keyPath
            )
        }
        
        public func callAsFunction(if condition: Bool, _ value: @escaping @autoclosure () -> Value) -> Builder {
            Builder(
                _block.builder._initialValue,
                _block.builder._configurator.appendingConfiguration { base in
                    _block.keyPath.embed(value(), in: base)
                }
            )
        }
        
        public func callAsFunction(_ value: @escaping @autoclosure () -> Value) -> Builder {
            Builder(
                _block.builder._initialValue,
                _block.builder._configurator.appendingConfiguration { base in
                    _block.keyPath.embed(value(), in: base)
                }
            )
        }
        
        public subscript<LocalValue>(
            dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
        ) -> CallableBlock<LocalValue> {
            CallableBlock<LocalValue>(
                builder: _block.builder,
                keyPath: _block.keyPath.appending(path: .init(keyPath))
            )
        }
        
        public subscript<LocalValue>(
            dynamicMember keyPath: KeyPath<Value, LocalValue>
        ) -> NonCallableBlock<LocalValue> {
            _block[dynamicMember: keyPath]
        }
        
        public subscript<Wrapped, LocalValue>(
            dynamicMember keyPath: WritableKeyPath<Wrapped, LocalValue>
        ) -> CallableBlock<LocalValue?> where Value == Optional<Wrapped> {
            CallableBlock<LocalValue?>(
                builder: _block.builder,
                keyPath: _block.keyPath.appending(
                    path: FunctionalKeyPath(keyPath).optional()
                )
            )
        }
        
        public subscript<Wrapped, LocalValue>(
            dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
        ) -> NonCallableBlock<LocalValue?> where Value == Optional<Wrapped> {
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
        var builder: Builder
        var keyPath: FunctionalKeyPath<Base, Value>
        
        public subscript<LocalValue>(
            dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
        ) -> CallableBlock<LocalValue> where Value: AnyObject {
            CallableBlock<LocalValue>(
                builder: self.builder,
                keyPath: self.keyPath.appending(path: .init(keyPath))
            )
        }
        
        public subscript<LocalValue>(
            dynamicMember keyPath: KeyPath<Value, LocalValue>
        ) -> NonCallableBlock<LocalValue> {
            NonCallableBlock<LocalValue>(
                builder: self.builder,
                keyPath: self.keyPath.appending(path: .getonly(keyPath))
            )
        }
        
        public subscript<Wrapped, LocalValue>(
            dynamicMember keyPath: WritableKeyPath<Wrapped, LocalValue>
        ) -> CallableBlock<LocalValue?> where Wrapped: AnyObject, Value == Optional<Wrapped> {
            CallableBlock<LocalValue?>(
                builder: self.builder,
                keyPath: self.keyPath.appending(
                    path: FunctionalKeyPath(keyPath).optional()
                )
            )
        }
        
        public subscript<Wrapped, LocalValue>(
            dynamicMember keyPath: KeyPath<Wrapped, LocalValue>
        ) -> NonCallableBlock<LocalValue?> where Value == Optional<Wrapped> {
            NonCallableBlock<LocalValue?>(
                builder: self.builder,
                keyPath: self.keyPath.appending(
                    path: FunctionalKeyPath.getonly(keyPath).optional()
                )
            )
        }
    }
}
