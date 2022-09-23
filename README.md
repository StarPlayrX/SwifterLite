![Platform](https://img.shields.io/badge/Platform-iOS%20macOS%20tvOS-4BC51D.svg?style=flat)
![Swift](https://img.shields.io/badge/Swift-5.6-4BC51D.svg?style=flat)
![Protocols](https://img.shields.io/badge/Protocols-HTTP%201.1-4BC51D.svg?style=flat)

### What is Swifter-Lite?

Unofficial fork of Swifter written in [Swift](https://developer.apple.com/swift/) programming language, designed to be an embedded REST API server for iOS macOS and tvOS. This fork focuses on speed and reliability with the ability to stream audio and video seamlessly on or to any Apple device. Swifter-Lite can also become a REST api middleware layer and use abstraction to any proprietary api that might not be supported natively, directly or is easier to keep that layer separate from your main app.

Supports data, json, text, bytes, audio and video streaming over HLS, over HTTP 1.1 protocol via http://localhost, ipv4 tcp ip

Swifter-Lite is used in StarPlayrX and future IPTVee works by Todd Bruss. This library uses a subset of features available in Swifter. Please do not attempt to merge it into http/Swifter as there are many changes and some pieces will not be available. Swifter-Lite is approximately 50% the size of Swifter.

### Branches
`horse`

#### To Do REST API examples to be expanded


### Swift Package Manager
```swift
import PackageDescription

let package = Package(
    name: "YourServerName",
    products: [
        .library(
            name: "YourServerName",
            targets: ["YourServerName"]),
    ],
    dependencies: [
        .package(url: "https://github.com/StarPlayrX/Swifter-Lite", branch: "horse")
    ],
    targets: [
        .target(
            name: "YourServerName",
            dependencies: [.product(name: "SwifterLite", package: "Swifter-Lite")]
        ),
    ]
)
```

### import SwifterLite
```swift
import SwifterLite
```

### How to start server with 1 route and select its port
```swift
let server = HttpServer()
server.get["/api/v3/ping"] = { request in
    return HttpResponse.ok(.text("pong"))
}
let port = 8080
try? server.start(port)
```

### Data Route
```swift
func dataRoute(_ data: Data) -> httpReq {{ request in
    return HttpResponse.ok(.data(data, contentType: "application/octet-stream"))
}}

let data = Data("commanderData".utf8)
server.get["/commander/data"] = dataRoute(data: data)
```
