//
//  WebDAVSession+Nextcloud+LivePhoto.swift
//  WebDAVKit
//
//  Created by Matteo Ludwig on 07.10.24.
//
//  Source: https://github.com/nextcloud/NextcloudKit

private let requestBodyLivephoto =
    """
    
    """

extension WebDAVSession {
    func setLivephoto(imagePath: any WebDAVPathProtocol, videoPath: (any WebDAVPathProtocol)?, account: any WebDAVAccount) async throws {
        guard account.serverType == .nextcloud else {
            throw WebDAVError.unsupported
        }
        
        var request = try self.authorizedRequest(method: .proppatch, filePath: imagePath, contentType: .applicationXml, account: account)
        
        let videoPath = try videoPath.map {
            try AbsoluteWebDAVPath(filePath: $0, account: account).relative(to: account.serverFilesPath).relativePath.stringRepresentation
        }
        
        let body =
"""
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<d:propertyupdate xmlns:d=\"DAV:\" xmlns:oc=\"http://owncloud.org/ns\" xmlns:nc=\"http://nextcloud.org/ns\">
    <d:set>
        <d:prop>
            <nc:metadata-files-live-photo>\(videoPath ?? "")</nc:metadata-files-live-photo>
        </d:prop>
    </d:set>
</d:propertyupdate>
"""
        
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await self.urlSession.data(for: request)

        try WebDAVError.checkForError(response: response, data: data)
    }

}
