import Testing
import Foundation
import KeyPathMapper
import KeyPathsExtensions
@testable import DeclarativeConfiguration

@Suite("ConfiguratorTests")
struct ConfiguratorTests {
	@Suite("ValueTypes")
	struct ValueTypes {
		struct DefaultMock: Equatable, CallAsFunctionConfigurableProtocol {
			var intProperty: Int
			var optionalIntProperty: Int?

			init(intProperty: Int = 0, optionalIntProperty: Int? = nil) {
				self.intProperty = intProperty
				self.optionalIntProperty = optionalIntProperty
			}
		}

		@Test
		func knownIssueWithImplicitTypeInference() {
			let mock = DefaultMock { $0
				.intProperty(1)
			}

			// Swift bug with callAsFunction.
			// It's not called when the type
			// of the rhs of the expression is
			// implicitly inferred from the context
			let corruptedMock: DefaultMock = .init { $0
				.intProperty(1)
			}

			#expect(mock != corruptedMock)
			#expect(mock == DefaultMock(intProperty: 1))
			#expect(corruptedMock == DefaultMock(intProperty: 0))
		}

		@Test
		func initializers() {
			do { // closure
				let config = Configurator<DefaultMock> { $0
					.intProperty(1)
					.optionalIntProperty.ifNil(0)
				}

				let expected = DefaultMock(intProperty: 1, optionalIntProperty: 0)
				#expect(config.configured(DefaultMock()) == expected)
			}

			do { // empty
				#expect(Configurator.empty.configured(DefaultMock()) == DefaultMock(intProperty: 0))
			}

			do { // dynamicMember
				let config = Configurator<DefaultMock>.intProperty(1)
				#expect(config.configured(DefaultMock()) == DefaultMock(intProperty: 1))
			}

			do { // modify
				let config = Configurator<DefaultMock>.modify { $0.intProperty += 1 }
				#expect(config.configured(DefaultMock()) == DefaultMock(intProperty: 1))
			}

			do { // transform
				let config = Configurator<DefaultMock>.transform {
					.init(intProperty: $0.intProperty + 1, optionalIntProperty: $0.optionalIntProperty)
				}
				#expect(config.configured(DefaultMock()) == DefaultMock(intProperty: 1))
			}

			do { // ifNil
				let config = Configurator<DefaultMock?>.ifNil(DefaultMock(intProperty: 1))
				#expect(config.configured(nil) == DefaultMock(intProperty: 1))
			}

			do { // ifLet
				do { // non-aggressive unwrapping
					let config = Configurator<DefaultMock?>.ifLet.intProperty(1)
					#expect(config.configured(nil) == nil)
				}

				do { // aggressive unwrapping
					let config = Configurator<DefaultMock?>.ifLet(else: .init()).intProperty(1)
					#expect(config.configured(nil) == DefaultMock(intProperty: 1))
				}
			}
		}

		@Test
		func inlineConfiguration() async throws {
			do { // callAsFunction
				let mock = DefaultMock { $0
					.intProperty(1)
				}

				#expect(mock == .init(intProperty: 1))
			}

			do { // transform
				let mock = DefaultMock { $0
					.intProperty.transform { $0 + 1 }
				}

				#expect(mock == .init(intProperty: 1))
			}

			do { // modify
				let mock = DefaultMock { $0
					.intProperty.modify { $0 += 1 }
				}

				#expect(mock == .init(intProperty: 1))
			}

			do { // some optional value
				let mock = DefaultMock { $0
					.intProperty(ifLet: 1)
				}

				#expect(mock == .init(intProperty: 1))
			}

			do { // none optional value
				let mock = DefaultMock { $0
					.intProperty(ifLet: Int?.none) // not set
				}

				#expect(mock == .init(intProperty: 0))
			}
		}

		@Test
		func optionals() async throws {
			do { // non-aggressive unwrapping of none
				let mock = DefaultMock { $0
					.optionalIntProperty.ifLet(1) // not set
				}

				#expect(mock == .init(optionalIntProperty: nil))
			}

			do { // non-aggressive unwrapping of some
				let mock = DefaultMock(optionalIntProperty: 0) { $0
					.optionalIntProperty.ifLet(1)
				}

				#expect(mock == .init(optionalIntProperty: 1))
			}

			do { // aggressive unwrapping of none
				let mock = DefaultMock { $0
					.optionalIntProperty.ifLet(else: 0).modify { $0 += 1 }
				}

				#expect(mock == .init(optionalIntProperty: 1))
			}

			do { // aggressive unwrapping of some
				let mock = DefaultMock(optionalIntProperty: 1) { $0
					.optionalIntProperty.ifLet(else: 0).modify { $0 += 1 }
				}

				#expect(mock == .init(optionalIntProperty: 2))
			}

			do { // nil replacing
				let mock = DefaultMock { $0
					.optionalIntProperty.ifNil(0)
					.optionalIntProperty.ifNil(1) // not set
				}

				#expect(mock == .init(optionalIntProperty: 0))
			}
		}

		@Test
		func scoping() async throws {
			struct Mock: Equatable, DefaultConfigurableProtocol {
				var nested: DefaultMock
				var optionalNested: DefaultMock?

				init(
					nested: DefaultMock = .init(),
					optionalNested: DefaultMock? = nil
				) {
					self.nested = nested
					self.optionalNested = optionalNested
				}
			}

			do { // basic scoping
				let mock = Mock { $0
					.nested.scope { $0
						.intProperty(1)
						.optionalIntProperty(0)
					}
				}

				#expect(mock == Mock(nested: .init(intProperty: 1, optionalIntProperty: 0)))
			}

			do { // optional scoping none
				let mock = Mock { $0
					.optionalNested.ifLet.scope { $0 // no effect for nil
						.intProperty(1)
						.optionalIntProperty(0)
					}
				}

				#expect(mock == Mock())
			}

			do { // optional scoping some
				let mock = Mock { $0
					.optionalNested.ifLet(else: .init()).scope { $0
						.intProperty(1)
						.optionalIntProperty(0)
					}
				}

				#expect(mock == Mock(optionalNested: .init(intProperty: 1, optionalIntProperty: 0)))
			}

			do { // alternative scoping some
				let mock = Mock { $0
					.ifLet(\.optionalNested)(else: .init()).scope { $0
						.intProperty(1)
						.optionalIntProperty(0)
					}
				}

				#expect(mock == Mock(optionalNested: .init(intProperty: 1, optionalIntProperty: 0)))
			}
		}

		@Test
		func collections() async throws {
			do { // default subscript
				let value = Configurator<Array<Int>> { $0
					.self[0].modify { $0 = 1 }
					.self[1].modify { $0 = 2 }
					.self[2].modify { $0 = 3 }
				}.configured([0,1,2])

				#expect(value == [1,2,3])
			}

			do { // KeyPathMapper safe subscript
				// Requres `import KeyPathMapper`
				let value = Configurator<Array<Int>> { $0
					.self[mapPath: \.[safeIndex: 0]].modify { $0 = 1 }
					.self[mapPath: \.[safeIndex: 1]].modify { $0 = 2 }
					.self[mapPath: \.[safeIndex: 2]].modify { $0 = 3 }
					.self[mapPath: \.[safeIndex: 3]].modify { $0 = 4 }
				}.configured([0,1,2])

				#expect(value == [1,2,3])
			}
		}
	}

	@Suite("ReferenceTypes")
	struct ReferenceTypes {
		class DefaultMock: Equatable, CallAsFunctionConfigurableProtocol {
			static func == (
				lhs: ConfiguratorTests.ReferenceTypes.DefaultMock,
				rhs: ConfiguratorTests.ReferenceTypes.DefaultMock
			) -> Bool {
				lhs.intProperty == rhs.intProperty
				&& lhs.optionalIntProperty == rhs.optionalIntProperty
			}
			
			var intProperty: Int
			var optionalIntProperty: Int?

			init(intProperty: Int = 0, optionalIntProperty: Int? = nil) {
				self.intProperty = intProperty
				self.optionalIntProperty = optionalIntProperty
			}
		}

		@Test
		func knownIssueWithImplicitTypeInference() {
			let mock = DefaultMock { $0
				.intProperty(1)
			}

			// Swift bug with callAsFunction.
			// It's not called when the type
			// of the rhs of the expression is
			// implicitly inferred from the context
			let corruptedMock: DefaultMock = .init { $0
				.intProperty(1)
			}

			#expect(mock != corruptedMock)
			#expect(mock == DefaultMock(intProperty: 1))
			#expect(corruptedMock == DefaultMock(intProperty: 0))
		}

		@Test
		func initializers() {
			do { // closure
				let config = Configurator<DefaultMock> { $0
					.intProperty(1)
					.optionalIntProperty.ifNil(0)
				}

				let expected = DefaultMock(intProperty: 1, optionalIntProperty: 0)
				#expect(config.configured(DefaultMock()) == expected)
			}

			do { // empty
				#expect(Configurator.empty.configured(DefaultMock()) == DefaultMock(intProperty: 0))
			}

			do { // dynamicMember
				let config = Configurator<DefaultMock>.intProperty(1)
				#expect(config.configured(DefaultMock()) == DefaultMock(intProperty: 1))
			}

			do { // modify
				let config = Configurator<DefaultMock>.modify { $0.intProperty += 1 }
				#expect(config.configured(DefaultMock()) == DefaultMock(intProperty: 1))
			}

			do { // transform
				let config = Configurator<DefaultMock>.transform {
					.init(intProperty: $0.intProperty + 1, optionalIntProperty: $0.optionalIntProperty)
				}
				#expect(config.configured(DefaultMock()) == DefaultMock(intProperty: 1))
			}

			do { // ifNil
				let config = Configurator<DefaultMock?>.ifNil(DefaultMock(intProperty: 1))
				#expect(config.configured(nil) == DefaultMock(intProperty: 1))
			}

			do { // ifLet
				do { // non-aggressive unwrapping
					let config = Configurator<DefaultMock?>.ifLet.intProperty(1)
					#expect(config.configured(nil) == nil)
				}

				do { // aggressive unwrapping
					let config = Configurator<DefaultMock?>.ifLet(else: .init()).intProperty(1)
					#expect(config.configured(nil) == DefaultMock(intProperty: 1))
				}
			}
		}

		@Test
		func inlineConfiguration() async throws {
			do { // callAsFunction
				let mock = DefaultMock { $0
					.intProperty(1)
				}

				#expect(mock == .init(intProperty: 1))
			}

			do { // transform
				let mock = DefaultMock { $0
					.intProperty.transform { $0 + 1 }
				}

				#expect(mock == .init(intProperty: 1))
			}

			do { // modify
				let mock = DefaultMock { $0
					.intProperty.modify { $0 += 1 }
				}

				#expect(mock == .init(intProperty: 1))
			}

			do { // some optional value
				let mock = DefaultMock { $0
					.intProperty(ifLet: 1)
				}

				#expect(mock == .init(intProperty: 1))
			}

			do { // none optional value
				let mock = DefaultMock { $0
					.intProperty(ifLet: Int?.none) // not set
				}

				#expect(mock == .init(intProperty: 0))
			}
		}

		@Test
		func optionals() async throws {
			do { // non-aggressive unwrapping of none
				let mock = DefaultMock { $0
					.optionalIntProperty.ifLet(1) // not set
				}

				#expect(mock == .init(optionalIntProperty: nil))
			}

			do { // non-aggressive unwrapping of some
				let mock = DefaultMock(optionalIntProperty: 0) { $0
					.optionalIntProperty.ifLet(1)
				}

				#expect(mock == .init(optionalIntProperty: 1))
			}

			do { // aggressive unwrapping of none
				let mock = DefaultMock { $0
					.optionalIntProperty.ifLet(else: 0).modify { $0 += 1 }
				}

				#expect(mock == .init(optionalIntProperty: 1))
			}

			do { // aggressive unwrapping of some
				let mock = DefaultMock(optionalIntProperty: 1) { $0
					.optionalIntProperty.ifLet(else: 0).modify { $0 += 1 }
				}

				#expect(mock == .init(optionalIntProperty: 2))
			}

			do { // nil replacing
				let mock = DefaultMock { $0
					.optionalIntProperty.ifNil(0)
					.optionalIntProperty.ifNil(1) // not set
				}

				#expect(mock == .init(optionalIntProperty: 0))
			}
		}

		@Test
		func scoping() async throws {
			class Mock: Equatable, DefaultConfigurableProtocol {
				static func == (
					lhs: Mock,
					rhs: Mock
				) -> Bool {
					lhs.nested == rhs.nested
					&& lhs.optionalNested == rhs.optionalNested
				}
				
				let nested: DefaultMock
				var optionalNested: DefaultMock?

				init(
					nested: DefaultMock = .init(),
					optionalNested: DefaultMock? = nil
				) {
					self.nested = nested
					self.optionalNested = optionalNested
				}
			}

			do { // basic scoping
				let mock = Mock { $0
					.nested.scope { $0
						.intProperty(1)
						.optionalIntProperty(0)
					}
				}

				#expect(mock == Mock(nested: .init(intProperty: 1, optionalIntProperty: 0)))
			}

			do { // optional scoping none
				let mock = Mock { $0
					.optionalNested.ifLet.scope { $0 // no effect for nil
						.intProperty(1)
						.optionalIntProperty(0)
					}
				}

				#expect(mock == Mock())
			}

			do { // optional scoping some
				let mock = Mock { $0
					.optionalNested.ifLet(else: .init()).scope { $0
						.intProperty(1)
						.optionalIntProperty(0)
					}
				}

				#expect(mock == Mock(optionalNested: .init(intProperty: 1, optionalIntProperty: 0)))
			}

			do { // alternative scoping some
				let mock = Mock { $0
					.ifLet(\.optionalNested)(else: .init()).scope { $0
						.intProperty(1)
						.optionalIntProperty(0)
					}
				}

				#expect(mock == Mock(optionalNested: .init(intProperty: 1, optionalIntProperty: 0)))
			}
		}
	}

	@Test
	func optionalValues() async throws {
		struct TestConfigurable: CustomConfigurableProtocol {
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
	func scoping() async throws {
		// Batch-test multiple paths

		struct Container: DefaultConfigurableProtocol {
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
				let innerClass: InnerClass? = .init()
				var innerStruct: InnerStruct? = .init()

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
				.innerClass.ifLet.scope { $0
					.value(1)
				}
				.innerStruct.ifLet.scope { $0
					.value(1)
				}
			}
		}

		#expect(actual.content.a != initial.content.a)
		#expect(actual.content.b != initial.content.b)
		#expect(actual.content.c != initial.content.c)
		#expect(actual.content.innerClass?.value != initial.content.innerClass?.value)
		#expect(actual.content.innerStruct?.value != initial.content.innerStruct?.value)

		#expect(actual.content.a == expected.content.a)
		#expect(actual.content.b == expected.content.b)
		#expect(actual.content.c == expected.content.c)
		#expect(actual.content.innerClass?.value == expected.content.innerClass?.value)
		#expect(actual.content.innerStruct?.value == expected.content.innerStruct?.value)
	}
}
