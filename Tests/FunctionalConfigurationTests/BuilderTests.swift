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
}
