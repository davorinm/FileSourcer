import PackagePlugin
import Foundation

@main
struct FilesSourcerPlugin: CommandPlugin {
    
    private let filesTemplate: String =
"""
// Generated source file

import Foundation
import FilesSourcer

struct Files: FilesSourcer {
    static let shared = Files()

    var dict: [String : Data] = [
        {{INDEXX}}
    ]
    
    private init() {}
}

"""
    
    private let filesTemplateContent: String =
"""
        "{{INDEXX_PATH}}": Data([{{INDEXX_DATA}}]),
        
"""
        
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let fileSource = context.package.directory.appending("Sources").appending("App").appending("Files.swift")
        var fileContent = filesTemplate
        var indexes: String = ""
        
        for resource in ["Resources", "Public"] {
            let resourcesPath = context.package.directory.appending(resource)
            print(resourcesPath)
            
            let items = getItemsFromDirectory(directory: resourcesPath.string)
            if items.isEmpty {
                return
            }
                    
            for item in items {
                let itemPathUrl = URL(string: "file://" + item)!
                print("itemPathUrl \(itemPathUrl)")
                
                let dataS = try Data(contentsOf: itemPathUrl).hexEncodedString()
                                                
                indexes += filesTemplateContent
                    .replacingOccurrences(of: "{{INDEXX_PATH}}", with: itemPathUrl.absoluteString)
                    .replacingOccurrences(of: "{{INDEXX_DATA}}", with: dataS)
            }
        }
                
        fileContent = fileContent.replacingOccurrences(of: "{{INDEXX}}", with: indexes)
        
        try fileContent.data(using: .utf8)?.write(to: URL(string: "file://" + fileSource.string)!)
    }
    
    private func getItemsFromDirectory(directory: String) -> [String] {
        var filteredItems: [String] = []
        
        do {
            let items = try FileManager.default.subpathsOfDirectory(atPath: directory)

            for item in items {
                
                if item.hasPrefix(".") {
                    continue
                }
                
                let itemPath = directory + "/" + item
                
                var isDirectory = directoryExistsAtPath(itemPath)
                if isDirectory {
                    continue
                }
                
                print("Found \(item), path \(itemPath)")
                
                filteredItems.append(itemPath)
            }
        } catch let error {
            fatalError("FileManager error: \(error)")
        }
        
        return filteredItems
    }
    
    private func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        
        return exists && isDirectory.boolValue
    }
}

extension Data {
    private static let hexAlphabet = Array("0123456789abcdef".unicodeScalars)
    func hexEncodedString() -> String {
        String(reduce(into: "".unicodeScalars) { result, value in
            result.append("0")
            result.append("x")
            result.append(Self.hexAlphabet[Int(value / 0x10)])
            result.append(Self.hexAlphabet[Int(value % 0x10)])
            result.append(",")
        })
    }
}
