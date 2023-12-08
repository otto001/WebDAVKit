//
//  WebDAVSession+OwnCloud.swift
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
//    func ownCloudBaseURL(for baseURL: URL) -> URL? {
//        guard baseURL.absoluteString.lowercased().contains("remote.php/dav/files/"),
//              let index = baseURL.pathComponents.map({ $0.lowercased() }).firstIndex(of: "remote.php") else {
//                  return nil
//              }
//        
//        var result = baseURL
//        for _ in 0 ..< baseURL.pathComponents.count - index {
//            result.deleteLastPathComponent()
//        }
//        
//        return result
//            .appendingPathComponent("apps/files/api/v1/files")
//    }
//    
//    func ownCloudURL(for path: WebDAVPath, account: any WebDAVAccount) -> URL? {
//        return self.ownCloudBaseURL(for: account.path.url)?.appendingPathComponent("path")
//    }
//    
    public func setIsFavorite(for path: any WebDAVPathProtocol, favorite: Bool, account: any WebDAVAccount) async throws {
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
        
        let (_, response) = try await self.urlSession.data(for: request)

        if let response = response as? HTTPURLResponse, !(200...299 ~= response.statusCode) {
            throw URLError(URLError.Code(rawValue: response.statusCode))
        }
    }
}
