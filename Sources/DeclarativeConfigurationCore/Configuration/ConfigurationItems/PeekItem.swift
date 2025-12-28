import Foundation

extension _ConfigurationItems {
	public struct Peek<Base>: _ConfigurationItem {
		private let _action: (Base) -> Void

		public init(_ update: @escaping (Base) -> Void) {
			self._action = update
		}

		public func update(_ base: Base) -> Base {
			_action(base)
			return base
		}
	}
}
