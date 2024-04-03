//
//  WebDAVSession.swift
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
import OSLog


public class WebDAVSession {
    /// A shared instance of WebDAVSession.
    public static let shared = WebDAVSession()
    
    /// The URLSession used for all requests.
    let urlSession: URLSession
    
    /// The logger used for all log messages.
    let logger: Logger?
    
    /// The signposter used for all signposts.
    let signposter: OSSignposter?
    
    /// Creates a new WebDAVSession.
    public init(urlSession: URLSession? = nil, logger: Logger? = nil) {
        self.logger = logger
        self.signposter = logger.map { OSSignposter(logger: $0)}
        self.urlSession = urlSession ?? URLSession(configuration: .ephemeral)
    }
}
