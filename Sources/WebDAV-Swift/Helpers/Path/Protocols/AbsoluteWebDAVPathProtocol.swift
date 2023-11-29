//
//  AbsoluteWebDAVPathProtocol.swift
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


public protocol AbsoluteWebDAVPathProtocol: WebDAVPathProtocol, Equatable {
    var hostname: String { get }
    var path: WebDAVPath { get }
    
    var urlComponents: URLComponents { get }
    var url: URL { get throws }
    
    var fileName: String? { get }
    var fileExtension: String? { get }
    
    func isSubpath(of other: any AbsoluteWebDAVPathProtocol) -> Bool
    func relative(to subPath: any AbsoluteWebDAVPathProtocol) throws -> RelativeWebDAVPath
}


public extension AbsoluteWebDAVPathProtocol {
    var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = hostname
        components.path = path.stringRepresentation
        return components
    }
    
    var url: URL {
        get throws {
            guard let url = urlComponents.url else {
                throw WebDAVError.urlBuildingError
            }
            return url
        }
    }
    
    var stringRepresentation: String {
        "\(hostname)\(path.stringRepresentation)"
    }
    
    var pathComponents: [String] {
        path.pathComponents
    }
    
    var fileName: String? {
        guard let lastPathComponent = self.lastPathComponent else { return nil }

        let filenameEndIdx = lastPathComponent.firstIndex(of: ".") ?? lastPathComponent.endIndex

        return String(lastPathComponent[..<filenameEndIdx])
    }

    var fileExtension: String? {
        guard let lastPathComponent = self.lastPathComponent else { return nil }
        if let dotIdx = lastPathComponent.firstIndex(of: ".") {
            let extensionStartIdx = lastPathComponent.index(dotIdx, offsetBy: 1)
            guard extensionStartIdx != lastPathComponent.endIndex else { return nil }
            return String(lastPathComponent[extensionStartIdx...])
        }
        return nil
    }
    
    func isSubpath(of other: any AbsoluteWebDAVPathProtocol) -> Bool {
        guard self.hostname == other.hostname else { return false }
        
        let ownPathComponents = self.pathComponents
        let otherPathComponents = other.pathComponents
        guard ownPathComponents.count <= otherPathComponents.count else { return false }
        
        return ownPathComponents.enumerated().allSatisfy { $0.element == otherPathComponents[$0.offset] }
    }
    
    func relative(to subPath: any AbsoluteWebDAVPathProtocol) throws -> RelativeWebDAVPath {
        guard self.hostname == subPath.hostname else {
            throw WebDAVError.pathsNotRelated
        }
        
        let pathComponents = self.pathComponents
        let subPathComponents = subPath.pathComponents
        
        guard pathComponents.count >= subPathComponents.count else {
            throw WebDAVError.pathsNotRelated
        }
        
        guard subPathComponents.enumerated().allSatisfy({ $0.element == pathComponents[$0.offset] }) else {
            throw WebDAVError.pathsNotRelated
        }
        
        let relativePath = pathComponents[subPathComponents.count...].joined(separator: "/")
        
        return RelativeWebDAVPath(relativePath: .init(relativePath), relativeTo: subPath)
    }
}
