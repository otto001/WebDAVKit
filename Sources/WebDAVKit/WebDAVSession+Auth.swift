//
//  WebDAVSession+Auth.swift
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

    /// Logout from the given account. Only supported for Nextcloud.
    /// - Parameters: account: The account to logout from.
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
    
    /// Creates a basic authentication header value.
    /// - Parameters: account: The account to create the header for.
    /// - Returns: A base-64 encoded credential if the provided credentials are valid (can be encoded as UTF-8).
    public func getAuthHeader(for account: any WebDAVAccount) throws -> String {
        return try self.getAuthHeader(username: account.username, password: account.password.inner)
    }
    
     /// Creates a basic authentication header value.
    /// - Parameters: username: The username to create the header for.
    /// - Parameters: password: The password to create the header for.
    /// - Returns: A base-64 encoded credential if the provided credentials are valid (can be encoded as UTF-8).
    public func getAuthHeader(username: String, password: String) throws -> String {
        let authString = username + ":" + password
        let authData = authString.data(using: .utf8)
        guard let header = authData?.base64EncodedString() else {
            throw WebDAVError.internalError
        }
        return header
    }
    
    /// Authorizes the given request with the given account by adding a basic authentication header.
    /// - Parameters: request: The request to authorize.
    /// - Parameters: account: The account to authorize the request with.
    public func authorizeRequest(request: inout URLRequest, account: any WebDAVAccount) throws {
        let authHeader = try self.getAuthHeader(for: account)
        request.addValue("Basic \(authHeader)", forHTTPHeaderField: "Authorization")
    }
    
    /// Creates a request with the given parameters and authorizes it with the given account.
    /// - Parameters: method: The http method to use for the request.
    /// - Parameters: path: The path to use for the request.
    /// - Parameters: query: The query parameters to use for the request.
    /// - Parameters: headers: The headers to add to the request.
    /// - Parameters: contentType: The content type to set for the request (sets content-type header).
    /// - Parameters: accept: The accept types to set for the request (sets accept header).
    /// - Parameters: ocsApiRequest: If true, the OCS-APIRequest header is set to true. Used for Owncloud/Nextcloud requests.
    /// - Parameters: account: The account to authorize the request with.
    public func authorizedRequest(method: WebDAVMethod, path: AbsoluteWebDAVPath, 
                                  query: [String: String]? = nil, headers: [String: String]? = nil,
                                  contentType: MimeType? = nil, accept: [MimeType]? = nil,
                                  ocsApiRequest: Bool = false,
                                  account: any WebDAVAccount) throws -> URLRequest {
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
        
        if let contentType = contentType {
            request.contentType = contentType
        }
        
        if let accept = accept {
            request.accept = accept
        }
        
        if ocsApiRequest && account.serverType.isOwncloud {
            request.setValue("true", forHTTPHeaderField: "OCS-APIRequest")
        }
        
        return request
    }

    /// Creates a request with the given parameters and authorizes it with the given account.
    /// - Parameters: method: The http method to use for the request.
    /// - Parameters: filePath: The path of the file the request is for. Can either be absolute or relative to the account's serverFilesPath.
    /// - Parameters: query: The query parameters to use for the request.
    /// - Parameters: headers: The headers to add to the request.
    /// - Parameters: contentType: The content type to set for the request (sets content-type header).
    /// - Parameters: accept: The accept types to set for the request (sets accept header).
    /// - Parameters: ocsApiRequest: If true, the OCS-APIRequest header is set to true. Used for Owncloud/Nextcloud requests.
    /// - Parameters: account: The account to authorize the request with.
    public func authorizedRequest(method: WebDAVMethod, filePath: any WebDAVPathProtocol, 
                                  query: [String: String]? = nil, headers: [String: String]? = nil,
                                  contentType: MimeType? = nil, accept: [MimeType]? = nil,
                                  ocsApiRequest: Bool = false,
                                  account: any WebDAVAccount) throws -> URLRequest {
        
        try self.authorizedRequest(method: method, path: try AbsoluteWebDAVPath(filePath: filePath, account: account),
                                   query: query, headers: headers,
                                   contentType: contentType, accept: accept,
                                   account: account)
    }
    
}

