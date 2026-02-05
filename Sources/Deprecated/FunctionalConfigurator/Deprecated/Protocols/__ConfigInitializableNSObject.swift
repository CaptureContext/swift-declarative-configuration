import Foundation

#if canImport(ObjectiveC)
/// Do not use this protocol, it will be removed in future versions in favor or safer APIs
///
/// It's an implementation detail used to silence implementation warnings for
/// `__ConfigInitializableNSObject` protocol, however this one will
/// also be removed in favor of safer APIs in `1.0.0`
///
/// - Note: Use `CallAsFunctionConfigurableProtocol` instead
public protocol ___ConfigInitializableNSObject_DEPRECATED: NSObjectProtocol {}

@available(
	*, deprecated,
	message: """
	Use CallAsFunctionConfigurableProtocol instead.
	
	FunctionalConfigurator module is deprecated and will be removed in v1.0.0
	Use `import DeclarativeConfiguration` instead
	"""
)
public typealias __ConfigInitializableNSObject = ___ConfigInitializableNSObject_DEPRECATED

extension ___ConfigInitializableNSObject_DEPRECATED where Self: NSObject {
	/// Instantiates a new object with specified configuration
	///
	/// - Warning: Type must implement custom intializer with no parameters, even if it inherits from NSObject
	@available(*, deprecated, renamed: "init(unsafeConfig:)")
	@_disfavoredOverload
	public init(config configuration: (Config) -> Config) {
		self.init(_unsafeConfig: configuration)
	}

	/// Instantiates a new object with specified configuration
	///
	/// - Warning: Type must implement custom intializer with no parameters, even if it inherits from NSObject
	@available(*, deprecated, renamed: "init(unsafeConfig:)")
	@_disfavoredOverload
	public init(config configurator: Config) {
		self.init(_unsafeConfig: configurator)
	}
}

fileprivate extension ___ConfigInitializableNSObject_DEPRECATED where Self: NSObject {
	/// Instantiates a new object with specified configuration
	///
	/// - Warning: Type must implement custom intializer with no parameters, even if it inherits from NSObject
	@available(
	*, deprecated,
	message: """
	Unsafe APIs are deprecated, and will be removed in v1.0.0.
	Use available init with trailing closure
	""")
	init(_unsafeConfig configuration: (Config) -> Config) {
		self.init(_unsafeConfig: configuration(.empty))
	}

	/// Instantiates a new object with specified configuration
	///
	/// - Warning: Type must implement custom intializer with no parameters, even if it inherits from NSObject
	@available(
	*, deprecated,
	message: """
	Unsafe APIs are deprecated, and will be removed in v1.0.0.
	Use available init with `configured(using:)` method
	""")
	init(_unsafeConfig configurator: Config) {
		/// Facing an `EXC_BREAKPOINT` here usually means the type added
		/// designated initializer(s) and did not reintroduce empty `init()` which
		/// is required for this API to work.
		///
		/// See stack trace or console logs of the exception to determine the type
		/// that caused the exception
		///
		/// Add empty init to type declaration:
		///   ```swift
		///   public convenience override init() {
		///     self.init(...)
		///   }
		///   ```
		///
		/// Or use safe API on the call site:
		///   ```
		///   YourType(...).configured { $0
		///     ...
		///   }
		///   ```
		self.init()
		configurator.configure(self)
	}
}

extension NSObject: ___ConfigInitializableNSObject_DEPRECATED {}
#endif
