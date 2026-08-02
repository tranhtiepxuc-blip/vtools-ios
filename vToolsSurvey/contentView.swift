import SwiftUI

struct ContentView: View {
    @State private var latInput: String = ""
    @State private var lonInput: String = ""
    
    @State private var northingResult: String = "--"
    @State private var eastingResult: String = "--"
    @State private var errorMessage: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Tọa độ WGS84 ban đầu")) {
                    TextField("Vĩ độ (Latitude)", text: $latInput)
                        .keyboardType(.decimalPad)
                    TextField("Kinh độ (Longitude)", text: $lonInput)
                        .keyboardType(.decimalPad)
                }
                
                Section {
                    Button(action: {
                        performConversion()
                    }) {
                        Text("Chuyển đổi sang VN-2000")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .fontWeight(.bold)
                    }
                }
                
                Section(header: Text("Kết quả hệ tọa độ VN-2000")) {
                    HStack {
                        Text("X (Northing):")
                        Spacer()
                        Text(northingResult).fontWeight(.bold).foregroundColor(.blue)
                    }
                    HStack {
                        Text("Y (Easting):")
                        Spacer()
                        Text(eastingResult).fontWeight(.bold).foregroundColor(.blue)
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("vTools Survey GIS")
        }
    }
    
    private func performConversion() {
        errorMessage = nil
        
        guard let lat = Double(latInput), let lon = Double(lonInput) else {
            errorMessage = "Vui lòng nhập định dạng số hợp lệ cho tọa độ."
            return
        }
        
        // Tạm tính mô phỏng (Sau này bạn thay thế bằng class TransverseMercator thực tế của bạn)
        northingResult = String(format: "%.3f", lat * 111320.0)
        eastingResult = String(format: "%.3f", lon * 110540.0)
    }
}
                        Spacer()
                        Text(northingResult).bold().foregroundColor(.blue)
                    }
                    HStack {
                        Text("Y (Easting):")
                        Spacer()
                        Text(eastingResult).bold().foregroundColor(.blue)
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("vTools Survey GIS")
        }
    }
    
    private func performConversion() {
        errorMessage = nil
        
        // Kiểm tra dữ liệu đầu vào hợp lệ
        guard let lat = Double(latInput), let lon = Double(lonInput) else {
            errorMessage = "Vui lòng nhập định dạng số hợp lệ cho tọa độ."
            return
        }
        
        // Gọi class/thuật toán TransverseMercator bạn đã port từ Java sang Swift 6
        // Ví dụ thực tế gọi hàm:
        // let vn2000Point = TransverseMercator.transformWGS84ToVN2000(lat: lat, lon: lon)
        // northingResult = String(format: "%.3f m", vn2000Point.x)
        // eastingResult = String(format: "%.3f m", vn2000Point.y)
        
        // Đoạn tạm tính minh họa kết nối logic:
        northingResult = String(format: "%.3f", lat * 111320.0)
        eastingResult = String(format: "%.3f", lon * 110540.0)
    }
}
