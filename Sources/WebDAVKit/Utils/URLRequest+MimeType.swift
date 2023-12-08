//
//  URLRequest+MimeType.swift
//
//
//  Created by Matteo Ludwig on 08.12.23.
//

import Foundation


extension HTTPURLResponse {
    var contentType: MimeType? {
        (value(forHTTPHeaderField: "Content-Type")?.prefix { $0 != ";" }).flatMap { .init($0) }
    }
}

extension URLRequest {
    var contentType: MimeType? {
        get {
            (value(forHTTPHeaderField: "Content-Type")?.prefix { $0 != ";" }).flatMap { .init($0) }
        }
        set {
            setValue(newValue?.stringRepresentation, forHTTPHeaderField: "Content-Type")
        }
    }
    
    var accept: [MimeType]? {
        get {
            guard let mimeTypes = value(forHTTPHeaderField: "Accept")?.split(separator: ",") else {
                return nil
            }
            
            return mimeTypes.map {
                $0.trimmingCharacters(in: .whitespaces).prefix { $0 != ";" }
            }.compactMap { .init($0) }
        }
        set {
            setValue(newValue?.map {$0.stringRepresentation}.joined(separator: ", "), forHTTPHeaderField: "Accept")
        }
    }
}
