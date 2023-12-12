//
//  WebDAVError.swift
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
import SwiftyJSON


public enum WebDAVError: Error {
    /// The credentials or path were unable to be encoded.
    /// No network request was called.
    case invalidCredentials
    /// The credentials were incorrect.
    case unauthorized
    /// The server was unable to store the data provided.
    case insufficientStorage
    /// The server does not support this feature.
    case unsupported
    /// 404.
    case notFound
    /// other.
    case httpErrorStatus(Int)
    
    /// Cannot move item due to the origin being the same as the destination.
    case originSameAsDestination

    /// Something went wrong that should not have.
    case internalError
    
    /// Could not perform logout.
    case logoutError
    
    /// The given path does not match the hostname / path of the given account.
    case pathDoesNotMatchAccount
    
    /// The given path cannot be expressed in a relative manner.
    case pathsNotRelated
    
    /// The origin and destination paths do not belong to the same hostname.
    case cannotMoveAcrossHostnames
    
    /// The directory already exists.
    case directoryAlreadyExists
    
    /// There was an error while building an url.
    case urlBuildingError
    
    /// The body of the response of the server did not meet expectations.
    case malformedResponseBody
    
    /// The ownCloud api returned an error (e.g., during sharing)
    case ownCloudError(statusCode: Int, message: String?)
    
    /// The etag of the directory being inspected changed in between the requests, making the result invalid.
    case etagChangedDuringIteration
    
    static func checkForError(response: URLResponse, data: Data? = nil) throws {
        if let error = self.getError(from: response, data: data) {
            throw error
        }
    }
    
    static public func getError(from response: URLResponse, data: Data? = nil) -> WebDAVError? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .internalError
        }
        return getError(from: httpResponse, data: data)
    }
    
    static func getOwnCloudError(from response: HTTPURLResponse, contentType: String, data: Data) -> WebDAVError? {
        if contentType.starts(with: "application/xml") == true {
            let xml = XMLHash.parse(data)
            // TODO: check namespacing!
            if let statusCode = ( xml["oc:ocs"]["oc:meta"]["oc:statuscode"].element?.text).flatMap({Int($0)}) {
                
                switch statusCode {
                case 200...299:
                    return nil
                default:
                    return .ownCloudError(statusCode: statusCode, message:  xml["oc:ocs"]["oc:meta"]["oc:message"].element?.text)
                }
            }
        } else if contentType.starts(with: "application/json") == true {
            do {
                let json = try JSON(data: data)
                let ocsMeta = json["ocs"]["meta"]
                if let statusCode = ocsMeta["statuscode"].int {
                    
                    switch statusCode {
                    case 200...299:
                        return nil
                    default:
                        return .ownCloudError(statusCode: statusCode, message: ocsMeta["message"].string)
                    }
                }
                
            } catch {
                return WebDAVError.malformedResponseBody
            }
        }
        
        return nil
    }
    
    static public func getError(from response: HTTPURLResponse, data: Data? = nil) -> WebDAVError? {
        if let data = data, let url = response.url, let contentType = response.value(forHTTPHeaderField: "Content-Type") {
            if url.relativePath.starts(with: "/ocs/") {
                return getOwnCloudError(from: response, contentType: contentType, data: data)
            }
        }
        
        
        switch response.statusCode {
        case 200...299: // Success
            return nil
        case 401, 403:
            return .unauthorized
        case 404:
            return .notFound
        case 507:
            return .insufficientStorage
        default:
            return .httpErrorStatus(response.statusCode)
        }
    
    }
}
