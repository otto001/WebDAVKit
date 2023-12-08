//
//  WebDAVSession+Data.swift
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
import Combine

extension WebDAVSession {
    
    /// Fetches the data for the given request.
    /// - Parameters: request: The request to fetch the data for.
    /// - Returns: The data and the response.
    public func data(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await self.urlSession.data(for: request)
        
        try WebDAVError.checkForError(response: response, data: data)
        
        return (data, response as! HTTPURLResponse)
    }
    
    /// Fetches the data for the given path.
    /// - Parameters: path: The path to fetch the data for.
    /// - Parameters: headers: Any additional headers to use for the request.
    /// - Parameters: query: The query to use for the request.
    /// - Parameters: account: The account used to authorize the request.
    /// - Returns: The data and the response.
    public func data(from path: any WebDAVPathProtocol, 
                     headers: [String: String]? = nil, query: [String: String]? = nil,
                     account: any WebDAVAccount) async throws -> (Data, HTTPURLResponse) {
        let request = try self.authorizedRequest(method: .get, filePath: path, query: query, headers: headers, account: account)
        return try await self.data(request: request)
    }
    
    /// Fetches the data for the given path.
    /// - Parameters: path: The path to fetch the data for.
    /// - Parameters: byteRangeStart: The start of the byte range to fetch.
    /// - Parameters: byteRangeEnd: The end of the byte range to fetch. If nil, the rest of the file is fetched.
    /// - Parameters: headers: Any additional headers to use for the request.
    /// - Parameters: query: The query to use for the request.
    /// - Parameters: account: The account used to authorize the request.
    /// - Returns: The data and the response.
    public func data(from path: any WebDAVPathProtocol, 
                     byteRangeStart: Int, byteRangeEnd: Int?,
                     headers: [String: String]? = nil, query: [String: String]? = nil,
                     account: any WebDAVAccount) async throws -> (Data, HTTPURLResponse) {
        
        var headers: [String: String] = headers ?? [:]
        if let byteRangeEnd = byteRangeEnd {
            headers["Range"] = "bytes=\(byteRangeStart)-\(byteRangeEnd)"
        } else {
            headers["Range"] = "bytes=\(byteRangeStart)-"
        }
        
        return try await self.data(from: path, headers: headers, query: query, account: account)
    }
}
