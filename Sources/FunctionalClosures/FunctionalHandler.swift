/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal closure-based hanlder or delegate with a functional API
@propertyWrapper
public struct FunctionalHandler<Input> {
    public struct Container {
        internal var action: ((Input) -> Void)?
        
        internal init() {}
        
        public init(handler: ((Input) -> Void)?) {
            self.action = handler
        }
        
        public mutating func callAsFunction(action: ((Input) -> Void)?) {
            self.action = action
        }
        
        @available(*, deprecated, message: """
        This API is not stable yet and may change (or may not), \
        consider using redeclaration with `(Input) -> Output` signature function. \
        Feel free to discuss the API here \
        https://github.com/MakeupStudio/swift-declarative-configuration/issues/1
        """)
        public mutating func callAsFunction(_ behaviour: Behaviour, action: ((Input) -> Void)?) {
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
    }
    
    public init() {}
    
    public init(wrappedValue: Container) {
        self.wrappedValue = wrappedValue
    }
    
    public var wrappedValue: Container = .init()
    
    public var projectedValue: ((Input) -> Void)? { wrappedValue.action }
}
