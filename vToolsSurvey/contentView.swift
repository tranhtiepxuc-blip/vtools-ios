import SwiftUI

struct ContentView: View {
    @State private var showMenu = false
    @State private var showSettings = false
    @State private var showLayers = false
    
    // Các trạng thái điều hướng màn hình phụ từ menu
    @State private var selectedMenuAction: MenuAction? = nil
    
    // Trạng thái thông số hiển thị
    @State private var currentSystem = "VN-2000 / BÌNH THUẬN"
    @State private var northingX: String = "489021.247"
    @State private var eastingY: String = "1221937.065"
    @State private var accuracy: String = "3.79 m"
    @State private var elevation: String = "75.17 m"
    @State private var speed: String = "0.00 m/s"

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomLeading) {
                // 1. Lớp nền bản đồ tương tác
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        VStack {
                            Image(systemName: "globe.americas.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            Text("Màn hình Bản đồ GIS / Vệ tinh")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("(Chạm vào các nút bên phải để mở tính năng)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    )
                    .ignoresSafeArea()

                // 2. Bảng thông số tọa độ góc dưới
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
                .background(.black.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(6)
                .padding(.leading, 8)
                .padding(.bottom, 20)

                // 3. Thanh công cụ nổi bên phải (Đã gán sự kiện bấm mở chức năng)
                VStack(spacing: 12) {
                    Button(action: { showLayers = true }) {
                        Image(systemName: "square.grid.2x2.fill")
                            .toolbarIconStyle()
                    }
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .toolbarIconStyle()
                    }
                    Button(action: { 
                        selectedMenuAction = .drawTools 
                    }) {
                        Image(systemName: "pencil.and.ruler.fill")
                            .toolbarIconStyle()
                    }
                    Button(action: { 
                        selectedMenuAction = .createPoint 
                    }) {
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
                    Button(action: { showMenu = true }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title3)
                    }
                }
            }
            // Sheet mở Menu danh mục chính
            .sheet(isPresented: $showMenu) {
                AppSettingsMenuView(selectedAction: $selectedMenuAction)
            }
            // Sheet quản lý lớp bản đồ
            .sheet(isPresented: $showLayers) {
                LayersManagementView()
            }
            // Sheet cài đặt hệ chiếu/bản đồ
            .sheet(isPresented: $showSettings) {
                MapSettingsView(currentSystem: $currentSystem)
            }
            // Điều hướng hiển thị popup/màn hình khi bấm chọn chức năng cụ thể
            .sheet(item: $selectedMenuAction) { actionItem in
                ActionDetailView(action: actionItem)
            }
        }
    }
}

// Định nghĩa danh sách các hành động trong menu
enum MenuAction: String, Identifiable {
    case mapSettings = "Cài đặt bản đồ"
    case dataStructure = "Cấu trúc dữ liệu"
    case satelliteFind = "Tìm ảnh vệ tinh"
    case pointFind = "Tìm tọa độ điểm"
    case coordinateTransform = "Chuyển tọa độ điểm"
    case importPoint = "Nhập mốc tọa độ"
    case exportData = "Xuất file dữ liệu"
    case wifiAccess = "Truy cập qua wifi"
    case dataBackup = "Sao lưu dữ liệu"
    case dataRestore = "Khôi phục dữ liệu"
    case drawTools = "Công cụ Đo Vẽ"
    case createPoint = "Tạo Mốc / Điểm Tọa Độ"
    
    var id: String { self.rawValue }
}

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

// MARK: - Sub-views xử lý tương tác từng mục

struct AppSettingsMenuView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedAction: MenuAction?
    
    var body: some View {
        NavigationStack {
            List {
                Button(action: { dismiss(); selectedAction = .mapSettings }) {
                    Label("Cài đặt bản đồ", systemImage: "map")
                }
                Button(action: { dismiss(); selectedAction = .dataStructure }) {
                    Label("Cấu trúc dữ liệu (Layers)", systemImage: "list.bullet.rectangle")
                }
                Button(action: { dismiss(); selectedAction = .satelliteFind }) {
                    Label("Tìm ảnh vệ tinh", systemImage: "globe")
                }
                Button(action: { dismiss(); selectedAction = .pointFind }) {
                    Label("Tìm tọa độ điểm", systemImage: "mappin.and.ellipse")
                }
                Button(action: { dismiss(); selectedAction = .coordinateTransform }) {
                    Label("Chuyển tọa độ điểm", systemImage: "arrow.left.arrow.right")
                }
                Button(action: { dismiss(); selectedAction = .importPoint }) {
                    Label("Nhập mốc tọa độ", systemImage: "pin.fill")
                }
                Button(action: { dismiss(); selectedAction = .exportData }) {
                    Label("Xuất file dữ liệu", systemImage: "square.and.arrow.up")
                }
                Button(action: { dismiss(); selectedAction = .wifiAccess }) {
                    Label("Truy cập qua wifi", systemImage: "wifi")
                }
                Button(action: { dismiss(); selectedAction = .dataBackup }) {
                    Label("Sao lưu dữ liệu", systemImage: "externaldrive.badge.icloud")
                }
                Button(action: { dismiss(); selectedAction = .dataRestore }) {
                    Label("Khôi phục dữ liệu", systemImage: "arrow.counterclockwise")
                }
            }
            .foregroundColor(.primary)
            .navigationTitle("Danh mục chức năng")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Đóng") { dismiss() }
                }
            }
        }
    }
}

struct MapSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var currentSystem: String
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Chọn hệ chiếu VN-2000 tỉnh thành")) {
                    Button("VN-2000 / BÌNH THUẬN") { currentSystem = "VN-2000 / BÌNH THUẬN"; dismiss() }
                    Button("VN-2000 / CÀ MAU") { currentSystem = "VN-2000 / CÀ MAU"; dismiss() }
                    Button("VN-2000 / CẦN THƠ") { currentSystem = "VN-2000 / CẦN THƠ"; dismiss() }
                    Button("VN-2000 / ĐÀ NẴNG") { currentSystem = "VN-2000 / ĐÀ NẴNG"; dismiss() }
                }
                Section(header: Text("Bản đồ nền Raster")) {
                    Text("Google Satellite (Đang chọn)")
                    Text("Google Terrain")
                    Text("Bing Satellite")
                }
            }
            .navigationTitle("Cài đặt bản đồ")
            .toolbar {
                Button("Xong") { dismiss() }
            }
        }
    }
}

struct LayersManagementView: View {
    @Environment(\.dismiss) var dismiss
    @State private var layer1 = true
    @State private var layer2 = true
    @State private var layer3 = true
    
    var body: some View {
        NavigationStack {
            List {
                Toggle("Hình ảnh khảo sát", isOn: $layer1)
                Toggle("Điểm mốc tọa độ (28)", isOn: $layer2)
                Toggle("Dữ liệu Điểm", isOn: $layer3)
                Toggle("Dữ liệu Đường (71)", isOn: .constant(true))
                Toggle("Dữ liệu Vùng (1)", isOn: .constant(true))
                Toggle("Tuyến Tracklog", isOn: .constant(true))
            }
            .navigationTitle("Quản lý lớp bản đồ")
            .toolbar {
                Button("Đóng") { dismiss() }
            }
        }
    }
}

struct ActionDetailView: View {
    let action: MenuAction
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "hammer.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                Text("Giao diện chức năng:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(action.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Tính năng này đang được liên kết dữ liệu và sẽ hoàn thiện chi tiết theo chuẩn khảo sát GIS.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle(action.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Quay lại") { dismiss() }
            }
        }
    }
}
