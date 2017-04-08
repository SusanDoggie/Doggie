
import Cocoa
import Doggie

public class CurveInsideView: NSView, NSGestureRecognizerDelegate {
    
    public var p0: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    public var p1: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    public var p2: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    public var p3: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    
    public var q: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    
    var textField = NSTextField(frame: NSRect(x: 10, y: 10, width: 200, height: 17))
    
    var target: Int = -1
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        self.addTrackingArea(NSTrackingArea(rect: self.bounds, options: [.mouseMoved, .activeInActiveApp, .inVisibleRect], owner: self, userInfo: nil))
        
        let pan = NSPanGestureRecognizer(target: self, action: #selector(handleGesture))
        pan.delegate = self
        
        self.addGestureRecognizer(pan)
        
        p0 = Point(x: frame.width * 0.1, y: frame.height * 0.1)
        p1 = Point(x: frame.width * 0.9, y: frame.height * 0.1)
        p2 = Point(x: frame.width * 0.9, y: frame.height * 0.9)
        p3 = Point(x: frame.width * 0.1, y: frame.height * 0.9)
        q = Point(x: frame.width * 0.5, y: frame.height * 0.5)
        
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        
        self.addSubview(textField)
    }
    
    private func test(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point, _ _triangle: (Point, Point, Point) -> Void, _ drawQuad: (Point, Point, Point) -> Void, _ drawCubic: (Point, Point, Point, Vector, Vector, Vector) -> Void) {
        
        let q1 = 3 * (p1 - p0)
        let q2 = 3 * (p2 + p0) - 6 * p1
        let q3 = p3 - p0 + 3 * (p1 - p2)
        
        let d1 = -cross(q3, q2)
        let d2 = cross(q3, q1)
        let d3 = -cross(q2, q1)
        
        let discr = 3 * d2 * d2 - 4 * d1 * d3
        
        func draw(_ k0: Vector, _ k1: Vector, _ k2: Vector, _ k3: Vector, _ _drawCubic: (Point, Point, Point, Vector, Vector, Vector) -> Void) {
            
            let v0 = k0
            let v1 = k0 + k1 / 3
            let v2 = k0 + (2 * k1 + k2) / 3
            let v3 = k0 + k1 + k2 + k3
            
            var q0 = p0
            var q1 = p1
            var q2 = p2
            var q3 = p3
            
            while true {
                
                var flag = false
                
                if !CircleInside(q0, q1, q2, q3) {
                    _drawCubic(p0, p1, p2, v0, v1, v2)
                    flag = true
                }
                if !CircleInside(q0, q2, q3, q1) {
                    _drawCubic(p0, p2, p3, v0, v2, v3)
                    flag = true
                }
                if !CircleInside(q1, q2, q3, q0) {
                    _drawCubic(p1, p2, p3, v1, v2, v3)
                    flag = true
                }
                if !CircleInside(q0, q1, q3, q2) {
                    _drawCubic(p0, p1, p3, v0, v1, v3)
                    flag = true
                }
                if !flag {
                    
                    q0 *= SDTransform.SkewX(1)
                    q1 *= SDTransform.SkewX(1)
                    q2 *= SDTransform.SkewX(1)
                    q3 *= SDTransform.SkewX(1)
                    
                    continue
                }
                
                return
            }
        }
        
        if d1.almostZero() {
            
            if d2.almostZero() {
                
                if !d3.almostZero(), let intersect = LinesIntersect(p0, p1, p2, p3) {
                    drawQuad(p0, intersect, p3)
                }
            } else {
                
                // cusp with cusp at infinity
                
                let tl = d3
                let sl = 3 * d2
                
                let tl2 = tl * tl
                let sl2 = sl * sl
                
                let k0 = Vector(x: tl, y: tl2 * tl, z: 1)
                let k1 = Vector(x: -sl, y: -3 * sl * tl2, z: 0)
                let k2 = Vector(x: 0, y: 3 * sl2 * tl, z: 0)
                let k3 = Vector(x: 0, y: -sl2 * sl, z: 0)
                
                draw(k0, k1, k2, k3, drawCubic)
            }
            
        } else {
            
            if discr.almostZero() || discr > 0 {
                
                // serpentine
                
                let delta = sqrt(max(0, discr)) / sqrt(3)
                
                let tl = d2 + delta
                let sl = 2 * d1
                let tm = d2 - delta
                let sm = sl
                
                let tl2 = tl * tl
                let sl2 = sl * sl
                let tm2 = tm * tm
                let sm2 = sm * sm
                
                var k0 = Vector(x: tl * tm, y: tl2 * tl, z: tm2 * tm)
                var k1 = Vector(x: -sm * tl - sl * tm, y: -3 * sl * tl2, z: -3 * sm * tm2)
                var k2 = Vector(x: sl * sm, y: 3 * sl2 * tl, z: 3 * sm2 * tm)
                var k3 = Vector(x: 0, y: -sl2 * sl, z: -sm2 * sm)
                
                if d1.sign == .minus {
                    k0.x = -k0.x
                    k1.x = -k1.x
                    k2.x = -k2.x
                    k3.x = -k3.x
                    k0.y = -k0.y
                    k1.y = -k1.y
                    k2.y = -k2.y
                    k3.y = -k3.y
                }
                
                draw(k0, k1, k2, k3, drawCubic)
                
            } else {
                
                // loop
                
                let delta = sqrt(-discr)
                
                let td = d2 + delta
                let sd = 2 * d1
                let te = d2 - delta
                let se = sd
                
                let split_t = [td / sd, te / se].filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }
                
                if split_t.count != 0 {
                    
                    let beziers = Bezier(p0, p1, p2, p3).split(split_t)
                    
                    _triangle(p0, beziers.last![0], beziers.last![3])
                    
                    beziers.forEach {
                        test($0[0], $0[1], $0[2], $0[3], _triangle, drawQuad, drawCubic)
                    }
                    
                } else {
                    
                    let td2 = td * td
                    let sd2 = sd * sd
                    let te2 = te * te
                    let se2 = se * se
                    
                    var k0 = Vector(x: td * te, y: td2 * te, z: td * te2)
                    var k1 = Vector(x: -se * td - sd * te, y: -se * td2 - 2 * sd * te * td, z: -sd * te2 - 2 * se * td * te)
                    var k2 = Vector(x: sd * se, y: te * sd2 + 2 * se * td * sd, z: td * se2 + 2 * sd * te * se)
                    var k3 = Vector(x: 0, y: -sd2 * se, z: -sd * se2)
                    
                    let v1x = k0.x + k1.x / 3
                    if d1.sign != v1x.sign {
                        k0.x = -k0.x
                        k1.x = -k1.x
                        k2.x = -k2.x
                        k3.x = -k3.x
                        k0.y = -k0.y
                        k1.y = -k1.y
                        k2.y = -k2.y
                        k3.y = -k3.y
                    }
                    
                    draw(k0, k1, k2, k3, drawCubic)
                    
                }
            }
        }
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        
        NSColor.white.setFill()
        NSRectFill(dirtyRect)
        
        func drawPoint(_ context: CGContext, _ point: Point) {
            context.strokeEllipse(in: CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4))
        }
        
        if let context = NSGraphicsContext.current()?.cgContext {
            
            context.setStrokeColor(NSColor.black.cgColor)
            
            let shape: Shape = [Shape.Component(start: p0, segments: [.cubic(p1, p2, p3)])]
            
            context.addPath(shape.cgPath)
            context.strokePath()
            
            context.setStrokeColor(NSColor.blue.cgColor)
            
            drawPoint(context, p0)
            drawPoint(context, p1)
            drawPoint(context, p2)
            drawPoint(context, p3)
            
            if let (t1, _) = CubicBezierSelfIntersect(p0, p1, p2, p3) {
                
                context.setStrokeColor(NSColor.red.cgColor)
                
                drawPoint(context, Bezier(p0, p1, p2, p3).eval(t1))
            }
            
            var counter = 0
            
            var str = ""
            
            test(p0, p1, p2, p3, {
                
                context.setStrokeColor(NSColor.yellow.cgColor)
                
                context.strokeLineSegments(between: [$0, $1, $1, $2, $2, $0].map(CGPoint.init))
                
            }, {
                
                context.setStrokeColor(NSColor.yellow.cgColor)
                
                context.strokeLineSegments(between: [$0, $1, $1, $2, $2, $0].map(CGPoint.init))
                
                if let p = Barycentric($0, $1, $2, q) {
                    
                    let v = p.x * Point(x: 0, y: 0) + p.y * Point(x: 0.5, y: 0) + p.z * Point(x: 1, y: 1)
                    
                    str = "\(v.x * v.x - v.y)"
                }
            },  {
                
                counter += 1
                
                context.setStrokeColor(NSColor.green.cgColor)
                
                context.strokeLineSegments(between: [$0, $1, $1, $2, $2, $0].map(CGPoint.init))
                
                if let p = Barycentric($0, $1, $2, q), p.x.sign == .plus && p.y.sign == .plus && p.z.sign == .plus {
                    
                    let v = p.x * $3 + p.y * $4 + p.z * $5
                    
                    str = "\(v.x * v.x * v.x - v.y * v.z)"
                }
                
            })
            
            textField.stringValue = "\(counter)\t\(str)"
        }
        
        super.draw(dirtyRect)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func mouseMoved(with event: NSEvent) {
        
        q = Point(self.convert(event.locationInWindow, from: nil))
        
        super.mouseMoved(with: event)
    }
    
    func handleGesture(_ sender: NSPanGestureRecognizer) {
        
        switch sender.state {
        case .began:
            let location = sender.location(in: self)
            target = [p0, p1, p2, p3].map { (Point(location) - $0).magnitude }.enumerated().min { $0.1 }?.0 ?? -1
        case .changed:
            switch target {
            case 0: p0 = Point(sender.location(in: self))
            case 1: p1 = Point(sender.location(in: self))
            case 2: p2 = Point(sender.location(in: self))
            case 3: p3 = Point(sender.location(in: self))
            default: break
            }
        default: break
        }
    }
}
