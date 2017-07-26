//
//  Git.swift
//  SniPository
//
//  Created by Ivan Foong Kwok Keong on 17/7/17.
//  Copyright © 2017 ivanfoong. All rights reserved.
//

protocol FileType {
    var filename: String { get }
}

protocol GitFileType: FileType {
    var status: GitFileStatus { get }
}

struct File: FileType {
    let filename: String
}

struct GitFile: GitFileType {
    let filename: String
    let status: GitFileStatus
}

enum GitFileStatus {
    case notUpdated, updatedInIndex, addedToIndex, deletedFromIndex, renamedInIndex, copiedInIndex, unmergedBothDeleted, unmergedAddedByUs, unmergedDeletedByThem, unmergedAddedByThem, unmergedDeletedByUs, unmergedBothAdded, unmergedBothModified
}

enum GitFileStatusCode: String {
    case unmodified = " "
    case modified = "M"
    case added = "A"
    case deleted = "D"
    case renamed = "R"
    case copied = "C"
    case updatedAndUnmerged = "U"
}

struct GitStatus {
    var files: [GitFile]
    var untrackedFiles: [File]
    var ignoredFiles: [File]
}

class Git {
    typealias GitPath = String
    typealias GitRemoteURL = String
    typealias GitRemoteName = String
    typealias GitBranchName = String
    typealias GitResult = (command: String, output: CommandLine.Output)
    
    @discardableResult
    func initialize(at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let command = "git init"
        let output = CommandLine().exec(command: command, at: path, with: environment, verbose: verbose)
        return (true, (command, output))
    }
    
    func status(at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (status: GitStatus?, result: GitResult) {
        let command = "git status --porcelain --ignored"
        let output = CommandLine().exec(command: command, at: path, with: environment, verbose: verbose)
        if output.exitCode != 0 {
            return (nil, (command, output))
        }
        var files: [GitFile] = []
        var untrackedFiles: [File] = []
        var ignoredFiles: [File] = []
        for line in output.output {
            let stagedStatusCode = line.substring(to: line.index(line.startIndex, offsetBy: 1))
            let unstagedStatusCode = line.substring(with: line.index(line.startIndex, offsetBy: 1)..<line.index(line.startIndex, offsetBy: 2))
            let filename = line.substring(from: line.index(line.startIndex, offsetBy: 3))
            
            if stagedStatusCode == "!" && unstagedStatusCode == "!" {
                // ignored file
                ignoredFiles.append(File(filename: filename))
            } else if stagedStatusCode == "?" && unstagedStatusCode == "?" {
                // untracked file
                untrackedFiles.append(File(filename: filename))
            } else if let stagedStatus = GitFileStatusCode.init(rawValue: stagedStatusCode), let unstagedStatus = GitFileStatusCode.init(rawValue: unstagedStatusCode) {
                switch(stagedStatus, unstagedStatus) {
                case (.unmodified, .modified), (.unmodified, .deleted):
                    // not updated
                    files.append(GitFile(filename: filename, status: .notUpdated))
                case (.modified, .unmodified), (.modified, .modified), (.modified, .deleted):
                    // updated in index
                    files.append(GitFile(filename: filename, status: .updatedInIndex))
                case (.added, .unmodified), (.added, .modified), (.added, .deleted):
                    // added to index
                    files.append(GitFile(filename: filename, status: .addedToIndex))
                case (.deleted, .unmodified), (.deleted, .modified):
                    // deleted from index
                    files.append(GitFile(filename: filename, status: .deletedFromIndex))
                case (.renamed, .unmodified), (.renamed, .modified), (.renamed, .deleted):
                    // renamed in index
                    files.append(GitFile(filename: filename, status: .renamedInIndex))
                case (.copied, .unmodified), (.copied, .modified), (.copied, .deleted):
                    // copied in index
                    files.append(GitFile(filename: filename, status: .copiedInIndex))
                case (.deleted, .deleted):
                    // unmerged, both deleted
                    files.append(GitFile(filename: filename, status: .unmergedBothDeleted))
                case (.added, .updatedAndUnmerged):
                    // unmerged, added by us
                    files.append(GitFile(filename: filename, status: .unmergedAddedByUs))
                case (.updatedAndUnmerged, .deleted):
                    // unmerged, deleted by them
                    files.append(GitFile(filename: filename, status: .unmergedDeletedByThem))
                case (.updatedAndUnmerged, .added):
                    // unmerged, added by them
                    files.append(GitFile(filename: filename, status: .unmergedAddedByThem))
                case (.deleted, .updatedAndUnmerged):
                    // unmerged, deleted by us
                    files.append(GitFile(filename: filename, status: .unmergedDeletedByUs))
                case (.added, .added):
                    // unmerged, both added
                    files.append(GitFile(filename: filename, status: .unmergedBothAdded))
                case (.updatedAndUnmerged, .updatedAndUnmerged):
                    // unmerged, both modified
                    files.append(GitFile(filename: filename, status: .unmergedBothModified))
                default:
                    // TODO
                    assertionFailure("Unexpected XY combination: \(stagedStatusCode), \(unstagedStatusCode)")
                }
            }
        }
        let status = GitStatus(files: files, untrackedFiles: untrackedFiles, ignoredFiles: ignoredFiles)
        return (status, (command, output))
    }
    
    @discardableResult
    func add(file: String, at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let command = "git add \(file)"
        let output = CommandLine().exec(command: command, at: path, with: environment, verbose: verbose)
        return (output.exitCode==0, (command, output))
    }
    
    @discardableResult
    func addAllFiles(at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let command = "git add --all"
        let output = CommandLine().exec(command: command, at: path, with: environment, verbose: verbose)
        return (output.exitCode==0, (command, output))
    }
    
    @discardableResult
    func commit(with message: String, at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let commands = ["git", "commit", "-m \(message)"]
        let output = CommandLine().exec(commands: commands, at: path, with: environment, verbose: verbose)
        return (output.exitCode == 0, (commands.joined(separator: " "), output))
    }
    
    @discardableResult
    func add(remote url: GitRemoteURL, for name: GitRemoteName, at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let command = "git remote add \(name) \(url)"
        let output = CommandLine().exec(command: command, at: path, with: environment, verbose: verbose)
        return (output.exitCode == 0, (command, output))
    }
    
    func listRemote(for name: GitRemoteName, at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (remoteUrl: GitRemoteURL?, result: GitResult) {
        let command = "git ls-remote --get-url \(name)"
        let output = CommandLine().exec(command: command, at: path, with: environment, verbose: verbose)
        var remoteUrl: GitRemoteURL?
        if output.exitCode == 0 && output.output.count > 0 && output.output[0] != "" {
            remoteUrl = output.output[0]
        }
        return (remoteUrl, (command, output))
    }
    
    @discardableResult
    func pull(branch: GitBranchName, from remoteName: GitRemoteName, at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let commands = ["git", "pull", remoteName, branch, "--rebase", "-X ours"]
        let output = CommandLine().exec(commands: commands, at: path, with: environment, verbose: verbose)
        return (output.exitCode == 0, (commands.joined(separator: " "), output))
    }
    
    @discardableResult
    func push(branch: GitBranchName, for remoteName: GitRemoteName, at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let commands = ["git", "push", remoteName, branch]
        let output = CommandLine().exec(commands: commands, at: path, with: environment, verbose: verbose)
        return (output.exitCode == 0, (commands.joined(separator: " "), output))
    }
    
    @discardableResult
    func checkout(file: String, at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let commands = ["git", "checkout", "--theirs", file]
        let output = CommandLine().exec(commands: commands, at: path, with: environment, verbose: verbose)
        return (output.exitCode == 0, (commands.joined(separator: " "), output))
    }
    
    @discardableResult
    func create(branch: String, at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let commands = ["git", "branch", branch]
        let output = CommandLine().exec(commands: commands, at: path, with: environment, verbose: verbose)
        return (output.exitCode == 0, (commands.joined(separator: " "), output))
    }
    
    @discardableResult
    func checkout(branch: String, at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let commands = ["git", "checkout", branch]
        let output = CommandLine().exec(commands: commands, at: path, with: environment, verbose: verbose)
        return (output.exitCode == 0, (commands.joined(separator: " "), output))
    }
    
    @discardableResult
    func rebaseContinue(at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let command = "git rebase --continue"
        let output = CommandLine().exec(command: command, at: path, with: environment, verbose: verbose)
        return (output.exitCode == 0, (command, output))
    }
    
    @discardableResult
    func reset(at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let command = "git reset HEAD~1"
        let output = CommandLine().exec(command: command, at: path, with: environment, verbose: verbose)
        return (output.exitCode == 0, (command, output))
    }
    
    @discardableResult
    func stashSave(at path: GitPath, includeUntracked: Bool = true, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let command = "git stash save -u"
        let output = CommandLine().exec(command: command, at: path, with: environment, verbose: verbose)
        return (output.exitCode == 0, (command, output))
    }
    
    @discardableResult
    func stashApply(at path: GitPath, for index: Int = 0, includeUntracked: Bool = true, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let command = "git stash apply stash@{\(index)}"
        let output = CommandLine().exec(command: command, at: path, with: environment, verbose: verbose)
        return (output.exitCode == 0, (command, output))
    }
    
    @discardableResult
    func stashDrop(at path: GitPath, for index: Int = 0, includeUntracked: Bool = true, with environment: [String: String] = [:], verbose: Bool = false) -> (success: Bool, result: GitResult) {
        let command = "git stash drop stash@{\(index)}"
        let output = CommandLine().exec(command: command, at: path, with: environment, verbose: verbose)
        return (output.exitCode == 0, (command, output))
    }
    
    func updatedFiles(at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (updatedFiles: [String]?, result: GitResult) {
        let commands = ["git", "diff", "--name-only", "--diff-filter=U"]
        let output = CommandLine().exec(commands: commands, at: path, with: environment, verbose: verbose)
        
        if output.exitCode != 0 {
            return (nil, (commands.joined(separator: " "), output))
        }
        
        let filenames = output.output.flatMap { line -> String? in
            if line != "" {
                return line
            }
            return nil
        }
        return (filenames, (commands.joined(separator: " "), output))
    }
    
    func currentBranch(at path: GitPath, with environment: [String: String] = [:], verbose: Bool = false) -> (currentBranchName: GitBranchName?, result: GitResult) {
        let command = "git rev-parse --abbrev-ref HEAD"
        let output = CommandLine().exec(command: command, at: path, with: environment, verbose: verbose)
        
        if output.exitCode != 0 {
            return (nil, (command, output))
        }
        
        var currentBranchName: GitBranchName?
        if output.output.count > 0 && output.output[0] != "" {
            currentBranchName = output.output[0]
        }
        
        return (currentBranchName, (command, output))
    }
}
