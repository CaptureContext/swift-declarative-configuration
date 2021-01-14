import XCTest
@testable import FunctionalClosures
import FunctionalConfigurator

final class FunctionalClosuresTests: XCTestCase {
    func testBasicUsage() {
        class Object: NSObject {
            @DataSource<(Int, Int), Int>
            var sum = .init { $0 + $1 } // You can specify default handler
            
            @Handler<Int>
            var handleSumResult // or leave it nil
            
            func sumOf(_ a: Int, _ b: Int) -> Int? {
                let result = _sum((a, b))
                if let result = result {
                    _handleSumResult(result)
                }
                return result
            }
        }
        
        let object = Object()
        let a = 10
        let b = 20
        let c = 30
        var storageForHandler: Int? = nil
        
        object.handleSumResult { int in
            storageForHandler = int
            XCTAssertEqual(int, c)
        }
        
        // object._handleSumResult(0) // private
        object.$handleSumResult!(c)
        XCTAssertEqual(storageForHandler, c)
        storageForHandler = nil
        
        XCTAssertEqual(object.sumOf(a, b), c)
        XCTAssertEqual(storageForHandler, c)
        storageForHandler = nil
        
        // object._sum(a, b) // private
        XCTAssertEqual(object.$sum((a,b)), c)
        XCTAssertEqual(storageForHandler, nil)
        
        object.handleSumResult(action: nil)
        XCTAssertEqual(storageForHandler, nil)
    }
    
    func testUsageWithBuilder() {
        final class Object: ConfigInitializable {
            @DataSource<(Int, Int), Int>
            var sum = .init { $0 + $1 } // You can specify default handler
            
            @Handler3<Int, Int, Int>
            var handleSum // or leave it nil
            
            init() {}
            
            func sumOf(_ a: Int, _ b: Int) -> Int? {
                let result = _sum((a, b))
                if let result = result {
                    _handleSum(a, b, result)
                }
                return result
            }
        }
        
        class Storage {
            var result: Int = 0
        }
        
        let storage = Storage()
        
        let object = Object { $0
            // Handle only result
            .$handleSum(assignThird(to: storage, \.result))
        }
        
        let a = 10
        let b = 20
        let c = 30
        
        XCTAssert(object.$handleSum != nil)
        XCTAssertEqual(object.sumOf(a, b), c)
        XCTAssertEqual(storage.result, c)
        
        // handle all values
        object.handleSum { _a, _b, _c in
            XCTAssertEqual(_a, a)
            XCTAssertEqual(_b, b)
            XCTAssertEqual(_c, c)
        }
        
        object.$handleSum?(a, b, c)
    }
}
