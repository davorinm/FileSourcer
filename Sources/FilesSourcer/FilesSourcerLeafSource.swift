//
//  FilesSourcerLeafSource.swift
//  
//
//  Created by Davorin Madaric on 23/11/2022.
//

import Vapor
import Leaf

public struct FilesSourcerLeafSource: LeafSource {
    let files: FilesSourcer
    
    public init(files: FilesSourcer) {
        self.files = files
    }

    func file(template: String, escape: Bool, on eventLoop: EventLoop) -> EventLoopFuture<ByteBuffer> {
        guard let fileData: Data = files.dict[template] else {
            return eventLoop.future(result: Result.failure(LeafError(.noTemplateExists(template))))
        }
        
        let buffer = ByteBuffer(data: fileData)
        return eventLoop.future(result: Result.success(buffer))
    }
}
