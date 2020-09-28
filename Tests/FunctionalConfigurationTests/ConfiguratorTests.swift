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
        
        let wrappedConfiguator = Configurator<TestConfigurable>
            .wrapped.value(1)
        
        let valueConfigurator = Configurator<TestConfigurable>
            .value(true)
        
        let configurator = wrappedConfiguator
            .appending(valueConfigurator)
        
        let initial = TestConfigurable()
        let expected = TestConfigurable(value: true, wrapped: .init(value: 1))
        let actual = configurator.configure(initial)
        
        XCTAssertNotEqual(actual, initial)
        XCTAssertEqual(actual, expected)
    }
    
    
    func testConfigInitializable() {
        class TestConfigurable: NSObject {
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
            TestConfigurable.Config
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
}
