//
//  WebDAVError.swift
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

public enum WebDAVError: LocalizedError {
    /// The credentials or path were unable to be encoded.
    /// No network request was called.
    case invalidCredentials
    /// The credentials were incorrect.
    case unauthorized
    /// The server was unable to store the data provided.
    case insufficientStorage
    /// The server does not support this feature.
    case unsupported
    /// 404
    case notFound
    /// other
    case other
    
    /// Cannot move item due to the origin being the same as the destination
    case originSameAsDestination

    /// Something went wrong that should not have
    case internalError
    
    /// Could not perform logout
    case logoutError
    
    /// The given path does not match the hostname / path of the given account
    case pathDoesNotMatchAccount
    
    /// The given path cannot be expressed in a relative manner
    case pathsNotRelated
    
    /// The origin and destination paths do not belong to the same hostname
    case cannotMoveAcrossHostnames
    
    /// There was an error while building an url.
    case urlBuildingError
    
    
    public var errorDescription: String? {
        switch self {

        case .invalidCredentials:
            return "Invalid Credentials"
        case .unauthorized:
            return "Unauthorized"
        case .insufficientStorage:
            return "Insufficient Storage"
        case .unsupported:
            return "Unsupported"
        case .notFound:
            return "Not Found"
        case .other:
            return "Unknown Error"
        case .internalError:
            return "Internal Error"
        case .logoutError:
            return "Unable to logout"
        default:
            return nil
        }
    }
    
    public var failureReason: String? {
        switch self {

        case .invalidCredentials:
            return "You are not logged in."
        case .unauthorized:
            return "You are not allowed to perform this action."
        case .insufficientStorage:
            return "The server does not have enough empty storage."
        case .unsupported:
            return "The server does not support the feature you tried to use."
        case .notFound:
            return "The resource you are trying to acces is not on the Server."
        case .other:
            return "Unknown Error."
        case .internalError:
            return "Internal Error."
        default:
            return nil
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        default:
            return nil
        }
    }

    
    static func checkForError(response: URLResponse) throws {
        if let error = self.getError(response: response) {
            throw error
        }
    }
    
    static func getError(statusCode: Int?) -> WebDAVError? {
        if let statusCode = statusCode {
            switch statusCode {
            case 200...299: // Success
                return nil
            case 401, 403:
                return .unauthorized
            case 404:
                return .notFound
            case 507:
                return .insufficientStorage
            default:
                return .other
            }
        }

        return nil
    }
    
    static func getError(response: URLResponse) -> WebDAVError? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .internalError
        }
        return getError(statusCode: httpResponse.statusCode)
    }
}
