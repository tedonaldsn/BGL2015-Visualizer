import Cocoa
import PlaygroundSupport
import BASimulationFoundation

class ArcView: NSView {
    
    var path = NSBezierPath()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        wantsLayer = true
        layer!.borderColor = NSColor.blue.cgColor
        layer!.borderWidth = 2.0
        
        let innerArc = CircularSegment(center: CGPoint(x: 25.0, y: 25.0),
                                       radius: 10.0,
                                       fromRadians: Trig.radians(fromDegrees: 150.0),
                                       toRadians: Trig.radians(fromDegrees: 210.0))
        
        Swift.print("Inner Arc (#1): \(innerArc)\n")
        
        let fromDegrees1: CGFloat = innerArc.fromRadians * Trig.radianToDegreeFactor
        let toDegrees1: CGFloat = innerArc.toRadians * Trig.radianToDegreeFactor
        
        // Mismatch: CircularSegment measures angles clockwise. NSBezierPath measures
        // arc angles counterclockwise. Must convert.
        //
        let fromPathDegrees1 = 360.0 - fromDegrees1
        let toPathDegrees1 = 360.0 - toDegrees1
        
        path.appendArc(withCenter: innerArc.circle.center,
                       radius: innerArc.circle.radius,
                       startAngle: fromPathDegrees1,
                       endAngle: toPathDegrees1,
                       clockwise: true)
        

        let lensThickness: CGFloat = 2.5
        let outerArc = innerArc.changeSagittaHeight(delta: lensThickness)
        
        Swift.print("Outer Arc (#2): \(outerArc)\n")
        
        let fromDegrees2: CGFloat = outerArc.fromRadians * Trig.radianToDegreeFactor
        let toDegrees2: CGFloat = outerArc.toRadians * Trig.radianToDegreeFactor

        // Mismatch: CircularSegment measures angles clockwise. NSBezierPath measures
        // arc angles counterclockwise. Must convert.
        //
        let fromPathDegrees2 = 360.0 - fromDegrees2
        let toPathDegrees2 = 360.0 - toDegrees2
        
        let arc2 = NSBezierPath()
        arc2.appendArc(withCenter: outerArc.circle.center,
                       radius: outerArc.circle.radius,
                       startAngle: fromPathDegrees2,
                       endAngle: toPathDegrees2,
                       clockwise: true)
        
        path.append(arc2)

        
        Swift.print("init()")
        
    } // end init
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.red.setStroke()
        path.stroke()
        Swift.print("draw()")
    }
}

let dia = 50

PlaygroundPage.current.needsIndefiniteExecution = true
let containerView = ArcView(frame: NSRect(x: 0, y: 0, width: dia, height: dia))
PlaygroundPage.current.liveView = containerView






