
import Cocoa
import Doggie
import DoggieGP

public func sampleImage(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext<ARGB32ColorPixel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
    
    context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
    
    context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
    
    context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
    
    context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
    
    return context.image
}

public func resampling<Pixel>(image: Image<Pixel>, width: Int, height: Int, resampling algorithm: ResamplingAlgorithm, antialias: Bool) -> Image<Pixel> {
    
    let context = ImageContext<Pixel>(width: width, height: height, colorSpace: image.colorSpace)
    
    context.shouldAntialias = false
    context.resamplingAlgorithm = algorithm
    
    context.draw(image: image, transform: SDTransform.scale(x: Double(width) / Double(image.width), y: Double(height) / Double(image.height)))
    
    return context.image
}

public func resampling_gp<Pixel>(image: Image<Pixel>, width: Int, height: Int, resampling algorithm: ResamplingAlgorithm, antialias: Bool) throws -> Image<FloatColorPixel<Pixel.Model>> {
    
    let context = DGImageContext<Pixel.Model>(width: width, height: height, colorSpace: image.colorSpace)
    
    context.shouldAntialias = false
    context.resamplingAlgorithm = algorithm
    
    context.draw(image: image, transform: SDTransform.scale(x: Double(width) / Double(image.width), y: Double(height) / Double(image.height)))
    
    try context.render()
    
    return context.image
}

