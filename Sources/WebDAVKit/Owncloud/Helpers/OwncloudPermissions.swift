//
//  OwncloudPermissions.swift
//  WebDAVKit
//
//  Created by Matteo Ludwig on 08.12.23.
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


public struct OwncloudPermissions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let read = Self(rawValue: 1)
    public static let update = Self(rawValue: 2)
    public static let create = Self(rawValue: 4)
    public static let delete = Self(rawValue: 8)
    public static let reShare = Self(rawValue: 16)
    
    public static let all: Self = [.read, .update, .create, .delete, .reShare]
}
