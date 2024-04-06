//
//  WebDAVSession+Upload.swift
//  WebDAVKit
//
//  Created by Matteo Ludwig on 29.11.23.
//  Licensed under the MIT-License included in the project.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

public typealias WebDAVRequestModifyClosure = (_ request: inout URLRequest) -> Void

extension WebDAVSession {
    
    /// Uploads the data with the given request.
    /// - Parameters: request: The request to upload the data with.
    /// - Parameters: data: The data to upload.
    /// - Returns: The Http response.
    @discardableResult public func upload(request: URLRequest, data: Data) async throws -> HTTPURLResponse {
        let (data, urlResponse) = try await self.urlSession.upload(for: request, from: data)
        
        try WebDAVError.checkForError(response: urlResponse, data: data)
        
        return urlResponse as! HTTPURLResponse
    }
    
    /// Uploads the data with the given request.
    /// - Parameters: request: The request to upload the data with.
    /// - Parameters: fileURL: The file URL from which to upload the data.
    /// - Returns: The Http response.
    @discardableResult public func upload(request: URLRequest, fromFile fileURL: URL) async throws -> HTTPURLResponse {
        let (data, urlResponse) = try await self.urlSession.upload(for: request, fromFile: fileURL)
        
        try WebDAVError.checkForError(response: urlResponse, data: data)
        
        return urlResponse as! HTTPURLResponse
    }
    
    /// Uploads the data to the given path.
    /// - Parameters: path: The path to upload the data to.
    /// - Parameters: data: The data to upload.
    /// - Parameters: contentType: The content type of the data.
    /// - Parameters: headers: Any additional headers to use for the request.
    /// - Parameters: query: The query to use for the request.
    /// - Parameters: modifiedTime: The modified time of the file. Only used for Owncloud/Nextcloud.
    /// - Parameters: account: The account used to authorize the request.
    /// - Returns: The Http response.
    @discardableResult public func upload(to path: any WebDAVPathProtocol, 
                                          data: Data, contentType: MimeType,
                                          headers: [String: String]? = nil, query: [String: String]? = nil,
                                          modifiedTime: Date?,
                                          account: any WebDAVAccount,
                                          modifyRequest: WebDAVRequestModifyClosure?) async throws -> HTTPURLResponse {
        
        var request = try self.authorizedRequest(method: .put, filePath: path,
                                                 query: query, headers: headers,
                                                 contentType: contentType,
                                                 ocsApiRequest: account.serverType.isOwncloud && modifiedTime != nil,
                                                 account: account)

        if let modifiedTime = modifiedTime, account.serverType.isOwncloud {
            request.addValue("\(Int(modifiedTime.timeIntervalSince1970))", forHTTPHeaderField: "X-OC-Mtime")
        }
        
        modifyRequest?(&request)
        
        return try await upload(request: request, data: data)
    }
    

    /// Uploads the data to the given path.
    /// - Parameters: path: The path to upload the data to.
    /// - Parameters: fileURL: The file URL from which to upload the data.
    /// - Parameters: contentType: The content type of the data.
    /// - Parameters: headers: Any additional headers to use for the request.
    /// - Parameters: query: The query to use for the request.
    /// - Parameters: modifiedTime: The modified time of the file. Only used for Owncloud/Nextcloud.
    /// - Parameters: account: The account used to authorize the request.
    /// - Returns: The Http response.
    @discardableResult public func upload(to path: any WebDAVPathProtocol,
                                          fromFile fileURL: URL, contentType: MimeType,
                                          headers: [String:  String]? = nil, query: [String: String]? = nil,
                                          modifiedTime: Date?,
                                          account: any WebDAVAccount,
                                          modifyRequest: WebDAVRequestModifyClosure?) async throws -> HTTPURLResponse {
        
        var request = try self.authorizedRequest(method: .put, filePath: path,
                                                 query: query, headers: headers,
                                                 contentType: contentType,
                                                 ocsApiRequest: account.serverType.isOwncloud && modifiedTime != nil,
                                                 account: account)

        if let modifiedTime = modifiedTime, account.serverType.isOwncloud {
            request.addValue("\(Int(modifiedTime.timeIntervalSince1970))", forHTTPHeaderField: "X-OC-Mtime")
        }
        
        modifyRequest?(&request)
        
        return try await upload(request: request, fromFile: fileURL)
    }
    
    /// Creates an upload task to upload data from a file to the given path. Suitable for background uploads.
    /// - Parameters: path: The path to upload the data to.
    /// - Parameters: fileURL: The file URL from which to upload the data.
    /// - Parameters: contentType: The content type of the data.
    /// - Parameters: headers: Any additional headers to use for the request.
    /// - Parameters: query: The query to use for the request.
    /// - Parameters: modifiedTime: The modified time of the file. Only used for Owncloud/Nextcloud.
    /// - Parameters: account: The account used to authorize the request.
    /// - Returns: The upload task.
    /// - Note: The task is not started automatically. You need to call `resume()` on it.
    public func createUploadTask(to path: any WebDAVPathProtocol,
                                 fromFile fileURL: URL, contentType: MimeType,
                                 headers: [String: String]? = nil, query: [String: String]? = nil,
                                 modifiedTime: Date?,
                                 account: any WebDAVAccount,
                                 modifyRequest: WebDAVRequestModifyClosure?) throws -> URLSessionUploadTask {
        
        var request = try self.authorizedRequest(method: .put, filePath: path,
                                                 query: query, headers: headers,
                                                 contentType: contentType,
                                                 ocsApiRequest: account.serverType.isOwncloud && modifiedTime != nil,
                                                 account: account)

        if let modifiedTime = modifiedTime, account.serverType.isOwncloud {
            request.addValue("\(Int(modifiedTime.timeIntervalSince1970))", forHTTPHeaderField: "X-OC-Mtime")
        }
        
        modifyRequest?(&request)
        
        return self.urlSession.uploadTask(with: request, fromFile: fileURL)
    }
}
