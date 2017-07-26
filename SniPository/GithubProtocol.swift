//
//  GithubProtocol.swift
//  SniPository
//
//  Created by Ivan Foong Kwok Keong on 20/7/17.
//  Copyright © 2017 ivanfoong. All rights reserved.
//

import Foundation

protocol GithubProtocol {
    func createPR(named name: String, with body: String, for headBranch: String, to baseBranch: String, githubAPIPullUrl: URL, githubToken: String, completion: @escaping (Data?, URLResponse?, Error?)->Void)
}
