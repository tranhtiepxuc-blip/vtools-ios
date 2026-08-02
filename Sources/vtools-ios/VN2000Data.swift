import Foundation
import CoreLocation

struct Province: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let centralMeridian: Double
    let zone: String = "Múi 3 độ"
}

class VN2000Helper {
    static let provinces: [Province] = [
        Province(name: "VN-2000 / AN GIANG", centralMeridian: 104.75),
        Province(name: "VN-2000 / BÀ RỊA - VŨNG TÀU", centralMeridian: 107.75),
        Province(name: "VN-2000 / BẮC GIẠNG", centralMeridian: 107.00),
        Province(name: "VN-2000 / BẮC KẠN", centralMeridian: 105.75),
        Province(name: "VN-2000 / BẠC LIÊU", centralMeridian: 104.75),
        Province(name: "VN-2000 / BẮC NINH", centralMeridian: 105.75),
        Province(name: "VN-2000 / BẾN TRE", centralMeridian: 105.75),
        Province(name: "VN-2000 / BÌNH ĐỊNH", centralMeridian: 108.00),
        Province(name: "VN-2000 / BÌNH DƯƠNG", centralMeridian: 105.75),
        Province(name: "VN-2000 / BÌNH PHƯỚC", centralMeridian: 106.00),
        Province(name: "VN-2000 / BÌNH THUẬN", centralMeridian: 108.50),
        Province(name: "VN-2000 / CÀ MAU", centralMeridian: 104.50),
        Province(name: "VN-2000 / CẦN THƠ", centralMeridian: 105.00),
        Province(name: "VN-2000 / CAO BẰNG", centralMeridian: 105.75),
        Province(name: "VN-2000 / ĐÀ NẮNG", centralMeridian: 107.75),
        Province(name: "VN-2000 / ĐẮK LẮK", centralMeridian: 108.50),
        Province(name: "VN-2000 / ĐẮK NÔNG", centralMeridian: 108.50),
        Province(name: "VN-2000 / ĐIỆN BIÊN", centralMeridian: 103.00),
        Province(name: "VN-2000 / ĐỒNG NAI", centralMeridian: 107.75),
        Province(name: "VN-2000 / ĐỒNG THÁP", centralMeridian: 105.00),
        Province(name: "VN-2000 / GIA LAI", centralMeridian: 108.50),
        Province(name: "VN-2000 / HÀ GIANG", centralMeridian: 105.00),
        Province(name: "VN-2000 / HÀ NAM", centralMeridian: 105.50),
        Province(name: "VN-2000 / HÀ NỘI", centralMeridian: 105.00),
        Province(name: "VN-2000 / HÀ TĨNH", centralMeridian: 105.75),
        Province(name: "VN-2000 / HẢI DƯƠNG", centralMeridian: 105.75),
        Province(name: "VN-2000 / HẢI PHÒNG", centralMeridian: 105.75),
        Province(name: "VN-2000 / HẬU GIANG", centralMeridian: 105.00),
        Province(name: "VN-2000 / HÒA BÌNH", centralMeridian: 105.00),
        Province(name: "VN-2000 / TP. HỒ CHÍ MINH", centralMeridian: 105.75),
        Province(name: "VN-2000 / HƯNG YÊN", centralMeridian: 105.50),
        Province(name: "VN-2000 / KHÁNH HÒA", centralMeridian: 108.25),
        Province(name: "VN-2000 / KIÊN GIANG", centralMeridian: 104.50),
        Province(name: "VN-2000 / KON TUM", centralMeridian: 107.50),
        Province(name: "VN-2000 / LAI CHÂU", centralMeridian: 103.00),
        Province(name: "VN-2000 / LÂM ĐỒNG", centralMeridian: 107.75),
        Province(name: "VN-2000 / LẠNG SƠN", centralMeridian: 107.25),
        Province(name: "VN-2000 / LÀO CAI", centralMeridian: 104.75),
        Province(name: "VN-2000 / LONG AN", centralMeridian: 105.75),
        Province(name: "VN-2000 / NAM ĐỊNH", centralMeridian: 105.50),
        Province(name: "VN-2000 / NGHỆ AN", centralMeridian: 104.75),
        Province(name: "VN-2000 / NINH BÌNH", centralMeridian: 105.50),
        Province(name: "VN-2000 / NINH THUẬN", centralMeridian: 108.25),
        Province(name: "VN-2000 / PHÚ THỌ", centralMeridian: 104.75),
        Province(name: "VN-2000 / PHÚ YÊN", centralMeridian: 108.50),
        Province(name: "VN-2000 / QUẢNG BÌNH", centralMeridian: 106.00),
        Province(name: "VN-2000 / QUẢNG NAM", centralMeridian: 107.75),
        Province(name: "VN-2000 / QUẢNG NGÃI", centralMeridian: 108.00),
        Province(name: "VN-2000 / QUẢNG NINH", centralMeridian: 107.75),
        Province(name: "VN-2000 / QUẢNG TRỊ", centralMeridian: 106.50),
        Province(name: "VN-2000 / SÓC TRĂNG", centralMeridian: 105.50),
        Province(name: "VN-2000 / SƠN LA", centralMeridian: 104.00),
        Province(name: "VN-2000 / TÂY NINH", centralMeridian: 105.50),
        Province(name: "VN-2000 / THÁI BÌNH", centralMeridian: 105.50),
        Province(name: "VN-2000 / THÁI NGUYÊN", centralMeridian: 105.75),
        Province(name: "VN-2000 / THANH HÓA", centralMeridian: 105.00),
        Province(name: "VN-2000 / THỪA THIÊN HUẾ", centralMeridian: 107.50),
        Province(name: "VN-2000 / TIỀN GIANG", centralMeridian: 105.75),
        Province(name: "VN-2000 / TRÀ VINH", centralMeridian: 105.50),
        Province(name: "VN-2000 / TUYÊN QUANG", centralMeridian: 105.00),
        Province(name: "VN-2000 / VĨNH LONG", centralMeridian: 105.50),
        Province(name: "VN-2000 / VĨNH PHÚC", centralMeridian: 105.50),
        Province(name: "VN-2000 / YÊN BÁI", centralMeridian: 104.75)
    ]

    /// Chuyển đổi từ WGS84 (Lat, Lon) sang VN-2000 Múi 3° (X, Y)
    static func wgs84ToVN2000(lat: Double, lon: Double, cm: Double) -> (x: Double, y: Double) {
        let radLat = lat * .pi / 180.0
        let radLon = lon * .pi / 180.0
        let radCM = cm * .pi / 180.0
        
        // Tham số Elipsoid WGS84 / VN2000 (WGS84 ellipsoid: a = 6378137.0, f = 1/298.257223563)
        let a = 6378137.0
        let e2 = 0.00669437999014
        let k0 = 0.9999 // Hệ số tỷ lệ múi 3 độ
        
        let dLon = radLon - radCM
        
        let sinLat = sin(radLat)
        let cosLat = cos(radLat)
        let tanLat = tan(radLat)
        
        let N = a / sqrt(1 - e2 * sinLat * sinLat)
        let T = tanLat * tanLat
        let C = (e2 / (1 - e2)) * cosLat * cosLat
        let A = dLon * cosLat
        
        // M: Khoảng cách cung kinh tuyến
        let M = a * ((1 - e2/4 - 3*e2*e2/64 - 5*e2*e2*e2/256) * radLat
                    - (3*e2/8 + 3*e2*e2/32 + 45*e2*e2*e2/1024) * sin(2*radLat)
                    + (15*e2*e2/256 + 45*e2*e2*e2/1024) * sin(4*radLat)
                    - (35*e2*e2*e2/3072) * sin(6*radLat))
        
        // Tọa độ phẳng VN-2000
        let x = k0 * (M + N * tanLat * (A*A/2 + (5 - T + 9*C + 4*C*C) * pow(A, 4)/24 + (61 - 58*T + T*T + 600*C - 330*e2) * pow(A, 6)/720))
        let y = k0 * N * (A + (1 - T + C) * pow(A, 3)/6 + (5 - 18*T + T*T + 14*C - 58*T*C) * pow(A, 5)/120) + 500000.0
        
        return (x: x, y: y)
    }
}
