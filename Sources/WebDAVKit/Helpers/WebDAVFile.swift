//
//  WebDAVFile.swift
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
import SWXMLHash

public struct WebDAVFile: Codable, Equatable, Hashable {
    

    public private(set) var path: RelativeWebDAVPath
    public private(set) var fileId: String?
    
    public private(set) var etag: String
    public private(set) var lastModified: Date
    
    public private(set) var size: Int
    public private(set) var contentType: MimeType?
    
    public private(set) var hasPreview: Bool?
    
    public var isDirectory: Bool {
        self.contentType == nil
    }
    
    public init(path: RelativeWebDAVPath, fileId: String?, lastModified: Date, size: Int, etag: String, contentType: MimeType?, hasPreview: Bool?) {
        self.path = path
        self.fileId = fileId
        self.lastModified = lastModified
        self.size = size
        self.etag = etag
        self.contentType = contentType
        self.hasPreview = hasPreview
    }
    
    init?(xml: XMLIndexer, basePath: AbsoluteWebDAVPath) {
        let properties = xml["propstat"][0]["prop"]
        guard var pathString = xml["href"].element?.text,
              let dateString = properties["getlastmodified"].element?.text,
              let date = WebDAVFile.rfc1123Formatter.date(from: dateString),
              let sizeString = properties["size"].element?.text,
              let size = Int(sizeString),
              let etag = properties["getetag"].element?.text.replacingOccurrences(of: "\"", with: "")  else { return nil }
        
        let contentTypeString = properties["getcontenttype"].element?.text
        let contentType: MimeType? = contentTypeString.flatMap { .init($0) }
        
        if contentTypeString != nil && contentType == nil {
            // Malformed content type
            return nil
        }
        
        let fileId = properties["fileid"].element?.text
        
        let hasPreview: Bool? = (properties["has-preview"].element?.text).map { $0 == "true" }
        
        if let decodedPath = pathString.removingPercentEncoding {
            pathString = decodedPath
        }
        
        guard let webDAVPath = try? AbsoluteWebDAVPath(hostname: basePath.hostname, path: .init(pathString)).relative(to: basePath) else {
            return nil
        }

        self.init(path: webDAVPath, 
                  fileId: fileId,
                  lastModified: date, 
                  size: size,
                  etag: etag, 
                  contentType: contentType,
                  hasPreview: hasPreview)
    }
    
    //MARK: Static
    
    static let rfc1123Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    //MARK: Public
    
    public var description: String {
        "WebDAVFile(path: \(path), id: \(fileId ?? "nil"), isDirectory: \(isDirectory), lastModified: \(WebDAVFile.rfc1123Formatter.string(from: lastModified)), size: \(size), etag: \(etag))"
    }
    
    public static func sortedFiles(_ files: [WebDAVFile], foldersFirst: Bool, dropFirst: Bool) -> [WebDAVFile] {
        var files = files
        if dropFirst && !files.isEmpty {
            files.removeFirst()
        }
        if foldersFirst {
            files = files.filter { $0.isDirectory } + files.filter { !$0.isDirectory }
        }
        return files
    }
    
    public static func propfindProps(hasPreview: Bool) -> String {
        let props = """
<d:getlastmodified />
<d:getetag />
<d:getcontenttype />
<oc:fileid />
<oc:permissions />
<oc:size />
\(hasPreview ? "<nc:has-preview />" : "")
<oc:favorite />
"""
        
        return props
    }
}
