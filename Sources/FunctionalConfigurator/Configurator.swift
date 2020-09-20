import FunctionalKeyPath
import FunctionalModification

@dynamicMemberLookup
public struct Configurator<Base> {
    private var _configure: (Base) -> Base
    public init() { _configure = { $0 } }
    
    @discardableResult
    public func configure(_ base: Base) -> Base {
        _configure(base)
    }
    
    public func configure(_ base: Base) where Base: AnyObject {
        _ = _configure(base)
    }
        
    public func set(_ transform: @escaping (inout Base) -> Void) -> Configurator {
        appendingConfiguration { base in
            modification(of: _configure(base), with: transform)
        }
    }
    
    @inlinable
    public func appending(_ configurator: Configurator) -> Configurator {
        appendingConfiguration(configurator.configure)
    }
    
    public func appendingConfiguration(_ configuration: @escaping (Base) -> Base) -> Configurator {
        modification(of: self) { _self in
            _self._configure = { configuration(_configure($0)) }
        }
    }
    
    public subscript<Value>(
        dynamicMember keyPath: WritableKeyPath<Base, Value>
    ) -> CallableBlock<Value> {
        .init(
            configurator: self,
            keyPath: .init(keyPath)
        )
    }
    
    public subscript<Value>(
        dynamicMember keyPath: KeyPath<Base, Value>
    ) -> NonCallableBlock<Value> where Base: AnyObject {
        .init(
            configurator: self,
            keyPath: .getonly(keyPath)
        )
    }
    
    public static subscript<Value>(
        dynamicMember keyPath: WritableKeyPath<Base, Value>
    ) -> CallableBlock<Value> {
        .init(
            configurator: .init(),
            keyPath: .init(keyPath)
        )
    }
    
    public static subscript<Value>(
        dynamicMember keyPath: KeyPath<Base, Value>
    ) -> NonCallableBlock<Value> where Base: AnyObject, Value: AnyObject {
        .init(
            configurator: .init(),
            keyPath: .getonly(keyPath)
        )
    }
    
}

extension Configurator {
    @dynamicMemberLookup
    public struct CallableBlock<Value> {
        private var _block: NonCallableBlock<Value>
        
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
            _block.configurator.appendingConfiguration { _block.keyPath.embed(value, in: $0) }
        }
        
        public subscript<LocalValue>(
            dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
        ) -> CallableBlock<LocalValue> {
            .init(
                configurator: _block.configurator,
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
        var configurator: Configurator
        var keyPath: FunctionalKeyPath<Base, Value>
        
        public subscript<LocalValue>(
            dynamicMember keyPath: WritableKeyPath<Value, LocalValue>
        ) -> CallableBlock<LocalValue> where Value: AnyObject {
            .init(
                configurator: self.configurator,
                keyPath: self.keyPath.appending(path: .init(keyPath))
            )
        }
        
        public subscript<LocalValue>(
            dynamicMember keyPath: KeyPath<Value, LocalValue>
        ) -> NonCallableBlock<LocalValue> where Value: AnyObject, LocalValue: AnyObject {
            .init(
                configurator: self.configurator,
                keyPath: self.keyPath.appending(path: .getonly(keyPath))
            )
        }
    }
}
