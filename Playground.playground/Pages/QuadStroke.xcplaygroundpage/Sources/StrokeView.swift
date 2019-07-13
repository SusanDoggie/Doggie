
import Cocoa
import Doggie

public class StrokeView: NSView, NSGestureRecognizerDelegate {
    
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
    
    var target: Int = -1
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        let pan = NSPanGestureRecognizer(target: self, action: #selector(handleGesture))
        pan.delegate = self
        
        self.addGestureRecognizer(pan)
        
        p0 = Point(x: frame.width * 0.1, y: frame.height * 0.1)
        p1 = Point(x: frame.width * 0.9, y: frame.height * 0.1)
        p2 = Point(x: frame.width * 0.1, y: frame.height * 0.9)
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        
        NSColor.white.setFill()
        dirtyRect.fill()
        
        func drawPoint(_ context: CGContext, _ point: Point) {
            context.strokeEllipse(in: CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4))
        }
        
        if let context = NSGraphicsContext.current?.cgContext {
            
            let shape: Shape = [Shape.Component(start: p0, segments: [.quad(p1, p2)])]
            
            context.addPath(shape.strokePath(width: 50, cap: .round, join: .round).cgPath)
            context.setFillColor(NSColor(calibratedWhite: 0.9, alpha: 1).cgColor)
            context.fillPath()
            
            context.addPath(shape.strokePath(width: 50, cap: .round, join: .round).cgPath)
            context.setStrokeColor(NSColor.red.cgColor)
            context.strokePath()
            
            context.addPath(shape)
            context.setStrokeColor(NSColor.purple.cgColor)
            context.strokePath()
            
            let bezier = QuadBezier(p0, p1, p2)
            
            bezier.offset(25) { range, segment in
                if range.lowerBound == 0 {
                    context.addPath(Shape([Shape.Component(start: bezier.p0, segments: [.line(segment.p0)])]).cgPath)
                    context.setStrokeColor(NSColor.red.cgColor)
                    context.strokePath()
                }
                context.addPath(Shape([Shape.Component(start: bezier.eval(range.upperBound), segments: [.line(segment.p3)])]).cgPath)
                context.setStrokeColor(NSColor.red.cgColor)
                context.strokePath()
            }
            
            bezier.offset(-25) { range, segment in
                if range.lowerBound == 0 {
                    context.addPath(Shape([Shape.Component(start: bezier.p0, segments: [.line(segment.p0)])]).cgPath)
                    context.setStrokeColor(NSColor.red.cgColor)
                    context.strokePath()
                }
                context.addPath(Shape([Shape.Component(start: bezier.eval(range.upperBound), segments: [.line(segment.p3)])]).cgPath)
                context.setStrokeColor(NSColor.red.cgColor)
                context.strokePath()
            }
            
            for t in bezier.stationary {
                context.setStrokeColor(NSColor.red.cgColor)
                drawPoint(context, bezier.eval(t))
                
                let frame = CGRect(origin: CGPoint(bezier.eval(t).offset(dx: 10, dy: 10)), size: CGSize(width: 500, height: -500))
                let text = NSAttributedString(string: "\(_decimal_round(bezier.curvature(t)))", attributes: [.foregroundColor: NSColor.red])
                context.draw(text, in: CGPath(rect: frame, transform: nil))
            }
            
            context.setStrokeColor(NSColor.blue.cgColor)
            
            drawPoint(context, p0)
            drawPoint(context, p1)
            drawPoint(context, p2)
            
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
            target = [p0, p1, p2].map { (Point(location) - $0).magnitude }.enumerated().min { $0.1 }?.0 ?? -1
        case .changed:
            switch target {
            case 0: p0 = Point(sender.location(in: self))
            case 1: p1 = Point(sender.location(in: self))
            case 2: p2 = Point(sender.location(in: self))
            default: break
            }
        default: break
        }
    }
}
