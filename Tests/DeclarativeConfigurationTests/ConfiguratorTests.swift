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

        let configurator = wrappedConfiguator
            .appending(valueConfigurator)

        let initial = TestConfigurable()
        let expected = TestConfigurable(value: true, wrapped: .init(value: 1))
        let actual = configurator.configured(initial)

        XCTAssertNotEqual(actual, initial)
        XCTAssertEqual(actual, expected)
    }
    
    
    func testConfigInitializable() {
        final class TestConfigurable: NSObject {
            override init() { // required init
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
        let actual1 = TestConfigurable { $0
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
        let actual = TestConfigurable().configured { $0
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
                self.wrapped?.value = wrappedValue
            }
            
            class Wrapped: NSObject {
                var value: Int? = 0
                override init() { self.value = 0 }
            }
            
            var value = false
            let _wrapped: Wrapped = Wrapped()
            var wrapped: Wrapped? { _wrapped }
        }
        
        let initial = TestConfigurable()
        let expected = TestConfigurable(value: true, wrappedValue: 1)
        let actual = TestConfigurable().configured { $0
            .value(true)
            .wrapped.value(1)
        }
        
        XCTAssertNotEqual(actual.value, initial.value)
        XCTAssertNotEqual(actual.wrapped?.value, initial.wrapped?.value)
        XCTAssertEqual(actual.value, expected.value)
        XCTAssertEqual(actual._wrapped.value, expected._wrapped.value)
    }
    
    func testScope() {
        struct Container: ConfigInitializable, Equatable {
            struct Content: Equatable {
                var a: Int = 0
                var b: Int = 0
                var c: Int = 0
            }
            var content: Content = .init()
        }
        
        let expected = Container(content: .init(a: 1, b: 2, c: 3))
        let actual = Container { $0
            .content.scope { $0
                .a(1)
                .b(2)
                .c(3)
            }
        }
        
        XCTAssertEqual(actual, expected)
    }
}
