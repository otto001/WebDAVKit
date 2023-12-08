//
//  WebDAVUtils.swift
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

public enum WebDAVListDepth: String {
    case zero = "0"
    case one = "1"
    case infinity = "infinity"
}

public enum WebDAVMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case propfind = "PROPFIND"
    case proppatch = "PROPPATCH"
    case report = "REPORT"
    case mkcol = "MKCOL"
    case move = "MOVE"
    case copy = "COPY"
}

public enum WebDAVServerType: Codable {
    case nextcloud, owncloud, other
    
    var isOwncloud: Bool {
        switch self {
        case .nextcloud, .owncloud:
            return true
        default:
            return false
        }
    }
}

public struct WebDAVSecret: CustomStringConvertible, CustomDebugStringConvertible, ExpressibleByStringLiteral, Codable {
    public let inner: String
    
    public var description: String {
        "<secret>"
    }
    
    public var debugDescription: String {
        "<secret>"
    }
    
    public init(_ inner: String) {
        self.inner = inner
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.inner = value
    }
}

