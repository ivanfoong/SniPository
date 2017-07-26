//
//  GitTests.swift
//  SniPositoryTests
//
//  Created by Ivan Foong Kwok Keong on 17/7/17.
//  Copyright © 2017 ivanfoong. All rights reserved.
//

import XCTest
@testable import SniPository

class GitTests: XCTestCase {
    
    lazy var path: String = {
        return NSTemporaryDirectory().appending("snipository_test")
    }()
    
    lazy var masterPath: String = {
        return NSTemporaryDirectory().appending("snipository_test_master")
    }()
    
    override func setUp() {
        super.setUp()
        //mkdir $path
        self.delete(file: self.path)
        do {
            try FileManager.default.createDirectory(atPath: self.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
        
        //mkdir $masterPath
        self.delete(file: self.masterPath)
        do {
            try FileManager.default.createDirectory(atPath: self.masterPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
    }
    
    override func tearDown() {
        super.tearDown()
        //rm -rf $path
        do {
            try FileManager.default.removeItem(atPath: self.path)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        //rm -rf $masterPath
        do {
            try FileManager.default.removeItem(atPath: self.masterPath)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    func testInitialize() {
        let (success, result) = Git().initialize(at: self.path)
        XCTAssertEqual(success, true)
        XCTAssertEqual(result.output.exitCode, 0)
        XCTAssertEqual(result.output.error.count, 0)
        XCTAssertEqual(result.output.output.count, 1)
        XCTAssertTrue(result.output.output[0].starts(with: "Initialized empty Git repository in "))
    }
    
    func testAddNewFile() {
        Git().initialize(at: self.path)
        let file = "README.md"
        let fileURL = URL(fileURLWithPath: self.path).appendingPathComponent(file)
        self.write(text: "test", to: fileURL)
        let (success, result) = Git().add(file: file, at: self.path)
        XCTAssertEqual(success, true)
        XCTAssertEqual(result.output.exitCode, 0)
        XCTAssertEqual(result.output.error.count, 0)
        XCTAssertEqual(result.output.output.count, 0)
        
        let (status, _) = Git().status(at: self.path)
        XCTAssertEqual(status?.ignoredFiles.count, 0)
        XCTAssertEqual(status?.untrackedFiles.count, 0)
        XCTAssertEqual(status?.files.count, 1)
        XCTAssertEqual(status?.files[0].status, GitFileStatus.addedToIndex)
    }
    
    func testAddNewMissingFile() {
        Git().initialize(at: self.path)
        let file = "README.md"
        let (success, result) = Git().add(file: file, at: self.path)
        XCTAssertEqual(success, false)
        XCTAssertEqual(result.output.exitCode, 128)
        XCTAssertEqual(result.output.output.count, 0)
        XCTAssertEqual(result.output.error.count, 1)
        XCTAssertEqual(result.output.error[0], "fatal: pathspec \'\(file)\' did not match any files")
    }
    
    func testCommitModifiedFile() {
        Git().initialize(at: self.path)
        let file = "README.md"
        let fileURL = URL(fileURLWithPath: self.path).appendingPathComponent(file)
        self.write(text: "test", to: fileURL)
        Git().add(file: file, at: self.path)
        let (commitSuccess, _) = Git().commit(with: "new commit", at: self.path)
        XCTAssertTrue(commitSuccess)
        
        self.write(text: "new text", to: fileURL)
        Git().add(file: file, at: self.path)
        
        let (status, _) = Git().status(at: self.path)
        XCTAssertEqual(status?.ignoredFiles.count, 0)
        XCTAssertEqual(status?.untrackedFiles.count, 0)
        XCTAssertEqual(status?.files.count, 1)
        XCTAssertEqual(status?.files[0].status, GitFileStatus.updatedInIndex)
    }
    
    func testDeleteExistingFile() {
        Git().initialize(at: self.path)
        let file = "README.md"
        let fileURL = URL(fileURLWithPath: self.path).appendingPathComponent(file)
        self.write(text: "test", to: fileURL)
        let (addSuccess, _) = Git().add(file: file, at: self.path)
        XCTAssertTrue(addSuccess)
        let (commitSuccess, _) = Git().commit(with: "new commit", at: self.path)
        XCTAssertTrue(commitSuccess)
        
        self.delete(file: "\(self.path)/\(file)")
        Git().add(file: file, at: self.path)
        
        let (status, result) = Git().status(at: self.path)
        XCTAssertEqual(status?.ignoredFiles.count, 0)
        XCTAssertEqual(status?.untrackedFiles.count, 0)
        XCTAssertEqual(status?.files.count, 1)
        XCTAssertEqual(status?.files[0].status, GitFileStatus.deletedFromIndex)
    }
    
    func testAddRemote() {
        Git().initialize(at: self.masterPath)
        let file = "README.md"
        let fileURL = URL(fileURLWithPath: self.masterPath).appendingPathComponent(file)
        self.write(text: "test", to: fileURL)
        let (addSuccess, _) = Git().add(file: file, at: self.masterPath)
        XCTAssertTrue(addSuccess)
        let (commitSuccess, _) = Git().commit(with: "new commit", at: self.masterPath)
        XCTAssertTrue(commitSuccess)
        
        Git().initialize(at: self.path)
        let remoteUrl = "file://".appending(self.masterPath)
        let (success, result) = Git().add(remote: remoteUrl, for: "origin", at: self.path)
        XCTAssertEqual(success, true)
        XCTAssertEqual(result.output.exitCode, 0)
        XCTAssertEqual(result.output.error.count, 0)
        XCTAssertEqual(result.output.output.count, 0)
        
        let (listRemoteUrl, listRemoteResult) = Git().listRemote(for: "origin", at: self.path)
        XCTAssertEqual(listRemoteUrl, remoteUrl)
    }
    
    func testPull() {
        Git().initialize(at: self.masterPath)
        let file = "README.md"
        let fileURL = URL(fileURLWithPath: self.masterPath).appendingPathComponent(file)
        self.write(text: "test", to: fileURL)
        let (addSuccess, _) = Git().add(file: file, at: self.masterPath)
        XCTAssertTrue(addSuccess)
        let (commitSuccess, _) = Git().commit(with: "new commit", at: self.masterPath)
        XCTAssertTrue(commitSuccess)
        
        Git().initialize(at: self.path)
        let remoteUrl = "file://".appending(self.masterPath)
        let (success, result) = Git().add(remote: remoteUrl, for: "origin", at: self.path)
        XCTAssertEqual(success, true)
        XCTAssertEqual(result.output.exitCode, 0)
        XCTAssertEqual(result.output.error.count, 0)
        XCTAssertEqual(result.output.output.count, 0)
        
        let (pullSuccess, _) = Git().pull(branch: "master", from: "origin", at: self.path)
        XCTAssertTrue(pullSuccess)
        
        let newFile = "\(self.path)/\(file)"
        XCTAssertTrue(FileManager.default.fileExists(atPath: newFile))
        XCTAssertEqual(read(from: URL(fileURLWithPath: newFile)), "test")
    }
    
    private func write(text: String, to fileURL: URL) {
        try? text.write(to: fileURL, atomically: false, encoding: String.Encoding.utf8)
    }
    
    private func read(from fileURL: URL) -> String? {
        return try? String(contentsOf: fileURL, encoding: String.Encoding.utf8)
    }
    
    private func delete(file: String) {
        do {
            try FileManager.default.removeItem(atPath: file)
        } catch let error as NSError {
            print(error.localizedDescription);
        }
    }
}

