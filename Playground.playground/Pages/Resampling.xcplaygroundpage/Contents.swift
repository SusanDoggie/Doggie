//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let sample = sampleImage(width: 100, height: 100)

if let image = resampling(image: sample, resampling: .none).cgImage {
    NSImage(cgImage: image)
}

if let image = resampling(image: sample, resampling: .linear).cgImage {
    NSImage(cgImage: image)
}

if let image = resampling(image: sample, resampling: .cosine).cgImage {
    NSImage(cgImage: image)
}

if let image = resampling(image: sample, resampling: .cubic).cgImage {
    NSImage(cgImage: image)
}

if let image = resampling(image: sample, resampling: .hermite(0.5, 0)).cgImage {
    NSImage(cgImage: image)
}

if let image = resampling(image: sample, resampling: .mitchell(1/3, 1/3)).cgImage {
    NSImage(cgImage: image)
}

if let image = resampling(image: sample, resampling: .lanczos(3)).cgImage {
    NSImage(cgImage: image)
}
