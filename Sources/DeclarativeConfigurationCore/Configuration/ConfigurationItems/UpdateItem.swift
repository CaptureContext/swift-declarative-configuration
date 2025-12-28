import Foundation

extension _ConfigurationItems {
	public struct Update<Base>: _ConfigurationItem {
		private let _action: (Base) -> Base

		public init(_ update: @escaping (Base) -> Base) {
			self._action = update
		}

		public func update(_ base: Base) -> Base {
			_action(base)
		}
	}
}
