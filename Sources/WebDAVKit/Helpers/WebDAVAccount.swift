//
//  WebDAVAccount.swift
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


public protocol WebDAVAccount: Sendable {
    var username: String { get }
    var password: WebDAVSecret { get }
    
    var hostname: String { get }
    
    var serverFilesPath: AbsoluteWebDAVPath { get }
    
    var serverType: WebDAVServerType { get }
    
    var userAgent: String? { get }
    
    var supportsFileIds: Bool { get }
}

public extension WebDAVAccount {
    var serverFilesPath: AbsoluteWebDAVPath {
        switch serverType {
        case .nextcloud, .owncloud:
            return AbsoluteWebDAVPath(hostname: hostname, path: .init("remote.php/dav/files/\(username)"))
        default:
            return AbsoluteWebDAVPath(hostname: hostname, path: .init(""))
        }
    }
    
    var supportsFileIds: Bool {
        switch serverType {
        case .nextcloud, .owncloud:
            return true
        case .other:
            return false
        }
    }
}

public struct BasicWebDAVAccount: WebDAVAccount {
    public var username: String
    public var password: WebDAVSecret
    
    public var hostname: String

    public var serverType: WebDAVServerType

    
    public var userAgent: String?
    
    public init(username: String, password: WebDAVSecret, hostname: String, serverType: WebDAVServerType, userAgent: String? = nil) {
        self.username = username
        self.password = password
        self.hostname = hostname
        self.serverType = serverType
        self.userAgent = userAgent
    }
}

extension BasicWebDAVAccount: Codable {
    
}
