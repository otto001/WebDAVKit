//
//  AbsoluteWebDAVPath.swift
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


public struct AbsoluteWebDAVPath {
    public var hostname: String
    public var path: WebDAVPath

    
    public init(hostname: String, path: WebDAVPath) {
        self.hostname = hostname
        self.path = path
    }
    
    public init(_ absolutePath: any AbsoluteWebDAVPathProtocol) {
        self.hostname = absolutePath.hostname
        self.path = absolutePath.path
    }
    
    public init(filePath: any WebDAVPathProtocol, account: any WebDAVAccount) throws {
        if let absolutePath = filePath as? any AbsoluteWebDAVPathProtocol {
            guard account.serverFilesPath.isSubpath(of: absolutePath) else {
                throw WebDAVError.pathDoesNotMatchAccount
            }
            self = AbsoluteWebDAVPath(absolutePath)
        } else {
            self = account.serverFilesPath.appending(filePath.stringRepresentation)
        }
    }
    
    public init(path: any WebDAVPathProtocol, account: any WebDAVAccount) throws {
        if let absolutePath = path as? any AbsoluteWebDAVPathProtocol {
            guard account.hostname == absolutePath.hostname else {
                throw WebDAVError.pathDoesNotMatchAccount
            }
            self = AbsoluteWebDAVPath(absolutePath)
        } else {
            self = AbsoluteWebDAVPath(hostname: account.hostname, path: .init(path.stringRepresentation))
        }
    }
    
    public init?(string: any StringProtocol) {
        let splitString = string.split(separator: "/", maxSplits: 1)
        guard splitString.count >= 1 else { return nil }
        self.hostname = String(splitString[0])
        
        if splitString.count == 2 {
            self.path = .init(String(splitString[1]))
        } else {
            self.path = ""
        }
    }
}

extension AbsoluteWebDAVPath: WebDAVPathProtocol {
    public mutating func append(_ other: WebDAVPath) {
        path.append(other)
    }

    @discardableResult
    public mutating func removeLastPathComponent() -> String? {
        path.removeLastPathComponent()
    }
    
    public func removingLastPathComponent() -> Self {
        var result = self
        result.removeLastPathComponent()
        return result
    }
    
    public mutating func appendExtension(_ pathExtension: String) {
        path.appendExtension(pathExtension)
    }
}

extension AbsoluteWebDAVPath: AbsoluteWebDAVPathProtocol {
    
}

extension AbsoluteWebDAVPath: Equatable {
    public static func == (lhs: AbsoluteWebDAVPath, rhs: AbsoluteWebDAVPath) -> Bool {
        lhs.hostname == rhs.hostname && lhs.path == rhs.path
    }
}

extension AbsoluteWebDAVPath: Hashable {
    
}

extension AbsoluteWebDAVPath: Comparable {
    public static func < (lhs: AbsoluteWebDAVPath, rhs: AbsoluteWebDAVPath) -> Bool {
        lhs.stringRepresentation < rhs.stringRepresentation
    }
}

extension AbsoluteWebDAVPath: Codable {
    
}
