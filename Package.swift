// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "vToolsSurvey",
    platforms: [.iOS(.v16)],
    products: [
        .executable(name: "vToolsSurvey", targets: ["vToolsSurvey"])
    ],
    targets: [
        .executableTarget(
            name: "vToolsSurvey",
            path: "Sources/vToolsSurvey"
        )
    ]
)
