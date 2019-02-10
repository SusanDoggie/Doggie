
import Cocoa
import Doggie

public class TensorPatchView: NSView, NSGestureRecognizerDelegate {

    public var shape: Shape? {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }

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
    public var p4: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    public var p5: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    public var p6: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    public var p7: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    public var p8: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    public var p9: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    public var p10: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    public var p11: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    public var p12: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    public var p13: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    public var p14: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    public var p15: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }

    var target: Int = -1

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        let pan = NSPanGestureRecognizer(target: self, action: #selector(handleGesture))
        pan.delegate = self

        self.addGestureRecognizer(pan)

        p0 = Point(x: frame.width * 0.1, y: frame.height * 0.1)
        p3 = Point(x: frame.width * 0.9, y: frame.height * 0.1)
        p12 = Point(x: frame.width * 0.1, y: frame.height * 0.9)
        p15 = Point(x: frame.width * 0.9, y: frame.height * 0.9)

        p1 = Bezier(p0, p3).eval(1 / 3)
        p2 = Bezier(p0, p3).eval(2 / 3)

        p13 = Bezier(p12, p15).eval(1 / 3)
        p14 = Bezier(p12, p15).eval(2 / 3)

        p4 = Bezier(p0, p12).eval(1 / 3)
        p8 = Bezier(p0, p12).eval(2 / 3)

        p5 = Bezier(p1, p13).eval(1 / 3)
        p9 = Bezier(p1, p13).eval(2 / 3)

        p6 = Bezier(p2, p14).eval(1 / 3)
        p10 = Bezier(p2, p14).eval(2 / 3)

        p7 = Bezier(p3, p15).eval(1 / 3)
        p11 = Bezier(p3, p15).eval(2 / 3)
    }

    public func implement() -> Shape? {

        if let shape = shape {

            var path: [Shape.Component] = []

            path.reserveCapacity(shape.count)

            for item in shape.identity {
                var flag = true
                var component = Shape.Component()

                var last = item.start

                func addCurves(_ points: [Bezier<Point>]) {
                    if let first = points.first {
                        if flag {
                            component.start = first[0]
                            flag = false
                        }
                        for p in points {
                            switch p.count {
                            case 2: component.append(.line(p[1]))
                            case 3: component.append(.quad(p[1], p[2]))
                            case 4: component.append(.cubic(p[1], p[2], p[3]))
                            default: break
                            }
                        }
                    }
                }

                for segment in item {
                    switch segment {
                    case let .line(p1):
                        addCurves(CubicBezierPatch(self.p0, self.p1, self.p2, self.p3, self.p4, self.p5, self.p6, self.p7, self.p8, self.p9, self.p10, self.p11, self.p12, self.p13, self.p14, self.p15).warping([last, p1]))
                        last = p1
                    case let .quad(p1, p2):
                        addCurves(CubicBezierPatch(self.p0, self.p1, self.p2, self.p3, self.p4, self.p5, self.p6, self.p7, self.p8, self.p9, self.p10, self.p11, self.p12, self.p13, self.p14, self.p15).warping([last, p1, p2]))
                        last = p2
                    case let .cubic(p1, p2, p3):
                        addCurves(CubicBezierPatch(self.p0, self.p1, self.p2, self.p3, self.p4, self.p5, self.p6, self.p7, self.p8, self.p9, self.p10, self.p11, self.p12, self.p13, self.p14, self.p15).warping([last, p1, p2, p3]))
                        last = p3
                    }
                }

                if item.isClosed {
                    let z = item.start - last
                    if !z.x.almostZero() || !z.y.almostZero() {
                        addCurves(CubicBezierPatch(self.p0, self.p1, self.p2, self.p3, self.p4, self.p5, self.p6, self.p7, self.p8, self.p9, self.p10, self.p11, self.p12, self.p13, self.p14, self.p15).warping([last, item.start]))
                    }
                    component.isClosed = true
                }

                path.append(component)
            }

            return Shape(path)
        }

        return nil
    }

    public override func draw(_ dirtyRect: NSRect) {

        NSColor.white.setFill()
        dirtyRect.fill()

        func drawPoint(_ context: CGContext, _ point: Point) {
            context.strokeEllipse(in: CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4))
        }

        if let context = NSGraphicsContext.current?.cgContext {

            context.setStrokeColor(NSColor(white: 0.9, alpha: 1).cgColor)

            let n = 8

            for _v in 0...n {
                let v = Double(_v) / Double(n)
                for _u in 0...n {
                    let u = Double(_u) / Double(n)

                    let q1 = Bezier(p0, p1, p2, p3)
                    let q2 = Bezier(p4, p5, p6, p7)
                    let q3 = Bezier(p8, p9, p10, p11)
                    let q4 = Bezier(p12, p13, p14, p15)

                    context.move(to: CGPoint(q1.eval(u)))
                    context.addCurve(to: CGPoint(q4.eval(u)), control1: CGPoint(q2.eval(u)), control2: CGPoint(q3.eval(u)))

                    let q5 = Bezier(p0, p4, p8, p12)
                    let q6 = Bezier(p1, p5, p9, p13)
                    let q7 = Bezier(p2, p6, p10, p14)
                    let q8 = Bezier(p3, p7, p11, p15)

                    context.move(to: CGPoint(q5.eval(v)))
                    context.addCurve(to: CGPoint(q8.eval(v)), control1: CGPoint(q6.eval(v)), control2: CGPoint(q7.eval(v)))
                }
            }

            context.strokePath()

            context.setStrokeColor(NSColor.red.cgColor)

            if let shape = implement() {
                context.addPath(shape.cgPath)
            }

            context.strokePath()

            context.setStrokeColor(NSColor.blue.cgColor)

            drawPoint(context, p0)
            drawPoint(context, p3)
            drawPoint(context, p12)
            drawPoint(context, p15)

            context.setStrokeColor(NSColor.green.cgColor)

            drawPoint(context, p1)
            drawPoint(context, p2)
            drawPoint(context, p4)
            drawPoint(context, p5)
            drawPoint(context, p6)
            drawPoint(context, p7)
            drawPoint(context, p8)
            drawPoint(context, p9)
            drawPoint(context, p10)
            drawPoint(context, p11)
            drawPoint(context, p13)
            drawPoint(context, p14)

        }

        super.draw(dirtyRect)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    func handleGesture(_ sender: NSPanGestureRecognizer) {

        switch sender.state {
        case .began:
            let location = sender.location(in: self)
            target = [p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15].map { (Point(location) - $0).magnitude }.enumerated().min { $0.1 }?.0 ?? -1
        case .changed:
            switch target {
            case 0: p0 = Point(sender.location(in: self))
            case 1: p1 = Point(sender.location(in: self))
            case 2: p2 = Point(sender.location(in: self))
            case 3: p3 = Point(sender.location(in: self))
            case 4: p4 = Point(sender.location(in: self))
            case 5: p5 = Point(sender.location(in: self))
            case 6: p6 = Point(sender.location(in: self))
            case 7: p7 = Point(sender.location(in: self))
            case 8: p8 = Point(sender.location(in: self))
            case 9: p9 = Point(sender.location(in: self))
            case 10: p10 = Point(sender.location(in: self))
            case 11: p11 = Point(sender.location(in: self))
            case 12: p12 = Point(sender.location(in: self))
            case 13: p13 = Point(sender.location(in: self))
            case 14: p14 = Point(sender.location(in: self))
            case 15: p15 = Point(sender.location(in: self))
            default: break
            }
        default: break
        }
    }
}
