//
//  WebDAVSession+Upload.swift
//  WebDAV-Swift
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

extension WebDAVSession {
    
    @discardableResult
    public func upload(request: URLRequest, data: Data) async throws -> HTTPURLResponse {
        let (_, urlResponse) = try await self.urlSession.upload(for: request, from: data)
        
        try WebDAVError.checkForError(response: urlResponse)
        
        return urlResponse as! HTTPURLResponse
    }
    
    @discardableResult
    public func upload(to path: any WebDAVPathProtocol, data: Data, contentType: String, headers: [String: String]? = nil, query: [String: String]? = nil, modifiedTime: Date?, account: any WebDAVAccount) async throws -> HTTPURLResponse {
        var request = try self.authorizedRequest(method: .put, path: path, query: query, headers: headers, account: account)
        
        request.addValue(contentType, forHTTPHeaderField: "Content-Type")
        request.addValue("true", forHTTPHeaderField: "OCS-APIREQUEST")
        if let modifiedTime = modifiedTime {
            request.addValue("\(Int(modifiedTime.timeIntervalSince1970))", forHTTPHeaderField: "X-OC-Mtime")
        }
        
        return try await upload(request: request, data: data)
    }
}
