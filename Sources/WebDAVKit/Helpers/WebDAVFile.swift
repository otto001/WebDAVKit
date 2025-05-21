//
//  WebDAVFile.swift
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
import SWXMLHash


public struct WebDAVFile: Sendable {
    public private(set) var path: RelativeWebDAVPath
    private var properties: [String: any Sendable] = [:]
    
    public func propery<T>(_ key: WebDAVFilePropertyKey<T>) -> T? {
        properties[key.xmlKey] as? T
    }
    
    public mutating func setPropery<T>(_ key: WebDAVFilePropertyKey<T>, _ value: T?) {
        properties[key.xmlKey] = value
    }
    
    public mutating func setPropery<T>(_ key: WebDAVFilePropertyKey<T>, from string: String?) {
        properties[key.xmlKey] = string.flatMap { key.convert($0) }
    }
    
    public mutating func setPropery(_ key: WebDAVFilePropertyFetchKey, from string: String?) {
        properties[key.xmlKey] = string.flatMap { key.convert($0) }
    }
    
    public subscript<T>(_ key: WebDAVFilePropertyKey<T>) -> T? {
        get {
            propery(key)
        }
        set {
            setPropery(key, newValue)
        }
    }
    
    public init(path: RelativeWebDAVPath) {
        self.path = path
    }
    
    public init?(xml: XMLIndexer, properties: [WebDAVFilePropertyFetchKey], basePath: AbsoluteWebDAVPath) {
        guard var pathString = xml["d:href"].element?.text else { return nil }
        
        if let decodedPath = pathString.removingPercentEncoding {
            pathString = decodedPath
        }
        
        guard let webDAVPath = try? AbsoluteWebDAVPath(hostname: basePath.hostname, path: .init(pathString)).relative(to: basePath) else {
            return nil
        }
        
        self.path = webDAVPath
        
        let xmlProperties = xml["d:propstat"][0]["d:prop"]
        for property in properties {
            guard let text = xmlProperties[property.xmlKey].element?.text else { continue }
            self.setPropery(property, from: text)
        }
    }
    
    public var description: String {
        "WebDAVFile(path: \(path))"
    }
}
