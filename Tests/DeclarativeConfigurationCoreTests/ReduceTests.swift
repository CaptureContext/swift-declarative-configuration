import Testing
@testable import DeclarativeConfigurationCore

@Suite("ReduceTests")
struct ReduceTests {
	@Test
	func valueModificationForValueTypes() {
		struct _Test { var value = 0 }
		let initial = _Test(value: 0)
		let expected = _Test(value: 1)
		let actual = reduce(initial) { $0.value = expected.value }
		#expect(initial.value != expected.value)
		#expect(actual.value == expected.value)
	}

	@Test
	func valueModificationForReferenceTypes() {
		class _Test { var value = 0 }
		let initial = _Test()
		let expected: _Test = {
			let test = _Test()
			test.value = 1
			return test
		}()

		let actual = reduce(initial) { $0.value = expected.value }
		#expect(ObjectIdentifier(actual) == ObjectIdentifier(initial))
		#expect(actual.value == expected.value)
	}

	@Test
	func instanceModificationForValueTypes() {
		struct _Test { var value = 0 }
		let initial = _Test(value: 0)
		let expected = _Test(value: 1)
		let actual = reduce(initial) { $0 = expected }
		#expect(initial.value != expected.value)
		#expect(actual.value == expected.value)
	}

	@Test
	func instanceModificationForReferenceTypes() {
		class _Test { var value = 0 }
		let initial = _Test()
		let expected: _Test = {
			let test = _Test()
			test.value = 1
			return test
		}()

		let actual = reduce(initial) { $0 = expected }
		#expect(ObjectIdentifier(initial) != ObjectIdentifier(expected))
		#expect(ObjectIdentifier(actual) == ObjectIdentifier(expected))
	}
}
