import XCTest

@testable import FunctionalConfigurator

final class ConfiguratorTests: XCTestCase {
  func testConfiguration() {
    struct TestConfigurable: Equatable {
      struct Wrapped: Equatable {
        var value = 0
      }

      var value = false
      var wrapped = Wrapped()
    }

    let wrappedConfiguator = Configurator<TestConfigurable>()
      .wrapped.value(1)

    let valueConfigurator = Configurator<TestConfigurable>()
      .value(true)

    let configurator =
      wrappedConfiguator
        .combined(with: valueConfigurator)

    let initial = TestConfigurable()
    let expected = TestConfigurable(value: true, wrapped: .init(value: 1))
    let actual = configurator.configured(initial)

    XCTAssertNotEqual(actual, initial)
    XCTAssertEqual(actual, expected)
  }

  func testConfigInitializable() {
    final class TestConfigurable: NSObject {
      override init() {
        super.init()
      }

      init(value: Bool, wrapped: TestConfigurable.Wrapped) {
        self.value = value
        self.wrapped = wrapped
      }

      struct Wrapped: Equatable {
        var value = 0
      }

      var value = false
      var wrapped = Wrapped()
    }

    let initial = TestConfigurable()
    let expected = TestConfigurable(value: true, wrapped: .init(value: 1))
    let actual1 = TestConfigurable {
      $0
        .value(true)
        .wrapped(.init(value: 1))
    }
    let actual2 = TestConfigurable(
      config: TestConfigurable.Config
        .value(true)
        .wrapped(.init(value: 1))
    )

    XCTAssertNotEqual(actual1.value, initial.value)
    XCTAssertNotEqual(actual1.wrapped, initial.wrapped)
    XCTAssertEqual(actual1.value, actual2.value)
    XCTAssertEqual(actual1.wrapped, actual2.wrapped)
    XCTAssertEqual(actual1.value, expected.value)
    XCTAssertEqual(actual1.wrapped, expected.wrapped)
  }

  func testCustomConfigurable() {
    struct TestConfigurable: CustomConfigurable {
      struct Wrapped: Equatable {
        var value = 0
      }

      var value = false
      var wrapped = Wrapped()
    }

    let initial = TestConfigurable()
    let expected = TestConfigurable(value: true, wrapped: .init(value: 1))
    let actual = TestConfigurable().configured {
      $0
        .value(true)
        .wrapped(.init(value: 1))
    }

    XCTAssertNotEqual(actual.value, initial.value)
    XCTAssertNotEqual(actual.wrapped, initial.wrapped)
    XCTAssertEqual(actual.value, expected.value)
    XCTAssertEqual(actual.wrapped, expected.wrapped)
  }

  func testOptional() {
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
    let expected = TestConfigurable(value: true, wrappedValue: 1)
    let actual = TestConfigurable().configured {
      $0
        .value(true)
        .wrapped.value(1)
    }

    XCTAssertNotEqual(actual.value, initial.value)
    XCTAssertNotEqual(actual.wrapped?.value, initial.wrapped?.value)
    XCTAssertEqual(actual.value, expected.value)
    XCTAssertEqual(actual._wrapped.value, expected._wrapped.value)
  }

  func testScope() {
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

    let expected = Container {
      $0
        .content.a(1)
        .content.b(2)
        .content.c(3)
        .content.innerClass.value(1)
        .content.innerStruct.value(1)
    }
    let initial = Container()
    let actual = Container {
      $0
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
            .innerStruct
            .ifLetScope {
              $0
                .value(1)
            }
        }
    }

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
