// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "EasyWrite",
    platforms: [.macOS("26.0")],
    targets: [
        .executableTarget(
            name: "EasyWrite",
            path: "Sources/EasyWrite",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ],
            linkerSettings: [
                .linkedFramework("Carbon")
            ]
        )
    ]
)
