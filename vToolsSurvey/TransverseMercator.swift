import Foundation

/// Cấu trúc lưu trữ tọa độ 2D (X, Y)
public struct ProjCoordinate {
    public var x: Double
    public var y: Double
    
    public init(x: Double = 0.0, y: Double = 0.0) {
        self.x = x
        self.y = y
    }
}

/// Thuật toán chiếu Transverse Mercator (dùng cho VN-2000 & UTM)
public class TransverseMercatorProjection {
    
    // Hằng số chuỗi Taylor cho phép chiếu
    private static let FC1: Double = 1.0
    private static let FC2: Double = 0.5
    private static let FC3: Double = 0.16666666666666666
    private static let FC4: Double = 0.08333333333333333
    private static let FC5: Double = 0.05
    private static let FC6: Double = 0.03333333333333333
    private static let FC7: Double = 0.023809523809523808
    private static let FC8: Double = 0.017857142857142856
    
    // Các tham số Ellipsoid & Phép chiếu
    public var es: Double = 0.006694380022900788 // Độ lệch tâm bình phương (WGS84/GRS80)
    public var projectionLatitude: Double = 0.0   // Vĩ độ trung tâm (Radian)
    public var projectionLongitude: Double = 0.0  // Kinh tuyến trục (Radian)
    public var scaleFactor: Double = 0.9996       // Hệ số tỷ lệ k0
    public var falseEasting: Double = 500000.0   // Tọa độ giả Đông (X0)
    public var falseNorthing: Double = 0.0        // Tọa độ giả Bắc (Y0)
    public var spherical: Bool = false
    
    private var en: [Double] = []
    private var esp: Double = 0.0
    private var ml0: Double = 0.0
    
    public init(projectionLongitudeRad: Double, projectionLatitudeRad: Double, scaleFactor: Double, falseEasting: Double, falseNorthing: Double) {
        self.projectionLongitude = projectionLongitudeRad
        self.projectionLatitude = projectionLatitudeRad
        self.scaleFactor = scaleFactor
        self.falseEasting = falseEasting
        self.falseNorthing = falseNorthing
        initialize()
    }
    
    public func initialize() {
        if spherical {
            esp = scaleFactor
            ml0 = scaleFactor * 0.5
        } else {
            en = ProjectionMath.enfn(es)
            ml0 = ProjectionMath.mlfn(projectionLatitude, sin(projectionLatitude), cos(projectionLatitude), en)
            esp = es / (1.0 - es)
        }
    }
    
    /// Chuyển từ Lat/Long (Radian) ➔ Tọa độ Vuông góc X/Y (Mét)
    public func project(lam: Double, phi: Double) -> ProjCoordinate {
        var coord = ProjCoordinate()
        let d2 = lam 
        let d3 = phi 
        
        if spherical {
            let dCos = cos(d3)
            let dSin = sin(d2) * dCos
            coord.x = ml0 * scaleFactor * log((dSin + 1.0) / (1.0 - dSin))
            var dAcos = acos((dCos * cos(d2)) / sqrt(1.0 - (dSin * dSin)))
            if d3 < 0.0 { dAcos = -dAcos }
            coord.y = esp * (dAcos - projectionLatitude)
        } else {
            let dSin2 = sin(d3)
            let dCos2 = cos(d3)
            let d4 = abs(dCos2) > 1.0e-10 ? dSin2 / dCos2 : 0.0
            let d5 = d4 * d4
            let d6 = dCos2 * d2
            let d7 = d6 * d6
            let dSqrt = d6 / sqrt(1.0 - ((es * dSin2) * dSin2))
            let d8 = esp * dCos2 * dCos2
            let d9 = scaleFactor
            
            coord.x = d9 * dSqrt * ((Self.FC3 * d7 * ((1.0 - d5) + d8 + (Self.FC5 * d7 * (((d5 - 18.0) * d5) + 5.0 + ((14.0 - (d5 * 58.0)) * d8) + (Self.FC7 * d7 * (((((179.0 - d5) * d5) - 479.0) * d5) + 61.0)))))) + 1.0)
            coord.y = d9 * ((ProjectionMath.mlfn(d3, dSin2, dCos2, en) - ml0) + (dSin2 * dSqrt * d2 * 0.5 * ((Self.FC4 * d7 * ((5.0 - d5) + (((4.0 * d8) + 9.0) * d8) + (Self.FC6 * d7 * (((d5 - 58.0) * d5) + 61.0 + (d8 * (270.0 - (330.0 * d5))) + (d7 * Self.FC8 * ((d5 * (((543.0 - d5) * d5) - 3111.0)) + 1385.0)))))) + 1.0)))
        }
        
        coord.x += falseEasting
        coord.y += falseNorthing
        return coord
    }
    
    /// Chuyển ngược từ X/Y (Mét) ➔ Lat/Long (Radian)
    public func projectInverse(x: Double, y: Double) -> ProjCoordinate {
        let d2 = x - falseEasting
        let d3 = y - falseNorthing
        var coord = ProjCoordinate()
        
        if spherical {
            let dExp = exp(d2 / scaleFactor)
            let d4 = (dExp - (1.0 / dExp)) * 0.5
            let dCos = cos(projectionLatitude + (d3 / scaleFactor))
            var dAsin = asin(sqrt((1.0 - (dCos * dCos)) / ((d4 * d4) + 1.0)))
            if d3 < 0.0 { dAsin = -dAsin }
            coord.y = dAsin
            coord.x = atan2(d4, dCos)
        } else {
            coord.y = ProjectionMath.inv_mlfn(ml0 + (d3 / scaleFactor), es, en)
            if abs(d3) >= 1.5707963267948966 {
                coord.y = d3 < 0.0 ? -1.5707963267948966 : 1.5707963267948966
                coord.x = 0.0
            } else {
                let dSin = sin(coord.y)
                let dCos2 = cos(coord.y)
                let d5 = abs(dCos2) > 1.0e-10 ? dSin / dCos2 : 0.0
                let d6 = esp * dCos2 * dCos2
                let d7 = 1.0 - ((es * dSin) * dSin)
                let dSqrt = (sqrt(d7) * d2) / scaleFactor
                let d8 = d7 * d5
                let d9 = d5 * d5
                let d10 = dSqrt * dSqrt
                
                coord.y -= (((d8 * d10) / (1.0 - es)) * 0.5) * (1.0 - ((Self.FC4 * d10) * (((((3.0 - (9.0 * d6)) * d9) + 5.0) + ((1.0 - (4.0 * d6)) * d6)) - ((Self.FC6 * d10) * ((((((90.0 - (252.0 * d6)) + (45.0 * d9)) * d9) + 61.0) + (46.0 * d6)) - ((Self.FC8 * d10) * ((((((1574.0 * d9) + 4095.0) * d9) + 3633.0) * d9) + 1385.0)))))))
                coord.x = (dSqrt * (1.0 - ((Self.FC3 * d10) * ((((2.0 * d9) + 1.0) + d6) - ((Self.FC5 * d10) * (((((((24.0 * d9) + 28.0) + (8.0 * d6)) * d9) + 5.0) + (d6 * 6.0)) - ((d10 * Self.FC7) * ((d9 * ((((720.0 * d9) + 1320.0) * d9) + 662.0)) + 61.0)))))))) / dCos2
            }
        }
        return coord
    }
}

/// Hỗ trợ tính toán độ dài cung kinh tuyến
public struct ProjectionMath {
    public static func enfn(_ es: Double) -> [Double] {
        var en = [Double](repeating: 0.0, count: 5)
        let C00 = 1.0, C02 = 0.25, C04 = 0.046875, C06 = 0.01953125, C08 = 0.01068115234375
        let C22 = 0.75, C44 = 0.46875, C46 = 0.013020833333333334, C66 = 0.3645833333333333
        
        en[0] = C00 - es * (C02 + es * (C04 + es * (C06 + es * C08)))
        let es2 = es * es
        en[1] = es * (C22 - es * (C04 + es * (C06 + es * C08)))
        en[2] = es2 * (C44 - es * (C46 + es * C06))
        let es3 = es2 * es
        en[3] = es3 * (C66 - es * C04)
        en[4] = es3 * es * 0.3076171875
        return en
    }
    
    public static func mlfn(_ phi: Double, _ sphi: Double, _ cphi: Double, _ en: [Double]) -> Double {
        let cphiSphi = cphi * sphi
        let sphi2 = sphi * sphi
        return en[0] * phi - cphiSphi * (en[1] + sphi2 * (en[2] + sphi2 * (en[3] + sphi2 * en[4])))
    }
    
    public static func inv_mlfn(_ arg: Double, _ es: Double, _ en: [Double]) -> Double {
        var phi = arg / en[0]
        for _ in 0..<10 {
            let s = sin(phi)
            let k = cos(phi)
            let diff = (arg - mlfn(phi, s, k, en)) / (en[0] - k * k * (en[1] + s * s * (en[2] + s * s * en[3])))
            phi += diff
            if abs(diff) < 1.0e-11 { break }
        }
        return phi
    }
}
