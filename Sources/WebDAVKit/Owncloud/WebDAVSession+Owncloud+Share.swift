//
//  WebDAVSession+Owncloud+Preview.swift
//  WebDAVKit
//
//  Created by Matteo Ludwig on 05.12.23.
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
import SwiftyJSON


// https://doc.owncloud.com/server/next/developer_manual/core/apis/ocs-share-api.html

private var shareApiPath: WebDAVPath = "/ocs/v2.php/apps/files_sharing/api/v1/shares"

extension WebDAVSession {
    /// Fetches the shares of the given account.
    /// - Parameters: path: The path to fetch the shares for. If nil, all shares are fetched regardless of the path.
    /// - Parameters: sharedWithMe: If true, only shares that are shared with the account are fetched.
    /// - Parameters: reshares: If true, also include shares that are not directly shared with the account.
    /// - Parameters: subfiles: If true, also include shares of subfiles.
    /// - Parameters: account: The account to fetch the shares for.
    public func owncloudShares(for path: (any WebDAVPathProtocol)?, sharedWithMe: Bool, reshares: Bool, subfiles: Bool = false, account: any WebDAVAccount) async throws -> [OwncloudShare] {
        
        guard account.serverType.isOwncloud else {
            throw WebDAVError.unsupported
        }
        
        var query: [String: String] = [
            "format": "json"
        ]
        
        if sharedWithMe {
            query["shared_with_me"] = "true"
        }
        if reshares {
            query["reshares"] = "true"
        }
        
        if let path = path {
            query["path"] = try AbsoluteWebDAVPath(filePath: path, account: account)
                .relative(to: account.serverFilesPath).relativePath.stringRepresentation
        }
        
        let request = try self.authorizedRequest(method: .get,
                                                 path: AbsoluteWebDAVPath(hostname: account.hostname,
                                                                          path: shareApiPath),
                                                 query: query,
                                                 contentType: .applicationJson, accept: [.applicationJson],
                                                 ocsApiRequest: true,
                                                 account: account)
        
        let (responseData, _) = try await self.data(request: request)
        
        guard let resultJson = JSON(responseData)["ocs"]["data"].array else {
            throw WebDAVError.malformedResponseBody
        }
        
        return try resultJson.map { try OwncloudShare(from: $0, account: account) }
    }
    
    public func owncloudCreateShare(path: any WebDAVPathProtocol,
                                    options: OwncloudShareOptions,
                                    account: any WebDAVAccount) async throws -> OwncloudShare {
        
        guard account.serverType.isOwncloud else {
            throw WebDAVError.unsupported
        }
        
        var request = try self.authorizedRequest(method: .post,
                                                 path: AbsoluteWebDAVPath(hostname: account.hostname,
                                                                          path: shareApiPath),
                                                 contentType: .applicationJson, accept: [.applicationJson],
                                                 ocsApiRequest: true,
                                                 account: account)
        
        
        let absolutePath = try AbsoluteWebDAVPath(filePath: path, account: account)
        
        var parameters = options.parameterDict()
        parameters["path"] = try absolutePath.relative(to: account.serverFilesPath).relativePath.stringRepresentation
        parameters["attributes"] = "[]"
        
        request.httpBody = try JSON(parameters).rawData()
        
        let (responseData, _) = try await self.data(request: request)
        
        return try OwncloudShare(from: JSON(responseData)["ocs"]["data"], account: account)
    }
    
    public func owncloudDeleteShare(shareId: String, account: any WebDAVAccount) async throws {
        guard account.serverType.isOwncloud else {
            throw WebDAVError.unsupported
        }
        
        let request = try self.authorizedRequest(method: .delete,
                                                 path: AbsoluteWebDAVPath(hostname: account.hostname,
                                                                          path: shareApiPath.appending(shareId)),
                                                 ocsApiRequest: true,
                                                 account: account)
        
        _ = try await self.data(request: request)
        
    }
}
