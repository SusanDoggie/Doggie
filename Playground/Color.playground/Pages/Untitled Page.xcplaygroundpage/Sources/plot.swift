
import Cocoa
import Doggie

let lab = ColorSpace.cieLab(white: Point(x: 0.34567, y: 0.35850))
let luv = ColorSpace.cieLuv(white: Point(x: 0.34567, y: 0.35850))

public func showLab(size: Int, x: ClosedRange<Double>, y: ClosedRange<Double>, z: Double, colorSpace: ColorSpace<RGBColorModel>) -> Image<ARGB32ColorPixel> {
    
    var image = Image<ARGB32ColorPixel>(width: size, height: size, colorSpace: colorSpace)
    
    for j in 0..<size {
        for i in 0..<size {
            let x = (x.upperBound - x.lowerBound) * Double(i) / Double(size) + x.lowerBound
            let y = (y.upperBound - y.lowerBound) * Double(j) / Double(size) + y.lowerBound
            let rgb = lab.convert(LabColorModel(lightness: z, a: x, b: y), to: colorSpace)
            if 0...1 ~= rgb.red && 0...1 ~= rgb.green && 0...1 ~= rgb.blue {
                image[i, j] = Color(colorSpace: colorSpace, color: rgb)
            } else {
                image[i, j] = Color(colorSpace: colorSpace, color: RGBColorModel())
            }
        }
    }
    
    return image
}

public func showLuv(size: Int, x: ClosedRange<Double>, y: ClosedRange<Double>, z: Double, colorSpace: ColorSpace<RGBColorModel>) -> Image<ARGB32ColorPixel> {
    
    var image = Image<ARGB32ColorPixel>(width: size, height: size, colorSpace: colorSpace)
    
    for j in 0..<size {
        for i in 0..<size {
            let x = (x.upperBound - x.lowerBound) * Double(i) / Double(size) + x.lowerBound
            let y = (y.upperBound - y.lowerBound) * Double(j) / Double(size) + y.lowerBound
            let rgb = luv.convert(LuvColorModel(lightness: z, u: x, v: y), to: colorSpace)
            if 0...1 ~= rgb.red && 0...1 ~= rgb.green && 0...1 ~= rgb.blue {
                image[i, j] = Color(colorSpace: colorSpace, color: rgb)
            } else {
                image[i, j] = Color(colorSpace: colorSpace, color: RGBColorModel())
            }
        }
    }
    
    return image
}
