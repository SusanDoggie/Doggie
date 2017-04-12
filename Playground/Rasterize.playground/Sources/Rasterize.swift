
import Doggie

public func drawImage(shape: Shape, width: Int, height: Int) -> Image {
    
    let srgb = CalibratedRGBColorSpace(white: XYZColorModel(luminance: 1, x: 0.3127, y: 0.3290), black: XYZColorModel(luminance: 0, x: 0.3127, y: 0.3290), red: XYZColorModel(luminance: 0.2126, x: 0.6400, y: 0.3300), green: XYZColorModel(luminance: 0.7152, x: 0.3000, y: 0.6000), blue: XYZColorModel(luminance: 0.0722, x: 0.1500, y: 0.0600))
    
    var image = Image(width: width, height: height, pixel: ARGB32ColorPixel(), colorSpace: srgb)
    
    var stencil = [Int](repeating: 0, count: width * height)
    
    shape.raster(width: width, height: height, stencil: &stencil)
    
    stencil.withUnsafeBufferPointer { stencil in
        
        if var stencil = stencil.baseAddress {
            
            image.withUnsafeMutableBytes {
                
                if var ptr = $0.baseAddress?.assumingMemoryBound(to: ARGB32ColorPixel.self) {
                    
                    for _ in 0..<width * height {
                        
                        let winding = stencil.pointee
                        
                        if winding & 1 == 1 {
                            ptr.pointee = ARGB32ColorPixel(red: 0, green: 0, blue: 0, opacity: 255)
                        }
                        
                        stencil += 1
                        ptr += 1
                    }
                }
            }
        }
    }
    
    return image
}

