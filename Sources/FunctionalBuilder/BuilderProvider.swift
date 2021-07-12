import Foundation

public protocol BuilderProvider {}
extension BuilderProvider {
  public var builder: Builder<Self> { .init(self) }
}

extension NSObject: BuilderProvider {}
