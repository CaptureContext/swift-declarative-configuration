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
        struct Container: BuilderProvider, Equatable {
            struct Content: Equatable {
                var a: Int = 0
                var b: Int = 0
                var c: Int = 0
            }
            var content: Content = .init()
        }
        
        let expected = Container(content: .init(a: 1, b: 2, c: 3))
        let initial = Container()
        let actual = initial.builder
            .content.scope { $0
                .a(1)
                .b(2)
                .c(3)
            }.build()
        
        XCTAssertNotEqual(initial, expected)
        XCTAssertEqual(actual, expected)
    }
}
