
/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal closure-based hanlder or delegate with a functional API
@propertyWrapper
public class Handler<Input> {
    public struct Container {
        internal var action: ((Input) -> Void)?
        
        internal init() {}
        
        public init(action: ((Input) -> Void)?) {
            self.action = action
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
        public mutating func callAsFunction(_ behaviour: Behaviour, perform action: ((Input) -> Void)?) {
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
    
    public var projectedValue: ((Input) -> Void)? {
        get { wrappedValue.action }
        set { wrappedValue.action = newValue }
    }
    
    public func callAsFunction(_ input: Input) {
        projectedValue?(input)
    }
    
    public func callAsFunction() where Input == Void {
        projectedValue?(())
    }
}

// MARK: Typed handlers

/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal closure-based hanlder or delegate with a functional API
@propertyWrapper
public class Handler2<T0, T1> {
    public struct Container {
        internal var action: ((T0, T1) -> Void)?
        
        internal init() {}
        
        public init(action: ((T0, T1) -> Void)?) {
            self.action = action
        }
        
        public mutating func callAsFunction(action: ((T0, T1) -> Void)?) {
            self.action = action
        }
        
        @available(*, deprecated, message: """
        This API is not stable yet and may change (or may not), \
        consider using redeclaration with `(Input) -> Output` signature function. \
        Feel free to discuss the API here \
        https://github.com/MakeupStudio/swift-declarative-configuration/issues/1
        """)
        public mutating func callAsFunction(_ behaviour: Behaviour, perform action: ((T0, T1) -> Void)?) {
            switch behaviour {
            case .resetting:
                self.action = action
            case .preceding:
                let oldAction = self.action
                self.action = { t0, t1 in
                    action?(t0, t1)
                    oldAction?(t0, t1)
                }
            case .appending:
                let oldAction = self.action
                self.action = { t0, t1 in
                    action?(t0, t1)
                    oldAction?(t0, t1)
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
    
    public var projectedValue: ((T0, T1) -> Void)? {
        get { wrappedValue.action }
        set { wrappedValue.action = newValue }
    }
    
    public func callAsFunction(_ t0: T0, _ t1: T1) {
        projectedValue?(t0, t1)
    }
}

/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal closure-based hanlder or delegate with a functional API
@propertyWrapper
public class Handler3<T0, T1, T2> {
    public struct Container {
        internal var action: ((T0, T1, T2) -> Void)?
        
        internal init() {}
        
        public init(action: ((T0, T1, T2) -> Void)?) {
            self.action = action
        }
        
        public mutating func callAsFunction(action: ((T0, T1, T2) -> Void)?) {
            self.action = action
        }
        
        @available(*, deprecated, message: """
        This API is not stable yet and may change (or may not), \
        consider using redeclaration with `(Input) -> Output` signature function. \
        Feel free to discuss the API here \
        https://github.com/MakeupStudio/swift-declarative-configuration/issues/1
        """)
        public mutating func callAsFunction(_ behaviour: Behaviour, perform action: ((T0, T1, T2) -> Void)?) {
            switch behaviour {
            case .resetting:
                self.action = action
            case .preceding:
                let oldAction = self.action
                self.action = { t0, t1, t2 in
                    action?(t0, t1, t2)
                    oldAction?(t0, t1, t2)
                }
            case .appending:
                let oldAction = self.action
                self.action = { t0, t1, t2 in
                    action?(t0, t1, t2)
                    oldAction?(t0, t1, t2)
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
    
    public var projectedValue: ((T0, T1, T2) -> Void)? {
        get { wrappedValue.action }
        set { wrappedValue.action = newValue }
    }
    
    public func callAsFunction(_ t0: T0, _ t1: T1, _ t2: T2) {
        projectedValue?(t0, t1, t2)
    }
}

/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal closure-based hanlder or delegate with a functional API
@propertyWrapper
public class Handler4<T0, T1, T2, T3> {
    public struct Container {
        internal var action: ((T0, T1, T2, T3) -> Void)?
        
        internal init() {}
        
        public init(action: ((T0, T1, T2, T3) -> Void)?) {
            self.action = action
        }
        
        public mutating func callAsFunction(action: ((T0, T1, T2, T3) -> Void)?) {
            self.action = action
        }
        
        @available(*, deprecated, message: """
        This API is not stable yet and may change (or may not), \
        consider using redeclaration with `(Input) -> Output` signature function. \
        Feel free to discuss the API here \
        https://github.com/MakeupStudio/swift-declarative-configuration/issues/1
        """)
        public mutating func callAsFunction(_ behaviour: Behaviour, perform action: ((T0, T1, T2, T3) -> Void)?) {
            switch behaviour {
            case .resetting:
                self.action = action
            case .preceding:
                let oldAction = self.action
                self.action = { t0, t1, t2, t3 in
                    action?(t0, t1, t2, t3)
                    oldAction?(t0, t1, t2, t3)
                }
            case .appending:
                let oldAction = self.action
                self.action = { t0, t1, t2, t3 in
                    action?(t0, t1, t2, t3)
                    oldAction?(t0, t1, t2, t3)
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
    
    public var projectedValue: ((T0, T1, T2, T3) -> Void)? {
        get { wrappedValue.action }
        set { wrappedValue.action = newValue }
    }
    
    public func callAsFunction(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3) {
        projectedValue?(t0, t1, t2, t3)
    }
}

/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal closure-based hanlder or delegate with a functional API
@propertyWrapper
public class Handler5<T0, T1, T2, T3, T4> {
    public struct Container {
        internal var action: ((T0, T1, T2, T3, T4) -> Void)?
        
        internal init() {}
        
        public init(action: ((T0, T1, T2, T3, T4) -> Void)?) {
            self.action = action
        }
        
        public mutating func callAsFunction(action: ((T0, T1, T2, T3, T4) -> Void)?) {
            self.action = action
        }
        
        @available(*, deprecated, message: """
        This API is not stable yet and may change (or may not), \
        consider using redeclaration with `(Input) -> Output` signature function. \
        Feel free to discuss the API here \
        https://github.com/MakeupStudio/swift-declarative-configuration/issues/1
        """)
        public mutating func callAsFunction(_ behaviour: Behaviour, perform action: ((T0, T1, T2, T3, T4) -> Void)?) {
            switch behaviour {
            case .resetting:
                self.action = action
            case .preceding:
                let oldAction = self.action
                self.action = { t0, t1, t2, t3, t4 in
                    action?(t0, t1, t2, t3, t4)
                    oldAction?(t0, t1, t2, t3, t4)
                }
            case .appending:
                let oldAction = self.action
                self.action = { t0, t1, t2, t3, t4 in
                    action?(t0, t1, t2, t3, t4)
                    oldAction?(t0, t1, t2, t3, t4)
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
    
    public var projectedValue: ((T0, T1, T2, T3, T4) -> Void)? {
        get { wrappedValue.action }
        set { wrappedValue.action = newValue }
    }
    
    public func callAsFunction(_ t0: T0, _ t1: T1, _ t2: T2, _ t3: T3, _ t4: T4) {
        projectedValue?(t0, t1, t2, t3, t4)
    }
}
