// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "vToolsSurvey",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(name: "vToolsSurvey", targets: ["vToolsSurvey"])
    ],
    targets: [
        .executableTarget(
            name: "vToolsSurvey",
            path: "vToolsSurvey"
        )
    ]
)
