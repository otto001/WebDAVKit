//
//  WebDAVSession+MakeDirectory.swift
//
//
//  Created by Matteo Ludwig on 10.12.23.
//

import Foundation


extension WebDAVSession {
    public func makeDirectory(at path: any WebDAVPathProtocol,
                              headers: [String: String]? = nil, query: [String: String]? = nil,
                              account: any WebDAVAccount) async throws -> HTTPURLResponse {
        let request = try self.authorizedRequest(method: .mkcol, filePath: path, query: query, headers: headers, account: account)
        return try await self.data(request: request).1
    }
}
