//: Playground - noun: a place where people can play

import Cocoa
import Doggie

var array = MappedBuffer<Int>(repeating: 0, count: 1)

array.capacity

array.append(contentsOf: 1...4900)

array.insert(0, at: 32)

array.remove(at: 64)

array.capacity

array.count

print(array)
