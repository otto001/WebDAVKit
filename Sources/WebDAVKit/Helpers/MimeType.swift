//
//  MimeType.swift
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


public struct MimeType {
    public var type: String
    public var subtype: String
    
    public var stringRepresentation: String {
        "\(type)/\(subtype)"
    }
    
    public init(type: String, subtype: String) {
        self.type = type
        self.subtype = subtype
    }
    
    public init?(_ string: any StringProtocol) {
        let split = string.split(separator: "/", maxSplits: 1)
        guard split.count == 2 else {
            return nil
        }
        self.type = String(split[0])
        self.subtype = String(split[1])
    }
}


extension MimeType: CustomStringConvertible {
    public var description: String {
        stringRepresentation
    }
}

extension MimeType: Codable {
    
}

extension MimeType: Equatable {
    
}

extension MimeType: Hashable {
    
}


extension MimeType: RawRepresentable {
    public typealias RawValue = String
    
    public init?(rawValue: String) {
        guard let _self = MimeType(rawValue) else { return nil }
        self = _self
    }
    
    public var rawValue: String {
        stringRepresentation
    }
}

extension MimeType {
    static public func text(_ subtype: String) -> MimeType {
        .init(type: "text", subtype: subtype)
    }
    
    static public func application(_ subtype: String) -> MimeType {
        .init(type: "application", subtype: subtype)
    }
    
    static public func image(_ subtype: String) -> MimeType {
        .init(type: "image", subtype: subtype)
    }
    
    static public func video(_ subtype: String) -> MimeType {
        .init(type: "video", subtype: subtype)
    }
    
    static public func audio(_ subtype: String) -> MimeType {
        .init(type: "audio", subtype: subtype)
    }
    
    static public func font(_ subtype: String) -> MimeType {
        .init(type: "font", subtype: subtype)
    }
    
    static let applicationJson: MimeType = .application("json")
    static let applicationXml: MimeType = .application("xml")
    static let videoMp4: MimeType = .video("mp4")
    static let videoQuicktime: MimeType = .video("quicktime")
    static let imageJpeg: MimeType = .image("jpeg")
    static let imagePng: MimeType = .image("png")
    static let imageGif: MimeType = .image("gif")
}
