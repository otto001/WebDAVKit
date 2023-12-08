//
//  WebDAVSession+Move.swift
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
    /// Moves the file from the origin to the destination.
    /// - Parameters: origin: The origin path.
    /// - Parameters: destination: The destination path.
    /// - Parameters: headers: Any additional headers to use for the request.
    /// - Parameters: query: The query to use for the request.
    /// - Parameters: account: The account used to authorize the request.
    /// - Returns: The response.
    /// - Throws: `WebDAVError.originSameAsDestination` if the origin and destination are the same.
    /// - Throws: `WebDAVError.cannotMoveAcrossHostnames` if the origin and destination are on different hosts.
    @discardableResult public func move(from origin: any WebDAVPathProtocol, to destination: any WebDAVPathProtocol, 
                                        headers: [String: String]? = nil, query: [String: String]? = nil,
                                        account: any WebDAVAccount) async throws -> HTTPURLResponse {
        let absoluteOrigin = try AbsoluteWebDAVPath(filePath: origin, account: account)
        let absoluteDestination = try AbsoluteWebDAVPath(filePath: destination, account: account)
        
        guard absoluteOrigin != absoluteDestination else {
            throw WebDAVError.originSameAsDestination
        }
        
        guard absoluteOrigin.hostname == absoluteDestination.hostname else {
            throw WebDAVError.cannotMoveAcrossHostnames
        }
        
        var request = try self.authorizedRequest(method: .move, filePath: origin, query: query, headers: headers, account: account)
        
        request.addValue(absoluteDestination.path.stringRepresentation, forHTTPHeaderField: "Destination")
        
        let (data, urlResponse) = try await self.urlSession.data(for: request)
        
        try WebDAVError.checkForError(response: urlResponse, data: data)
        
        return urlResponse as! HTTPURLResponse
    }
}
