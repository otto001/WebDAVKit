//
//  WebDAVPath.swift
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


public struct WebDAVPath: WebDAVPathProtocol {
    private var _stringRepresentation: String
    
    /// The string representation of the path. Always has a leading slash, never has a trailing slash.
    public var stringRepresentation: String {
        get {
            self._stringRepresentation
        }
        set {
            self._stringRepresentation = Self.sanitize(newValue)
        }
    }
    
    private static func sanitize(_ string: any StringProtocol) -> String {
        return "/" + string.trimmingCharacters(in: .init(charactersIn: "/"))
    }
    
    public init(_ stringRepresentation: any StringProtocol) {
        self._stringRepresentation = Self.sanitize(stringRepresentation)
    }
    
    public var pathComponents: [String] {
        self._stringRepresentation.split(separator: "/").map {String($0)}
    }
    
    public var lastPathComponent: String? {
        if let lastSlashIdx = self._stringRepresentation.lastIndex(of: "/") {
            let filenameStartIdx = self._stringRepresentation.index(lastSlashIdx, offsetBy: 1)
            guard filenameStartIdx != self._stringRepresentation.endIndex else { return nil }

            return String(self._stringRepresentation[filenameStartIdx...])
        }
        return nil
    }
    
    public mutating func append(_ other: WebDAVPath) {
        self.stringRepresentation.append(other.stringRepresentation)
    }
    
    @discardableResult
    public mutating func removeLastPathComponent() -> String? {
        var pathComponents = self.pathComponents
        guard !pathComponents.isEmpty else { return nil }
        let lastPathComponent = pathComponents.removeLast()
        stringRepresentation = Self.sanitize(pathComponents.joined(separator: "/"))
        return lastPathComponent
    }

    public mutating func appendExtension(_ pathExtension: String) {
        self.stringRepresentation.append(".\(pathExtension)")
    }
}

extension WebDAVPath: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self._stringRepresentation = Self.sanitize(value)
    }
}

extension WebDAVPath: Equatable {
    public static func == (lhs: WebDAVPath, rhs: WebDAVPath) -> Bool {
        lhs.stringRepresentation == rhs.stringRepresentation
    }
}

extension WebDAVPath: Hashable {
    
}

extension WebDAVPath: Comparable {
    public static func < (lhs: WebDAVPath, rhs: WebDAVPath) -> Bool {
        lhs.stringRepresentation < rhs.stringRepresentation
    }
}

extension WebDAVPath: Codable {
    
}

extension WebDAVPath: RawRepresentable {
    public init(rawValue: String) {
        self = .init(rawValue)
    }
    
    public var rawValue: String {
        self._stringRepresentation
    }
    
    public typealias RawValue = String
}


