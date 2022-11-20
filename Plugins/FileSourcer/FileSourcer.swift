import PackagePlugin
import Foundation

@main
struct FileSourcer: CommandPlugin {
    
    private let filesTemplateStart: String =
"""
// Generated source file

import Foundation

struct Files {

    let index: String =
\"\"\"

"""
    
    private let filesTemplateEnd: String =
"""

\"\"\"
   


}

"""
    
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let cpTool = try context.tool(named: "cp")
        let cpToolURL = URL(fileURLWithPath: cpTool.path.string)
        
        let resourcesPath = context.package.directory.appending("Resources")
        print(resourcesPath)
                
        let fm = FileManager.default
        
        do {
            let items = try fm.subpathsOfDirectory(atPath: resourcesPath.string)

            for item in items {
                print("-------")
                
                if item.hasPrefix(".") {
                    continue
                }
                
                let itemPath = resourcesPath.appending(item)
                print("itemPath \(itemPath.string)")
                
                var isDirectory = directoryExistsAtPath(itemPath.string)
                if isDirectory {
                    continue
                }
                
                print("Found \(item), path \(itemPath)")
                
                let itemPathUrl = URL(string: "file://" + itemPath.string)!
                print("itemPathUrl \(itemPathUrl)")
                
                let dataS = try String(contentsOf: itemPathUrl)
                
                let filesSource = context.package.directory.appending("Sources").appending("App").appending("Files.swift")
                
                let fileContent = filesTemplateStart + dataS + filesTemplateEnd
                
                try fileContent.data(using: .utf8)?.write(to: URL(string: "file://" + filesSource.string)!)
                
                
                print("-------")
            }
        } catch let error {
            fatalError("FileManager error: \(error)")
        }
    }
    
    fileprivate func directoryExistsAtPath(_ path: String) -> Bool {
        var isDirectory = ObjCBool(false)
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        
        return exists && isDirectory.boolValue
    }
}
