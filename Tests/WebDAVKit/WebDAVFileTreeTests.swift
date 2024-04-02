//
//  WebDAVFileTreeTests.swift
//
//
//  Created by Matteo Ludwig on 01.04.24.
//

import XCTest
@testable import WebDAVKit


final class WebDAVFileTreeTests: XCTestCase {
    static let basePath = AbsoluteWebDAVPath(string: "test.de/base/base2/")!
    let folder1 = WebDAVFile(path: .init(relativePath: "", relativeTo: basePath))
    let folder2 = WebDAVFile(path: .init(relativePath: "testa/", relativeTo: basePath))
    let folder3 = WebDAVFile(path: .init(relativePath: "testb/", relativeTo: basePath))
    let file1 = WebDAVFile(path: .init(relativePath: "/1.txt", relativeTo: basePath))
    let file2 = WebDAVFile(path: .init(relativePath: "testa/a1.txt", relativeTo: basePath))
    let file3 = WebDAVFile(path: .init(relativePath: "testa/a2.txt", relativeTo: basePath))
    
    
    override func setUp() {
        
    }
    
    func testInsertInOrder() throws {
        
        var tree = WebDAVFileTree(basePath: Self.basePath)
        
        XCTAssertNoThrow(XCTAssertEqual(try tree[folder1.path]?.path, folder1.path))
        XCTAssertNoThrow(try tree.insert(folder1))
        XCTAssertEqual(tree.count, 1)
        XCTAssertNoThrow(XCTAssertEqual(try tree[folder1.path]?.path, folder1.path))
        
        XCTAssertNoThrow(XCTAssertNil(try tree[folder2.path]?.path))
        XCTAssertNoThrow(try tree.insert(folder2))
        XCTAssertEqual(tree.count, 2)
        XCTAssertNoThrow(XCTAssertEqual(try tree[folder2.path]?.path, folder2.path))
        
        XCTAssertNoThrow(XCTAssertNil(try tree[folder3.path]?.path))
        XCTAssertNoThrow(try tree.insert(folder3))
        XCTAssertEqual(tree.count, 3)
        XCTAssertNoThrow(XCTAssertEqual(try tree[folder3.path]?.path, folder3.path))
        
        XCTAssertNoThrow(XCTAssertNil(try tree[file1.path]?.path))
        XCTAssertNoThrow(try tree.insert(file1))
        XCTAssertEqual(tree.count, 4)
        XCTAssertNoThrow(XCTAssertEqual(try tree[file1.path]?.path, file1.path))
        
        XCTAssertNoThrow(XCTAssertNil(try tree[file2.path]?.path))
        XCTAssertNoThrow(try tree.insert(file2))
        XCTAssertEqual(tree.count, 5)
        XCTAssertNoThrow(XCTAssertEqual(try tree[file2.path]?.path, file2.path))
        
        XCTAssertNoThrow(XCTAssertNil(try tree[file3.path]?.path))
        XCTAssertNoThrow(try tree.insert(file3))
        XCTAssertEqual(tree.count, 6)
        XCTAssertNoThrow(XCTAssertEqual(try tree[file3.path]?.path, file3.path))
    }
    
    func testInsertOutOfOrder() throws {
        
        var tree = WebDAVFileTree(basePath: Self.basePath)
        XCTAssertNoThrow(XCTAssertEqual(try tree[folder1.path]?.path, folder1.path))
        
        XCTAssertNoThrow(XCTAssertNil(try tree[file2.path]?.path))
        XCTAssertNoThrow(try tree.insert(file2))
        XCTAssertEqual(tree.count, 3)
        XCTAssertEqual(try tree[file2.path]?.path, file2.path)
        
        XCTAssertNoThrow(XCTAssertNil(try tree[file3.path]?.path))
        XCTAssertNoThrow(try tree.insert(file3))
        XCTAssertEqual(tree.count, 4)
        XCTAssertNoThrow(XCTAssertEqual(try tree[file3.path]?.path, file3.path))
        
        XCTAssertNoThrow(XCTAssertNil(try tree[file1.path]?.path))
        XCTAssertNoThrow(try tree.insert(file1))
        XCTAssertEqual(tree.count, 5)
        XCTAssertNoThrow(XCTAssertEqual(try tree[file1.path]?.path, file1.path))
        
        XCTAssertNoThrow(XCTAssertEqual(try tree[folder1.path]?.path, folder1.path))
        XCTAssertNoThrow(try tree.insert(folder1))
        XCTAssertEqual(tree.count, 5)
        XCTAssertNoThrow(XCTAssertEqual(try tree[folder1.path]?.path, folder1.path))
        
        XCTAssertNoThrow(XCTAssertEqual(try tree[folder2.path]?.path, folder2.path))
        XCTAssertNoThrow(try tree.insert(folder2))
        XCTAssertEqual(tree.count, 5)
        XCTAssertNoThrow(XCTAssertEqual(try tree[folder2.path]?.path, folder2.path))
        
        XCTAssertNoThrow(XCTAssertNil(try tree[folder3.path]?.path))
        XCTAssertNoThrow(try tree.insert(folder3))
        XCTAssertEqual(tree.count, 6)
        XCTAssertNoThrow(XCTAssertEqual(try tree[folder3.path]?.path, folder3.path))
    }
    
    func testIterating() throws {
        let list = [file1, file2, file3, folder1, folder2, folder3].sorted {
            $0.path < $1.path
        }
        let tree = try WebDAVFileTree(list, basePath: Self.basePath)
        
        let iterResult = tree.map {$0}
        
        XCTAssertEqual(list.map {$0.path}, iterResult.map {$0.path}.sorted {
            $0.path < $1.path
        })
    }
    
    func testRemoveSubtree() throws {
        let list = [file1, file2, file3, folder1, folder2, folder3].sorted {
            $0.path < $1.path
        }
        var tree = try WebDAVFileTree(list, basePath: Self.basePath)
        XCTAssertEqual(tree.count, 6)
        
        XCTAssertNoThrow(try tree.removeSubtree(folder3.path))
        XCTAssertEqual(tree.count, 5)
        XCTAssertEqual([folder1, file1, folder2, file2, file3].map {$0.path}, tree.map {$0.path}.sorted {
            $0.path < $1.path
        })
        
        XCTAssertNoThrow(try tree.insert(folder3))
        XCTAssertEqual(tree.count, 6)
        XCTAssertEqual([folder1, file1, folder2, file2, file3, folder3].map {$0.path}, tree.map {$0.path}.sorted {
            $0.path < $1.path
        })
        
        XCTAssertNoThrow(try tree.removeSubtree(folder2.path))
        XCTAssertEqual(tree.count, 3)
        XCTAssertEqual([folder1, file1, folder3].map {$0.path}, tree.map {$0.path}.sorted {
            $0.path < $1.path
        })
        
        XCTAssertNoThrow(try tree.removeSubtree(file1.path))
        XCTAssertEqual(tree.count, 2)
        XCTAssertEqual([folder1, folder3].map {$0.path}, tree.map {$0.path}.sorted {
            $0.path < $1.path
        })
        
        XCTAssertNoThrow(try tree.insert(file2))
        XCTAssertEqual(tree.count, 4)
        XCTAssertEqual([folder1, folder2, file2, folder3].map {$0.path}, tree.map {$0.path}.sorted {
            $0.path < $1.path
        })
    }
}
