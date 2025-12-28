import Testing
@testable import DeclarativeConfiguration

@Suite("BuilderTests")
struct BuilderTests {
	@Suite("ValueTypes")
	struct ValueTypes {
		struct Mock: BuilderProvider, Equatable {
			struct Nested: Equatable {
				var intValue: Int
				var optionalIntValue: Int?

				init(
					intValue: Int = 0,
					optionalIntValue: Int? = nil
				) {
					self.intValue = intValue
					self.optionalIntValue = optionalIntValue
				}
			}

			var value: Int
			var nested: Nested
			var optionalNested: Nested?

			init(
				value: Int = 0,
				nested: Nested = .init(),
				optionalNested: Nested? = nil
			) {
				self.value = value
				self.nested = nested
				self.optionalNested = optionalNested
			}
		}

		@Test
		func build() async throws {
			let initialValue = Mock()

			let actualValue = initialValue.builder
				.value(1)
				.nested.intValue(1)
				.nested.scope { $0
					.optionalIntValue.ifLet(1) // not set
				}
				.optionalNested.ifLet(else: .init()).scope { $0
					.intValue(1)
					.optionalIntValue.ifNil(1)
					.optionalIntValue.ifNil(2) // not set
				}
				.build()

			let expectedValue = Mock(
				value: 1,
				nested: .init(intValue: 1),
				optionalNested: .init(intValue: 1, optionalIntValue: 1)
			)

			#expect(actualValue == expectedValue)
		}


		@Test
		func commit() async throws {
			let initialValue = Mock()

			let builder = initialValue.builder.value(1)
			let baseBeforeCommit = builder.base
			let baseAfterCommit = builder.commit().base

			#expect(baseBeforeCommit == initialValue)
			#expect(baseAfterCommit == .init(value: 1))
		}

		@Test
		func combined() async throws {
			let initialValue: Mock = .init()

			let nestedConfig = Configurator<Mock>.value(1)

			let actualValue = initialValue.builder
				.combined(with: nestedConfig)
				.build()

			#expect(actualValue == .init(value: 1))
		}
	}

	@Suite("ReferenceTypes")
	struct ReferenceTypes {
		class Mock: BuilderProvider {
			class Nested {
				var intValue: Int
				var optionalIntValue: Int?

				init(
					intValue: Int = 0,
					optionalIntValue: Int? = nil
				) {
					self.intValue = intValue
					self.optionalIntValue = optionalIntValue
				}
			}

			var value: Int
			var nested: Nested
			var optionalNested: Nested?

			init(
				value: Int = 0,
				nested: Nested = .init(),
				optionalNested: Nested? = nil
			) {
				self.value = value
				self.nested = nested
				self.optionalNested = optionalNested
			}
		}

		@Test
		func build() async throws {
			let initialValue = Mock()

			let actualValue = initialValue.builder
				.value(1)
				.nested.intValue(1)
				.nested.scope { $0
					.optionalIntValue.ifLet(1) // not set
				}
				.optionalNested.ifLet(else: .init()).scope { $0
					.intValue(1)
					.optionalIntValue.ifNil(1)
					.optionalIntValue.ifNil(2) // not set
				}
				.build()

			#expect(actualValue === initialValue)
			#expect(actualValue.value == 1)
			#expect(actualValue.nested.intValue == 1)
			#expect(actualValue.nested.optionalIntValue == nil)
			#expect(actualValue.optionalNested?.intValue == 1)
			#expect(actualValue.optionalNested?.optionalIntValue == 1)
		}

		@Test
		func apply() async throws {
			let initialValue = Mock()

			initialValue.builder
				.value(1)
				.nested.intValue(1)
				.nested.scope { $0
					.optionalIntValue.ifLet(1) // not set
				}
				.optionalNested.ifLet(else: .init()).scope { $0
					.intValue(1)
					.optionalIntValue.ifNil(1)
					.optionalIntValue.ifNil(2) // not set
				}
				.apply()

			#expect(initialValue.value == 1)
			#expect(initialValue.nested.intValue == 1)
			#expect(initialValue.nested.optionalIntValue == nil)
			#expect(initialValue.optionalNested?.intValue == 1)
			#expect(initialValue.optionalNested?.optionalIntValue == 1)
		}

		@Test
		func commit() async throws {
			let initialValue = Mock()

			let builder = initialValue.builder.value(1)
			let baseBeforeCommit = builder.base
			let baseAfterCommit = builder.commit().base

			#expect(baseBeforeCommit === initialValue)
			#expect(baseAfterCommit === initialValue)
			#expect(initialValue.value == 1)
		}

		@Test
		func combined() async throws {
			let initialValue: Mock = .init()

			let nestedConfig = Configurator<Mock>.value(1)

			let actualValue = initialValue.builder
				.combined(with: nestedConfig)
				.build()

			#expect(actualValue === initialValue)
			#expect(actualValue.value == 1)
		}
	}
}
