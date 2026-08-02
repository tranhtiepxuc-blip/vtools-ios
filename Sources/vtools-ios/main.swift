import UIKit

// Nếu app dịch ngược dùng AppDelegate truyền thống:
UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    NSStringFromClass(AppDelegate.self)
)
