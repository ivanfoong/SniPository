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
            return UserDefaults.standard.string(forKey: Const.UserDefaults.githubAPIUrl.rawValue) ?? "https://api.github.com/repos/ivanfoong/xcode-swift-snippets"
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
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func terminate(sender: AnyObject) {
        NSApplication.shared.terminate(sender)
    }
    
    @objc func sync(sender: AnyObject) {
        if isSyncing { return }
        
        isSyncing = true
        if hasUncommitedChanges() {
            DispatchQueue.global().async {
                // pull repo and rebase changes as working
                self.pullAndRebase()
                
                // save stash to be able to restore unmerged changes
                self.saveWorkingCodes()
                
                // identify new/updated snippets
                let updatedFiles = self.filesWithUncommitedChanges()
//                print(updatedFiles)
                
                // send PR for conflicts and new changes
                let path = self.snippetPath()
                updatedFiles.forEach { file in
                    let filepath = "\(path)/\(file)"
                    let url = URL(fileURLWithPath: filepath)
                    if let data = try? Data(contentsOf: url), let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil), let resultDict = result as? [String: Any] {
                        if let title = resultDict["IDECodeSnippetTitle"] as? String, let contents = resultDict["IDECodeSnippetContents"] as? String, let completionPrefix = resultDict["IDECodeSnippetCompletionPrefix"] as? String {
                            var summary = title
                            if let foundSummary = resultDict["IDECodeSnippetSummary"] as? String {
                                summary = foundSummary
                            }
                            let snippet = Snippet(filename: file, title: title, summary: summary, completionPrefix: completionPrefix, contents: contents)
                            //                    print("gitCheckout(master)", gitCheckout(branch: "master"))
                            self.createPR(for: snippet)
                        } else {
                            //TODO show error
                            print("Failed to read snippet's title, content or completion prefix from plist")
                        }
                    } else {
                        //TODO show error
                        print("Failed to read snippet from plist")
                    }
                }
                
                // restore stash onto master to keep unmerged changes
                self.restoreWorkingCodes()
                self.completedSyncing()
            }
        } else {
            DispatchQueue.global().async {
                self.gitInit()
                self.gitPull()
                self.completedSyncing()
            }
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
    
    private func completedSyncing() {
        self.lastSyncDate = Date()
        self.isSyncing = false
    }
    
    private func saveWorkingCodes() {
        self.gitStash()
        self.gitStashApply()
    }
    
    private func restoreWorkingCodes() {
        self.gitStashApply()
        self.gitStashDrop()
    }
    
    private func gitStash() -> (output: [String], error: [String], exitCode: Int32) {
        return self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "stash", "save", "-u")
    }
    
    private func gitStashApply(index: Int = 0) -> (output: [String], error: [String], exitCode: Int32) {
        return self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "stash", "apply", "stash@{\(index)}")
    }
    
    private func gitStashDrop(index: Int = 0) -> (output: [String], error: [String], exitCode: Int32) {
        return self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "stash", "drop", "stash@{\(index)}")
    }
    
    private func gitCommitAllChanges() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let timestamp = dateFormatter.string(from: Date())
        self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "add", ".")
        self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "commit", "-m", "\"Latest commit as of \(timestamp)\"")
    }
    
    private func gitInit() {
        self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "init", ".")
        self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "remote", "add", "origin", self.repo)
    }
    
    enum MergeStrategy {
        case Ours, Theirs
    }
    
    private func gitPull(mergeStrategy: MergeStrategy = .Ours) -> (output: [String], error: [String], exitCode: Int32) {
        switch mergeStrategy {
        case .Ours:
            return self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "pull", "origin", "master", "-X", "ours")
        case .Theirs:
            return self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "pull", "origin", "master", "-X", "theirs")
        }
        
    }
    
    private func gitStatus(silent: Bool = true) -> (output: [String], error: [String], exitCode: Int32) {
        if silent {
            return self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "status", "-s")
        }
        return self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "status")
    }
    
    private func gitCreate(branch: String) -> (output: [String], error: [String], exitCode: Int32) {
        return self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "checkout", "-b", branch)
    }
    
    private func gitTrack(branch: String) -> (output: [String], error: [String], exitCode: Int32) {
        return self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "branch", "-u", "origin/\(branch)", branch)
    }
    
    private func gitCheckout(branch: String) -> (output: [String], error: [String], exitCode: Int32) {
        return self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "checkout", branch)
    }
    
    private func gitAdd(filename: String) -> (output: [String], error: [String], exitCode: Int32) {
        return self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "add", filename)
    }
    
    private func gitCommit(with message: String) -> (output: [String], error: [String], exitCode: Int32) {
        return self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "commit", "-m", message)
    }
    
    private func gitPush(branch: String = "master") -> (output: [String], error: [String], exitCode: Int32) {
        return self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "push", "origin", branch)
    }
    
    private func hasUncommitedChanges() -> Bool {
        let (output, _, _) = gitStatus()
        return output.count > 0 && output[0] != ""
    }
    
    private func filesWithUncommitedChanges() -> [String] {
        let (output, _, _) = gitStatus()
        let filenames = output.flatMap { line -> String? in
            let tokens = line.components(separatedBy: " ")
            return tokens[tokens.count-1]
        }
        return filenames
    }
    
    private func filesWithConflicts() -> [String] {
        let (output, _, _) = self.shell(at: self.snippetPath(), with: self.environment, "git", "diff", "--name-only", "--diff-filter=U")
        let filenames = output.flatMap { line -> String? in
            return line
        }
        return filenames
        
    }
    
    private func pullAndRebase() {
        self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "add", "--all")
        self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "commit", "-m", "[STASH]")
        self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "pull", "--rebase", "origin", "master")
        
        let conflictFiles = self.filesWithConflicts()
        conflictFiles.forEach { file in
            self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "checkout", "--theirs", "--", file)
            self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "add", file)
        }
        self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "rebase", "--continue")
        self.shell(at: self.snippetPath(), with: self.environment, verbose: VERBOSE, "git", "reset", "HEAD~1")
    }
    
    private func snippetPath() -> String {
        let homeDirectory = NSHomeDirectory()
        let snippetPath = homeDirectory.appending("/Library/Developer/Xcode/UserData/CodeSnippets")
        return snippetPath
    }
    
    private func createPR(for snippet: Snippet) {
        let branch = snippet.completionPrefix
        
        gitStash()
        
        // create branch
        gitCreate(branch: branch)
        // gitTrack(branch: branch)
        
        gitStashApply()
        gitStashDrop()
        
        // commit and push branch
        gitAdd(filename: snippet.filename)
        gitCommit(with: "Updating for \(snippet.filename)")
        gitPush(branch: branch)
        
        // create PR
        let prBody = "## Description\n" +
            snippet.summary + "\n" +
            "## Snippet\n" +
            "```\n" +
            snippet.contents + "\n" +
            "```\n"
        let dict = [
            "title": snippet.title,
            "body": prBody,
            "head": branch,
            "base": "master"
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        guard let httpBody = jsonData else {
            return
        }
        
        var request = URLRequest(url: URL(string: "\(githubAPIUrl)/pulls")!)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("token \(githubToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                //TODO return error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                //TODO return error
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            if VERBOSE {
                print("responseString = \(responseString)")
            }
        }
        task.resume()
        
        gitCheckout(branch: "master")
    }
    
    @discardableResult
    fileprivate func shell(at path: String, with environment: [String: String], verbose: Bool = false, _ args: String...) -> (output: [String], error: [String], exitCode: Int32) {
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
        
        if verbose {
            print("shell:",
                  "\n- command:", args.joined(separator: " "),
                  "\n- outputs:", output,
                  "\n- errors:", error,
                  "\n- exitCode:", status
            )
        }
        
        return (output, error, status)
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
