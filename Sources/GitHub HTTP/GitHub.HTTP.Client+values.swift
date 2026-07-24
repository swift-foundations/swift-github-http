import EmailAddress_Standard
import GitHub
import GitHub_Standard
import JSON
import RFC_3339
import RFC_3986

extension GitHub.HTTP.Client {
    static func email(_ json: JSON) throws(JSON.Error) -> EmailAddress {
        let raw = try String.deserialize(json)
        do throws(EmailAddress.Error) {
            return try .init(raw)
        } catch {
            throw .typeMismatch(expected: "email address", got: raw)
        }
    }

    static func email(ifPresent json: JSON) throws(JSON.Error) -> EmailAddress? {
        guard let raw = try String?.deserialize(json) else { return nil }
        do throws(EmailAddress.Error) {
            return try .init(raw)
        } catch {
            throw .typeMismatch(expected: "email address or null", got: raw)
        }
    }

    static func nonnegative(
        _ json: JSON,
        expected: String
    ) throws(JSON.Error) -> UInt64 {
        let raw = try Int64.deserialize(json)
        guard let value = UInt64(exactly: raw) else {
            throw .typeMismatch(expected: expected, got: String(raw))
        }
        return value
    }

    static func timestamp(_ json: JSON) throws(JSON.Error) -> RFC_3339.DateTime {
        let raw = try String.deserialize(json)
        do throws(RFC_3339.DateTime.Error) {
            return try .init(raw)
        } catch {
            throw .typeMismatch(expected: "RFC 3339 date-time", got: raw)
        }
    }

    static func timestamp(ifPresent json: JSON) throws(JSON.Error) -> RFC_3339.DateTime? {
        guard let raw = try String?.deserialize(json) else { return nil }
        do throws(RFC_3339.DateTime.Error) {
            return try .init(raw)
        } catch {
            throw .typeMismatch(expected: "RFC 3339 date-time or null", got: raw)
        }
    }

    static func uri(_ json: JSON) throws(JSON.Error) -> RFC_3986.URI {
        let raw = try String.deserialize(json)
        do throws(RFC_3986.Error) {
            return try .init(raw)
        } catch {
            throw .typeMismatch(expected: "RFC 3986 URI", got: raw)
        }
    }

    static func uri(ifPresent json: JSON) throws(JSON.Error) -> RFC_3986.URI? {
        guard let raw = try String?.deserialize(json) else { return nil }
        do throws(RFC_3986.Error) {
            return try .init(raw)
        } catch {
            throw .typeMismatch(expected: "RFC 3986 URI or null", got: raw)
        }
    }

    static func owner(from json: JSON) throws(JSON.Error) -> GitHub.Owner.Summary {
        .init(
            id: .init(try nonnegative(json["id"], expected: "nonnegative owner id")),
            login: .init(try String.deserialize(json["login"])),
            nodeID: try String.deserialize(json["node_id"]),
            avatarURL: try uri(json["avatar_url"]),
            gravatarID: try String.deserialize(json["gravatar_id"]),
            url: try uri(json["url"]),
            htmlURL: try uri(json["html_url"]),
            type: try String.deserialize(json["type"]),
            siteAdmin: try Bool.deserialize(json["site_admin"])
        )
    }

    static func user(from json: JSON) throws(JSON.Error) -> GitHub.User.Summary {
        .init(
            id: .init(try nonnegative(json["id"], expected: "nonnegative user id")),
            login: .init(try String.deserialize(json["login"])),
            nodeID: try String.deserialize(json["node_id"]),
            avatarURL: try uri(json["avatar_url"]),
            gravatarID: try String.deserialize(json["gravatar_id"]),
            url: try uri(json["url"]),
            htmlURL: try uri(json["html_url"]),
            type: try String.deserialize(json["type"]),
            siteAdmin: try Bool.deserialize(json["site_admin"])
        )
    }

    static func metadata(from json: JSON) throws(JSON.Error) -> GitHub.Repository.Metadata {
        let rawVisibility = try String.deserialize(json["visibility"])
        guard let visibility = GitHub.Repository.Visibility(rawValue: rawVisibility) else {
            throw .typeMismatch(
                expected: "public, private, or internal visibility",
                got: rawVisibility
            )
        }

        let license: GitHub.Repository.License?
        if json["license"].isNull {
            license = nil
        } else {
            let value = json["license"]
            license = try .init(
                key: String.deserialize(value["key"]),
                name: String.deserialize(value["name"]),
                spdxID: String.deserialize(value["spdx_id"]),
                url: uri(ifPresent: value["url"]),
                nodeID: String.deserialize(value["node_id"])
            )
        }

        return try .init(
            id: .init(
                nonnegative(json["id"], expected: "nonnegative repository id")
            ),
            nodeID: String.deserialize(json["node_id"]),
            name: .init(String.deserialize(json["name"])),
            fullName: String.deserialize(json["full_name"]),
            owner: owner(from: json["owner"]),
            htmlURL: uri(json["html_url"]),
            url: uri(json["url"]),
            homepage: uri(ifPresent: json["homepage"]),
            description: String?.deserialize(json["description"]),
            isPrivate: Bool.deserialize(json["private"]),
            isFork: Bool.deserialize(json["fork"]),
            isArchived: Bool.deserialize(json["archived"]),
            isDisabled: Bool.deserialize(json["disabled"]),
            isTemplate: Bool.deserialize(json["is_template"]),
            hasIssues: Bool.deserialize(json["has_issues"]),
            hasProjects: Bool.deserialize(json["has_projects"]),
            hasDownloads: Bool.deserialize(json["has_downloads"]),
            hasWiki: Bool.deserialize(json["has_wiki"]),
            hasPages: Bool.deserialize(json["has_pages"]),
            allowForking: Bool.deserialize(json["allow_forking"]),
            language: String?.deserialize(json["language"]),
            visibility: visibility,
            defaultBranch: String.deserialize(json["default_branch"]),
            topics: [String].deserialize(json["topics"]),
            license: license,
            stargazersCount: nonnegative(
                json["stargazers_count"], expected: "nonnegative stargazer count"
            ),
            forksCount: nonnegative(json["forks_count"], expected: "nonnegative fork count"),
            openIssuesCount: nonnegative(
                json["open_issues_count"], expected: "nonnegative open issue count"
            ),
            watchersCount: nonnegative(
                json["watchers_count"], expected: "nonnegative watcher count"
            ),
            size: nonnegative(json["size"], expected: "nonnegative repository size"),
            createdAt: timestamp(json["created_at"]),
            updatedAt: timestamp(json["updated_at"]),
            pushedAt: timestamp(ifPresent: json["pushed_at"])
        )
    }
}
