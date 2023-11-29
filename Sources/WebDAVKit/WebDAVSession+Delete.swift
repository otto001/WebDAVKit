//
//  WebDAVSession+Delete.swift
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

extension WebDAVSession {
    @discardableResult
    public func delete(path: any WebDAVPathProtocol, headers: [String: String]? = nil, query: [String: String]? = nil, account: any WebDAVAccount) async throws -> HTTPURLResponse {
        let request = try self.authorizedRequest(method: .delete, path: path, query: query, headers: headers, account: account)
        
        let (_, urlResponse) = try await self.urlSession.data(for: request)

        try WebDAVError.checkForError(response: urlResponse)
        
        return urlResponse as! HTTPURLResponse
    }
}
