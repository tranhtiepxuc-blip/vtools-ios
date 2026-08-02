import SwiftUI

@main
struct vToolsSurveyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack(spacing: 20) {
                    Text("vTools Survey GIS")
                        .font(.title)
                        .bold()
                    Text("Hệ thống chuyển đổi tọa độ VN-2000 đã sẵn sàng.")
                        .foregroundColor(.gray)
                }
                .padding()
                .navigationTitle("Trang chủ")
            }
        }
    }
}
