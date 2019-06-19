//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let sample = sampleImage(width: 100, height: 100)

resampling(image: sample, width: 500, height: 500, resampling: .none, antialias: false)

resampling(image: sample, width: 500, height: 500, resampling: .linear, antialias: false)

resampling(image: sample, width: 500, height: 500, resampling: .cosine, antialias: false)

resampling(image: sample, width: 500, height: 500, resampling: .cubic, antialias: false)

resampling(image: sample, width: 500, height: 500, resampling: .hermite(0.5, 0), antialias: false)

resampling(image: sample, width: 500, height: 500, resampling: .mitchell(1/3, 1/3), antialias: false)

resampling(image: sample, width: 500, height: 500, resampling: .lanczos(3), antialias: false)
