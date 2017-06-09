//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let sample = sampleImage(width: 100, height: 100)

if let image = Image(image: sample, width: 1000, height: 1000, resampling: .none).cgImage {
    NSImage(cgImage: image)
}

if let image = Image(image: sample, width: 1000, height: 1000, resampling: .linear).cgImage {
    NSImage(cgImage: image)
}

if let image = Image(image: sample, width: 1000, height: 1000, resampling: .cosine).cgImage {
    NSImage(cgImage: image)
}

if let image = Image(image: sample, width: 1000, height: 1000, resampling: .cubic).cgImage {
    NSImage(cgImage: image)
}

if let image = Image(image: sample, width: 1000, height: 1000, resampling: .hermite(0.5, 0)).cgImage {
    NSImage(cgImage: image)
}

if let image = Image(image: sample, width: 1000, height: 1000, resampling: .mitchell(1/3, 1/3)).cgImage {
    NSImage(cgImage: image)
}

if let image = Image(image: sample, width: 1000, height: 1000, resampling: .lanczos(3)).cgImage {
    NSImage(cgImage: image)
}
