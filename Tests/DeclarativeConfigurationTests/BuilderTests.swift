import XCTest

@testable import FunctionalBuilder

final class BuilderTests: XCTestCase {
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

    XCTAssertNotEqual(actual, TestBuildable())
    XCTAssertEqual(actual, expected)
  }

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
      .reinforce { actual in
        flag = true
        XCTAssertNotEqual(actual, TestBuildable())
        XCTAssertEqual(actual, expected)
      }

    XCTAssertEqual(flag, false, "Reinforce transform wasn't called")
  }

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
        var innerStruct: InnerStruct? = nil

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
      .content.scope {
        $0
          .a(1)
          .b(2)
          .c(3)
          .innerClass
          .ifLetScope {
            $0
              .value(1)
          }
      }.build()

    XCTAssertNotEqual(actual.content.a, initial.content.a)
    XCTAssertNotEqual(actual.content.b, initial.content.b)
    XCTAssertNotEqual(actual.content.c, initial.content.c)
    XCTAssertEqual(actual.content.innerClass?.value, initial.content.innerClass?.value)
    XCTAssertEqual(actual.content.innerStruct?.value, initial.content.innerStruct?.value)

    XCTAssertEqual(actual.content.a, expected.content.a)
    XCTAssertEqual(actual.content.b, expected.content.b)
    XCTAssertEqual(actual.content.c, expected.content.c)
    XCTAssertEqual(actual.content.innerClass?.value, expected.content.innerClass?.value)
    XCTAssertEqual(actual.content.innerStruct?.value, expected.content.innerStruct?.value)
  }
}
