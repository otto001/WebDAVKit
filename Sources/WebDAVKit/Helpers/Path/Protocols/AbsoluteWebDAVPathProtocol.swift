//
//  AbsoluteWebDAVPathProtocol.swift
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

/// A protocol that represents the absolute path of a file or directory in a WebDAV server, including the hostname of the server.
public protocol AbsoluteWebDAVPathProtocol: WebDAVPathProtocol, Equatable {
    /// The hostname of the server.
    var hostname: String { get }
    /// The path of the file or directory on the server.
    var path: WebDAVPath { get }
    
    /// The path converted to an URLComponents object.
    var urlComponents: URLComponents { get }
    /// The path converted to an URL.
    var url: URL { get throws }
    
    /// The name of the file or directory. Equal to the last path component without the file extension.
    var fileName: String? { get }
    /// The file extension of the file or directory. Equal to the last path component without the file name. Does not include the first leading `.`.
    var fileExtension: String? { get }
    
    /// Returns whether the path itself is a subpath of the given path.
    /// - Parameters: superPath: The path to check.
    /// - Returns: Whether the path is a subpath of the given path.
    func isSubpath(of superPath: any AbsoluteWebDAVPathProtocol) -> Bool

    /// Returns whether the given path is a subpath of the path itself.
    /// - Parameters: subPath: The path to check.
    /// - Returns: Whether the given path is a subpath of self.
    func isSuperpath(of subPath: any AbsoluteWebDAVPathProtocol) -> Bool

    /// Returns a relative path to the given path.
    /// - Parameters: subPath: The path to return a relative path to.
    /// - Returns: The relative path.
    /// - Throws: `WebDAVError.pathsNotRelated` if the given path is not a subpath of the path.
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

        var filenameEndIdx = lastPathComponent.firstIndex(of: ".") ?? lastPathComponent.endIndex
        if filenameEndIdx == lastPathComponent.startIndex {
            filenameEndIdx = lastPathComponent.endIndex
        }
        return String(lastPathComponent[..<filenameEndIdx])
    }

    var fileExtension: String? {
        guard let lastPathComponent = self.lastPathComponent else { return nil }
        if let dotIdx = lastPathComponent[lastPathComponent.index(after: lastPathComponent.startIndex)..<lastPathComponent.endIndex].firstIndex(of: ".") {
            let extensionStartIdx = lastPathComponent.index(dotIdx, offsetBy: 1)
            guard extensionStartIdx != lastPathComponent.endIndex else { return nil }
            return String(lastPathComponent[extensionStartIdx...])
        }
        return nil
    }
    
    func isSubpath(of superPath: any AbsoluteWebDAVPathProtocol) -> Bool {
        guard self.hostname == superPath.hostname else { return false }
        
        let ownPathString = self.path.stringRepresentation
        let otherPathString = superPath.path.stringRepresentation
        
        guard ownPathString.count > 1 else { return true }
        guard ownPathString.count < otherPathString.count else { return false }
        
        let matchEndIndex = otherPathString.index(otherPathString.startIndex, offsetBy: ownPathString.count)
        return ownPathString == otherPathString[..<matchEndIndex] && otherPathString[matchEndIndex] == "/"
    }

     func isSuperpath(of subPath: any AbsoluteWebDAVPathProtocol) -> Bool {
        subPath.isSubpath(of: self)
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
