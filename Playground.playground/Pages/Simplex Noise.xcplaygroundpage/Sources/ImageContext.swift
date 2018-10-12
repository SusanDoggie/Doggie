
import Cocoa
import Doggie

public func simplexNoise(width: Int, height: Int, octaves: Int, persistence: Double, scale: Double) -> Image<Gray16ColorPixel> {
    
    let context = ImageContext<Gray16ColorPixel>(width: width, height: height, colorSpace: .calibratedGray(from: .sRGB, gamma: 2.2))
    
    context.withUnsafeMutableImageBufferPointer {
        
        guard var ptr = $0.baseAddress else { return }
        
        for y in 0..<height {
            for x in 0..<width {
                ptr.pointee.white = SimplexNoise(octaves, persistence, scale, Double(x), Double(y))
                ptr.pointee.opacity = 1
                ptr += 1
            }
        }
    }
    
    return context.image
}

public func marble(width: Int, height: Int, octaves: Int, persistence: Double, scale: Double, period: Size, power: Double) -> Image<Gray16ColorPixel> {
    
    let context = ImageContext<Gray16ColorPixel>(width: width, height: height, colorSpace: .calibratedGray(from: .sRGB, gamma: 2.2))
    
    context.withUnsafeMutableImageBufferPointer {
        
        guard var ptr = $0.baseAddress else { return }
        
        for y in 0..<height {
            for x in 0..<width {
                let noise = Double(x) * period.width / Double(width) + Double(y) * period.height / Double(height) + power * SimplexNoise(octaves, persistence, scale, Double(x), Double(y))
                ptr.pointee.white = abs(sin(noise * .pi))
                ptr.pointee.opacity = 1
                ptr += 1
            }
        }
    }
    
    return context.image
}
