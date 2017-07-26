//
//  Github.swift
//  SniPository
//
//  Created by Ivan Foong Kwok Keong on 20/7/17.
//  Copyright © 2017 ivanfoong. All rights reserved.
//

import Foundation

class Github: GithubProtocol {
    func createPR(named name: String, with body: String, for headBranch: String, to baseBranch: String, githubAPIPullUrl: URL, githubToken: String, completion: @escaping (Data?, URLResponse?, Error?)->Void) {
        let dict = [
            "title": name,
            "body": body,
            "head": headBranch,
            "base": baseBranch
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        guard let httpBody = jsonData else {
            return
        }
        
        var request = URLRequest(url: githubAPIPullUrl)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("token \(githubToken)", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            completion(data, response, error)
        }
        task.resume()
    }
}
