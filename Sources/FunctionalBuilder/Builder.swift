import FunctionalConfigurator
import FunctionalKeyPath

@dynamicMemberLookup
public struct Builder<Base> {
    private var _initialValue: () -> Base
    private var _configurator: Configurator<Base>
    
    public func build() -> Base { _configurator.configure(_initialValue()) }
    
    @inlinable
    public func apply() where Base: AnyObject { _ = build() }
    
    @inlinable
    public func reinforce(_ transform: @escaping (inout Base) -> Void) -> Builder {
        Builder(build()).set(transform)
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
        .init(
            builder: self,
            keyPath: .init(keyPath)
        )
    }
    
    public subscript<Value>(
        dynamicMember keyPath: KeyPath<Base, Value>
    ) -> NonCallableBlock<Value> where Base: AnyObject, Value: AnyObject {
        .init(
            builder: self,
            keyPath: .getonly(keyPath)
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
            .init(
                builder: _block.builder,
                keyPath: _block.keyPath.appending(path: .init(keyPath))
            )
        }
        
        public subscript<LocalValue>(
            dynamicMember keyPath: KeyPath<Value, LocalValue>
        ) -> NonCallableBlock<LocalValue> where Value: AnyObject, LocalValue: AnyObject {
            _block[dynamicMember: keyPath]
        }
    }
    
    @dynamicMemberLookup
    public struct NonCallableBlock<Value> {
        var builder: Builder
        var keyPath: FunctionalKeyPath<Base, Value>
        
        public subscript<LocalValue>(
            dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
        ) -> CallableBlock<LocalValue> where Value: AnyObject {
            .init(
                builder: self.builder,
                keyPath: self.keyPath.appending(path: .init(keyPath))
            )
        }
        
        public subscript<LocalValue>(
            dynamicMember keyPath: KeyPath<Value, LocalValue>
        ) -> NonCallableBlock<LocalValue> where Value: AnyObject, LocalValue: AnyObject {
            .init(
                builder: self.builder,
                keyPath: self.keyPath.appending(path: .getonly(keyPath))
            )
        }
    }
}
