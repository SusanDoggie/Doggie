
import Doggie

public func drawImage(shape: Shape, width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    var image = Image(width: width, height: height, colorSpace: CalibratedRGBColorSpace.sRGB, pixel: ARGB32ColorPixel())
    
    var stencil = [Int](repeating: 0, count: width * height)
    
    shape.raster(width: width, height: height, stencil: &stencil)
    
    stencil.withUnsafeBufferPointer { stencil in
        
        if var stencil = stencil.baseAddress {
            
            image.withUnsafeMutableBufferPointer {
                
                if var ptr = $0.baseAddress {
                    
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

extension Image : CustomPlaygroundQuickLookable {
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        
        return .text("Image{ width: \(width), height: \(height) }")
    }
}
