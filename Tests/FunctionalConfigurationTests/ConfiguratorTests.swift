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
}
