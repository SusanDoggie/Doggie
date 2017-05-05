
import Doggie

public func drawImage(shape: Shape, width: Int, height: Int) -> Image {
    
    var image = Image(width: width, height: height, pixel: ARGB32ColorPixel(), colorSpace: CalibratedRGBColorSpace.sRGB)
    
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

