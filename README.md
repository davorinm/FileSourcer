# FilesSourcerPlugin - SPM plugin

FilesSourcerPlugin is a plugin for converting resource files to sourcde code. 

When building and distributing Vapor application, with binary is needed also Resources folder with files required to display web page.
FilesSourcerPlugin reads Resources folder and copy contents of files to single source file.

# Usage

Add dependency:

dependencies: [
...
    .package(path: "../FilesSourcerPlugin")
...
],

Update config:

let customSource = CustomSource()

let multipleSources = LeafSources()
try multipleSources.register(using: defaultSource)
try multipleSources.register(source: "custom-source-key", using: customSource)

app.leaf.sources = multipleSources

app.views.use(.leaf)


struct CustomSource: LeafSource {
    func file(template: String, escape: Bool, on eventLoop: EventLoop) -> EventLoopFuture<ByteBuffer> {
        return eventLoop.future(result: Result.success(ByteBuffer(string: Files.index)))
    }
}

# Build

swift package --allow-writing-to-package-directory fileSourcer