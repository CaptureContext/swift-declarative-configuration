import Foundation

public protocol CallAsFunctionConfigurable {}

extension CallAsFunctionConfigurable {
	public typealias Config = Configurator<Self>

	@discardableResult
	@inlinable
	public func callAsFunction(config configuration: (Config) -> Config) -> Self {
		configuration(.empty).configured(self)
	}
}

extension NSObject: CallAsFunctionConfigurable {}
