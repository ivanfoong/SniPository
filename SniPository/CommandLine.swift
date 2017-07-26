//
//  CommandLine.swift
//  SniPository
//
//  Created by Ivan Foong Kwok Keong on 17/7/17.
//  Copyright © 2017 ivanfoong. All rights reserved.
//

import Foundation

class CommandLine {
    typealias Output = (output: [String], error: [String], exitCode: Int32)
    
    var history: [Output] = []
    var defaultEnvironment: [String: String] {
        return ProcessInfo.processInfo.environment
    }
    
    @discardableResult
    func exec(commands: [String], at path: String, with environment: [String: String] = [:], verbose: Bool = false) -> Output {
        var output: [String] = []
        var error: [String] = []
        
        let task = Process()
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launchPath = "/usr/bin/env"
        task.currentDirectoryPath = path
        task.arguments = commands
        var finalEnvironment = self.defaultEnvironment
        environment.forEach { finalEnvironment[$0.key] = $0.value }
        task.environment = finalEnvironment
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: NSCharacterSet.newlines)
            output = string.components(separatedBy: "\n").filter{$0 != ""}
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: NSCharacterSet.newlines)
            error = string.components(separatedBy: "\n").filter{$0 != ""}
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        if verbose {
            print("shell:",
                  "\n- command:", commands.joined(separator: " "),
                  "\n- outputs:", output,
                  "\n- errors:", error,
                  "\n- exitCode:", status
            )
        }
        
        let historyEntry = (output, error, status)
        self.history.append(historyEntry)
        return historyEntry
    }
    
    @discardableResult
    func exec(command: String, at path: String, with environment: [String: String] = [:], verbose: Bool = false) -> Output {
        let commands = command.components(separatedBy: " ") //TODO @ivanfoong: handle "-x blah" as single argument
        return exec(commands: commands, at: path, with: environment, verbose: verbose)
    }
}
