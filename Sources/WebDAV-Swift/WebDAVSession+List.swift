//
//  WebDAVSession+List.swift
//  WebDAV-Swift
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

extension WebDAVSession {
    
    private func getFilesFromResponse(response: URLResponse, data: Data, basePath: AbsoluteWebDAVPath, foldersFirst: Bool = true, dropFirst: Bool = false) throws -> [WebDAVFile] {
        try WebDAVError.checkForError(response: response)
        
        guard let string = String(data: data, encoding: .utf8) else {
            throw WebDAVError.other
        }
        
        let xml = XMLHash.config { config in
            config.shouldProcessNamespaces = true
        }.parse(string)
        
        let files = xml["multistatus"]["response"].all.compactMap { WebDAVFile(xml: $0, basePath: basePath) }
        
        let sortedFiles = WebDAVFile.sortedFiles(files, foldersFirst: foldersFirst, dropFirst: dropFirst)
        
        return sortedFiles
    }
    
    public func listFiles(at path: any WebDAVPathProtocol, headers: [String: String]? = nil, query: [String: String]? = nil, foldersFirst: Bool = false, dropFirst: Bool = false, depth: WebDAVListDepth? = nil, checkHasPreview: Bool = true, account: any WebDAVAccount) async throws -> [WebDAVFile] {
        let absolutePath = try AbsoluteWebDAVPath(path, account: account)
        
        var request = try self.authorizedRequest(method: .propfind, path: path, query: query, headers: headers, account: account)
        
        if let depth = depth {
            request.addValue(depth.rawValue, forHTTPHeaderField: "Depth")
        }
        
        let body =
"""
<?xml version="1.0"?>
<d:propfind  xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns" xmlns:nc="http://nextcloud.org/ns">
    <d:prop>
        \(WebDAVFile.propfindProps(hasPreview: checkHasPreview))
    </d:prop>
</d:propfind>
"""
        
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await self.urlSession.data(for: request)
        return try self.getFilesFromResponse(response: response, data: data, basePath: absolutePath,
                                             foldersFirst: foldersFirst, dropFirst: dropFirst)
    }
    
    public func filterFiles(at path: any WebDAVPathProtocol, headers: [String: String]? = nil, query: [String: String]? = nil, foldersFirst: Bool = true, checkHasPreview: Bool = true, favorites: Bool? = nil, account: any WebDAVAccount) async throws -> [WebDAVFile] {
        let absolutePath = try AbsoluteWebDAVPath(path, account: account)
        
        var request = try self.authorizedRequest(method: .report, path: path, query: query, headers: headers, account: account)
        
        var rules = [String]()
        if let favorites = favorites {
            rules.append("<oc:favorite>\(favorites ? 1 : 0)</oc:favorite>")
        }
        let rulesString = rules.joined(separator: "\n")
        
        let body =
"""
<oc:filter-files  xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns" xmlns:nc="http://nextcloud.org/ns" xmlns:ocs="http://open-collaboration-services.org/ns">
    <d:prop>
        \(WebDAVFile.propfindProps(hasPreview: checkHasPreview))
    </d:prop>
    <oc:filter-rules>
        \(rulesString)
    </oc:filter-rules>
</oc:filter-files>
"""
        
        request.httpBody = body.data(using: .utf8)
        let (data, response) = try await self.urlSession.data(for: request)
        
        return try self.getFilesFromResponse(response: response, data: data, 
                                             basePath: absolutePath,
                                             foldersFirst: foldersFirst)
        
    }
    

}
