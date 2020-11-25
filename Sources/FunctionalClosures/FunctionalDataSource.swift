/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal closure-based datasource with a functional API
@propertyWrapper
public struct FunctionalDataSource<Input, Output> {
    public struct Container {
        internal var action: ((Input) -> Output)?
        
        internal init() {}
        
        public init(handler: ((Input) -> Output)?) {
            self.action = handler
        }
        
        public mutating func callAsFunction(action: ((Input) -> Output)?) {
            self.action = action
        }
    }
    
    public init() {}
    
    public init(wrappedValue: Container) {
        self.wrappedValue = wrappedValue
    }
    
    public var wrappedValue: Container = .init()
    
    public var projectedValue: ((Input) -> Output)? { wrappedValue.action }
    
    public func callAsFunction(_ input: Input) -> Output? {
        projectedValue?(input)
    }
}
