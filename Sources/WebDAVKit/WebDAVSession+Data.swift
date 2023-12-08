//
//  WebDAVSession+Data.swift
//  WebDAVKit
//
//  Created by Matteo Ludwig on 29.11.23.
//  Licensed under the MIT-License included in the project
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
    
    public func data(request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await self.urlSession.data(for: request)
        
        try WebDAVError.checkForError(response: response)
        
        return (data, response as! HTTPURLResponse)
    }
    
    public func data(from path: any WebDAVPathProtocol, headers: [String: String]? = nil, query: [String: String]? = nil, account: any WebDAVAccount) async throws -> (Data, HTTPURLResponse) {
        let request = try self.authorizedRequest(method: .get, filePath: path, query: query, headers: headers, account: account)
        return try await self.data(request: request)
    }
    
    public func data(from path: any WebDAVPathProtocol, byteRangeStart: Int, byteRangeEnd: Int?, headers: [String: String]? = nil, query: [String: String]? = nil, account: any WebDAVAccount) async throws -> (Data, HTTPURLResponse) {
        
        var headers: [String: String] = headers ?? [:]
        if let byteRangeEnd = byteRangeEnd {
            headers["Range"] = "bytes=\(byteRangeStart)-\(byteRangeEnd)"
        } else {
            headers["Range"] = "bytes=\(byteRangeStart)-"
        }
        
        return try await self.data(from: path, headers: headers, query: query, account: account)
    }
}
