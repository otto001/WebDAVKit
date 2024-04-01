//
//  WebDAVPath.swift
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

/// A struct that represents a simple path in a WebDAV server.
public struct WebDAVPath: WebDAVPathProtocol {
    /// The internal string representation of the path. Always starts with a `/`. Never ends with a `/`.
    private var _stringRepresentation: String
    
    /// The string representation of the path. Always starts with a `/`. Never ends with a `/`. Is sanitized on set.
    public var stringRepresentation: String {
        get {
            self._stringRepresentation
        }
        set {
            self._stringRepresentation = Self.sanitize(newValue)
        }
    }
    
    /// Sanitizes the given string representation of a path. 
    /// - Parameters: string: The string representation of a path to sanitize.
    /// - Returns: The sanitized string representation of a path. The returned string always starts with a `/` and never ends with a `/`.
    private static func sanitize(_ string: any StringProtocol) -> String {
        return "/" + string.trimmingCharacters(in: .init(charactersIn: "/"))
    }
    
    /// Initializes a new path with the given string representation.
    public init(_ stringRepresentation: any StringProtocol) {
        self._stringRepresentation = Self.sanitize(stringRepresentation)
    }
    
    /// Initializes a new path with the given path components.
    public init(_ pathComponents: [String]) {
        self._stringRepresentation = Self.sanitize(pathComponents.joined(separator: "/"))
    }
    
    /// The path components of the path. Created by splitting the string representation at every `/`.
    public var pathComponents: [String] {
        self._stringRepresentation.split(separator: "/").map {String($0)}
    }
    
    /// The last path component of the path. Equal to the last element of `pathComponents`.
    public var lastPathComponent: String? {
        if let lastSlashIdx = self._stringRepresentation.lastIndex(of: "/") {
            let filenameStartIdx = self._stringRepresentation.index(lastSlashIdx, offsetBy: 1)
            guard filenameStartIdx != self._stringRepresentation.endIndex else { return nil }

            return String(self._stringRepresentation[filenameStartIdx...])
        }
        return nil
    }
    
    /// Appends the given path to the path.
    public mutating func append(_ other: WebDAVPath) {
        self.stringRepresentation.append(other.stringRepresentation)
    }
    
    /// Removes the last path component from the path if possible. If the path is empty, nothing happens.
    /// - Returns: The removed last path component.
    @discardableResult public mutating func removeLastPathComponent() -> String? {
        var pathComponents = self.pathComponents
        guard !pathComponents.isEmpty else { return nil }
        let lastPathComponent = pathComponents.removeLast()
        stringRepresentation = Self.sanitize(pathComponents.joined(separator: "/"))
        return lastPathComponent
    }

    /// Appends the given path extension to the path. The path extension will be appended to the last path component with a `.` in between.
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
    public typealias RawValue = String
    
    public init(rawValue: String) {
        self = .init(rawValue)
    }
    
    public var rawValue: String {
        self._stringRepresentation
    } 
}


