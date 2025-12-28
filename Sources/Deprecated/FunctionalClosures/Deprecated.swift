// MARK: - Handler

public enum HandlerContainerBehaviour {
	case resetting
	case preceding
	case appending
}

/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal closure-based hanlder or delegate with a functional API
@available(macOS 14.0.0, iOS 17.0.0, tvOS 17.0.0, watchOS 10.0.0, *)
@available(*, deprecated, message: "If you use this functionality, consider copying sources and please submit an issue to the repo, our advice is to use Combine/Observation instead")
@propertyWrapper
public class _Handler<each T> {
	public struct Container {
		public typealias Behaviour = HandlerContainerBehaviour
		
		@usableFromInline
		internal var action: ((repeat each T) -> Void)?
		
		internal init() {}
		
		public init(action: ((repeat each T) -> Void)?) {
			self.action = action
		}
		
		@inlinable
		public mutating func callAsFunction(perform action: ((repeat each T) -> Void)?) {
			self.action = action
		}
	}
	
	public init() {}
	
	public init(wrappedValue: Container) {
		self.wrappedValue = wrappedValue
	}
	
	public var wrappedValue: Container = .init()
	
	public var projectedValue: ((repeat each T) -> Void)? {
		get { wrappedValue.action }
		set { wrappedValue.action = newValue }
	}
	
	public func callAsFunction(_ input: repeat each T) {
		projectedValue?(repeat each input)
	}
}

@available(*, deprecated, message: "If you use this functionality, consider copying sources and please submit an issue to the repo, our advice is to use Combine/Observation instead")
public typealias Handler = Handler1

/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal closure-based hanlder or delegate with a functional API
@available(*, deprecated, message: "If you use this functionality, consider copying sources and please submit an issue to the repo, our advice is to use Combine/Observation instead")
@propertyWrapper
public class Handler1<Input> {
	public struct Container {
		public typealias Behaviour = HandlerContainerBehaviour
		
		@usableFromInline
		internal var action: ((Input) -> Void)?
		
		internal init() {}
		
		public init(action: ((Input) -> Void)?) {
			self.action = action
		}
		
		@inlinable
		public mutating func callAsFunction(perform action: ((Input) -> Void)?) {
			self.action = action
		}
		
		@available(
			*,
			 deprecated,
			 message:
			"""
			This API will be removed, \
			consider using redeclaration with `(Input) -> Output` signature function. \
			Feel free to discuss the API here \
			https://github.com/CaptureContext/swift-declarative-configuration/issues/1
			"""
		)
		@inlinable
		public mutating func callAsFunction(_ behaviour: Behaviour, perform action: ((Input) -> Void)?)
		{
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
@available(*, deprecated, message: "If you use this functionality, consider copying sources and please submit an issue to the repo, our advice is to use Combine/Observation instead")
@propertyWrapper
public class Handler2<T0, T1> {
	public struct Container {
		public typealias Behaviour = HandlerContainerBehaviour
		
		internal var action: ((T0, T1) -> Void)?
		
		internal init() {}
		
		public init(action: ((T0, T1) -> Void)?) {
			self.action = action
		}
		
		public mutating func callAsFunction(perform action: ((T0, T1) -> Void)?) {
			self.action = action
		}
		
		@available(
			*,
			 deprecated,
			 message:
			"""
			This API will be removed, \
			consider using redeclaration with `(Input) -> Output` signature function. \
			Feel free to discuss the API here \
			https://github.com/MakeupStudio/swift-declarative-configuration/issues/1
			"""
		)
		public mutating func callAsFunction(_ behaviour: Behaviour, perform action: ((T0, T1) -> Void)?)
		{
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
@available(*, deprecated, message: "If you use this functionality, consider copying sources and please submit an issue to the repo, our advice is to use Combine/Observation instead")
@propertyWrapper
public class Handler3<T0, T1, T2> {
	public struct Container {
		public typealias Behaviour = HandlerContainerBehaviour
		
		internal var action: ((T0, T1, T2) -> Void)?
		
		internal init() {}
		
		public init(action: ((T0, T1, T2) -> Void)?) {
			self.action = action
		}
		
		public mutating func callAsFunction(perform action: ((T0, T1, T2) -> Void)?) {
			self.action = action
		}
		
		@available(
			*,
			 deprecated,
			 message:
			"""
			This API will be removed, \
			consider using redeclaration with `(Input) -> Output` signature function. \
			Feel free to discuss the API here \
			https://github.com/MakeupStudio/swift-declarative-configuration/issues/1
			"""
		)
		public mutating func callAsFunction(
			_ behaviour: Behaviour,
			perform action: ((T0, T1, T2) -> Void)?
		) {
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
@available(*, deprecated, message: "If you use this functionality, consider copying sources and please submit an issue to the repo, our advice is to use Combine/Observation instead")
@propertyWrapper
public class Handler4<T0, T1, T2, T3> {
	public struct Container {
		public typealias Behaviour = HandlerContainerBehaviour
		
		internal var action: ((T0, T1, T2, T3) -> Void)?
		
		internal init() {}
		
		public init(action: ((T0, T1, T2, T3) -> Void)?) {
			self.action = action
		}
		
		public mutating func callAsFunction(perform action: ((T0, T1, T2, T3) -> Void)?) {
			self.action = action
		}
		
		@available(
			*,
			 deprecated,
			 message:
			"""
			This API will be removed, \
			consider using redeclaration with `(Input) -> Output` signature function. \
			Feel free to discuss the API here \
			https://github.com/MakeupStudio/swift-declarative-configuration/issues/1
			"""
		)
		public mutating func callAsFunction(
			_ behaviour: Behaviour,
			perform action: ((T0, T1, T2, T3) -> Void)?
		) {
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
@available(*, deprecated, message: "If you use this functionality, consider copying sources and please submit an issue to the repo, our advice is to use Combine/Observation instead")
@propertyWrapper
public class Handler5<T0, T1, T2, T3, T4> {
	public struct Container {
		public typealias Behaviour = HandlerContainerBehaviour
		
		internal var action: ((T0, T1, T2, T3, T4) -> Void)?
		
		internal init() {}
		
		public init(action: ((T0, T1, T2, T3, T4) -> Void)?) {
			self.action = action
		}
		
		public mutating func callAsFunction(perform action: ((T0, T1, T2, T3, T4) -> Void)?) {
			self.action = action
		}
		
		@available(
			*,
			 deprecated,
			 message:
			"""
			This API will be removed, \
			consider using redeclaration with `(Input) -> Output` signature function. \
			Feel free to discuss the API here \
			https://github.com/MakeupStudio/swift-declarative-configuration/issues/1
			"""
		)
		public mutating func callAsFunction(
			_ behaviour: Behaviour,
			perform action: ((T0, T1, T2, T3, T4) -> Void)?
		) {
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

func unpack<each Args, T>(
	_ f: @escaping ((repeat each Args)) -> T
) -> (repeat each Args) -> T {
	return { (args: repeat each Args) in
		return f((repeat each args))
	}
}

// MARK: - DataSource

/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal closure-based datasource with a functional API
@available(macOS 14.0.0, iOS 17.0.0, tvOS 17.0.0, watchOS 10.0.0, *)
@available(*, deprecated, message: "If you use this functionality, consider copying sources and please submit an issue to the repo")
@propertyWrapper
public class _DataSource<each T, Output> {
	public struct Container {
		@usableFromInline
		internal var action: (repeat each T) -> Output

		public init(action: @escaping (repeat each T) -> Output) {
			self.action = action
		}

		@inlinable
		public mutating func callAsFunction(perform action: @escaping (repeat each T) -> Output) {
			self.action = action
		}
	}

	public init(wrappedValue: Container) {
		self.wrappedValue = wrappedValue
	}

	public var wrappedValue: Container

	@inlinable
	public var projectedValue: (repeat each T) -> Output {
		get { wrappedValue.action }
		set { wrappedValue.action = newValue }
	}

	@inlinable
	public func callAsFunction(_ args: repeat each T) -> Output? {
		projectedValue(repeat each args)
	}
}

/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal closure-based datasource with a functional API
@available(*, deprecated, message: "If you use this functionality, consider copying sources and please submit an issue to the repo")
@propertyWrapper
public class DataSource<Input, Output> {
	public struct Container {
		@usableFromInline
		internal var action: (Input) -> Output

		public init(action: @escaping (Input) -> Output) {
			self.action = action
		}

		@inlinable
		public mutating func callAsFunction(perform action: @escaping (Input) -> Output) {
			self.action = action
		}
	}

	public init(wrappedValue: Container) {
		self.wrappedValue = wrappedValue
	}

	public var wrappedValue: Container

	@inlinable
	public var projectedValue: (Input) -> Output {
		get { wrappedValue.action }
		set { wrappedValue.action = newValue }
	}

	@inlinable
	public func callAsFunction(_ input: Input) -> Output? {
		projectedValue(input)
	}

	@inlinable
	public func callAsFunction() -> Output where Input == Void {
		projectedValue(())
	}
}

/// A wrapper for clusure-based interaction between objects
///
/// Provides a public API to set internal closure-based datasource with a functional API
@available(*, deprecated, message: "If you use this functionality, consider copying sources and please submit an issue to the repo")
@propertyWrapper
public class OptionalDataSource<Input, Output> {
	public struct Container {
		@usableFromInline
		internal var action: ((Input) -> Output)?

		internal init() {}

		public init(action: ((Input) -> Output)?) {
			self.action = action
		}

		@inlinable
		public mutating func callAsFunction(perform action: ((Input) -> Output)?) {
			self.action = action
		}
	}

	public init() {}

	public init(wrappedValue: Container) {
		self.wrappedValue = wrappedValue
	}

	public var wrappedValue: Container = .init()

	@inlinable
	public var projectedValue: ((Input) -> Output)? {
		get { wrappedValue.action }
		set { wrappedValue.action = newValue }
	}

	@inlinable
	public func callAsFunction(_ input: Input) -> Output? {
		projectedValue?(input)
	}

	@inlinable
	public func callAsFunction() -> Output? where Input == Void {
		projectedValue?(())
	}
}
