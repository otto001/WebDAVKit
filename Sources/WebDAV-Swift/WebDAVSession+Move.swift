//
//  WebDAVSession+Move.swift
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
    public func move(from origin: any WebDAVPathProtocol, to destination: any WebDAVPathProtocol, headers: [String: String]? = nil, query: [String: String]? = nil, account: any WebDAVAccount) async throws -> HTTPURLResponse {
        let absoluteOrigin = try AbsoluteWebDAVPath(origin, account: account)
        let absoluteDestination = try AbsoluteWebDAVPath(destination, account: account)
        
        guard absoluteOrigin != absoluteDestination else {
            throw WebDAVError.originSameAsDestination
        }
        
        guard absoluteOrigin.hostname == absoluteDestination.hostname else {
            throw WebDAVError.cannotMoveAcrossHostnames
        }
        
        var request = try self.authorizedRequest(method: .move, path: origin, query: query, headers: headers, account: account)
        
        request.addValue(absoluteDestination.path.stringRepresentation, forHTTPHeaderField: "Destination")
        
        let (_, urlResponse) = try await self.urlSession.data(for: request)

        try WebDAVError.checkForError(response: urlResponse)
        
        return urlResponse as! HTTPURLResponse
    }
}
