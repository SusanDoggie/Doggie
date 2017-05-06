//: Playground - noun: a place where people can play

import Cocoa
import Doggie
import Metal
import PlaygroundSupport


let size = 500

var shape = try Shape(code: "M100 0c0-100-236.60 36.60-150 86.60S36.60-136.60-50-86.60 100 100 100 0z")

shape.scale *= Double(size) / shape.boundary.height

shape.center = Point(x: 0.5 * Double(size), y: 0.5 * Double(size))

var operation: [(Int32, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float, Float)] = []

shape.identity.render {
    switch $0 {
    case let .triangle(p0, p1, p2): operation.append((0, Float(p0.x), Float(p0.y), Float(p1.x), Float(p1.y), Float(p2.x), Float(p2.y), 0, 0, 0, 0, 0, 0, 0, 0, 0))
    case let .quadratic(p0, p1, p2): operation.append((1, Float(p0.x), Float(p0.y), Float(p1.x), Float(p1.y), Float(p2.x), Float(p2.y), 0, 0, 0, 0, 0, 0, 0, 0, 0))
    case let .cubic(p0, p1, p2, v0, v1, v2): operation.append((2, Float(p0.x), Float(p0.y), Float(p1.x), Float(p1.y), Float(p2.x), Float(p2.y), Float(v0.x), Float(v0.y), Float(v0.z), Float(v1.x), Float(v1.y), Float(v1.z), Float(v2.x), Float(v2.y), Float(v2.z)))
    }
}

// Setup Metal
let device = MTLCreateSystemDefaultDevice()!

let view = NSView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

view.wantsLayer = true

let metalLayer = CAMetalLayer()
metalLayer.device = device
metalLayer.pixelFormat = .bgra8Unorm
metalLayer.framebufferOnly = true
metalLayer.frame = view.layer!.frame
view.layer!.addSublayer(metalLayer)

PlaygroundPage.current.liveView = view

let source = try String(contentsOfFile: Bundle.main.path(forResource: "Raster", ofType: "metal")!, encoding: .utf8)
let library = try! device.makeLibrary(source: source, options: nil)

let commandQueue = device.makeCommandQueue()
let commandBuffer = commandQueue.makeCommandBuffer()

let drawable = metalLayer.nextDrawable()!
let renderPassDescriptor = MTLRenderPassDescriptor()
renderPassDescriptor.colorAttachments[0].texture = drawable.texture
renderPassDescriptor.colorAttachments[0].loadAction = .clear
renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)

let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)

let pipelineDescriptor = MTLRenderPipelineDescriptor()

pipelineDescriptor.vertexFunction = library.makeFunction(name: "basic_vertex")
pipelineDescriptor.fragmentFunction = library.makeFunction(name: "basic_fragment")
pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

renderEncoder.setRenderPipelineState(try device.makeRenderPipelineState(descriptor: pipelineDescriptor))

let vertexData: [Float] = [-1.0, -1.0, 0.0,
                           1.0, -1.0, 0.0,
                           -1.0, 1.0, 0.0,
                           1.0, 1.0, 0.0]

let vertexBuffer = device.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout.size(ofValue: vertexData[0]), options: [])

let operationBuffer = device.makeBuffer(bytes: operation, length: operation.count == 0 ? 1 : operation.count * MemoryLayout.size(ofValue: operation[0]), options: [])
let operationCount = device.makeBuffer(bytes: [Int32(operation.count)], length: MemoryLayout<Int32>.size, options: [])

renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)

renderEncoder.setFragmentBuffer(operationBuffer, offset: 0, at: 0)
renderEncoder.setFragmentBuffer(operationCount, offset: 0, at: 1)

renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)

renderEncoder.endEncoding()

commandBuffer.present(drawable)
commandBuffer.commit()
