//
//  WebDAVFilePropertyKey.swift
//  WebDAVKit
//
//  Created by Matteo Ludwig on 11.12.23.
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



private let _lastModified: WebDAVFilePropertyKey<Date> = .init(xmlKey: "d:getlastmodified") {
    DateFormatter.rfc1123.date(from: $0)
}

private let _etag: WebDAVFilePropertyKey<String> = .init(xmlKey: "d:getetag")
private let _contentType: WebDAVFilePropertyKey<MimeType> = .init(xmlKey: "d:getcontenttype")
private let _resourcetype: WebDAVFilePropertyKey<String> = .init(xmlKey: "d:resourcetype")
private let _contentLength: WebDAVFilePropertyKey<Int> = .init(xmlKey: "d:getcontentlength")

private let _ownCloudId: WebDAVFilePropertyKey<String> = .init(xmlKey: "oc:id")
private let _ownCloudFileId: WebDAVFilePropertyKey<String> = .init(xmlKey: "oc:fileid")
private let _ownCloudFavorite: WebDAVFilePropertyKey<Bool> = .init(xmlKey: "oc:favorite")
private let _ownCloudOwnerId: WebDAVFilePropertyKey<String> = .init(xmlKey: "oc:owner-id")
private let _ownCloudOwnerDisplayName: WebDAVFilePropertyKey<String> = .init(xmlKey: "oc:owner-display-name")
private let _ownCloudPermissions: WebDAVFilePropertyKey<String> = .init(xmlKey: "oc:permissions")
private let _ownCloudSize: WebDAVFilePropertyKey<Int> = .init(xmlKey: "oc:size")

private let _nextcloudHasPreview: WebDAVFilePropertyKey<Bool> = .init(xmlKey: "nc:has-preview")
private let _nextcloudLivePhotoFile: WebDAVFilePropertyKey<String> = .init(xmlKey: "nc:metadata-files-live-photo")


public struct WebDAVFilePropertyKey<T> {
    public let xmlKey: String
    public let convert: @Sendable (_ text: String) -> T?
    
    public init(xmlKey: String, convert: @Sendable @escaping (_: String) -> T?) {
        self.xmlKey = xmlKey
        self.convert = convert
    }
}

extension WebDAVFilePropertyKey: Sendable where T: Sendable {
    
}

extension WebDAVFilePropertyKey where T == String {
    public init(xmlKey: String) {
        self.init(xmlKey: xmlKey) { $0 }
    }
}

extension WebDAVFilePropertyKey where T == Int {
    public init(xmlKey: String) {
        self.init(xmlKey: xmlKey) { Int($0) }
    }
}

extension WebDAVFilePropertyKey where T == Bool {
    public init(xmlKey: String) {
        self.init(xmlKey: xmlKey) { $0 == "true" }
    }
}

extension WebDAVFilePropertyKey where T == MimeType {
    public init(xmlKey: String) {
        self.init(xmlKey: xmlKey) { MimeType($0) }
    }
}

extension WebDAVFilePropertyKey where T == Date {
    public static var lastModified: WebDAVFilePropertyKey { _lastModified }
}

extension WebDAVFilePropertyKey where T == MimeType {
    public static var contentType: WebDAVFilePropertyKey { _contentType }
}

extension WebDAVFilePropertyKey where T == Int {
    public static var contentLength: WebDAVFilePropertyKey { _contentLength }
    public static var ownCloudSize: WebDAVFilePropertyKey { _ownCloudSize }
}


extension WebDAVFilePropertyKey where T == Bool {
    public static var ownCloudFavorite: WebDAVFilePropertyKey { _ownCloudFavorite }
    public static var nextcloudHasPreview: WebDAVFilePropertyKey { _nextcloudHasPreview }
}


extension WebDAVFilePropertyKey where T == String {
    public static var etag: WebDAVFilePropertyKey { _etag }
    public static var resourcetype: WebDAVFilePropertyKey { _resourcetype }
    
    public static var ownCloudId: WebDAVFilePropertyKey { _ownCloudId }
    public static var ownCloudFileId: WebDAVFilePropertyKey { _ownCloudFileId }
    public static var ownCloudOwnerId: WebDAVFilePropertyKey { _ownCloudOwnerId }
    public static var ownCloudOwnerDisplayName: WebDAVFilePropertyKey { _ownCloudOwnerDisplayName }
    public static var ownCloudPermissions: WebDAVFilePropertyKey { _ownCloudPermissions }
    
    public static var nextcloudLivePhotoFile: WebDAVFilePropertyKey { _nextcloudLivePhotoFile }
}


public struct WebDAVFilePropertyFetchKey: Hashable, Equatable {
    public let xmlKey: String
    public let convert: @Sendable (_ text: String) -> Any?
    
    private init(xmlKey: String, convert: @Sendable @escaping (_: String) -> Any?) {
        self.xmlKey = xmlKey
        self.convert = convert
    }
    
    public init<T>(_ key: WebDAVFilePropertyKey<T>) {
        self.init(xmlKey: key.xmlKey, convert: key.convert)
    }
    
    public static func == (lhs: WebDAVFilePropertyFetchKey, rhs: WebDAVFilePropertyFetchKey) -> Bool {
        lhs.xmlKey == rhs.xmlKey
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(xmlKey)
    }
    
}

extension WebDAVFilePropertyFetchKey: Sendable {
    
}

extension WebDAVFilePropertyFetchKey {
    
    public static let lastModified: WebDAVFilePropertyFetchKey = .init(.lastModified)
    public static let etag: WebDAVFilePropertyFetchKey = .init(.etag)
    public static let contentType: WebDAVFilePropertyFetchKey = .init(.contentType)
    public static let resourcetype: WebDAVFilePropertyFetchKey = .init(.resourcetype)
    public static let contentLength: WebDAVFilePropertyFetchKey = .init(.contentLength)
    
    /// The fileid namespaced by the instance id, globally unique
    public static let ownCloudId: WebDAVFilePropertyFetchKey = .init(.ownCloudId)
    public static let ownCloudFileId: WebDAVFilePropertyFetchKey = .init(.ownCloudFileId)
    public static let ownCloudFavorite: WebDAVFilePropertyFetchKey = .init(.ownCloudFavorite)
    public static let ownCloudOwnerId: WebDAVFilePropertyFetchKey = .init(.ownCloudOwnerId)
    public static let ownCloudOwnerDisplayName: WebDAVFilePropertyFetchKey = .init(.ownCloudOwnerDisplayName)
    public static let ownCloudPermissions: WebDAVFilePropertyFetchKey = .init(.ownCloudPermissions)
    /// Unlike getcontentlength, this property also works for folders reporting the size of everything in the folder.
    public static let ownCloudSize: WebDAVFilePropertyFetchKey = .init(.ownCloudSize)
    
    public static let nextcloudHasPreview: WebDAVFilePropertyFetchKey = .init(.nextcloudHasPreview)
    public static let nextcloudLivePhotoFile: WebDAVFilePropertyFetchKey = .init(.nextcloudLivePhotoFile)
}

