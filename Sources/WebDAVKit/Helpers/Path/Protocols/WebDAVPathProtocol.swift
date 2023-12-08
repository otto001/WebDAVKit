//
//  WebDAVPathProtocol.swift
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


/// A protocol that represents a simple path in a WebDAV server.
public protocol WebDAVPathProtocol: CustomStringConvertible {
    /// The string representation of the path. Always starts with a `/`. Never ends with a `/`.
    var stringRepresentation: String { get }
    
    /// The path components of the path. Created by splitting the string representation at every `/`.
    var pathComponents: [String] { get }
    
    /// The last path component of the path. Equal to the last element of `pathComponents`.
    var lastPathComponent: String? { get }
    
    /// Appends the given path to the path.
    /// - Parameters: other: The path to append.
    mutating func append(_ other: WebDAVPath)

    /// Convenience method to append a string to the path.
    /// - Parameters: other: The string to append.
    mutating func append(_ string: String)

    /// Returns a new path by appending the given path to the path.
    /// - Parameters: other: The path to append.
    /// - Returns: A new path with the appended path.
    func appending(_ other: WebDAVPath) -> Self

    /// Convenience method to return a new path by appending a string to the path.
    /// - Parameters: other: The string to append.
    /// - Returns: A new path with the appended string.
    func appending(_ string: String) -> Self
    
    /// Appends the given path extension to the path. The path extension will be appended to the last path component with a `.` in between.
    /// - Parameters: pathExtension: The path extension to append.
    mutating func appendExtension(_ pathExtension: String)

    /// Convenience method to return a new path by appending the given path extension to the path. The path extension will be appended to the last path component with a `.` in between.
    /// - Parameters: pathExtension: The path extension to append.
    /// - Returns: A new path with the appended path extension.
    func appendingExtension(_ pathExtension: String) -> Self
}

public extension WebDAVPathProtocol {
     /// The last path component of the path. Equal to the last element of `pathComponents`.
    var lastPathComponent: String? {
        pathComponents.last
    }
    
    /// Convenience method to append a string to the path.
    /// - Parameters: other: The string to append.
    mutating func append(_ other: String) {
        self.append(WebDAVPath(other))
    }
    
    /// Returns a new path by appending the given path to the path.
    /// - Parameters: other: The path to append.
    /// - Returns: A new path with the appended path.
    func appending(_ other: WebDAVPath) -> Self {
        var result = self
        result.append(other)
        return result
    }
    
    /// Convenience method to return a new path by appending a string to the path.
    /// - Parameters: other: The string to append.
    /// - Returns: A new path with the appended string.
    func appending(_ other: String) -> Self {
        var result = self
        result.append(other)
        return result
    }
    
    /// Convenience method to return a new path by appending the given path extension to the path. The path extension will be appended to the last path component with a `.` in between.
    /// - Parameters: pathExtension: The path extension to append.
    /// - Returns: A new path with the appended path extension.
    func appendingExtension(_ pathExtension: String) -> Self {
        var result = self
        result.appendExtension(pathExtension)
        return result
    }
    
    var description: String { self.stringRepresentation }
}


