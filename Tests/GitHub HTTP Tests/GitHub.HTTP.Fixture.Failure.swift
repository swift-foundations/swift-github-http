@testable import GitHub_HTTP

extension GitHub.HTTP {
    enum Fixture {}
}

extension GitHub.HTTP.Fixture {
    enum Execution: Swift.Error, Equatable, Sendable {
        case unexpected
    }

    enum Pagination: Swift.Error, Equatable, Sendable {
        case unexpected
    }

    static let metadata =
        #"{"id":42,"node_id":"R_42","name":"swift","full_name":"swiftlang/swift","owner":{"id":7,"login":"swiftlang","node_id":"O_7","avatar_url":"https://avatars.githubusercontent.com/u/7","gravatar_id":"","url":"https://api.github.com/users/swiftlang","html_url":"https://github.com/swiftlang","type":"Organization","site_admin":false},"html_url":"https://github.com/swiftlang/swift","url":"https://api.github.com/repos/swiftlang/swift","homepage":null,"description":"The Swift Programming Language","private":false,"fork":false,"archived":false,"disabled":false,"is_template":false,"has_issues":true,"has_projects":true,"has_downloads":true,"has_wiki":true,"has_pages":false,"allow_forking":true,"language":"C++","visibility":"public","default_branch":"main","topics":["swift"],"license":{"key":"apache-2.0","name":"Apache License 2.0","spdx_id":"Apache-2.0","url":"https://api.github.com/licenses/apache-2.0","node_id":"MDc6TGljZW5zZTI="},"stargazers_count":70000,"forks_count":11000,"open_issues_count":900,"watchers_count":70000,"size":1200000,"created_at":"2015-10-23T21:15:07Z","updated_at":"2026-07-22T18:30:00Z","pushed_at":"2026-07-22T18:00:00Z"}"#

    static let user =
        #"{"id":9,"login":"octocat","node_id":"U_9","avatar_url":"https://avatars.githubusercontent.com/u/9","gravatar_id":"","url":"https://api.github.com/users/octocat","html_url":"https://github.com/octocat","type":"User","site_admin":false}"#

    static func bytes(_ string: String) -> [Byte] {
        string.utf8.map(Byte.init)
    }
}
