//
//  FilesSourcerMidleware.swift
//  
//
//  Created by Davorin Madaric on 27/11/2022.
//

import Vapor

public struct FilesSourcerMidleware: Middleware {
    let files: FilesSourcer
    
    public init(files: FilesSourcer) {
        self.files = files
    }
    
    public func respond(to request: Vapor.Request, chainingTo next: Vapor.Responder) -> NIOCore.EventLoopFuture<Vapor.Response> {
        // make a copy of the percent-decoded path
        guard let path = request.url.path.removingPercentEncoding else {
            return request.eventLoop.makeFailedFuture(Abort(.badRequest))
        }

        // protect against relative paths
        guard !path.contains("../") else {
            return request.eventLoop.makeFailedFuture(Abort(.forbidden))
        }
        
        print("FilesSourcerMidleware path \(path)")

        // check if path exists and whether it is a directory
        guard let fileData: Data = files.files[path] else {
            return next.respond(to: request)
        }
                
        // Create empty headers array.
        let headers: HTTPHeaders = [:]
        
        // Create the HTTP response.
        let response = Response(status: .ok, headers: headers)
        
        // Set Content-Type header based on the media type
        // Only set Content-Type if file not modified and returned above.
        if let fileExtension = path.components(separatedBy: ".").last, let type = HTTPMediaType.fileExtension(fileExtension) {
            response.headers.contentType = type
        }
        
        response.body = .init(data: fileData)
                
        return request.eventLoop.makeSucceededFuture(response)
    }
}
