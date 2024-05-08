//
//  WebDAVSession+OwnCloud.swift
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
import SwiftyJSON


extension WebDAVSession {

    public func owncloudSetFavorite(for path: any WebDAVPathProtocol, favorite: Bool, account: any WebDAVAccount) async throws {
        guard account.serverType.isOwncloud else {
            throw WebDAVError.unsupported
        }
        var request = try self.authorizedRequest(method: .proppatch, filePath: path, account: account)
        
        let body =
"""
<?xml version="1.0"?>
<d:propertyupdate xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns">
  <d:set>
    <d:prop>
      <oc:favorite>\(favorite)</oc:favorite>
    </d:prop>
  </d:set>
</d:propertyupdate>
"""
        
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await self.urlSession.data(for: request)

        try WebDAVError.checkForError(response: response, data: data)
    }
    
    public func owncloudDirectLink(fileId: String, account: any WebDAVAccount) async throws -> URL {
        guard account.serverType.isOwncloud else {
            throw WebDAVError.unsupported
        }
        var request = try self.authorizedRequest(method: .post, path: AbsoluteWebDAVPath(hostname: account.hostname, path:  "/ocs/v2.php/apps/dav/api/v1/direct"), contentType: .applicationJson, accept: [.applicationJson], account: account)
       
        let parameters = ["fileId": fileId]
        request.httpBody = try JSON(parameters).rawData()
        
        let (responseData, response) = try await self.urlSession.data(for: request)
        try WebDAVError.checkForError(response: response, data: responseData)
        
        guard let urlString = (JSON(responseData)["ocs"]["data"]["url"]).string, let url = URL(string: urlString) else {
            throw WebDAVError.malformedResponseBody
        }
        
        return url
    }
}
