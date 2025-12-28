import Foundation

public protocol CallAsFunctionConfigurableProtocol: _BaseConfigurableProtocol {}

extension CallAsFunctionConfigurableProtocol {
	@discardableResult
	@inlinable
	public func callAsFunction(
		config configuration: (Config) -> Config
	) -> Self {
		configuration(.empty).configured(self)
	}
}
