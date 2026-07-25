//
//  Authenticated.swift
//  swift-github-live
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

// GitHub uses Bearer token authentication:
// https://docs.github.com/en/rest/authentication/authenticating-to-the-rest-api
//
// NOTE (2026-07-25): this file previously declared an `Authenticated` typealias
// whose bearer-authentication basis was supplied by a routing-authentication
// package that is now being retired. That basis has been removed so it does not
// block the retirement. This `GitHub *Live*` layer is undeclared work-in-progress
// (compiled by no target); when it is revived, re-introduce the typealias over
// the successor API — a bearer Router Header built on RFC 7617 / RFC 6750 plus
// the routing Foundation-Integration leaf. The prior declaration is recoverable
// from git history.
