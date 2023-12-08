//
//  OwncloudShare.swift
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

public enum OwncloudShareType: Int {
    case user = 0
    case group = 1
    case `public` = 3
}

public typealias OwncloudUserID = String

public struct OwncloudShare {
    
    public var account: any WebDAVAccount
    
    public var id: String
    public var shareType: OwncloudShareType
    
    public var path: WebDAVPath
    public var itemType: String
    public var mimeType: MimeType
    
    public var permissions: OwncloudPermissions
    public var canEdit: Bool = false
    public var canDelete: Bool = false
    
    public var uidOwner: OwncloudUserID
    public var displaynameOwner: String
    
    public var uidFileOwner: OwncloudUserID
    public var displaynameFileOwner: String
    
    public var shareWith: String?
    public var shareWithDisplayname: String?
    
    public var timestamp: Date?
    public var expirationDate: Date?
    
    public var hideDownload: Bool?
    
    public var shareLink: String?
    public var token: String?
    
    public var label: String?
    public var note: String?
    
    public var parent: String?
    
    public var hasPreview: Bool = false
    
    public var storageId: String?
    public var storage: Int?
    
    public var itemSource: Int?
    public var fileSource: Int?
    public var fileParent: Int?
    public var fileTarget: String?

    public var password: WebDAVSecret?
    public var sendPasswordByTalk: Bool?
    public var mailSend: Bool?

    public var attributes: String?
    
    public init(from json: JSON, account: any WebDAVAccount) throws {
        self.account = account
        
        self.id = try json["id"].string.requiredField()
        self.shareType = try json["share_type"].ocsInt.flatMap { .init(rawValue: $0) }.requiredField()
        
        self.path = try json["path"].string.flatMap { .init($0) }.requiredField()
        self.itemType = try json["item_type"].string.requiredField()
        self.mimeType = try json["mimetype"].string.flatMap { MimeType(rawValue: $0) }.requiredField()
        
        self.permissions = try json["permissions"].ocsInt.flatMap { .init(rawValue: $0) }.requiredField()
        self.canDelete = json["can_delete"].boolValue
        self.canEdit = json["can_edit"].boolValue
        
        self.uidOwner = try json["uid_owner"].stringValue.nilIfEmtpy.requiredField()
        self.displaynameOwner = try json["displayname_owner"].stringValue.nilIfEmtpy.requiredField()
        
        self.uidFileOwner = try json["uid_file_owner"].stringValue.nilIfEmtpy.requiredField()
        self.displaynameFileOwner = try json["displayname_file_owner"].stringValue.nilIfEmtpy.requiredField()
        
        self.shareWith = json["share_with"].stringValue.nilIfEmtpy
        self.shareWithDisplayname = json["share_with_displayname"].stringValue.nilIfEmtpy
        
        self.timestamp = json["stime"].double.flatMap { Date(timeIntervalSince1970: $0) }
        self.expirationDate = json["expiration"].string.flatMap { DateFormatter.nextcloud.date(from: $0) }

        self.hideDownload = json["hide_download"].boolValue
        
        self.shareLink = json["url"].string
        self.token = json["token"].string
        
        self.label = json["label"].string
        self.note = json["note"].string
        
        self.parent = json["parent"].string
        
        self.hasPreview = json["has_preview"].boolValue
        
        self.storageId = json["storage_id"].string
        self.storage = json["storage"].ocsInt
        
        
        self.itemSource = json["item_source"].ocsInt
        self.fileSource = json["file_source"].ocsInt
        self.fileTarget = json["file_target"].stringValue
        self.fileParent = json["file_parent"].ocsInt
        
        self.password = json["password"].string.map {.init($0) }
        self.sendPasswordByTalk = json["send_password_by_talk"].boolValue
        
        self.mailSend = json["mail_send"].boolValue
        
        self.attributes = json["attributes"].string
    }
    
}

private extension Optional {
    func requiredField() throws -> Wrapped {
        try unwrapOrFail(with: WebDAVError.malformedResponseBody)
    }
}

extension JSON {
    var ocsInt: Int? {
        switch type {
        case .string:
            let decimal = NSDecimalNumber(string: object as? String)
            return decimal == .notANumber ? nil : decimal.intValue
        case .number: return (object as? NSNumber)?.intValue
        default: return nil
        }
    }
}
