import XCTest

@testable import FunctionalModification

final class ModificationTests: XCTestCase {
  func testValueModificationForValueTypes() {
    struct _Test { var value = 0 }
    let initial = _Test(value: 0)
    let expected = _Test(value: 1)
    let actual = reduce(initial) { $0.value = expected.value }
    XCTAssertNotEqual(initial.value, expected.value)
    XCTAssertEqual(actual.value, expected.value)
  }

  func testInstanceModificationForValueTypes() {
    struct _Test { var value = 0 }
    let initial = _Test(value: 0)
    let expected = _Test(value: 1)
    let actual = reduce(initial) { $0 = expected }
    XCTAssertNotEqual(initial.value, expected.value)
    XCTAssertEqual(actual.value, expected.value)
  }

  func testValueModificationForReferenceTypes() {
    class _Test { var value = 0 }
    let initial = _Test()
    let expected: _Test = {
      let test = _Test()
      test.value = 1
      return test
    }()

    let actual = reduce(initial) { $0.value = expected.value }
    XCTAssertEqual(ObjectIdentifier(actual), ObjectIdentifier(initial))
    XCTAssertEqual(actual.value, expected.value)
  }

  func testInstanceModificationForReferenceTypes() {
    class _Test { var value = 0 }
    let initial = _Test()
    let expected: _Test = {
      let test = _Test()
      test.value = 1
      return test
    }()

    let actual = reduce(initial) { $0 = expected }
    XCTAssertNotEqual(ObjectIdentifier(initial), ObjectIdentifier(expected))
    XCTAssertEqual(ObjectIdentifier(actual), ObjectIdentifier(expected))
  }
}
