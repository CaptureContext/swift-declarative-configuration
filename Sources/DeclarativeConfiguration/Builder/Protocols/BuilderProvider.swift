import Foundation

public protocol BuilderProvider {}

extension BuilderProvider {
	/// Builder for the current value
	@inlinable
	public var builder: Builder<Self> { .init(self) }
}

extension NSObject: BuilderProvider {}
