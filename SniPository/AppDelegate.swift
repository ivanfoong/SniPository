//
//  AppDelegate.swift
//  SniPository
//
//  Created by Ivan Foong Kwok Keong on 31/5/17.
//  Copyright © 2017 ivanfoong. All rights reserved.
//

import Cocoa

let VERBOSE = true

struct Const {
    enum UserDefaults: String {
        case repo = "repo"
        case githubAPIUrl = "github_api_url"
        case githubToken = "github_token"
        case lastSyncDate = "last_sync_date"
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover = NSPopover()
    let menu = NSMenu()
    let syncMenuItem = NSMenuItem(title: "Sync", action: #selector(sync(sender:)), keyEquivalent: "s")
    let configMenuItem = NSMenuItem(title: "Config", action: #selector(showConfig(sender:)), keyEquivalent: ",")
    let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(terminate(sender:)), keyEquivalent: "q")
    let environment: [String: String] = [:]
    let dateFormatter = DateFormatter()
    var isSyncing = false
    
    var repo: String? {
        get {
            return UserDefaults.standard.string(forKey: Const.UserDefaults.repo.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Const.UserDefaults.repo.rawValue)
        }
    }
    
    var githubToken: String? {
        get {
            return UserDefaults.standard.string(forKey: Const.UserDefaults.githubToken.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Const.UserDefaults.githubToken.rawValue)
        }
    }
    
    var githubAPIUrl: String? {
        get {
            return UserDefaults.standard.string(forKey: Const.UserDefaults.githubAPIUrl.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Const.UserDefaults.githubAPIUrl.rawValue)
        }
    }
    
    var lastSyncDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: Const.UserDefaults.lastSyncDate.rawValue) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Const.UserDefaults.lastSyncDate.rawValue)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        dateFormatter.locale = Locale.current
        
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImage"))
        }
        menu.autoenablesItems = false
        menu.addItem(syncMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(configMenuItem)
        menu.addItem(quitMenuItem)
        menu.delegate = self
        statusItem.menu = menu
        
        if self.repo == nil || self.githubAPIUrl == nil || self.githubToken == nil {
            self.showConfigPrompt()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func showConfigPrompt() {
        let a = NSAlert()
        a.messageText = "Configs"
        a.addButton(withTitle: "Save")
        a.addButton(withTitle: "Cancel")
        
        let repoInputTextField = NSTextField(frame: NSRect(x: 0, y: 56, width: 300, height: 24))
        repoInputTextField.placeholderString = "git@github.com:ivanfoong/xcode-swift-snippets.git"
        repoInputTextField.stringValue = self.repo ?? ""
        let githubAPIUrlInputTextField = NSTextField(frame: NSRect(x: 0, y: 28, width: 300, height: 24))
        githubAPIUrlInputTextField.placeholderString = "http://github.com/api/v3/repos/ivanfoong/xcode-swift-snippets"
        githubAPIUrlInputTextField.stringValue = self.githubAPIUrl ?? ""
        let githubTokenInputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        githubTokenInputTextField.placeholderString = "<Github Personal API Token>"
        githubTokenInputTextField.stringValue = self.githubToken ?? ""
        
        let containerView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 90))
        containerView.addSubview(repoInputTextField)
        containerView.addSubview(githubAPIUrlInputTextField)
        containerView.addSubview(githubTokenInputTextField)
        
        a.accessoryView = containerView
        let response = a.runModal()
        switch response {
        case .alertFirstButtonReturn: //Save
            let repoString = repoInputTextField.stringValue
            let githubAPIUrlString = githubAPIUrlInputTextField.stringValue
            let githubTokenString = githubTokenInputTextField.stringValue
            self.repo = repoString == "" ? nil : repoString
            self.githubAPIUrl = githubAPIUrlString == "" ? nil : githubAPIUrlString
            self.githubToken = githubTokenString == "" ? nil : githubTokenString
        case .alertSecondButtonReturn: //Cancel
            break
        default:
            break
        }
    }
    
    @objc func terminate(sender: AnyObject) {
        NSApplication.shared.terminate(sender)
    }
    
    @objc func sync(sender: AnyObject) {
        if isSyncing { return }
        
        if let repo = self.repo, let githubAPIUrl = self.githubAPIUrl, let githubToken = self.githubToken {
            self.startingToSync()
            let url = URL(string: "\(githubAPIUrl)/pulls")!
            let engine = SniPositoryCore(githubAPIPullUrl: url, githubToken: githubToken, snippetPath: self.snippetPath())
            DispatchQueue.global().async {
                engine.initGit(with: repo)
                engine.sync(with: self.environment, verbose: true)
                self.completedSyncing()
            }
        } else {
            showConfigPrompt()
        }
    }
    
    private func showConfig(with message: String, and placeholder: String) -> String? {
        let a = NSAlert()
        a.messageText = message
        a.addButton(withTitle: "Save")
        a.addButton(withTitle: "Cancel")
        
        let inputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        inputTextField.placeholderString = placeholder
        a.accessoryView = inputTextField
        let response = a.runModal()
        switch response {
        case .alertFirstButtonReturn: //Save
            let enteredString = inputTextField.stringValue
            print("Entered string = \"\(enteredString)\"")
            return enteredString
        case .alertSecondButtonReturn: //Cancel
            break
        default:
            break
        }
        return nil
    }
    
    @objc
    func showConfig(sender: AnyObject) {
        showConfigPrompt()
    }
    
    private func startingToSync() {
        self.isSyncing = true
    }
    
    private func completedSyncing() {
        self.lastSyncDate = Date()
        self.isSyncing = false
    }
    
    private func snippetPath() -> String {
        let homeDirectory = NSHomeDirectory()
        let snippetPath = homeDirectory.appending("/Library/Developer/Xcode/UserData/CodeSnippets")
        return snippetPath
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        syncMenuItem.isEnabled = !isSyncing
        var syncMenuItemTitle: String
        if isSyncing {
            syncMenuItemTitle = "Sync (Syncing)"
        } else if let lastSyncDate = lastSyncDate {
            syncMenuItemTitle = "Sync (Last Sync: \(lastSyncDate.timeAgo))"
        } else {
            syncMenuItemTitle = "Sync (Last Sync: Never)"
        }
        syncMenuItem.title = syncMenuItemTitle
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return menuItem == self.syncMenuItem
    }
}

