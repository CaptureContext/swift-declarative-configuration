import IssueReporting

// Internal implementation. Using protocol types may be useful
// for future Equatable/Codable configurations support or
// implicit extraction of object configurations

@_spi(Internals)
public enum _ConfigurationItems {}

@_spi(Internals)
public protocol _ConfigurationItem<Base> {
	associatedtype Base
	func update(_ base: Base) -> Base
}

extension _ConfigurationItem {
	func tryUpdate<Element>(_ element: Element) -> Element {
		(element as? Base).flatMap { update($0) as? Element } ?? element
	}

	public func checkCompatible<Other: _ConfigurationItem>(
		with otherType: Other.Type,
		fileID: StaticString = #fileID,
		filePath: StaticString = #filePath,
		line: UInt = #line,
		column: UInt = #column
	) -> Bool {
		if isCompatible(with: otherType) { return true }
		reportIssue(
			"\(Self.self) is not compatible with \(otherType).",
			fileID: fileID,
			filePath: filePath,
			line: line,
			column: column
		)
		return false
	}

	public func isCompatible<Other: _ConfigurationItem>(
		with otherType: Other.Type
	) -> Bool {
		Base.self is Other.Type
	}
}

extension _ConfigurationItem {
	public var __baseType: Any.Type {
		Base.self
	}
}

