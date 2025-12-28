import Foundation

extension _ConfigurationItems {
	public struct Modify<Base>: _ConfigurationItem {
		@usableFromInline
		internal let _action: (inout Base) -> Void

		public init(_ action: @escaping (inout Base) -> Void) {
			self._action = action
		}

		@inlinable
		public func update(_ base: Base) -> Base {
			reduce(base, with: _action)
		}
	}
}
