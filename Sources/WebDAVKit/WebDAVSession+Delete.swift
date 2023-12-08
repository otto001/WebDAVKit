//
//  WebDAVSession+Delete.swift
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

extension WebDAVSession {
    /// Deletes the file at the given path.
    /// - Parameters: path: The path to delete.
    /// - Parameters: headers: Any additional headers to use for the request.
    /// - Parameters: query: The query to use for the request.
    /// - Parameters: account: The account used to authorize the request.
    /// - Returns: The response.
    @discardableResult public func delete(path: any WebDAVPathProtocol, 
                                          headers: [String: String]? = nil, query: [String: String]? = nil, 
                                          account: any WebDAVAccount) async throws -> HTTPURLResponse {
        let request = try self.authorizedRequest(method: .delete, filePath: path, query: query, headers: headers, account: account)
        
        let (data, urlResponse) = try await self.urlSession.data(for: request)

        try WebDAVError.checkForError(response: urlResponse, data: data)
        
        return urlResponse as! HTTPURLResponse
    }
}
