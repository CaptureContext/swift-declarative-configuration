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
	@inlinable
	public init(
		unsafeConfig configuration: (Config) -> Config,
		fileID: StaticString = #fileID,
		filePath: StaticString = #filePath,
		line: UInt = #line,
		column: UInt = #column
	) {
		self.init(
			unsafeConfig: configuration(.empty),
			fileID: fileID,
			filePath: filePath,
			line: line,
			column: column,
		)
	}

	/// Instantiates a new object with specified configuration
	///
	/// Note: Type must implement custom intializer with no parameters, even if it inherits from NSObject
	public init(
		unsafeConfig configurator: Config,
		fileID: StaticString = #fileID,
		filePath: StaticString = #filePath,
		line: UInt = #line,
		column: UInt = #column
	) {
		Self.reportMissingInitIfNeeded(
			fileID: fileID,
			filePath: filePath,
			line: line,
			column: column
		)

		self.init()
		configurator.configure(self)
	}
}

extension NSObject: __ConfigInitializableNSObject {}

import IssueReporting

extension __ConfigInitializableNSObject {
	@usableFromInline
	static func reportMissingInitIfNeeded(
		fileID: StaticString,
		filePath: StaticString,
		line: UInt,
		column: UInt
	) {
		guard emptyInitLooksUnavailable()
		else { return print("hasinit") }

		withIssueReporters([.default, .fatalError]) {
			reportIssue(
				"""
				init(unsafeConfig:) requires empty init to be available for \(Self.self).
				
				This usually means the type added designated initializer(s) and did not reintroduce init().
				
				Add empty init to type declaration:
					public convenience override init() {
						self.init(...)
					}
				
				Or use:
					\(Self.self)(...).configured { $0 
						...
					}
				""",
				fileID: fileID,
				filePath: filePath,
				line: line,
				column: column
			)
		}
	}

	@usableFromInline
	static func emptyInitLooksUnavailable() -> Bool {
		let method = class_getInstanceMethod(self, #selector(NSObject.init))
		let implementation = method.flatMap { method_getImplementation($0) }
		return implementation == nil
	}
}
