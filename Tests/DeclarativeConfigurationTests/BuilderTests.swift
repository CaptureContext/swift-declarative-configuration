import Testing
@testable import DeclarativeConfiguration

@Suite("BuilderTests")
struct BuilderTests {
	@Test
	func testBuilder() {
		struct TestBuildable: Equatable {
			struct Wrapped: Equatable {
				var value = 0
			}

			var value = false
			var wrapped = Wrapped()
		}

		let expected: TestBuildable = {
			var test = TestBuildable()
			test.value = true
			test.wrapped.value = 1
			return test
		}()

		let actual = Builder(TestBuildable())
			.wrapped.value(1)
			.value(true)
			.build()

		#expect(actual != TestBuildable())
		#expect(actual == expected)
	}

	@Test
	func testReinforce() {
		struct TestBuildable: Equatable {
			struct Wrapped: Equatable {
				var value = 0
			}

			var value = false
			var wrapped = Wrapped()
		}

		let expected: TestBuildable = {
			var test = TestBuildable()
			test.wrapped.value = 1
			return test
		}()

		var flag = false

		_ = Builder(TestBuildable())
			.wrapped.value(1)
			.reinforce()
			.combined(with: .modify { actual in
				flag = true
				#expect(actual != TestBuildable())
				#expect(actual == expected)
			})
			.reinforce()

		#expect(flag == false, "Reinforce transform wasn't called")
	}

	@Test
	func testScope() {
		struct Container: BuilderProvider {
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

		let expected = Container().builder
			.content.a(1)
			.content.b(2)
			.content.c(3)
			.content.innerClass.value(1)
			.content.innerStruct.value(1)
			.build()

		let initial = Container()
		let actual = Container().builder
			.content.scope { $0
				.a(1)
				.b(2)
				.c(3)
				.innerClass
				.ifLetScope { $0
					.value(1)
				}
			}
			.build()

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
