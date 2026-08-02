import SwiftUI
import MapKit

struct ContentView: View {
    @State private var showMenu = false
    @State private var showSettings = false
    @State private var showLayers = false
    @State private var selectedMenuAction: MenuAction? = nil
    
    // Trạng thái hệ chiếu và thông số GPS thực tế
    @State private var currentSystem = "VN-2000 / BÌNH THUẬN"
    @State private var northingX: String = "489021.247"
    @State private var eastingY: String = "1221937.065"
    @State private var accuracy: String = "3.79 m"
    @State private var elevation: String = "75.17 m"
    @State private var speed: String = "0.00 m/s"
    
    @StateObject private var locationManager = LocationDataManager()

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomLeading) {
                // 1. Bản đồ vệ tinh thực tế của iOS (MapKit)
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: locationManager.userLocation ?? CLLocationCoordinate2D(latitude: 10.762622, longitude: 106.660172),
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                ))) {
                    UserAnnotation()
                }
                .mapStyle(.imagery(elevation: .realistic))
                .ignoresSafeArea()

                // 2. Bảng thông số tọa độ cập nhật theo GPS thực
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
                .background(.black.opacity(0.75))
                .foregroundColor(.white)
                .cornerRadius(6)
                .padding(.leading, 8)
                .padding(.bottom, 20)

                // 3. Thanh công cụ nổi bên phải
                VStack(spacing: 12) {
                    Button(action: { showLayers = true }) {
                        Image(systemName: "square.grid.2x2.fill").toolbarIconStyle()
                    }
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill").toolbarIconStyle()
                    }
                    Button(action: { selectedMenuAction = .drawTools }) {
                        Image(systemName: "pencil.and.ruler.fill").toolbarIconStyle()
                    }
                    Button(action: { selectedMenuAction = .createPoint }) {
                        Image(systemName: "flag.fill").toolbarIconStyle()
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
                        Image(systemName: "line.3.horizontal").font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showMenu) {
                AppSettingsMenuView(selectedAction: $selectedMenuAction)
            }
            .sheet(isPresented: $showLayers) {
                LayersManagementView()
            }
            .sheet(isPresented: $showSettings) {
                MapSettingsView(currentSystem: $currentSystem)
            }
            .sheet(item: $selectedMenuAction) { actionItem in
                ActionDetailView(action: actionItem)
            }
            .onChange(of: locationManager.latitudeValue) { newLat in
                if let lat = newLat, let lon = locationManager.longitudeValue {
                    northingX = String(format: "%.3f", lat * 111320.0)
                    eastingY = String(format: "%.3f", lon * 110540.0)
                }
            }
        }
    }
}

// MARK: - Trình quản lý GPS phần cứng
class LocationDataManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D? = nil
    @Published var latitudeValue: Double? = nil
    @Published var longitudeValue: Double? = nil

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.userLocation = location.coordinate
                self.latitudeValue = location.coordinate.latitude
                self.longitudeValue = location.coordinate.longitude
            }
        }
    }
}

// MARK: - Các cấu trúc phụ trợ menu
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

struct AppSettingsMenuView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedAction: MenuAction?
    
    var body: some View {
        NavigationStack {
            List {
                Button(action: { dismiss(); selectedAction = .mapSettings }) { Label("Cài đặt bản đồ", systemImage: "map") }
                Button(action: { dismiss(); selectedAction = .dataStructure }) { Label("Cấu trúc dữ liệu (Layers)", systemImage: "list.bullet.rectangle") }
                Button(action: { dismiss(); selectedAction = .satelliteFind }) { Label("Tìm ảnh vệ tinh", systemImage: "globe") }
                Button(action: { dismiss(); selectedAction = .pointFind }) { Label("Tìm tọa độ điểm", systemImage: "mappin.and.ellipse") }
                Button(action: { dismiss(); selectedAction = .coordinateTransform }) { Label("Chuyển tọa độ điểm", systemImage: "arrow.left.arrow.right") }
                Button(action: { dismiss(); selectedAction = .importPoint }) { Label("Nhập mốc tọa độ", systemImage: "pin.fill") }
                Button(action: { dismiss(); selectedAction = .exportData }) { Label("Xuất file dữ liệu", systemImage: "square.and.arrow.up") }
                Button(action: { dismiss(); selectedAction = .wifiAccess }) { Label("Truy cập qua wifi", systemImage: "wifi") }
                Button(action: { dismiss(); selectedAction = .dataBackup }) { Label("Sao lưu dữ liệu", systemImage: "externaldrive.badge.icloud") }
                Button(action: { dismiss(); selectedAction = .dataRestore }) { Label("Khôi phục dữ liệu", systemImage: "arrow.counterclockwise") }
            }
            .navigationTitle("Danh mục chức năng")
            .toolbar { Button("Đóng") { dismiss() } }
        }
    }
}

struct MapSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var currentSystem: String
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Chọn hệ chiếu VN-2000")) {
                    Button("VN-2000 / BÌNH THUẬN") { currentSystem = "VN-2000 / BÌNH THUẬN"; dismiss() }
                    Button("VN-2000 / CÀ MAU") { currentSystem = "VN-2000 / CÀ MAU"; dismiss() }
                    Button("VN-2000 / CẦN THƠ") { currentSystem = "VN-2000 / CẦN THƠ"; dismiss() }
                    Button("VN-2000 / ĐÀ NẴNG") { currentSystem = "VN-2000 / ĐÀ NẴNG"; dismiss() }
                }
            }
            .navigationTitle("Cài đặt bản đồ")
            .toolbar { Button("Xong") { dismiss() } }
        }
    }
}

struct LayersManagementView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationStack {
            List {
                Toggle("Hình ảnh khảo sát", isOn: .constant(true))
                Toggle("Điểm mốc tọa độ (28)", isOn: .constant(true))
                Toggle("Dữ liệu Điểm", isOn: .constant(true))
            }
            .navigationTitle("Quản lý lớp bản đồ")
            .toolbar { Button("Đóng") { dismiss() } }
        }
    }
}

struct ActionDetailView: View {
    let action: MenuAction
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "hammer.fill").font(.system(size: 50)).foregroundColor(.blue)
                Text(action.rawValue).font(.title2).fontWeight(.bold)
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle(action.rawValue)
            .toolbar { Button("Quay lại") { dismiss() } }
        }
    }
}
