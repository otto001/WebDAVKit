//
//  WebDAVSession+List.swift
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
import SWXMLHash

extension WebDAVSession {
    
    private func getFilesFromResponse(response: URLResponse, data: Data, 
                                      basePath: AbsoluteWebDAVPath,
                                      properties: [WebDAVFilePropertyFetchKey]) throws -> [WebDAVFile] {
        try WebDAVError.checkForError(response: response, data: data)
        
        guard let string = String(data: data, encoding: .utf8) else {
            throw WebDAVError.malformedResponseBody
        }
        
        let xml = XMLHash.parse(string)
        
        let files = xml["d:multistatus"]["d:response"].all.compactMap { WebDAVFile(xml: $0, properties: properties, basePath: basePath) }
        
        return files
    }
    
    public func listFiles(at path: any WebDAVPathProtocol, 
                          properties: [WebDAVFilePropertyFetchKey],
                          depth: WebDAVListDepth? = nil,
                          headers: [String: String]? = nil, query: [String: String]? = nil,
                          account: any WebDAVAccount) async throws -> [WebDAVFile] {
        let absolutePath = try AbsoluteWebDAVPath(filePath: path, account: account)
        
        var request = try self.authorizedRequest(method: .propfind, filePath: path, query: query, headers: headers, account: account)
        
        if let depth = depth {
            request.addValue(depth.rawValue, forHTTPHeaderField: "Depth")
        }
        
        let propertiesString = properties.map {"<\($0.xmlKey) />"}.joined(separator: "\n")
        
        let body =
"""
<?xml version="1.0"?>
<d:propfind  xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns" xmlns:nc="http://nextcloud.org/ns">
    <d:prop>
        \(propertiesString)
    </d:prop>
</d:propfind>
"""
        
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await self.urlSession.data(for: request)
        return try self.getFilesFromResponse(response: response, data: data, basePath: absolutePath, properties: properties)
    }
    
    public func filterFiles(at path: any WebDAVPathProtocol,
                            properties: [WebDAVFilePropertyFetchKey],
                            favorites: Bool? = nil,
                            headers: [String: String]? = nil, query: [String: String]? = nil,
                            account: any WebDAVAccount) async throws -> [WebDAVFile] {
        let absolutePath = try AbsoluteWebDAVPath(filePath: path, account: account)
        
        var request = try self.authorizedRequest(method: .report, filePath: path, query: query, headers: headers, account: account)
        
        var rules = [String]()
        if let favorites = favorites {
            rules.append("<oc:favorite>\(favorites ? 1 : 0)</oc:favorite>")
        }
        let rulesString = rules.joined(separator: "\n")
        
        let propertiesString = properties.map {"<\($0.xmlKey) />"}.joined(separator: "\n")
        
        let body =
"""
<oc:filter-files  xmlns:d="DAV:" xmlns:oc="http://owncloud.org/ns" xmlns:nc="http://nextcloud.org/ns" xmlns:ocs="http://open-collaboration-services.org/ns">
    <d:prop>
        \(propertiesString)
    </d:prop>
    <oc:filter-rules>
        \(rulesString)
    </oc:filter-rules>
</oc:filter-files>
"""
        
        request.httpBody = body.data(using: .utf8)
        let (data, response) = try await self.urlSession.data(for: request)
        
        return try self.getFilesFromResponse(response: response, data: data, basePath: absolutePath, properties: properties)
        
    }
    

}
