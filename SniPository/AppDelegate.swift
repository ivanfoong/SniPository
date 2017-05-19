//
//  AppDelegate.swift
//  SniPository
//
//  Created by Ivan Foong Kwok Keong on 31/5/17.
//  Copyright © 2017 ivanfoong. All rights reserved.
//

import Cocoa

let VERBOSE = true

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover = NSPopover()
    let menu = NSMenu()
    let syncMenuItem = NSMenuItem(title: "Sync", action: #selector(sync(sender:)), keyEquivalent: "s")
    let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(terminate(sender:)), keyEquivalent: "q")
    let environment: [String: String] = [:]
    var lastSyncDate = Date()
    let dateFormatter = DateFormatter()
    let repo = "https://github.com/ivanfoong/xcode-swift-snippets.git" // TODO: needs to be configurable
    var isSyncing = false
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        dateFormatter.locale = Locale.current
        
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImage"))
        }
        menu.addItem(syncMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitMenuItem)
        menu.delegate = self
        statusItem.menu = menu
        
        sync(sender: self)
        
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "environment"
        myPopup.informativeText = ProcessInfo.processInfo.environment.description
        myPopup.alertStyle = NSAlert.Style.warning
        myPopup.addButton(withTitle: "OK")
        myPopup.runModal()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func terminate(sender: AnyObject) {
        NSApplication.shared.terminate(sender)
    }
    
    @objc func sync(sender: AnyObject) {
        if isSyncing { return }
        
        if hasUncommitedChanges() {
            isSyncing = true
            DispatchQueue.global().async {
                self.gitStash()
                self.gitPull()
                self.gitStashApply()
                self.gitCommitAllChanges()
                self.gitPull()
                self.gitPush()
                self.lastSyncDate = Date()
                self.isSyncing = false
            }
        } else {
            isSyncing = true
            DispatchQueue.global().async {
                self.gitInit()
                self.gitPull()
                self.lastSyncDate = Date()
                self.isSyncing = false
            }
        }
    }
    
    private func gitStash() {
        if VERBOSE { print("gitStash") }
        self.shell(at: self.snippetPath(), with: self.environment, "git", "stash")
    }
    
    private func gitStashApply() {
        if VERBOSE { print("gitStashApply") }
        self.shell(at: self.snippetPath(), with: self.environment, "git", "stash", "apply")
    }
    
    private func gitCommitAllChanges() {
        if VERBOSE { print("gitCommitAllChanges") }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let timestamp = dateFormatter.string(from: Date())
        self.shell(at: self.snippetPath(), with: self.environment, "git", "add", ".")
        self.shell(at: self.snippetPath(), with: self.environment, "git", "commit", "-m", "\"Latest commit as of \(timestamp)\"")
    }
    
    private func gitInit() {
        if VERBOSE { print("gitInit") }
        self.shell(at: self.snippetPath(), with: self.environment, "git", "init", ".")
        self.shell(at: self.snippetPath(), with: self.environment, "git", "remote", "add", "origin", self.repo)
    }
    
    private func gitPull() {
        if VERBOSE { print("gitPull") }
        self.shell(at: self.snippetPath(), with: self.environment, "git", "pull", "origin", "master")
    }
    
    private func gitPush() {
        if VERBOSE { print("gitPush") }
        self.shell(at: self.snippetPath(), with: self.environment, "git", "push", "origin", "master")
    }
    
    private func hasUncommitedChanges() -> Bool {
        let (output, _, _) = self.shell(at: self.snippetPath(), with: self.environment, "git", "status", "-s")
        return output.count > 0
    }
    
    private func snippetPath() -> String {
        let homeDirectory = NSHomeDirectory()
        let snippetPath = homeDirectory.appending("/Library/Developer/Xcode/UserData/CodeSnippets")
        return snippetPath
    }
    
    @discardableResult
    fileprivate func shell(at path: String, with environment: [String: String], _ args: String...) -> (output: [String], error: [String], exitCode: Int32) {
        var output: [String] = []
        var error: [String] = []
        
        let task = Process()
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launchPath = "/usr/bin/env"
        task.currentDirectoryPath = path
        task.arguments = args
//        print(ProcessInfo.processInfo.environment)
        
        task.environment = environment
//        print(task.environment)
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: NSCharacterSet.newlines)
            output = string.components(separatedBy: "\n")
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: NSCharacterSet.newlines)
            error = string.components(separatedBy: "\n")
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        if isSyncing {
            syncMenuItem.title = "Sync (Syncing)"
        } else {
            syncMenuItem.title = "Sync (Last Sync: \(lastSyncDate.timeAgo))"
        }
    }
}
