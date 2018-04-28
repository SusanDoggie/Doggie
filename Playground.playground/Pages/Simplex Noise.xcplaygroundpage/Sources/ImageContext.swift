
import Cocoa
import Doggie

public func simplexNoise(width: Int, height: Int, octaves: Int, persistence: Double, scale: Double) -> Image<Gray16ColorPixel> {
    
    let context = ImageContext<Gray16ColorPixel>(width: width, height: height, colorSpace: .calibratedGray(from: .sRGB, gamma: 2.2))
    
    context.withUnsafeMutableImageBufferPointer {
        
        guard var ptr = $0.baseAddress else { return }
        
        for y in 0..<height {
            for x in 0..<width {
                ptr.pointee.white = scaled_octave_noise_2d(octaves, persistence, scale, 0, 1, Double(x), Double(y))
                ptr.pointee.opacity = 1
                ptr += 1
            }
        }
    }
    
    return context.image
}
