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
    let configRepoMenuItem = NSMenuItem(title: "Set Repo", action: #selector(showRepoConfig(sender:)), keyEquivalent: "r")
    let configGithubAPIUrlMenuItem = NSMenuItem(title: "Set Github API Url", action: #selector(showGithubAPIUrlConfig(sender:)), keyEquivalent: "a")
    let configGithubTokenMenuItem = NSMenuItem(title: "Set Github Token", action: #selector(showGithubTokenConfig(sender:)), keyEquivalent: "t")
    let configShowMenuItem = NSMenuItem(title: "Show Config", action: #selector(showCurrentConfig(sender:)), keyEquivalent: "")
    let configResetMenuItem = NSMenuItem(title: "Reset Config", action: #selector(resetConfig(sender:)), keyEquivalent: "")
    let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(terminate(sender:)), keyEquivalent: "q")
    let environment: [String: String] = [:]
    let dateFormatter = DateFormatter()
    var isSyncing = false
    
    var repo: String {
        get {
            return UserDefaults.standard.string(forKey: Const.UserDefaults.repo.rawValue) ?? "git@github.com:ivanfoong/xcode-swift-snippets.git"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Const.UserDefaults.repo.rawValue)
        }
    }
    
    var githubToken: String {
        get {
            return UserDefaults.standard.string(forKey: Const.UserDefaults.githubToken.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Const.UserDefaults.githubToken.rawValue)
        }
    }
    
    var githubAPIUrl: String {
        get {
            return UserDefaults.standard.string(forKey: Const.UserDefaults.githubAPIUrl.rawValue) ?? "http://github.com/api/v3/repos/ivanfoong/xcode-swift-snippets"
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
        menu.addItem(syncMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(configRepoMenuItem)
        menu.addItem(configGithubAPIUrlMenuItem)
        menu.addItem(configGithubTokenMenuItem)
        menu.addItem(configShowMenuItem)
        menu.addItem(configResetMenuItem)
        menu.addItem(quitMenuItem)
        menu.delegate = self
        statusItem.menu = menu
        
        if self.githubToken == "" {
            showConfigWizard()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func showConfigWizard() {
        let a = NSAlert()
        a.messageText = "Configs"
        a.addButton(withTitle: "Save")
        a.addButton(withTitle: "Cancel")
        
        let repoInputTextField = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        repoInputTextField.placeholderString = "git@github.com:ivanfoong/xcode-swift-snippets.git"
        let githubAPIUrlInputTextField = NSTextField(frame: NSRect(x: 0, y: 28, width: 300, height: 24))
        githubAPIUrlInputTextField.placeholderString = "http://github.com/api/v3/repos/ivanfoong/xcode-swift-snippets"
        let githubTokenInputTextField = NSTextField(frame: NSRect(x: 0, y: 56, width: 300, height: 24))
        githubTokenInputTextField.placeholderString = "Token"
        
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
            self.repo = repoString
            self.githubAPIUrl = githubAPIUrlString
            self.githubToken = githubTokenString
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
        
        self.startingToSync()
        let url = URL(string: "\(githubAPIUrl)/pulls")!
        let engine = SniPositoryCore(githubAPIPullUrl: url, githubToken: self.githubToken, snippetPath: self.snippetPath())
        DispatchQueue.global().async {
            engine.initGit(with: self.repo)
            engine.sync(with: self.environment, verbose: true)
            self.completedSyncing()
        }
    }
    
    @objc
    func showRepoConfig(sender: AnyObject) {
        if let repo = self.showConfig(with: "Enter repo:", and: "git@github.com:ivanfoong/xcode-swift-snippets.git") {
            self.repo = repo
        }
    }
    
    @objc
    func showGithubAPIUrlConfig(sender: AnyObject) {
        if let githubAPIUrl = self.showConfig(with: "Enter Github API Url:", and: "https://api.github.com/repos/ivanfoong/xcode-swift-snippets") {
            self.githubAPIUrl = githubAPIUrl
        }
    }
    
    @objc
    func showGithubTokenConfig(sender: AnyObject) {
        if let githubToken = self.showConfig(with: "Enter Github Token:", and: "Token") {
            self.githubToken = githubToken
        }
    }
    
    @objc
    func resetConfig(sender: AnyObject) {
        self.resetConfig()
    }
    
    @objc
    func showCurrentConfig(sender: AnyObject) {
        self.showCurrentConfig()
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
    
    private func resetConfig() {
        UserDefaults.standard.set(nil, forKey: Const.UserDefaults.repo.rawValue)
        UserDefaults.standard.set(nil, forKey: Const.UserDefaults.githubToken.rawValue)
        UserDefaults.standard.set(nil, forKey: Const.UserDefaults.githubAPIUrl.rawValue)
    }
    
    private func showCurrentConfig() {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "Current Config"
        myPopup.informativeText = "Repo: \(self.repo)\nGithub API Url: \(self.githubAPIUrl)\nGithub Token: \(self.githubToken)"
        myPopup.alertStyle = NSAlert.Style.warning
        myPopup.addButton(withTitle: "OK")
        myPopup.runModal()
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
}

