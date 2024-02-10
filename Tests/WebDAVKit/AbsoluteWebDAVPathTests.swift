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
}
