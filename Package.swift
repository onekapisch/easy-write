// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "EasyWrite",
    platforms: [.macOS("26.0")],
    dependencies: [
        // Signed auto-updates. Opt-in; see UpdateController.swift and SECURITY.md.
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0"),
    ],
    targets: [
        .executableTarget(
            name: "EasyWrite",
            dependencies: [.product(name: "Sparkle", package: "Sparkle")],
            path: "Sources/EasyWrite",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ],
            linkerSettings: [
                .linkedFramework("Carbon"),
                // build.sh embeds Sparkle.framework in Contents/Frameworks. The second path lets
                // the dev tools (--eval, --snapshots) run straight from the build folder.
                .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks",
                              "-Xlinker", "-rpath", "-Xlinker", "@executable_path"]),
            ]
        )
    ]
)
