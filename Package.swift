// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RustyPlugins",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .plugin(
            name: "ShowTodosPlugin",
            targets: [
                "ShowTodos"
            ]
        )
    ],
    dependencies: [],
    targets: [
        .plugin(name: "ShowTodos",
                capability: .command(
                    intent: .custom(
                        verb: "show-todos",
                        description: "Displays Todos and FixMes in the Project"),
                permissions: [])
        )
    ]
)
