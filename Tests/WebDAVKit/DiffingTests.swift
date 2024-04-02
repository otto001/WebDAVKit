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


}
