//
//  SniPositoryCore.swift
//  SniPository
//
//  Created by Ivan Foong Kwok Keong on 14/7/17.
//  Copyright © 2017 ivanfoong. All rights reserved.
//

import Foundation

class SniPositoryCore {
    lazy var snippetPath: String = {
        return self.defaultSnippetPath
    }()
    
    var githubAPIPullUrl: URL
    var githubToken: String
    var github: GithubProtocol
    
    init(githubAPIPullUrl: URL, githubToken: String, github: GithubProtocol = Github()) {
        self.githubAPIPullUrl = githubAPIPullUrl
        self.githubToken = githubToken
        self.github = github
    }
    
    convenience init(githubAPIPullUrl: URL, githubToken: String, snippetPath: String, github: GithubProtocol = Github()) {
        self.init(githubAPIPullUrl: githubAPIPullUrl, githubToken: githubToken, github: github)
        self.snippetPath = snippetPath
    }
    
    @discardableResult
    func initGit(with remoteURL: String, with environment: [String: String] = [:], verbose: Bool = false) -> Bool {
        if !FileManager.default.fileExists(atPath: self.snippetPath.appending("/.git")) {
            // if .git not available
            Git().initialize(at: self.snippetPath, with: environment, verbose: verbose)
            Git().add(remote: remoteURL, for: "origin", at: self.snippetPath, with: environment, verbose: verbose)
        }
        Git().pull(branch: "master", from: "origin", at: self.snippetPath, with: environment, verbose: verbose)
        let (status, _) = Git().status(at: self.snippetPath, with: environment, verbose: verbose)
        return status != nil
    }
    
    @discardableResult
    func sync(with environment: [String: String] = [:], verbose: Bool = false) -> Bool {
        if filesWithUncommitedChanges().count > 0 {
            Git().addAllFiles(at: self.snippetPath)
            Git().commit(with: "[STASH]", at: self.snippetPath)
            let (success, _) = Git().pull(branch: "master", from: "origin", at: self.snippetPath)
            let (updatedFiles, _) = Git().updatedFiles(at: self.snippetPath)
            if let updatedFiles = updatedFiles, updatedFiles.count > 0 {
                for updatedFile in updatedFiles {
                    Git().checkout(file: updatedFile, at: self.snippetPath)
                    Git().add(file: updatedFile, at: self.snippetPath)
                }
                Git().rebaseContinue(at: self.snippetPath)
            }
            Git().reset(at: self.snippetPath)
            Git().stashSave(at: self.snippetPath)
            Git().stashApply(at: self.snippetPath)
            var hasFailedPRRequest = false
            for updatedFile in self.filesWithUncommitedChanges() {
                guard let snippet = self.parse(snippetFile: updatedFile) else {
                    //TODO handle failure to read snippet plist
                    continue
                }
                Git().stashSave(at: self.snippetPath)
                Git().create(branch: snippet.completionPrefix, at: self.snippetPath)
                let (_, r) = Git().checkout(branch: snippet.completionPrefix, at: self.snippetPath)
                print(r)
                Git().stashApply(at: self.snippetPath)
                Git().stashDrop(at: self.snippetPath)
                Git().add(file: updatedFile, at: self.snippetPath)
                Git().commit(with: "Updating for \(updatedFile)", at: self.snippetPath)
                Git().push(branch: snippet.completionPrefix, for: "origin", at: self.snippetPath)
                let waitGroup = DispatchGroup.init()
                waitGroup.enter()
                //TODO: ignore creating PR for only version change
                createPR(for: snippet, to: self.githubAPIPullUrl, with: self.githubToken) { (data, response, error) in
                    guard let data = data, error == nil else {                                                 // check for fundamental networking error
                        //TODO return error
                        print("error=\(error)")
                        hasFailedPRRequest = true
                        waitGroup.leave()
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 201 {           // check for http errors
                        hasFailedPRRequest = true
                        //TODO return error
                        print("statusCode should be 201, but is \(httpStatus.statusCode)")
                        print("response = \(response)")
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    if VERBOSE {
                        print("responseString = \(responseString)")
                    }
                    waitGroup.leave()
                }
                waitGroup.wait()
                if self.filesWithUncommitedChanges().count > 0 {
                    Git().stashSave(at: self.snippetPath)
                    Git().checkout(branch: "master", at: self.snippetPath)
                    Git().stashApply(at: self.snippetPath)
                    Git().stashDrop(at: self.snippetPath)
                } else {
                    Git().checkout(branch: "master", at: self.snippetPath)
                }
            }
            Git().stashApply(at: self.snippetPath)
            Git().stashDrop(at: self.snippetPath)
            return hasFailedPRRequest == false
        } else {
            let (success, _) = Git().pull(branch: "master", from: "origin", at: self.snippetPath)
            return success
        }
    }
    
    fileprivate func filesWithUncommitedChanges() -> [String] {
        let (_, result) = Git().status(at: self.snippetPath)
        let filenames = result.output.output.flatMap { line -> String? in
            let tokens = line.components(separatedBy: " ")
            return tokens[tokens.count-1]
        }
        return filenames
    }
    
    fileprivate func parse(snippetFile: String) -> Snippet? {
        var snippet: Snippet?
        let filepath = "\(self.snippetPath)/\(snippetFile)"
        let url = URL(fileURLWithPath: filepath)
        if let data = try? Data(contentsOf: url), let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil), let resultDict = result as? [String: Any] {
            if let title = resultDict["IDECodeSnippetTitle"] as? String, let contents = resultDict["IDECodeSnippetContents"] as? String, let completionPrefix = resultDict["IDECodeSnippetCompletionPrefix"] as? String {
                var summary = title
                if let foundSummary = resultDict["IDECodeSnippetSummary"] as? String {
                    summary = foundSummary
                }
                var version = 0
                if let foundVersion = resultDict["IDECodeSnippetVersion"] as? Int {
                    version = foundVersion
                }
                snippet = Snippet(filename: snippetFile, title: title, summary: summary, completionPrefix: completionPrefix, contents: contents, version: version)
            } else {
                //TODO show error
                print("Failed to read snippet's title, content or completion prefix from plist")
            }
        } else {
            //TODO show error
            print("Failed to read snippet from plist")
        }
        return snippet
    }
    
    fileprivate var defaultSnippetPath: String {
        let homeDirectory = NSHomeDirectory()
        let snippetPath = homeDirectory.appending("/Library/Developer/Xcode/UserData/CodeSnippets")
        return snippetPath
    }
    
    fileprivate func createPR(for snippet: Snippet, to githubURL: URL, with githubToken: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let body = "## Description\n" +
            snippet.summary + "\n" +
            "## Snippet\n" +
            "```\n" +
            snippet.contents + "\n" +
        "```\n"
        self.github.createPR(named: snippet.title, with: body, for: snippet.completionPrefix, to: "master", githubAPIPullUrl: self.githubAPIPullUrl, githubToken: githubToken) { (data, response, error) in
            completion(data, response, error)
        }
    }
}
