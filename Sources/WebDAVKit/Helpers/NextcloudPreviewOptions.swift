//
//  NextcloudPreviewOptions.swift
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
import CoreGraphics

public struct NextcloudPreviewOptions: Hashable, Sendable {
    private var width: Int?
    private var height: Int?
    
    public var contentMode: ContentMode
    
    public var size: CGSize? {
        get {
            if let width = width, let height = height {
                return CGSize(width: width, height: height)
            }
            return nil
        }
        set {
            width = (newValue?.width).map { Int($0) }
            height = (newValue?.height).map { Int($0) }
        }
    }
    
    /// Configurable default thumbnail properties. Initial value of content fill and 512x512 dimensions.
    public static var `default` = NextcloudPreviewOptions(size: CGSize(width: 512, height: 512), contentMode: .fill)
    
    /// Constants that define how the thumbnail fills the dimensions.
    public enum ContentMode: Hashable, Sendable {
        case fill
        case fit
    }
    
    /// - Parameters:
    ///   - size: The size of the thumbnail. A nil value will use the server's default dimensions.
    ///   - contentMode: A flag that indicates whether the thumbnail view fits or fills the dimensions.
    public init(_ size: (width: Int, height: Int)? = nil, contentMode: ContentMode) {
        if let size = size {
            width = size.width
            height = size.height
        }
        self.contentMode = contentMode
    }
    
    /// - Parameters:
    ///   - size: The size of the thumbnail. Width and height will be truncated to integer pixel counts.
    ///   - contentMode: A flag that indicates whether the thumbnail view fits or fills the image of the given dimensions.
    public init(size: CGSize, contentMode: ContentMode) {
        width = Int(size.width)
        height = Int(size.height)
        self.contentMode = contentMode
    }
}
