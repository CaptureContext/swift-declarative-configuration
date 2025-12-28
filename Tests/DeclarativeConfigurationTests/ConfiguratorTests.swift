import Testing
import Foundation
@testable import DeclarativeConfiguration

@Suite("ConfiguratorTests")
struct ConfiguratorTests {
	@Test
	func basicChecks() {
		struct TestConfigurable: Equatable {
			struct Wrapped: Equatable {
				var value = 0
			}

			var value: Bool = false
			var wrapped: Wrapped = .init()
		}

		let wrappedConfiguator = Configurator<TestConfigurable>()
			.wrapped.value(1)

		let valueConfigurator = Configurator<TestConfigurable>()
			.value(true)

		let configurator = wrappedConfiguator
			.combined(with: valueConfigurator)

		let initial = TestConfigurable()

		let expected = TestConfigurable(
			value: true,
			wrapped: .init(value: 1)
		)

		let actual = configurator.configured(initial)

		#expect(actual != initial)
		#expect(actual == expected)
	}

	@Test
	func configInitializableWithDesignatedInit() {
		final class TestConfigurable: NSObject {
			struct Wrapped: Equatable {
				var value = 0
			}

			var value: Bool
			var wrapped: Wrapped

			// THIS INIT IS REQUIRED TO AVOID CRASHES
			// WHEN DESIGNATED INIT IS DECLARED IN CLASS
//			convenience override init() {
//				self.init(
//					value: false,
//					wrapped: .init()
//				)
//			}

			init(
				value: Bool = false,
				wrapped: TestConfigurable.Wrapped = .init()
			) {
				self.value = value
				self.wrapped = wrapped
			}
		}

		let initial = TestConfigurable()

		let expected = TestConfigurable(
			value: true,
			wrapped: .init(value: 1)
		)

		let actual1 = TestConfigurable { $0
			.value(true)
			.wrapped(.init(value: 1))
		}

		let actual2 = TestConfigurable(
			unsafeConfig: TestConfigurable.Config
				.value(true)
				.wrapped(.init(value: 1))
		)

		#expect(actual1.value != initial.value)
		#expect(actual1.wrapped != initial.wrapped)
		#expect(actual1.value == actual2.value)
		#expect(actual1.wrapped == actual2.wrapped)
		#expect(actual1.value == expected.value)
		#expect(actual1.wrapped == expected.wrapped)
	}

	@Test
	func configInitializable() {
		final class TestConfigurable: NSObject {
			struct Wrapped: Equatable {
				var value = 0
			}

			var value: Bool = false
			var wrapped: Wrapped = .init()

			// NO DESIGNATED INITS, BASIC INIT() IS AVAILABLE
			convenience init(
				value: Bool = false,
				wrapped: TestConfigurable.Wrapped = .init()
			) {
				self.init()
				self.value = value
				self.wrapped = wrapped
			}
		}

		let initial = TestConfigurable()

		let expected = TestConfigurable(
			value: true,
			wrapped: .init(value: 1)
		)

		let actual1 = TestConfigurable { $0
			.value(true)
			.wrapped(.init(value: 1))
		}

		let actual2 = TestConfigurable(
			unsafeConfig: TestConfigurable.Config
				.value(true)
				.wrapped(.init(value: 1))
		)

		#expect(actual1.value != initial.value)
		#expect(actual1.wrapped != initial.wrapped)
		#expect(actual1.value == actual2.value)
		#expect(actual1.wrapped == actual2.wrapped)
		#expect(actual1.value == expected.value)
		#expect(actual1.wrapped == expected.wrapped)
	}

	@Test
	func customConfigurable() {
		struct TestConfigurable: CustomConfigurable {
			struct Wrapped: Equatable {
				var value = 0
			}

			var value: Bool = false
			var wrapped: Wrapped = .init()
		}

		let initial = TestConfigurable()

		let expected = TestConfigurable(
			value: true,
			wrapped: .init(value: 1)
		)

		let actual = TestConfigurable().configured { $0
			.value(true)
			.wrapped(.init(value: 1))
		}

		#expect(actual.value != initial.value)
		#expect(actual.wrapped != initial.wrapped)
		#expect(actual.value == expected.value)
		#expect(actual.wrapped == expected.wrapped)
	}

	@Test
	func optionalValues() {
		struct TestConfigurable: CustomConfigurable {
			internal init(value: Bool = false, wrappedValue: Int = 0) {
				self.value = value
				wrapped?.value = wrappedValue
			}

			class Wrapped: NSObject {
				var value: Int? = 0
				override init() { self.value = 0 }
			}

			var value = false
			let _wrapped: Wrapped = .init()
			var wrapped: Wrapped? { _wrapped }
		}

		let initial = TestConfigurable()

		let expected = TestConfigurable(
			value: true,
			wrappedValue: 1
		)

		let actual = TestConfigurable().configured { $0
			.value(true)
			.wrapped.value(1)
		}

		#expect(actual.value != initial.value)
		#expect(actual.wrapped?.value != initial.wrapped?.value)
		#expect(actual.value == expected.value)
		#expect(actual._wrapped.value == expected._wrapped.value)
	}

	@Test
	func scoping() {
		struct Container: ConfigInitializable {
			class Content {
				class InnerClass {
					var value: Int = 0
				}

				struct InnerStruct {
					var value: Int = 0
				}

				var a: Int = 0
				var b: Int = 0
				var c: Int = 0
				let innerClass: InnerClass? = nil
				var innerStruct: InnerStruct?

				init() {}
			}

			let content: Content = .init()
		}

		let initial = Container()

		let expected = Container { $0
			.content.a(1)
			.content.b(2)
			.content.c(3)
			.content.innerClass.value(1)
			.content.innerStruct.value(1)
		}

		let actual = Container { $0
			.content.scope { $0
				.a(1)
				.b(2)
				.c(3)
				.innerClass
				.ifLetScope { $0
					.value(1)
				}
				.innerStruct
				.ifLetScope { $0
					.value(1)
				}
			}
		}

		#expect(actual.content.a != initial.content.a)
		#expect(actual.content.b != initial.content.b)
		#expect(actual.content.c != initial.content.c)
		#expect(actual.content.innerClass?.value == initial.content.innerClass?.value)
		#expect(actual.content.innerStruct?.value == initial.content.innerStruct?.value)

		#expect(actual.content.a == expected.content.a)
		#expect(actual.content.b == expected.content.b)
		#expect(actual.content.c == expected.content.c)
		#expect(actual.content.innerClass?.value == expected.content.innerClass?.value)
		#expect(actual.content.innerStruct?.value == expected.content.innerStruct?.value)
	}
}
