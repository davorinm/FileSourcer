//
//  FilesSourcer.swift
//  
//
//  Created by Davorin Madaric on 27/11/2022.
//

import Foundation

public protocol FilesSourcer {
    /// Filename: data
    var dict: [String: Data] { get }
}
