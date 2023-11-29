//
//  WebDAVSession+Nextcloud.swift
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
import Combine


extension WebDAVSession {
    private func nextcloudPreviewRequest(with previewOptions: PreviewOptions, fileId: String?, filePath: (any WebDAVPathProtocol)?, account: any WebDAVAccount) throws -> URLRequest {
        
        var urlComponents = try account.nextcloudPreviewPath.urlComponents
        urlComponents.queryItems = []
        
        if let size = previewOptions.size {
            urlComponents.queryItems!.append(URLQueryItem(name: "x", value: "\(size.width)"))
            urlComponents.queryItems!.append(URLQueryItem(name: "y", value: "\(size.height)"))
        }
        
        if previewOptions.contentMode == .fill {
            urlComponents.queryItems!.append(URLQueryItem(name: "a", value: "1"))
            urlComponents.queryItems!.append(URLQueryItem(name: "mode", value: "cover"))
        }
        
        if let fileId = fileId {
            urlComponents.queryItems!.append(URLQueryItem(name: "fileId", value: fileId))
        } else if let filePath = filePath {
            let absolutePath = try AbsoluteWebDAVPath(filePath, account: account)
            urlComponents.queryItems!.append(URLQueryItem(name: "file", value: absolutePath.path.stringRepresentation))
        }
        
        guard let url = urlComponents.url else {
            throw WebDAVError.urlBuildingError
        }
        
        var request = URLRequest(url: url)
        try self.authorizeRequest(request: &request, account: account)
        
        return request
    }
    
    public func preview(fileId: String, with previewOptions: PreviewOptions = .default, account: any WebDAVAccount) async throws -> Data {
        return try await self.data(request: try self.nextcloudPreviewRequest(with: previewOptions, fileId: fileId, filePath: nil, account: account)).0
    }
    
    public func preview(filePath: any WebDAVPathProtocol, with previewOptions: PreviewOptions = .default, account: any WebDAVAccount) async throws -> Data {
        return try await self.data(request: try self.nextcloudPreviewRequest(with: previewOptions, fileId: nil, filePath: filePath, account: account)).0
    }
}
