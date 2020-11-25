import XCTest
@testable import FunctionalClosures

final class FunctionalClosuresTests: XCTestCase {
    func testHandler() {
        class Object: NSObject {
            @FunctionalDataSource<(Int, Int), Int>
            var sum = .init { $0 + $1 } // You can specify default handler
            
            @FunctionalHandler<Int>
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
        XCTAssertEqual(object.$sum!((a,b)), c)
        XCTAssertEqual(storageForHandler, nil)
        
        object.handleSumResult(action: nil)
        XCTAssertEqual(storageForHandler, nil)
    }
}
