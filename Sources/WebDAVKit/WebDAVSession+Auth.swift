//
//  WebDAVSession+Auth.swift
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

    
    public func logout(account: any WebDAVAccount) async throws {
        switch account.serverType {
        case .nextcloud:
            let authHeader = try self.getAuthHeader(for: account)
            var request = URLRequest(url: try AbsoluteWebDAVPath(hostname: account.hostname, path: "/ocs/v2.php/core/apppassword").url)

            request.addValue("Basic \(authHeader)", forHTTPHeaderField: "Authorization")
            request.addValue("true", forHTTPHeaderField: "OCS-APIREQUEST")
    
            let (_, response) = try await self.urlSession.data(for: request)
    
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw WebDAVError.logoutError
            }
        default:
            throw WebDAVError.unsupported
        }
    }
    
    /// Creates a basic authentication credential.
    /// - Returns: A base-64 encoded credential if the provided credentials are valid (can be encoded as UTF-8).
    public func getAuthHeader(for account: any WebDAVAccount) throws -> String {
        return try self.getAuthHeader(username: account.username, password: account.password.inner)
    }
    
    public func getAuthHeader(username: String, password: String) throws -> String {
        let authString = username + ":" + password
        let authData = authString.data(using: .utf8)
        guard let header = authData?.base64EncodedString() else {
            throw WebDAVError.internalError
        }
        return header
    }
    
    public func authorizeRequest(request: inout URLRequest, account: any WebDAVAccount) throws {
        let authHeader = try self.getAuthHeader(for: account)
        request.addValue("Basic \(authHeader)", forHTTPHeaderField: "Authorization")
    }
    
    public func authorizedRequest(method: WebDAVMethod, path: AbsoluteWebDAVPath, query: [String: String]? = nil, headers: [String: String]? = nil, account: any WebDAVAccount) throws -> URLRequest {
        var urlComponents = path.urlComponents
        
        urlComponents.queryItems = query?.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        
        guard let url = urlComponents.url else {
            throw WebDAVError.urlBuildingError
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        try self.authorizeRequest(request: &request, account: account)
        
        headers?.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        return request
    }
    
    public func authorizedRequest(method: WebDAVMethod, filePath: any WebDAVPathProtocol, query: [String: String]? = nil, headers: [String: String]? = nil, account: any WebDAVAccount) throws -> URLRequest {
        try self.authorizedRequest(method: method, path: try AbsoluteWebDAVPath(filePath: filePath, account: account),
                                   query: query, headers: headers, account: account)
    }
    
}

