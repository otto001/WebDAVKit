//
//  NextcloudShareOptions.swift
//  WebDAVKit
//
//  Created by Matteo Ludwig on 08.12.23.
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


public struct NextcloudShareOptions {
    public let shareType: NextcloudShareType
    public let shareWith: NextcloudUserId?
    public let permissions: NextcloudPermissions
    public let allowUploadsByPublic: Bool?
    public let hideDownload: Bool?
    public let password: WebDAVSecret?
    
    public var note: String?
    
    private init(shareType: NextcloudShareType, shareWith: NextcloudUserId?, permissions: NextcloudPermissions,
                 allowUploadsByPublic: Bool?, hideDownload: Bool?,
                 password: WebDAVSecret?) {
        self.shareType = shareType
        self.shareWith = shareWith
        self.permissions = permissions
        self.allowUploadsByPublic = allowUploadsByPublic
        self.hideDownload = hideDownload
        self.password = password
    }
    
    public static func user(userId: NextcloudUserId, permissions: NextcloudPermissions, hideDownload: Bool? = nil) -> Self {
        .init(shareType: .user, shareWith: userId, permissions: permissions,
              allowUploadsByPublic: false, hideDownload: hideDownload,
              password: nil)
    }
    
    public static func group(groupId: NextcloudUserId, permissions: NextcloudPermissions, hideDownload: Bool? = nil) -> Self {
        .init(shareType: .group, shareWith: groupId, permissions: permissions,
              allowUploadsByPublic: false, hideDownload: hideDownload,
              password: nil)
    }
    
    public static func `public`(permissions: NextcloudPermissions, allowUploads: Bool? = nil, hideDownload: Bool? = nil, password: WebDAVSecret?) -> Self {
        .init(shareType: .public, shareWith: nil, permissions: permissions,
              allowUploadsByPublic: allowUploads, hideDownload: hideDownload,
              password: password)
    }
    
    internal func parameterDict() -> [String: Any] {
        var parameters: [String: Any] = [
            "shareType": shareType.rawValue,
            "permissions": String(permissions.rawValue),
        ]
        
        if let hideDownload = hideDownload {
            parameters["hideDownload"] = hideDownload ? "true" : "false"
        }
        
        if let shareWith = shareWith {
            parameters["shareWith"] = shareWith
        }
        
        if shareType == .public {
            if let allowUploadsByPublic = allowUploadsByPublic {
                parameters["publicUpload"] = allowUploadsByPublic ? "true" : "false"
            }
           
            if let password = password {
                parameters["password"] = password.inner
            }
        }
        
        if let note = note {
            parameters["note"] = note
        }
        
        return parameters
    }
}
