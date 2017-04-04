
import Cocoa
import Doggie

public class QuadCurveInsideView: NSView, NSGestureRecognizerDelegate {
    
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
    
    public var q: Point = Point() {
        didSet {
            self.setNeedsDisplay(frame)
        }
    }
    
    var textField = NSTextField(frame: NSRect(x: 10, y: 10, width: 200, height: 17))
    
    var target: Int = -1
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        let pan = NSPanGestureRecognizer(target: self, action: #selector(handleGesture))
        pan.delegate = self
        
        self.addGestureRecognizer(pan)
        
        p0 = Point(x: frame.width * 0.1, y: frame.height * 0.1)
        p1 = Point(x: frame.width * 0.9, y: frame.height * 0.1)
        p2 = Point(x: frame.width * 0.1, y: frame.height * 0.9)
        q = Point(x: frame.width * 0.5, y: frame.height * 0.5)
        
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        
        self.addSubview(textField)
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        
        NSColor.white.setFill()
        NSRectFill(dirtyRect)
        
        func drawPoint(_ context: CGContext, _ point: Point) {
            context.strokeEllipse(in: CGRect(x: point.x - 2, y: point.y - 2, width: 4, height: 4))
        }
        
        if let context = NSGraphicsContext.current()?.cgContext {
            
            context.setStrokeColor(NSColor.red.cgColor)
            
            let shape: Shape = [Shape.Component(start: p0, segments: [.quad(p1, p2)])]
            
            context.addPath(shape.cgPath)
            context.strokePath()
            
            context.setStrokeColor(NSColor.blue.cgColor)
            
            drawPoint(context, p0)
            drawPoint(context, p1)
            drawPoint(context, p2)
            
            if let transform = SDTransform(from: p0, p1, p2, to: Point(x: 0, y: 0), Point(x: 0.5, y: 0), Point(x: 1, y: 1)) {
                let _q = q * transform
                if _q.x * _q.x - _q.y > 0 {
                    context.setStrokeColor(NSColor.green.cgColor)
                }
                textField.stringValue = "\(_q.x * _q.x - _q.y)"
            }
            
            drawPoint(context, q)
            
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
            target = [p0, p1, p2, q].map { (Point(location) - $0).magnitude }.enumerated().min { $0.1 }?.0 ?? -1
        case .changed:
            switch target {
            case 0: p0 = Point(sender.location(in: self))
            case 1: p1 = Point(sender.location(in: self))
            case 2: p2 = Point(sender.location(in: self))
            case 3: q = Point(sender.location(in: self))
            default: break
            }
        default: break
        }
    }
}
