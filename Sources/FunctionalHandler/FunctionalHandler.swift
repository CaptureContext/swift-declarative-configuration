/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal handlers (closure-based delegates & datasources)
@propertyWrapper
public struct FunctionalHandler<Input, Output> {
    public struct Container {
        internal var action: ((Input) -> Output)?
        
        internal init() {}
        
        public init(handler: ((Input) -> Output)?) {
            self.action = handler
        }
        
        public mutating func callAsFunction(action: ((Input) -> Output)?) {
            self.action = action
        }
        
        @available(*, deprecated, message: """
        This API is not stable yet and may change (or may not), \
        consider using redeclaration with `(Input) -> Output` signature fucntion. \
        Feel free to discuss the API here \
        https://github.com/MakeupStudio/swift-declarative-configuration/issues/1
        """)
        public mutating func callAsFunction(_ behaviour: Behaviour, action: ((Input) -> Output)?) where Output == Void {
            switch behaviour {
            case .resetting:
                self.action = action
            case .preceding:
                let oldAction = self.action
                self.action = { input in
                    action?(input)
                    oldAction?(input)
                }
            case .appending:
                let oldAction = self.action
                self.action = { input in
                    action?(input)
                    oldAction?(input)
                }
            }
        }
        
        public enum Behaviour {
            case resetting
            case preceding
            case appending
        }
        
        @available(*, deprecated, message: """
        This API is not stable yet and may change (or may not), \
        consider using redeclaration with `(Input) -> Output` signature fucntion. \
        Feel free to discuss the API here \
        https://github.com/MakeupStudio/swift-declarative-configuration/issues/1
        """)
        public mutating func callAsFunction(map transform: @escaping (Output) -> Output) {
            guard let action = self.action else { return }
            self.action = { input in transform(action(input)) }
        }
    }
    
    public init() {}
    
    public init(wrappedValue: Container) {
        self.wrappedValue = wrappedValue
    }
    
    public var wrappedValue: Container = .init()
    
    public var projectedValue: ((Input) -> Output)? { wrappedValue.action }
}
