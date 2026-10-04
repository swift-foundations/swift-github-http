import GitHub_Standard
import HTTP
import HTTP_Router
import RFC_9110
import RFC_3986
import RFC_8288

extension GitHub.HTTP.Pagination.Witness where Failure == GitHub.HTTP.Pagination.Error {
    /// RFC 8288 `Link` field pagination for GitHub REST responses.
    public static let link = Self { headers throws(GitHub.HTTP.Pagination.Error) in
        let links: [RFC_8288.Link]
        do throws(RFC_8288.Link.Parse.Error) {
            links = try RFC_8288.Link.Parse()(headers)
        } catch {
            throw .link(error)
        }

        let next = links.filter { $0.relations.contains(.next) }
        guard next.count <= 1 else {
            throw .next(.multiple(next.count))
        }
        guard let target = next.first?.target else { return nil }
        guard let query = target.query else { throw .page(.missing) }

        let pages = query["page"]
        guard pages.count <= 1 else { throw .page(.multiple(pages.count)) }
        guard let raw = pages.first, let raw else { throw .page(.missing) }
        guard let value = UInt(raw), let page = GitHub.Page.Number(rawValue: value) else {
            throw .page(.invalid(raw))
        }

        return page
    }
}
