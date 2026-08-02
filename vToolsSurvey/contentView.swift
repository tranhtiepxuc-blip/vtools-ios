import SwiftUI

struct ContentView: View {
    @State private var showMenu = false
    @State private var showSettings = false
    @State private var showLayers = false
    
    // Trạng thái tọa độ giả lập/GPS thực tế
    @State private var currentSystem = "VN-2000 / BÌNH THUẬN"
    @State private var northingX: String = "489021.247"
    @State private var eastingY: String = "1221937.065"
    @State private var accuracy: String = "3.79 m"
    @State private var elevation: String = "75.17 m"
    @State private var speed: String = "0.00 m/s"

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomLeading) {
                // 1. Lớp nền bản đồ (Giả lập hiển thị vệ tinh)
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Text("[ Khung Bản Đồ Vệ Tinh GIS ]")
                            .foregroundColor(.white)
                            .font(.headline)
                    )
                    .ignoresSafeArea()

                // 2. Bảng hiển thị thông số tọa độ ở góc dưới bên trái (giống bản APK)
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentSystem)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.yellow)
                    
                    Text("Tọa độ X(E): \(northingX) m")
                    Text("Tọa độ Y(N): \(eastingY) m")
                    Text("Sai số: \(accuracy)")
                    Text("Độ cao: \(elevation)")
                    Text("Tốc độ: \(speed)")
                }
                .font(.system(size: 12, weight: .medium))
                .padding(8)
                .background(.black.opacity(0.6))
                .foregroundColor(.white)
                .cornerRadius(6)
                .padding(.leading, 8)
                .padding(.bottom, 20)

                // 3. Thanh công cụ nổi bên phải (Menu chức năng nhanh)
                VStack(spacing: 12) {
                    Button(action: { showLayers.toggle() }) {
                        Image(systemName: "square.grid.2x2.fill")
                            .toolbarIconStyle()
                    }
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gearshape.fill")
                            .toolbarIconStyle()
                    }
                    Button(action: { /* Thao tác Đo vẽ */ }) {
                        Image(systemName: "pencil.and.ruler.fill")
                            .toolbarIconStyle()
                    }
                    Button(action: { /* Tạo điểm mốc */ }) {
                        Image(systemName: "flag.fill")
                            .toolbarIconStyle()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 12)
                .padding(.bottom, 40)
            }
            .navigationTitle("vTools Survey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showMenu.toggle() }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title3)
                    }
                }
            }
            // Sheet hiển thị Menu chính giống hình 3 của APK
            .sheet(isPresented: $showMenu) {
                AppSettingsMenuView()
            }
            // Sheet quản lý lớp bản đồ (Layers)
            .sheet(isPresented: $showLayers) {
                LayersManagementView()
            }
            // Sheet cài đặt bản đồ / hệ chiếu
            .sheet(isPresented: $showSettings) {
                MapSettingsView()
            }
        }
    }
}

// Style cho các icon nổi bên phải bản đồ
extension View {
    func toolbarIconStyle() -> some View {
        self
            .font(.system(size: 18))
            .foregroundColor(.white)
            .padding(12)
            .background(Color.blue)
            .clipShape(Circle())
            .shadow(radius: 4)
    }
}

// MARK: - Các màn hình menu phụ trợ mô phỏng theo APK

struct AppSettingsMenuView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: MapSettingsView()) {
                    Label("Cài đặt bản đồ", systemImage: "map")
                }
                NavigationLink(destination: LayersManagementView()) {
                    Label("Cấu trúc dữ liệu (Layers)", systemImage: "list.bullet.rectangle")
                }
                Label("Tìm ảnh vệ tinh", systemImage: "globe")
                Label("Tìm tọa độ điểm", systemImage: "mappin.and.ellipse")
                Label("Chuyển tọa độ điểm", systemImage: "arrow.left.arrow.right")
                Label("Nhập mốc tọa độ", systemImage: "pin.fill")
                Label("Xuất file dữ liệu", systemImage: "square.and.arrow.up")
                Label("Truy cập qua wifi", systemImage: "wifi")
                Label("Sao lưu dữ liệu", systemImage: "externaldrive.badge.icloud")
                Label("Khôi phục dữ liệu", systemImage: "arrow.counterclockwise")
            }
            .navigationTitle("Danh mục chức năng")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Đóng") { dismiss() }
            }
        }
    }
}

struct MapSettingsView: View {
    var body: some View {
        List {
            Section(header: Text("Hệ chiếu VN-2000 phổ biến")) {
                Text("VN-2000 / BÌNH THUẬN (Kinh tuyến 108.50°)")
                Text("VN-2000 / CÀ MAU (Kinh tuyến 104.50°)")
                Text("VN-2000 / CẦN THƠ (Kinh tuyến 105.00°)")
                Text("VN-2000 / ĐÀ NẴNG (Kinh tuyến 107.75°)")
            }
            Section(header: Text("Bản đồ nền Raster")) {
                Text("Google Satellite")
                Text("Google Terrain")
                Text("Bing Satellite")
            }
        }
        .navigationTitle("Cài đặt bản đồ & Hệ chiếu")
    }
}

struct LayersManagementView: View {
    var body: some View {
        List {
            Toggle("Hình ảnh khảo sát", isOn: .constant(true))
            Toggle("Điểm mốc tọa độ (28)", isOn: .constant(true))
            Toggle("Dữ liệu Điểm", isOn: .constant(true))
            Toggle("Dữ liệu Đường (71)", isOn: .constant(true))
            Toggle("Dữ liệu Vùng (1)", isOn: .constant(true))
            Toggle("Tuyến Tracklog", isOn: .constant(true))
            Toggle("Dữ liệu TAB/MIF (1)", isOn: .constant(true))
            Toggle("Dữ liệu SHP", isOn: .constant(true))
        }
        .navigationTitle("Quản lý các lớp dữ liệu")
    }
}
