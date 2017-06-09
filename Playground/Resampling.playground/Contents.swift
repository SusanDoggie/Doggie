//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let context = ImageContext(width: 100, height: 100, colorSpace: CalibratedRGBColorSpace.sRGB)

context.draw(shape: Shape.Ellipse(Rect(x: 10, y: 35, width: 55, height: 55)), color: Color(colorSpace: CalibratedRGBColorSpace.sRGB, color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255)), winding: .nonZero)

context.draw(shape: Shape.Ellipse(Rect(x: 10, y: 35, width: 55, height: 55)).strokePath(width: 1, cap: .round, join: .round), color: Color(colorSpace: CalibratedRGBColorSpace.sRGB, color: RGBColorModel()), winding: .nonZero)

context.draw(shape: Shape.Ellipse(Rect(x: 35, y: 10, width: 55, height: 55)), color: Color(colorSpace: CalibratedRGBColorSpace.sRGB, color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255)), winding: .nonZero)

context.draw(shape: Shape.Ellipse(Rect(x: 35, y: 10, width: 55, height: 55)).strokePath(width: 1, cap: .round, join: .round), color: Color(colorSpace: CalibratedRGBColorSpace.sRGB, color: RGBColorModel()), winding: .nonZero)

let sample = Image<ARGB32ColorPixel>(image: context.image)

Image(image: sample, width: 1000, height: 1000, resampling: .none).cgImage

Image(image: sample, width: 1000, height: 1000, resampling: .linear).cgImage

Image(image: sample, width: 1000, height: 1000, resampling: .cosine).cgImage

Image(image: sample, width: 1000, height: 1000, resampling: .cubic).cgImage

Image(image: sample, width: 1000, height: 1000, resampling: .hermite(0.5, 0)).cgImage

Image(image: sample, width: 1000, height: 1000, resampling: .mitchell(1/3, 1/3)).cgImage

Image(image: sample, width: 1000, height: 1000, resampling: .lanczos(3)).cgImage
