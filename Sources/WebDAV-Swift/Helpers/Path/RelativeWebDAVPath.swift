//
//  RelativeWebDAVPath.swift
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


public struct RelativeWebDAVPath {
    public var relativePath: WebDAVPath
    public var relativeTo: AbsoluteWebDAVPath
    
    public var absolutePath: AbsoluteWebDAVPath {
        var absolutePath = relativeTo
        absolutePath.path.append(relativePath)
        return absolutePath
    }
    
    public init(relativePath: WebDAVPath, relativeTo: any AbsoluteWebDAVPathProtocol) {
        self.relativePath = relativePath
        self.relativeTo = AbsoluteWebDAVPath(relativeTo)
    }
}

extension RelativeWebDAVPath: WebDAVPathProtocol {
    public mutating func append(_ other: WebDAVPath) {
        relativePath.append(other)
    }

    
    public mutating func appendExtension(_ pathExtension: String) {
        relativePath.appendExtension(pathExtension)
    }
}

extension RelativeWebDAVPath: AbsoluteWebDAVPathProtocol {
    public var hostname: String { relativeTo.hostname }
    public var path: WebDAVPath { relativeTo.path.appending(relativePath) }
}

public extension RelativeWebDAVPath {
    var stringRepresentation: String {
        absolutePath.stringRepresentation
    }
}

extension RelativeWebDAVPath: Equatable {
    public static func == (lhs: RelativeWebDAVPath, rhs: RelativeWebDAVPath) -> Bool {
        lhs.absolutePath == rhs.absolutePath
    }
}

extension RelativeWebDAVPath: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(absolutePath)
    }
}

extension RelativeWebDAVPath: Comparable {
    public static func < (lhs: RelativeWebDAVPath, rhs: RelativeWebDAVPath) -> Bool {
        lhs.stringRepresentation < rhs.stringRepresentation
    }
}

extension RelativeWebDAVPath: Codable {
    
}
