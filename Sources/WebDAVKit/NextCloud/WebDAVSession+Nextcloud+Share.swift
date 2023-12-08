//
//  WebDAVSession+Nextcloud+Preview.swift
//  WebDAVKit
//
//  Created by Matteo Ludwig on 05.12.23.
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
import SwiftyJSON


extension WebDAVSession {
    
    public func nextcloudShareLink(path: any WebDAVPathProtocol,
                            options: NextcloudShareOptions,
                            account: any WebDAVAccount) async throws -> NextcloudShare {
        guard account.serverType == .nextcloud else {
            throw WebDAVError.unsupported
        }
        
        var request = try self.authorizedRequest(method: .post,
                                             path: AbsoluteWebDAVPath(hostname: account.hostname, path: "/ocs/v2.php/apps/files_sharing/api/v1/shares"),
                                             account: account)

        
        let absolutePath = try AbsoluteWebDAVPath(filePath: path, account: account)
        
        var parameters = options.parameterDict()
        parameters["path"] = try absolutePath.relative(to: account.serverFilesPath).relativePath.stringRepresentation
        parameters["attributes"] = "[]"
        
        request.httpBody = try JSON(parameters).rawData()
        
        request.setValue("true", forHTTPHeaderField: "OCS-APIRequest")
        
        request.contentType = .applicationJson
        request.accept = [.applicationJson]
        
        let (responseData, _) = try await self.data(request: request)
        
        return try NextcloudShare(from: JSON(responseData)["ocs"]["data"], account: account)
    }
}
