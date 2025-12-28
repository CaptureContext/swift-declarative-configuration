import Foundation

extension _ConfigurationItems {
	public struct Concat<Base>: _ConfigurationItem {
		let items: [any _ConfigurationItem]

		public init(uncheckedItems items: [any _ConfigurationItem]) {
			self.items = items
		}

		public init(
			checkedItems items: [any _ConfigurationItem],
			fileID: StaticString = #fileID,
			filePath: StaticString = #filePath,
			line: UInt = #line,
			column: UInt = #column
		) {
			self.init(uncheckedItems: items.filter {
				$0.checkCompatible(
					with: Self.self,
					fileID: fileID,
					filePath: filePath,
					line: line,
					column: column
				)
			})
		}

		public func update(_ base: Base) -> Base {
			items.reduce(base) { $1.tryUpdate($0) }
		}

		public init<
			T0: _ConfigurationItem
		>(
			_ t0: T0
		) where
		T0.Base == Base
		{
			self.init(uncheckedItems: [t0])
		}

		public init<
			T0: _ConfigurationItem,
			T1: _ConfigurationItem
		>(
			_ t0: T0,
			_ t1: T1
		) where
		T0.Base == Base,
		T1.Base == Base
		{
			self.init(uncheckedItems: [t0, t1])
		}

		public init<
			T0: _ConfigurationItem,
			T1: _ConfigurationItem,
			T2: _ConfigurationItem
		>(
			_ t0: T0,
			_ t1: T1,
			_ t2: T2
		) where
		T0.Base == Base,
		T1.Base == Base,
		T2.Base == Base
		{
			self.init(
				uncheckedItems: [t0, t1, t2]
			)
		}

		public init<
			T0: _ConfigurationItem,
			T1: _ConfigurationItem,
			T2: _ConfigurationItem,
			T3: _ConfigurationItem
		>(
			_ t0: T0,
			_ t1: T1,
			_ t2: T2,
			_ t3: T3
		) where
		T0.Base == Base,
		T1.Base == Base,
		T2.Base == Base,
		T3.Base == Base
		{
			self.init(
				uncheckedItems: [t0, t1, t2, t3]
			)
		}

		public init<
			T0: _ConfigurationItem,
			T1: _ConfigurationItem,
			T2: _ConfigurationItem,
			T3: _ConfigurationItem,
			T4: _ConfigurationItem
		>(
			_ t0: T0,
			_ t1: T1,
			_ t2: T2,
			_ t3: T3,
			_ t4: T4
		) where
		T0.Base == Base,
		T1.Base == Base,
		T2.Base == Base,
		T3.Base == Base,
		T4.Base == Base
		{
			self.init(
				uncheckedItems: [t0, t1, t2, t3, t4]
			)
		}
	}
}
