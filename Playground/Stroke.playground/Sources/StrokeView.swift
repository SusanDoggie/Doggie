
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
    public var p3: Point = Point() {
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
        p3 = Point(x: frame.width * 0.9, y: frame.height * 0.9)
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        
        NSColor.white.setFill()
        NSRectFill(dirtyRect)
        
        func drawPoint(_ context: CGContext, _ point: Point) {
            context.strokeEllipse(in: CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4))
        }
        
        if let context = NSGraphicsContext.current()?.cgContext {
            
            let shape: Shape = [Shape.Component(start: p0, segments: [.cubic(p1, p2, p3)])]
            
            QuadBezierFitting([p0, p1, p2, p3]).enumerated().forEach { idx, points in
                
                context.setStrokeColor(idx & 1 == 0 ? NSColor.blue.cgColor : NSColor.red.cgColor)
                
                let path = CGMutablePath()
                path.move(to: CGPoint(points[0]))
                
                switch points.count {
                case 2: path.addLine(to: CGPoint(points[1]))
                case 3: path.addQuadCurve(to: CGPoint(points[2]), control: CGPoint(points[1]))
                default: break
                }
                context.addPath(path)
                context.strokePath()
            }
            
            context.setFillColor(NSColor.yellow.cgColor)
            context.setStrokeColor(NSColor.red.cgColor)
            
            context.addPath(shape.cgPath)
            context.fillPath()
            
            context.addPath(shape.strokePath(width: 50, cap: .round, join: .round).cgPath)
            context.strokePath()
            
            context.setStrokeColor(NSColor.blue.cgColor)
            
            drawPoint(context, p0)
            drawPoint(context, p1)
            drawPoint(context, p2)
            drawPoint(context, p3)
            
        }
        
        super.draw(dirtyRect)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
