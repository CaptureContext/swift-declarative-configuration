import Foundation

extension __ConfigInitializableNSObject where Self: NSObject {
	/// Instantiates a new object with specified configuration
	///
	/// Note: Type must implement custom intializer with no parameters, even if it inherits from NSObject
	@available(*, deprecated, renamed: "init(unsafeConfig:)")
	@inlinable @_disfavoredOverload
	public init(config configuration: (Config) -> Config) {
		self.init(unsafeConfig: configuration)
	}

	/// Instantiates a new object with specified configuration
	///
	/// Note: Type must implement custom intializer with no parameters, even if it inherits from NSObject
	@available(*, deprecated, renamed: "init(unsafeConfig:)")
	@inlinable @_disfavoredOverload
	public init(config configurator: Config) {
		self.init(unsafeConfig: configurator)
	}
}
