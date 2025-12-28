import Foundation

extension _ConfigurationItems {
	public struct SetValue<Base, Value>: _ConfigurationItem {
		public let keyPath: WritableKeyPath<Base, Value>
		public let value: Value

		public init(_ value: Value, to keyPath: WritableKeyPath<Base, Value>) {
			self.keyPath = keyPath
			self.value = value
		}

		@inlinable
		public func update(_ base: Base) -> Base {
			reduce(base, with: { $0[keyPath: keyPath] = value })
		}
	}
}

extension _ConfigurationItems.SetValue: Equatable where Value: Equatable {}
extension _ConfigurationItems.SetValue: Hashable where Value: Hashable {}
