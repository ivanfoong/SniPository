//
//  SniPositoryCoreTests.swift
//  SniPositoryTests
//
//  Created by Ivan Foong Kwok Keong on 19/7/17.
//  Copyright © 2017 ivanfoong. All rights reserved.
//

import XCTest
@testable import SniPository

class SniPositoryCoreTests: XCTestCase {
    
    lazy var path: String = {
        return NSTemporaryDirectory().appending("snipository_test")
    }()
    
    lazy var masterPath: String = {
        return NSTemporaryDirectory().appending("snipository_test_master")
    }()
    
    let originalSnippet: String = "<?xml version= \"1.0 \" encoding= \"UTF-8 \"?><!DOCTYPE plist PUBLIC  \"-//Apple//DTD PLIST 1.0//EN \"  \"http://www.apple.com/DTDs/PropertyList-1.0.dtd \"><plist version= \"1.0 \"><dict><key>IDECodeSnippetCompletionPrefix</key><string>dequeueGenericCell</string><key>IDECodeSnippetCompletionScopes</key><array><string>TopLevel</string></array><key>IDECodeSnippetContents</key><string>extension UITableView {\n    func dequeueCell&lt;T: UITableViewCell&gt;(with identifier: String, for indexPath: IndexPath) -&gt; T {\n        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T\n    }\n}</string><key>IDECodeSnippetIdentifier</key><string>34471D06-76C8-4E40-94C0-A5DD6F7C5B83</string><key>IDECodeSnippetLanguage</key><string>Xcode.SourceCodeLanguage.Swift</string><key>IDECodeSnippetSummary</key><string>This generic method will allow you to get custom cell’s reference without force casting!</string><key>IDECodeSnippetTitle</key><string>Dequeue Generic Cell - TableView Extension</string><key>IDECodeSnippetUserSnippet</key><true/><key>IDECodeSnippetVersion</key><integer>0</integer></dict></plist>"
    let updatedSnippet: String = "<?xml version= \"1.0 \" encoding= \"UTF-8 \"?><!DOCTYPE plist PUBLIC  \"-//Apple//DTD PLIST 1.0//EN \"  \"http://www.apple.com/DTDs/PropertyList-1.0.dtd \"><plist version= \"1.0 \"><dict><key>IDECodeSnippetCompletionPrefix</key><string>dequeueGenericCell</string><key>IDECodeSnippetCompletionScopes</key><array><string>TopLevel</string></array><key>IDECodeSnippetContents</key><string>extension UITableView {\n    func dequeueCell&lt;T: UITableViewCell&gt;(with identifier: String, for indexPath: IndexPath) -&gt; T {\n        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T\n    }\n}</string><key>IDECodeSnippetIdentifier</key><string>34471D06-76C8-4E40-94C0-A5DD6F7C5B83</string><key>IDECodeSnippetLanguage</key><string>Xcode.SourceCodeLanguage.Swift</string><key>IDECodeSnippetSummary</key><string>This generic method will allow you to get custom cell’s reference without force casting!</string><key>IDECodeSnippetTitle</key><string>Dequeue Generic Cell - TableView Extension</string><key>IDECodeSnippetUserSnippet</key><true/><key>IDECodeSnippetVersion</key><integer>1</integer></dict></plist>"
    let prBody = "HTTP/1.1 201 OK\n\n{ \"id \":1, \"url \": \"https://api.github.com/repos/octocat/Hello-World/pulls/1347 \", \"html_url \": \"https://github.com/octocat/Hello-World/pull/1347 \", \"diff_url \": \"https://github.com/octocat/Hello-World/pull/1347.diff \", \"patch_url \": \"https://github.com/octocat/Hello-World/pull/1347.patch \", \"issue_url \": \"https://api.github.com/repos/octocat/Hello-World/issues/1347 \", \"commits_url \": \"https://api.github.com/repos/octocat/Hello-World/pulls/1347/commits \", \"review_comments_url \": \"https://api.github.com/repos/octocat/Hello-World/pulls/1347/comments \", \"review_comment_url \": \"https://api.github.com/repos/octocat/Hello-World/pulls/comments{/number} \", \"comments_url \": \"https://api.github.com/repos/octocat/Hello-World/issues/1347/comments \", \"statuses_url \": \"https://api.github.com/repos/octocat/Hello-World/statuses/6dcb09b5b57875f334f61aebed695e2e4193db5e \", \"number \":1347, \"state \": \"open \", \"title \": \"new-feature \", \"body \": \"Please pull these awesome changes \", \"assignee \":{ \"login \": \"octocat \", \"id \":1, \"avatar_url \": \"https://github.com/images/error/octocat_happy.gif \", \"gravatar_id \": \" \", \"url \": \"https://api.github.com/users/octocat \", \"html_url \": \"https://github.com/octocat \", \"followers_url \": \"https://api.github.com/users/octocat/followers \", \"following_url \": \"https://api.github.com/users/octocat/following{/other_user} \", \"gists_url \": \"https://api.github.com/users/octocat/gists{/gist_id} \", \"starred_url \": \"https://api.github.com/users/octocat/starred{/owner}{/repo} \", \"subscriptions_url \": \"https://api.github.com/users/octocat/subscriptions \", \"organizations_url \": \"https://api.github.com/users/octocat/orgs \", \"repos_url \": \"https://api.github.com/users/octocat/repos \", \"events_url \": \"https://api.github.com/users/octocat/events{/privacy} \", \"received_events_url \": \"https://api.github.com/users/octocat/received_events \", \"type \": \"User \", \"site_admin \":false}, \"milestone \":{ \"url \": \"https://api.github.com/repos/octocat/Hello-World/milestones/1 \", \"html_url \": \"https://github.com/octocat/Hello-World/milestones/v1.0 \", \"labels_url \": \"https://api.github.com/repos/octocat/Hello-World/milestones/1/labels \", \"id \":1002604, \"number \":1, \"state \": \"open \", \"title \": \"v1.0 \", \"description \": \"Tracking milestone for version 1.0 \", \"creator \":{ \"login \": \"octocat \", \"id \":1, \"avatar_url \": \"https://github.com/images/error/octocat_happy.gif \", \"gravatar_id \": \" \", \"url \": \"https://api.github.com/users/octocat \", \"html_url \": \"https://github.com/octocat \", \"followers_url \": \"https://api.github.com/users/octocat/followers \", \"following_url \": \"https://api.github.com/users/octocat/following{/other_user} \", \"gists_url \": \"https://api.github.com/users/octocat/gists{/gist_id} \", \"starred_url \": \"https://api.github.com/users/octocat/starred{/owner}{/repo} \", \"subscriptions_url \": \"https://api.github.com/users/octocat/subscriptions \", \"organizations_url \": \"https://api.github.com/users/octocat/orgs \", \"repos_url \": \"https://api.github.com/users/octocat/repos \", \"events_url \": \"https://api.github.com/users/octocat/events{/privacy} \", \"received_events_url \": \"https://api.github.com/users/octocat/received_events \", \"type \": \"User \", \"site_admin \":false}, \"open_issues \":4, \"closed_issues \":8, \"created_at \": \"2011-04-10T20:09:31Z \", \"updated_at \": \"2014-03-03T18:58:10Z \", \"closed_at \": \"2013-02-12T13:22:01Z \", \"due_on \": \"2012-10-09T23:39:01Z \"}, \"locked \":false, \"created_at \": \"2011-01-26T19:01:12Z \", \"updated_at \": \"2011-01-26T19:01:12Z \", \"closed_at \": \"2011-01-26T19:01:12Z \", \"merged_at \": \"2011-01-26T19:01:12Z \", \"head \":{ \"label \": \"new-topic \", \"ref \": \"new-topic \", \"sha \": \"6dcb09b5b57875f334f61aebed695e2e4193db5e \", \"user \":{ \"login \": \"octocat \", \"id \":1, \"avatar_url \": \"https://github.com/images/error/octocat_happy.gif \", \"gravatar_id \": \" \", \"url \": \"https://api.github.com/users/octocat \", \"html_url \": \"https://github.com/octocat \", \"followers_url \": \"https://api.github.com/users/octocat/followers \", \"following_url \": \"https://api.github.com/users/octocat/following{/other_user} \", \"gists_url \": \"https://api.github.com/users/octocat/gists{/gist_id} \", \"starred_url \": \"https://api.github.com/users/octocat/starred{/owner}{/repo} \", \"subscriptions_url \": \"https://api.github.com/users/octocat/subscriptions \", \"organizations_url \": \"https://api.github.com/users/octocat/orgs \", \"repos_url \": \"https://api.github.com/users/octocat/repos \", \"events_url \": \"https://api.github.com/users/octocat/events{/privacy} \", \"received_events_url \": \"https://api.github.com/users/octocat/received_events \", \"type \": \"User \", \"site_admin \":false}, \"repo \":{ \"id \":1296269, \"owner \":{ \"login \": \"octocat \", \"id \":1, \"avatar_url \": \"https://github.com/images/error/octocat_happy.gif \", \"gravatar_id \": \" \", \"url \": \"https://api.github.com/users/octocat \", \"html_url \": \"https://github.com/octocat \", \"followers_url \": \"https://api.github.com/users/octocat/followers \", \"following_url \": \"https://api.github.com/users/octocat/following{/other_user} \", \"gists_url \": \"https://api.github.com/users/octocat/gists{/gist_id} \", \"starred_url \": \"https://api.github.com/users/octocat/starred{/owner}{/repo} \", \"subscriptions_url \": \"https://api.github.com/users/octocat/subscriptions \", \"organizations_url \": \"https://api.github.com/users/octocat/orgs \", \"repos_url \": \"https://api.github.com/users/octocat/repos \", \"events_url \": \"https://api.github.com/users/octocat/events{/privacy} \", \"received_events_url \": \"https://api.github.com/users/octocat/received_events \", \"type \": \"User \", \"site_admin \":false}, \"name \": \"Hello-World \", \"full_name \": \"octocat/Hello-World \", \"description \": \"This your first repo! \", \"private \":false, \"fork \":false, \"url \": \"https://api.github.com/repos/octocat/Hello-World \", \"html_url \": \"https://github.com/octocat/Hello-World \", \"archive_url \": \"http://api.github.com/repos/octocat/Hello-World/{archive_format}{/ref} \", \"assignees_url \": \"http://api.github.com/repos/octocat/Hello-World/assignees{/user} \", \"blobs_url \": \"http://api.github.com/repos/octocat/Hello-World/git/blobs{/sha} \", \"branches_url \": \"http://api.github.com/repos/octocat/Hello-World/branches{/branch} \", \"clone_url \": \"https://github.com/octocat/Hello-World.git \", \"collaborators_url \": \"http://api.github.com/repos/octocat/Hello-World/collaborators{/collaborator} \", \"comments_url \": \"http://api.github.com/repos/octocat/Hello-World/comments{/number} \", \"commits_url \": \"http://api.github.com/repos/octocat/Hello-World/commits{/sha} \", \"compare_url \": \"http://api.github.com/repos/octocat/Hello-World/compare/{base}...{head} \", \"contents_url \": \"http://api.github.com/repos/octocat/Hello-World/contents/{+path} \", \"contributors_url \": \"http://api.github.com/repos/octocat/Hello-World/contributors \", \"deployments_url \": \"http://api.github.com/repos/octocat/Hello-World/deployments \", \"downloads_url \": \"http://api.github.com/repos/octocat/Hello-World/downloads \", \"events_url \": \"http://api.github.com/repos/octocat/Hello-World/events \", \"forks_url \": \"http://api.github.com/repos/octocat/Hello-World/forks \", \"git_commits_url \": \"http://api.github.com/repos/octocat/Hello-World/git/commits{/sha} \", \"git_refs_url \": \"http://api.github.com/repos/octocat/Hello-World/git/refs{/sha} \", \"git_tags_url \": \"http://api.github.com/repos/octocat/Hello-World/git/tags{/sha} \", \"git_url \": \"git:github.com/octocat/Hello-World.git \", \"hooks_url \": \"http://api.github.com/repos/octocat/Hello-World/hooks \", \"issue_comment_url \": \"http://api.github.com/repos/octocat/Hello-World/issues/comments{/number} \", \"issue_events_url \": \"http://api.github.com/repos/octocat/Hello-World/issues/events{/number} \", \"issues_url \": \"http://api.github.com/repos/octocat/Hello-World/issues{/number} \", \"keys_url \": \"http://api.github.com/repos/octocat/Hello-World/keys{/key_id} \", \"labels_url \": \"http://api.github.com/repos/octocat/Hello-World/labels{/name} \", \"languages_url \": \"http://api.github.com/repos/octocat/Hello-World/languages \", \"merges_url \": \"http://api.github.com/repos/octocat/Hello-World/merges \", \"milestones_url \": \"http://api.github.com/repos/octocat/Hello-World/milestones{/number} \", \"mirror_url \": \"git:git.example.com/octocat/Hello-World \", \"notifications_url \": \"http://api.github.com/repos/octocat/Hello-World/notifications{?since, all, participating} \", \"pulls_url \": \"http://api.github.com/repos/octocat/Hello-World/pulls{/number} \", \"releases_url \": \"http://api.github.com/repos/octocat/Hello-World/releases{/id} \", \"ssh_url \": \"git@github.com:octocat/Hello-World.git \", \"stargazers_url \": \"http://api.github.com/repos/octocat/Hello-World/stargazers \", \"statuses_url \": \"http://api.github.com/repos/octocat/Hello-World/statuses/{sha} \", \"subscribers_url \": \"http://api.github.com/repos/octocat/Hello-World/subscribers \", \"subscription_url \": \"http://api.github.com/repos/octocat/Hello-World/subscription \", \"svn_url \": \"https://svn.github.com/octocat/Hello-World \", \"tags_url \": \"http://api.github.com/repos/octocat/Hello-World/tags \", \"teams_url \": \"http://api.github.com/repos/octocat/Hello-World/teams \", \"trees_url \": \"http://api.github.com/repos/octocat/Hello-World/git/trees{/sha} \", \"homepage \": \"https://github.com \", \"language \":null, \"forks_count \":9, \"stargazers_count \":80, \"watchers_count \":80, \"size \":108, \"default_branch \": \"master \", \"open_issues_count \":0, \"topics \":[ \"octocat \", \"atom \", \"electron \", \"API \"], \"has_issues \":true, \"has_wiki \":true, \"has_pages \":false, \"has_downloads \":true, \"pushed_at \": \"2011-01-26T19:06:43Z \", \"created_at \": \"2011-01-26T19:01:12Z \", \"updated_at \": \"2011-01-26T19:14:43Z \", \"permissions \":{ \"admin \":false, \"push \":false, \"pull \":true}, \"allow_rebase_merge \":true, \"allow_squash_merge \":true, \"allow_merge_commit \":true, \"subscribers_count \":42, \"network_count \":0}}, \"base \":{ \"label \": \"master \", \"ref \": \"master \", \"sha \": \"6dcb09b5b57875f334f61aebed695e2e4193db5e \", \"user \":{ \"login \": \"octocat \", \"id \":1, \"avatar_url \": \"https://github.com/images/error/octocat_happy.gif \", \"gravatar_id \": \" \", \"url \": \"https://api.github.com/users/octocat \", \"html_url \": \"https://github.com/octocat \", \"followers_url \": \"https://api.github.com/users/octocat/followers \", \"following_url \": \"https://api.github.com/users/octocat/following{/other_user} \", \"gists_url \": \"https://api.github.com/users/octocat/gists{/gist_id} \", \"starred_url \": \"https://api.github.com/users/octocat/starred{/owner}{/repo} \", \"subscriptions_url \": \"https://api.github.com/users/octocat/subscriptions \", \"organizations_url \": \"https://api.github.com/users/octocat/orgs \", \"repos_url \": \"https://api.github.com/users/octocat/repos \", \"events_url \": \"https://api.github.com/users/octocat/events{/privacy} \", \"received_events_url \": \"https://api.github.com/users/octocat/received_events \", \"type \": \"User \", \"site_admin \":false}, \"repo \":{ \"id \":1296269, \"owner \":{ \"login \": \"octocat \", \"id \":1, \"avatar_url \": \"https://github.com/images/error/octocat_happy.gif \", \"gravatar_id \": \" \", \"url \": \"https://api.github.com/users/octocat \", \"html_url \": \"https://github.com/octocat \", \"followers_url \": \"https://api.github.com/users/octocat/followers \", \"following_url \": \"https://api.github.com/users/octocat/following{/other_user} \", \"gists_url \": \"https://api.github.com/users/octocat/gists{/gist_id} \", \"starred_url \": \"https://api.github.com/users/octocat/starred{/owner}{/repo} \", \"subscriptions_url \": \"https://api.github.com/users/octocat/subscriptions \", \"organizations_url \": \"https://api.github.com/users/octocat/orgs \", \"repos_url \": \"https://api.github.com/users/octocat/repos \", \"events_url \": \"https://api.github.com/users/octocat/events{/privacy} \", \"received_events_url \": \"https://api.github.com/users/octocat/received_events \", \"type \": \"User \", \"site_admin \":false}, \"name \": \"Hello-World \", \"full_name \": \"octocat/Hello-World \", \"description \": \"This your first repo! \", \"private \":false, \"fork \":false, \"url \": \"https://api.github.com/repos/octocat/Hello-World \", \"html_url \": \"https://github.com/octocat/Hello-World \", \"archive_url \": \"http://api.github.com/repos/octocat/Hello-World/{archive_format}{/ref} \", \"assignees_url \": \"http://api.github.com/repos/octocat/Hello-World/assignees{/user} \", \"blobs_url \": \"http://api.github.com/repos/octocat/Hello-World/git/blobs{/sha} \", \"branches_url \": \"http://api.github.com/repos/octocat/Hello-World/branches{/branch} \", \"clone_url \": \"https://github.com/octocat/Hello-World.git \", \"collaborators_url \": \"http://api.github.com/repos/octocat/Hello-World/collaborators{/collaborator} \", \"comments_url \": \"http://api.github.com/repos/octocat/Hello-World/comments{/number} \", \"commits_url \": \"http://api.github.com/repos/octocat/Hello-World/commits{/sha} \", \"compare_url \": \"http://api.github.com/repos/octocat/Hello-World/compare/{base}...{head} \", \"contents_url \": \"http://api.github.com/repos/octocat/Hello-World/contents/{+path} \", \"contributors_url \": \"http://api.github.com/repos/octocat/Hello-World/contributors \", \"deployments_url \": \"http://api.github.com/repos/octocat/Hello-World/deployments \", \"downloads_url \": \"http://api.github.com/repos/octocat/Hello-World/downloads \", \"events_url \": \"http://api.github.com/repos/octocat/Hello-World/events \", \"forks_url \": \"http://api.github.com/repos/octocat/Hello-World/forks \", \"git_commits_url \": \"http://api.github.com/repos/octocat/Hello-World/git/commits{/sha} \", \"git_refs_url \": \"http://api.github.com/repos/octocat/Hello-World/git/refs{/sha} \", \"git_tags_url \": \"http://api.github.com/repos/octocat/Hello-World/git/tags{/sha} \", \"git_url \": \"git:github.com/octocat/Hello-World.git \", \"hooks_url \": \"http://api.github.com/repos/octocat/Hello-World/hooks \", \"issue_comment_url \": \"http://api.github.com/repos/octocat/Hello-World/issues/comments{/number} \", \"issue_events_url \": \"http://api.github.com/repos/octocat/Hello-World/issues/events{/number} \", \"issues_url \": \"http://api.github.com/repos/octocat/Hello-World/issues{/number} \", \"keys_url \": \"http://api.github.com/repos/octocat/Hello-World/keys{/key_id} \", \"labels_url \": \"http://api.github.com/repos/octocat/Hello-World/labels{/name} \", \"languages_url \": \"http://api.github.com/repos/octocat/Hello-World/languages \", \"merges_url \": \"http://api.github.com/repos/octocat/Hello-World/merges \", \"milestones_url \": \"http://api.github.com/repos/octocat/Hello-World/milestones{/number} \", \"mirror_url \": \"git:git.example.com/octocat/Hello-World \", \"notifications_url \": \"http://api.github.com/repos/octocat/Hello-World/notifications{?since, all, participating} \", \"pulls_url \": \"http://api.github.com/repos/octocat/Hello-World/pulls{/number} \", \"releases_url \": \"http://api.github.com/repos/octocat/Hello-World/releases{/id} \", \"ssh_url \": \"git@github.com:octocat/Hello-World.git \", \"stargazers_url \": \"http://api.github.com/repos/octocat/Hello-World/stargazers \", \"statuses_url \": \"http://api.github.com/repos/octocat/Hello-World/statuses/{sha} \", \"subscribers_url \": \"http://api.github.com/repos/octocat/Hello-World/subscribers \", \"subscription_url \": \"http://api.github.com/repos/octocat/Hello-World/subscription \", \"svn_url \": \"https://svn.github.com/octocat/Hello-World \", \"tags_url \": \"http://api.github.com/repos/octocat/Hello-World/tags \", \"teams_url \": \"http://api.github.com/repos/octocat/Hello-World/teams \", \"trees_url \": \"http://api.github.com/repos/octocat/Hello-World/git/trees{/sha} \", \"homepage \": \"https://github.com \", \"language \":null, \"forks_count \":9, \"stargazers_count \":80, \"watchers_count \":80, \"size \":108, \"default_branch \": \"master \", \"open_issues_count \":0, \"topics \":[ \"octocat \", \"atom \", \"electron \", \"API \"], \"has_issues \":true, \"has_wiki \":true, \"has_pages \":false, \"has_downloads \":true, \"pushed_at \": \"2011-01-26T19:06:43Z \", \"created_at \": \"2011-01-26T19:01:12Z \", \"updated_at \": \"2011-01-26T19:14:43Z \", \"permissions \":{ \"admin \":false, \"push \":false, \"pull \":true}, \"allow_rebase_merge \":true, \"allow_squash_merge \":true, \"allow_merge_commit \":true, \"subscribers_count \":42, \"network_count \":0}}, \"_links \":{ \"self \":{ \"href \": \"https://api.github.com/repos/octocat/Hello-World/pulls/1347 \"}, \"html \":{ \"href \": \"https://github.com/octocat/Hello-World/pull/1347 \"}, \"issue \":{ \"href \": \"https://api.github.com/repos/octocat/Hello-World/issues/1347 \"}, \"comments \":{ \"href \": \"https://api.github.com/repos/octocat/Hello-World/issues/1347/comments \"}, \"review_comments \":{ \"href \": \"https://api.github.com/repos/octocat/Hello-World/pulls/1347/comments \"}, \"review_comment \":{ \"href \": \"https://api.github.com/repos/octocat/Hello-World/pulls/comments{/number} \"}, \"commits \":{ \"href \": \"https://api.github.com/repos/octocat/Hello-World/pulls/1347/commits \"}, \"statuses \":{ \"href \": \"https://api.github.com/repos/octocat/Hello-World/statuses/6dcb09b5b57875f334f61aebed695e2e4193db5e \"}}, \"user \":{ \"login \": \"octocat \", \"id \":1, \"avatar_url \": \"https://github.com/images/error/octocat_happy.gif \", \"gravatar_id \": \" \", \"url \": \"https://api.github.com/users/octocat \", \"html_url \": \"https://github.com/octocat \", \"followers_url \": \"https://api.github.com/users/octocat/followers \", \"following_url \": \"https://api.github.com/users/octocat/following{/other_user} \", \"gists_url \": \"https://api.github.com/users/octocat/gists{/gist_id} \", \"starred_url \": \"https://api.github.com/users/octocat/starred{/owner}{/repo} \", \"subscriptions_url \": \"https://api.github.com/users/octocat/subscriptions \", \"organizations_url \": \"https://api.github.com/users/octocat/orgs \", \"repos_url \": \"https://api.github.com/users/octocat/repos \", \"events_url \": \"https://api.github.com/users/octocat/events{/privacy} \", \"received_events_url \": \"https://api.github.com/users/octocat/received_events \", \"type \": \"User \", \"site_admin \":false}}"
    
    override func setUp() {
        super.setUp()
        self.delete(file: self.path)
        self.create(folder: self.path)
        
        self.delete(file: self.masterPath)
        self.create(folder: self.masterPath)
    }
    
    override func tearDown() {
        super.tearDown()
        self.delete(file: self.path)
        self.delete(file: self.masterPath)
    }
    
    func testGitInit_newFolder() {
        let mockGithub = MockGithub(mockData: nil, mockURLResponse: nil, mockError: nil)
        let engine = SniPositoryCore(githubAPIPullUrl: URL(string: "http://example.com/pull")!, githubToken: "token", snippetPath: self.path, github: mockGithub)
        Git().initialize(at: self.masterPath)
        let file = "dequeueGenericCell.codesnippet"
        let fileURL = URL(fileURLWithPath: self.masterPath).appendingPathComponent(file)
        self.write(text: self.originalSnippet, to: fileURL)
        Git().add(file: file, at: self.masterPath)
        Git().commit(with: "new commit", at: self.masterPath)
        
        let remoteUrl = "file://".appending(self.masterPath)
        let result = engine.initGit(with: remoteUrl)
        XCTAssertTrue(result)
        
        let newFile = "\(self.path)/\(file)"
        XCTAssertTrue(FileManager.default.fileExists(atPath: newFile))
        XCTAssertEqual(read(from: URL(fileURLWithPath: newFile)), self.originalSnippet)
    }
    
    func testGitInit_existingFolder() {
        let mockGithub = MockGithub(mockData: nil, mockURLResponse: nil, mockError: nil)
        let engine = SniPositoryCore(githubAPIPullUrl: URL(string: "http://example.com/pull")!, githubToken: "token", snippetPath: self.path, github: mockGithub)
        
        Git().initialize(at: self.masterPath)
        let file = "dequeueGenericCell.codesnippet"
        let fileURL = URL(fileURLWithPath: self.masterPath).appendingPathComponent(file)
        self.write(text: self.originalSnippet, to: fileURL)
        Git().add(file: file, at: self.masterPath)
        Git().commit(with: "new commit", at: self.masterPath)
        
        Git().initialize(at: self.path)
        let testFileURL = URL(fileURLWithPath: self.path).appendingPathComponent(file)
        self.write(text: self.updatedSnippet, to: testFileURL)
        Git().add(file: file, at: self.path)
        Git().commit(with: "new commit from test", at: self.path)
        
        let remoteUrl = "file://".appending(self.masterPath)
        let result = engine.initGit(with: remoteUrl)
        XCTAssertTrue(result)
        
        let newFile = "\(self.path)/\(file)"
        XCTAssertTrue(FileManager.default.fileExists(atPath: newFile))
        XCTAssertEqual(read(from: URL(fileURLWithPath: newFile)), self.updatedSnippet)
    }
    
//    func testGitInit_missingFolder() {
//        self.delete(file: self.path)
//        let mockGithub = MockGithub(mockData: nil, mockURLResponse: nil, mockError: nil)
//        let engine = SniPositoryCore(githubAPIPullUrl: URL(string: "http://example.com/pull")!, githubToken: "token", snippetPath: self.path, github: mockGithub)
//        Git().initialize(at: self.path)
//        let file = "dequeueGenericCell.codesnippet"
//        let fileURL = URL(fileURLWithPath: self.masterPath).appendingPathComponent(file)
//        self.write(text: self.originalSnippet, to: fileURL)
//        Git().add(file: file, at: self.masterPath)
//        Git().commit(with: "new commit", at: self.masterPath)
//
//        let remoteUrl = "file://".appending(self.masterPath)
//        let result = engine.initGit(with: remoteUrl)
//        XCTAssertTrue(result)
//
//        let newFile = "\(self.path)/\(file)"
//        XCTAssertTrue(FileManager.default.fileExists(atPath: newFile))
//        XCTAssertEqual(read(from: URL(fileURLWithPath: newFile)), self.originalSnippet)
//    }
    
    func testSync_noChanges() {
        let mockGithub = MockGithub(mockData: nil, mockURLResponse: nil, mockError: nil)
        let engine = SniPositoryCore(githubAPIPullUrl: URL(string: "http://example.com/pull")!, githubToken: "token", snippetPath: self.path, github: mockGithub)
        
        Git().initialize(at: self.masterPath)
        let file = "dequeueGenericCell.codesnippet"
        let fileURL = URL(fileURLWithPath: self.masterPath).appendingPathComponent(file)
        self.write(text: self.originalSnippet, to: fileURL)
        Git().add(file: file, at: self.masterPath)
        Git().commit(with: "new commit", at: self.masterPath)
        
        let remoteUrl = "file://".appending(self.masterPath)
        let result = engine.initGit(with: remoteUrl)
        XCTAssertTrue(result)
        
        let success = engine.sync()
        XCTAssertTrue(success)
        let newFile = "\(self.path)/\(file)"
        XCTAssertTrue(FileManager.default.fileExists(atPath: newFile))
        XCTAssertEqual(read(from: URL(fileURLWithPath: newFile)), self.originalSnippet)
    }
    
    func testSync_remoteChanges() {
        let mockGithub = MockGithub(mockData: nil, mockURLResponse: nil, mockError: nil)
        let engine = SniPositoryCore(githubAPIPullUrl: URL(string: "http://example.com/pull")!, githubToken: "token", snippetPath: self.path, github: mockGithub)
        
        Git().initialize(at: self.masterPath)
        let file = "dequeueGenericCell.codesnippet"
        let fileURL = URL(fileURLWithPath: self.masterPath).appendingPathComponent(file)
        self.write(text: self.originalSnippet, to: fileURL)
        Git().add(file: file, at: self.masterPath)
        Git().commit(with: "new commit", at: self.masterPath)
        
        let remoteUrl = "file://".appending(self.masterPath)
        let result = engine.initGit(with: remoteUrl)
        XCTAssertTrue(result)
        
        self.write(text: self.updatedSnippet, to: fileURL)
        Git().add(file: file, at: self.masterPath)
        Git().commit(with: "new commit 2", at: self.masterPath)
        
        let success = engine.sync()
        XCTAssertTrue(success)
        let newFile = "\(self.path)/\(file)"
        XCTAssertTrue(FileManager.default.fileExists(atPath: newFile))
        XCTAssertEqual(read(from: URL(fileURLWithPath: newFile)), self.updatedSnippet)
    }
    
    func testSync_localChanges() {
        let mockData = Data(bytes: [UInt8](prBody.utf8))
        let url = URL(string: "http://example.com/pull")!
        let mockURLResponse = HTTPURLResponse(url: url, statusCode: 201, httpVersion: "1.1", headerFields: nil)
        let mockError: Error? = nil
        let mockGithub = MockGithub(mockData: mockData, mockURLResponse: mockURLResponse, mockError: mockError)
        let engine = SniPositoryCore(githubAPIPullUrl: url, githubToken: "token", snippetPath: self.path, github: mockGithub)
        
        Git().initialize(at: self.masterPath)
        let file = "dequeueGenericCell.codesnippet"
        let fileURL = URL(fileURLWithPath: self.masterPath).appendingPathComponent(file)
        self.write(text: self.originalSnippet, to: fileURL)
        Git().add(file: file, at: self.masterPath)
        Git().commit(with: "new commit", at: self.masterPath)
        
        let remoteUrl = "file://".appending(self.masterPath)
        let result = engine.initGit(with: remoteUrl)
        XCTAssertTrue(result)
        
        let newFile = "\(self.path)/\(file)"
        self.write(text: self.updatedSnippet, to: URL(fileURLWithPath: newFile))
        
        let success = engine.sync()
        XCTAssertTrue(success)
        XCTAssertTrue(FileManager.default.fileExists(atPath: newFile))
        guard let newFileContent = read(from: URL(fileURLWithPath: newFile)) else {
            XCTFail()
            return
        }
        XCTAssertEqual(newFileContent, self.updatedSnippet)
        XCTAssertEqual(mockGithub.prName, "Dequeue Generic Cell - TableView Extension")
        XCTAssertEqual(mockGithub.prBody, "## Description\nThis generic method will allow you to get custom cell’s reference without force casting!\n## Snippet\n```\nextension UITableView {\n    func dequeueCell<T: UITableViewCell>(with identifier: String, for indexPath: IndexPath) -> T {\n        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! T\n    }\n}\n```\n")
        XCTAssertEqual(mockGithub.prHeadBranch, "dequeueGenericCell")
        XCTAssertEqual(mockGithub.prBaseBranch, "master")
        XCTAssertEqual(mockGithub.prAPIPullUrl, url)
        XCTAssertEqual(mockGithub.prToken, "token")
        XCTAssertTrue(mockGithub.didCalled)
        
        let (currentBranchName, _) = Git().currentBranch(at: self.path)
        XCTAssertEqual(currentBranchName, "master")
        
        let (s, _) = Git().status(at: self.path)
        guard let status = s else {
            XCTFail()
            return
        }
        if status.files.count <= 0 {
            XCTFail()
            return
        }
        XCTAssertEqual(status.files[0].filename, file)
        XCTAssertEqual(status.files[0].status, GitFileStatus.notUpdated)
    }
    
    func testSync_deleteFile() {
    }
    
    private func write(text: String, to fileURL: URL) {
        try? text.write(to: fileURL, atomically: false, encoding: String.Encoding.utf8)
    }
    
    private func read(from fileURL: URL) -> String? {
        return try? String(contentsOf: fileURL, encoding: String.Encoding.utf8)
    }
    
    private func delete(file: String, verbose: Bool = false) {
        do {
            try FileManager.default.removeItem(atPath: file)
        } catch let error as NSError {
            if verbose {
                print(error.localizedDescription);
            }
        }
    }
    
    private func create(folder: String, verbose: Bool = false) {
        do {
            try FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            if verbose {
                print(error.localizedDescription)
            }
        }
    }
    
    class MockGithub: GithubProtocol {
        var prName: String?
        var prBody: String?
        var prHeadBranch: String?
        var prBaseBranch: String?
        var prAPIPullUrl: URL?
        var prToken: String?
        var mockData: Data?
        var mockURLResponse: URLResponse?
        var mockError: Error?
        var didCalled = false
        
        init(mockData: Data?, mockURLResponse: URLResponse?, mockError: Error?) {
            self.mockData = mockData
            self.mockURLResponse = mockURLResponse
            self.mockError = mockError
        }
        
        func createPR(named name: String, with body: String, for headBranch: String, to baseBranch: String, githubAPIPullUrl: URL, githubToken: String, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
            self.didCalled = true
            self.prName = name
            self.prBody = body
            self.prHeadBranch = headBranch
            self.prBaseBranch = baseBranch
            self.prAPIPullUrl = githubAPIPullUrl
            self.prToken = githubToken
            completion(self.mockData, self.mockURLResponse, self.mockError)
        }
    }
}
