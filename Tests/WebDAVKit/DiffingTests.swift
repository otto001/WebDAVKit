//
//  DiffingTests.swift
//  
//
//  Created by Matteo Ludwig on 01.04.24.
//

import XCTest
@testable import WebDAVKit


final class DiffingTests: XCTestCase {
    static let basePath = AbsoluteWebDAVPath(string: "test.de/")!
    let folder1 = WebDAVFile(path: .init(relativePath: "", relativeTo: basePath))
    let folder2 = WebDAVFile(path: .init(relativePath: "testa/", relativeTo: basePath))
    let folder3 = WebDAVFile(path: .init(relativePath: "testb/", relativeTo: basePath))
    let folder4 = WebDAVFile(path: .init(relativePath: "testa/testc", relativeTo: basePath))
    let file1 = WebDAVFile(path: .init(relativePath: "/1.txt", relativeTo: basePath))
    let file2 = WebDAVFile(path: .init(relativePath: "testa/a1.txt", relativeTo: basePath))
    let file3 = WebDAVFile(path: .init(relativePath: "testa/a2.txt", relativeTo: basePath))
    let file4 = WebDAVFile(path: .init(relativePath: "testa/testc/a3.txt", relativeTo: basePath))

    func testRemoveFilesFromDirectories() throws {
        let list: [WebDAVFile] = [file1, file2, file3, file4, folder1, folder2, folder3, folder4]
        
        XCTAssertEqual(list.removingFilesFromDirectories(directories: []).map {$0.path}, list.map {$0.path})
        XCTAssertEqual(list.removingFilesFromDirectories(directories: [folder1]).map {$0.path}, [])
        
        XCTAssertEqual(list.removingFilesFromDirectories(directories: [folder3]).map {$0.path}, [folder1, file1, folder2, file2, file3, folder4, file4].map {$0.path})
        
        XCTAssertEqual(list.removingFilesFromDirectories(directories: [folder2]).map {$0.path}, [folder1, file1, folder3].map {$0.path})
        XCTAssertEqual(list.removingFilesFromDirectories(directories: [folder2, folder3]).map {$0.path}, [folder1, file1].map {$0.path})
        
        
        let list2: [WebDAVFile] = [file1, folder1, folder3]
        XCTAssertEqual(list2.removingFilesFromDirectories(directories: [folder3]).map {$0.path}, [folder1, file1].map {$0.path})
        
        XCTAssertEqual(list2.removingFilesFromDirectories(directories: [folder2, folder3]).map {$0.path}, [folder1, file1].map {$0.path})
        
        XCTAssertEqual(list2.removingFilesFromDirectories(directories: [folder2]).map {$0.path}, [folder1, file1, folder3].map {$0.path})
        
        XCTAssertEqual(list2.removingFilesFromDirectories(directories: [folder4, folder3]).map {$0.path}, [folder1, file1].map {$0.path})
        
        XCTAssertEqual(list2.removingFilesFromDirectories(directories: [folder4]).map {$0.path}, [folder1, file1, folder3].map {$0.path})
    }


}
