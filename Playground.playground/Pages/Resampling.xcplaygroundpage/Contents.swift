//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let sample = sampleImage(width: 100, height: 100)

if let image = resampling(image: sample, width: 1000, height: 1000, resampling: .none, antialias: false).cgImage {
    NSImage(cgImage: image)
}

if let image = resampling(image: sample, width: 1000, height: 1000, resampling: .linear, antialias: false).cgImage {
    NSImage(cgImage: image)
}

if let image = resampling(image: sample, width: 1000, height: 1000, resampling: .cosine, antialias: false).cgImage {
    NSImage(cgImage: image)
}

if let image = resampling(image: sample, width: 1000, height: 1000, resampling: .cubic, antialias: false).cgImage {
    NSImage(cgImage: image)
}

if let image = resampling(image: sample, width: 1000, height: 1000, resampling: .hermite(0.5, 0), antialias: false).cgImage {
    NSImage(cgImage: image)
}

if let image = resampling(image: sample, width: 1000, height: 1000, resampling: .mitchell(1/3, 1/3), antialias: false).cgImage {
    NSImage(cgImage: image)
}

if let image = resampling(image: sample, width: 1000, height: 1000, resampling: .lanczos(3), antialias: false).cgImage {
    NSImage(cgImage: image)
}
