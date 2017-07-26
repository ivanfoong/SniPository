//
//  CommandLineTests.swift
//  SniPositoryTests
//
//  Created by Ivan Foong Kwok Keong on 17/7/17.
//  Copyright © 2017 ivanfoong. All rights reserved.
//

import XCTest
@testable import SniPository

class CommandLineTests: XCTestCase {
    
    func testExec_echo() {
        let output = CommandLine().exec(command: "echo Test", at: "/tmp")
        XCTAssertEqual(output.exitCode, 0)
        XCTAssertEqual(output.error.count, 0)
        XCTAssertEqual(output.output.count, 1)
        XCTAssertEqual(output.output[0], "Test")
    }
    
    func testExec_ls_no_such_file() {
        let output = CommandLine().exec(commands: ["ls", "/iuehdiuahdiuhdiuwhdiua"], at: "/tmp")
        XCTAssertEqual(output.exitCode, 1)
        XCTAssertEqual(output.output.count, 0)
        XCTAssertEqual(output.error.count, 1)
        XCTAssertEqual(output.error[0], "ls: /iuehdiuahdiuhdiuwhdiua: No such file or directory")
    }
}
