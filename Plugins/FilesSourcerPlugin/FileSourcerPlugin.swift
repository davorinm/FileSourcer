import Foundation
import PackagePlugin

@main
struct FilesSourcerPlugin: CommandPlugin {
    
    private let template: String =
"""
// Generated source file

import Foundation
import FilesSourcer

struct Files: FilesSourcer {
    static let shared = Files()

    var files: [String : Data] = [
        {{#FILES}}
        "{{FILE_PATH}}" : Data([{{FILE_DATA}}]),
        {{/FILES}}
    ]
    
    private init() {}
}

"""
        
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let fileSource = context.package.directory.appending("Sources").appending("App").appending("Files.swift")
        var filesData: [Any] = []
        
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
                
                var fileData: [String : Any] = [:]
                fileData["FILE_PATH"] = itemPathUrl.absoluteString
                fileData["FILE_DATA"] = dataS
                
                filesData.append(fileData)
            }
        }
                
        let context: [String : Any] = ["FILES" : filesData]
                        
        let fileContent = scafold(data: context)
        
        let filePath = URL(string: "file://" + fileSource.string)!
        try fileContent.data(using: .utf8)?.write(to: filePath)
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
                
                let isDirectory = directoryExistsAtPath(itemPath)
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
    
    private func scafold(data: [String : Any]) -> String {
        var parser = MustacheParser()

        let tree = parser.parse(string: template)
        let result = tree.render(object: data)
        
        return result
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
