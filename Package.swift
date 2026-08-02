// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "vtools-ios",
    platforms: [
        .iOS(.v15) // Hoặc phiên bản iOS tương ứng của bạn
    ],
    products: [
        .library(
            name: "vtools-ios",
            targets: ["vtools-ios"]),
    ],
    targets: [
        .target(
            name: "vtools-ios",
            path: "Sources"), // Đảm bảo đường dẫn thư mục chứa code đúng
    ]
)
