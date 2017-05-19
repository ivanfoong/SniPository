# SniPository

## Purpose

To share Xcode code snippets with a group of people

## Proposal

- Synchronize Xcode code snippets across group from a repository
- Browse code snippets repository

## Research

Code snippets are stored as individual plist files in `~/Library/Developer/Xcode/UserData/CodeSnippets`

For example:

file `0023F145-4385-480E-B990-5B5299B31890.codesnippet`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>IDECodeSnippetCompletionPrefix</key>
        <string>gdh</string>
        <key>IDECodeSnippetCompletionScopes</key>
        <array>
                <string>ClassImplementation</string>
        </array>
        <key>IDECodeSnippetContents</key>
        <string>fileprivate func getDefaultHeaders() -&gt; HTTPHeaders {
        return [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
    }</string>
        <key>IDECodeSnippetIdentifier</key>
        <string>0023F145-4385-480E-B990-5B5299B31890</string>
        <key>IDECodeSnippetLanguage</key>
        <string>Xcode.SourceCodeLanguage.Swift</string>
        <key>IDECodeSnippetTitle</key>
        <string>getDefaultHeaders()</string>
        <key>IDECodeSnippetUserSnippet</key>
        <true/>
        <key>IDECodeSnippetVersion</key>
        <integer>0</integer>
</dict>
</plist>
```

## References

- [Menubar app tutorial](https://www.raywenderlich.com/98178/os-x-tutorial-menus-popovers-menu-bar-apps)
- [Swift Git library](https://github.com/SwiftGit2/SwiftGit2)
- [How do I run an terminal command in a swift script?](https://stackoverflow.com/a/26973384)

```swift
#!/usr/bin/env swift

import Foundation

@discardableResult
func shell(_ args: String...) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

shell("ls")
shell("xcodebuild", "-workspace", "myApp.xcworkspace")
```
