import Foundation

public protocol BuilderProvider {}

extension BuilderProvider {
	@inlinable
	public var builder: Builder<Self> { .init(self) }
}

extension NSObject: BuilderProvider {}
