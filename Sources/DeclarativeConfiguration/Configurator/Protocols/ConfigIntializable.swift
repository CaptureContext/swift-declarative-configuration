import Foundation

/// Allows to intialize a new object without parameters or with configuration
public protocol ConfigInitializable {
	init()
}

extension ConfigInitializable {
	public typealias Config = Configurator<Self>

	/// Instantiates a new object with specified configuration
	///
	/// Note: Type must implement custom intializer with no parameters, even if it inherits from NSObject
	@inlinable
	public init(config configuration: (Config) -> Config) {
		self.init(config: configuration(Config()))
	}

	/// Instantiates a new object with specified configuration
	///
	/// Note: Type must implement custom intializer with no parameters, even if it inherits from NSObject
	public init(config configurator: Config) {
		self = configurator.configured(.init())
	}
}

// MARK: NSObject

public protocol __ConfigInitializableNSObject: NSObjectProtocol {}

extension __ConfigInitializableNSObject where Self: NSObject {
	public typealias Config = Configurator<Self>

	/// Instantiates a new object with specified configuration
	///
	/// Note: Type must implement custom intializer with no parameters, even if it inherits from NSObject
	@available(*, deprecated, message: "Use available init with trailing closure")
	@inlinable
	public init(unsafeConfig configuration: (Config) -> Config) {
		self.init(unsafeConfig: configuration(.empty))
	}

	/// Instantiates a new object with specified configuration
	///
	/// Note: Type must implement custom intializer with no parameters, even if it inherits from NSObject
	@available(*, deprecated, message: "Use available init with `configured(using:)` method")
	@inlinable
	public init(unsafeConfig configurator: Config) {
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

extension NSObject: __ConfigInitializableNSObject {}
