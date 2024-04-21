import XCTest
@testable import WebDAVKit


final class AbsoluteWebDAVPathTests: XCTestCase {
    func testFileName() throws {
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/c")!.fileName, "c")
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/fileName")!.fileName, "fileName")
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/c.d")!.fileName, "c")
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/fileName.fileExtension")!.fileName, "fileName")
        
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/a/b/c")!.fileName, "c")
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/a/b/fileName")!.fileName, "fileName")
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/a/b/c.d")!.fileName, "c")
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/a/b/fileName.fileExtension")!.fileName, "fileName")
        
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/.c")!.fileName, ".c")
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/.fileName")!.fileName, ".fileName")
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/a/b/.c")!.fileName, ".c")
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/a/b/.fileName")!.fileName, ".fileName")
    }
    
    func testFileExtension() throws {
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/c")!.fileExtension, nil)
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/fileName")!.fileExtension, nil)
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/c.d")!.fileExtension, "d")
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/fileName.fileExtension")!.fileExtension, "fileExtension")
        
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/a/b/c")!.fileExtension, nil)
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/a/b/fileName")!.fileExtension, nil)
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/a/b/c.d")!.fileExtension, "d")
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/a/b/fileName.fileExtension")!.fileExtension, "fileExtension")
        
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/.c")!.fileExtension, nil)
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/.fileName")!.fileExtension, nil)
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/a/b/.c")!.fileExtension, nil)
        XCTAssertEqual(AbsoluteWebDAVPath(string: "cloud.com/a/b/.fileName")!.fileExtension, nil)
    }
    
    func testIsSubpath() {
        let path1 = AbsoluteWebDAVPath(string: "cloud.com/aaaaaaaaaaaa/bbbbbbbbbbb/cccccccccccc")!
        let path2 = AbsoluteWebDAVPath(string: "cloud.com/aaaaaaaaaaaa/bbbbbbbbbbb/cccccccccccc/dddddddddd")!
        let path3 = AbsoluteWebDAVPath(string: "cloud.com/aaaaaaaaaaaa/bbbbbbbbbbb/ccccccccccc/dddddddddd")!
        let path4 = AbsoluteWebDAVPath(string: "cloud.com/aaaaaaaaaaaa/yy/cccccccccccc/dddddddddd")!
        let path5 = AbsoluteWebDAVPath(string: "cloud.de/aaaaaaaaaaaa/bbbbbbbbbbb/cccccccccccc/dddddddddd")!
        let path6 = AbsoluteWebDAVPath(string: "cloud.com/")!
        
        XCTAssertTrue(path1.isSubpath(of: path1))
        
        XCTAssertTrue(path1.isSubpath(of: path2))
        XCTAssertFalse(path2.isSubpath(of: path1))
        
        XCTAssertFalse(path1.isSubpath(of: path3))
        XCTAssertFalse(path3.isSubpath(of: path1))
        
        XCTAssertFalse(path1.isSubpath(of: path4))
        XCTAssertFalse(path4.isSubpath(of: path1))
        
        XCTAssertFalse(path1.isSubpath(of: path5))
        XCTAssertFalse(path5.isSubpath(of: path1))
        
        XCTAssertFalse(path1.isSubpath(of: path6))
        XCTAssertTrue(path6.isSubpath(of: path1))
    }
    
    func testIsSubpathPerformance() {
        let path1 = AbsoluteWebDAVPath(string: "cloud.com/aaaaaaaaaaaa/bbbbbbbbbbb/cccccccccccc")!
        let path2 = AbsoluteWebDAVPath(string: "cloud.com/aaaaaaaaaaaa/bbbbbbbbbbb/cccccccccccc/dddddddddd")!
        let path3 = AbsoluteWebDAVPath(string: "cloud.com/aaaaaaaaaaaa/yy/cccccccccccc/dddddddddd")!
        let path4 = AbsoluteWebDAVPath(string: "cloud.de/aaaaaaaaaaaa/bbbbbbbbbbb/cccccccccccc/dddddddddd")!
        self.measure {
            for _ in 0..<10_000 {
                _ = path1.isSubpath(of: path2)
                _ = path1.isSubpath(of: path3)
                _ = path1.isSubpath(of: path4)
            }
        }
    }
    
    func testRelativeTo() {
        let path1 = AbsoluteWebDAVPath(string: "cloud.com/aaaaaaaaaaaa/bbbbbbbbbbb/cccccccccccc")!
        let path2 = AbsoluteWebDAVPath(string: "cloud.com/aaaaaaaaaaaa/bbbbbbbbbbb/cccccccccccc/dddddddddd")!
        let path3 = AbsoluteWebDAVPath(string: "cloud.com/aaaaaaaaaaaa/bbbbbbbbbbb/ccccccccccc/dddddddddd")!
        let path4 = AbsoluteWebDAVPath(string: "cloud.com")!
        
        XCTAssertNoThrow(XCTAssertEqual(try path1.relative(to: path1), RelativeWebDAVPath(relativePath: "", relativeTo: path1)))
        XCTAssertNoThrow(XCTAssertEqual(try path2.relative(to: path1), RelativeWebDAVPath(relativePath: "dddddddddd", relativeTo: path1)))
        XCTAssertNoThrow(XCTAssertEqual(try path2.relative(to: path4), RelativeWebDAVPath(relativePath: "/aaaaaaaaaaaa/bbbbbbbbbbb/cccccccccccc/dddddddddd", relativeTo: path4)))
        XCTAssertNoThrow(XCTAssertEqual(try path1.relative(to: path4), RelativeWebDAVPath(relativePath: "/aaaaaaaaaaaa/bbbbbbbbbbb/cccccccccccc", relativeTo: path4)))
        XCTAssertThrowsError(try path1.relative(to: path2))
        XCTAssertThrowsError(try path3.relative(to: path1))
    }
    
    func testRelativeToPerformance() {
        let path1 = AbsoluteWebDAVPath(string: "cloud.com/aaaaaaaaaaaa/bbbbbbbbbbb/cccccccccccc")!
        let path2 = AbsoluteWebDAVPath(string: "cloud.com/aaaaaaaaaaaa/bbbbbbbbbbb/cccccccccccc/dddddddddd")!
        let path3 = AbsoluteWebDAVPath(string: "cloud.com/aaaaaaaaaaaa/bbbbbbbbbbb/ccccccccccc/dddddddddd")!
        let path4 = AbsoluteWebDAVPath(string: "cloud.com")!
        
        self.measure {
            for _ in 0..<10_000 {
                _ = try? path2.relative(to: path1)
                _ = try? path2.relative(to: path4)
                _ = try? path1.relative(to: path4)
                _ = try? path1.relative(to: path2)
                _ = try? path3.relative(to: path1)
            }
        }
    }
}
