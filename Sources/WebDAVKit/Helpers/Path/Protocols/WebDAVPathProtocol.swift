//
//  WebDAVPathProtocol.swift
//  WebDAVKit
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


public protocol WebDAVPathProtocol: CustomStringConvertible {
    var stringRepresentation: String { get }
    
    var pathComponents: [String] { get }
    
    var lastPathComponent: String? { get }
    
    mutating func append(_ other: WebDAVPath)
    mutating func append(_ other: String)

    func appending(_ other: WebDAVPath) -> Self
    func appending(_ other: String) -> Self
    
    
    mutating func appendExtension(_ pathExtension: String)
    func appendingExtension(_ pathExtension: String) -> Self
}

public extension WebDAVPathProtocol {
    var lastPathComponent: String? {
        pathComponents.last
    }
    
    mutating func append(_ other: String) {
        self.append(WebDAVPath(other))
    }
    
    func appending(_ other: WebDAVPath) -> Self {
        var result = self
        result.append(other)
        return result
    }
    
    func appending(_ other: String) -> Self {
        var result = self
        result.append(other)
        return result
    }
    
    func appendingExtension(_ pathExtension: String) -> Self {
        var result = self
        result.appendExtension(pathExtension)
        return result
    }
    
    var description: String { self.stringRepresentation }
}


