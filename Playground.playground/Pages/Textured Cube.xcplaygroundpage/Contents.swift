//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let t = Date()

let image = sampleImage(width: 500, height: 500)

t.timeIntervalSinceNow

if let image = image.cgImage {
    NSImage(cgImage: image)
}
