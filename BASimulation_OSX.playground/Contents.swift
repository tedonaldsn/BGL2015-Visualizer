//: Playground - noun: a place where people can play

import Cocoa
import PlaygroundSupport

import BASimulationFoundation

let fubar = Scaled0to1Value()


public struct Trig {
    
    static let degreeToRadianFactor: CGFloat = CGFloat(Trig.pi/180.0)
    static let radianToDegreeFactor: CGFloat = 1.0 / Trig.degreeToRadianFactor
    
    static let pi: CGFloat = CGFloat(M_PI)
    static let triangle: CGFloat = pi
    static let square: CGFloat = pi * 2.0
    static let circle: CGFloat = pi * 2.0
    
    static let degrees360: CGFloat = circle
    static let degrees180: CGFloat = pi
    static let degrees90: CGFloat = degrees180 / 2.0
    static let degrees45: CGFloat = degrees90 / 2.0
    
    static func radians(_ fromDegrees: CGFloat) -> CGFloat {
        return fromDegrees * Trig.degreeToRadianFactor
    }
    static func degrees(_ fromRadians: CGFloat) -> CGFloat {
        return fromRadians * Trig.radianToDegreeFactor
    }
    
    
    static func reciprocalHeading(_ heading: CGFloat) -> CGFloat {
        assert(heading >= 0.0)
        assert(heading <= circle)
        
        return fabs(heading - Trig.pi)
    }
    
    
    
    // Heading is measured clockwise from due east in the range 0 ≤ r ≤ 2π.
    //
    static func pointAt(_ distance: CGFloat,
                        heading: CGFloat,
                        fromPoint: CGPoint) -> CGPoint {
        assert(heading >= 0)
        assert(heading <= Trig.circle)
        //
        // Convert heading to what would have been returned by atan2(). See
        // angle(), below.
        //
        let atanHeading = convertFullCircleAngleToAtan2(heading)
        
        let xDelta = distance * cos(atanHeading)
        let yDelta = distance * sin(atanHeading)
        let point = CGPoint(x: xDelta + fromPoint.x,
                            y: yDelta + fromPoint.y)
        
        // Swift.print("Distance \(distance) on heading \(heading) from \(fromPoint) -> \(point)")
        
        return point
    }
    
    
    
    // Distance between two points.
    //
    static func distance(_ fromPoint: CGPoint, toPoint: CGPoint) -> CGFloat {
        return sqrt(
            pow(toPoint.x - fromPoint.x, 2.0) + pow(toPoint.y - fromPoint.y, 2.0)
        )
    }
    
    
    
    
    // Returns a clockwise angle from the "east" zero point. Range is
    // 0 ≤ r ≤ 2π.
    //
    // atan2(): https://en.wikipedia.org/wiki/Atan2
    //
    static func angle(_ fromPoint: CGPoint, toPoint: CGPoint) -> CGFloat {
        
        assert(fromPoint != toPoint)
        
        let xDelta: CGFloat = toPoint.x - fromPoint.x
        let yDelta: CGFloat = toPoint.y - fromPoint.y
        
        // atan2() returns radians in the range: −π < atan2(y, x) ≤ π, in which
        // positive values are counterclockwise radians from the "east" pointing
        // zero radian, and negative values are clockwise radians from the
        // same point.
        //
        // We want only clockwise values from the zero point in the full range
        // of  0 ≤ r ≤ 2π.
        //
        let rawRads: CGFloat = atan2(yDelta, xDelta)
        
        return convertAtan2AngleToFullCircle(rawRads)
        
    } // end angle
    
    
    // Full-circle angle is clockwise from due east in the full range of
    // 2π radians, akin to compass angles, but with the zero point at east
    // instead of north.
    //
    // Atan2() angle is from due east. Positive values are counterclockwise
    // and negative angles are clockwise, limited to an abolute value of pi.
    //
    static func convertFullCircleAngleToAtan2(_ compassAngle: CGFloat) -> CGFloat {
        assert(compassAngle >= 0)
        assert(compassAngle <= circle)
        
        var atan2Angle: CGFloat = 0.0
        
        if compassAngle <= pi {
            atan2Angle = -compassAngle
            
        } else if compassAngle > pi {
            atan2Angle = circle - compassAngle
        }
        
        assert(atan2Angle <= 0.0 || atan2Angle <= pi)
        assert(atan2Angle >= 0.0 || atan2Angle >= -pi)
        
        return atan2Angle
    }
    
    
    
    
    // Full-circle angle is clockwise from due east in the full range of
    // 2π radians, akin to compass angles, but with the zero point at east
    // instead of north.
    //
    // Atan2() angle is from due east. Positive values are counterclockwise
    // and negative angles are clockwise, limited to an abolute value of pi.
    //
    static func convertAtan2AngleToFullCircle(_ atan2Angle: CGFloat) -> CGFloat {
        assert(atan2Angle <= 0.0 || atan2Angle <= pi)
        assert(atan2Angle >= 0.0 || atan2Angle >= -pi)
        
        var compassAngle: CGFloat = 0.0
        
        if atan2Angle < 0.0 {
            compassAngle = -atan2Angle
            
        } else if atan2Angle > 0.0 {
            compassAngle = circle - atan2Angle
        }
        
        assert(compassAngle >= 0)
        assert(compassAngle <= circle)
        
        return compassAngle
    }
    
    
    
    // Case AAS: Any two angles, and one side, BUT the side must NOT be
    // between the two angles.
    //
    static func side2TriangleAAS(_ angle1: CGFloat, side1: CGFloat, angle2: CGFloat) -> CGFloat {
        assert(triangle - (angle1 + angle2) > 0.0)
        let side2 = (side1 * sin(angle2)) / sin(angle1)
        return side2
    }
    
    // Case SAS: knowns are two sides and the angle in between them -> returns
    // the angle opposite the first side (i.e, returns angle1).
    //
    static func angle1TriangleSAS(_ side1: CGFloat, side2: CGFloat, angle3: CGFloat) -> CGFloat {
        let angle1 = sqrt(
            pow(side1, 2.0)
                + pow(side2, 2.0)
                - (2 * (side1 + side2 + cos(angle3)))
        )
        return angle1
    }
    
    // Case SSA: knowns are two sides and either of the two angles that are NOT
    // between the two sides -> returns the unknown side
    //
    // NOT IMPLEMENTED: Always two solutions?
    
    
} // end struct Trig






class ArcView: NSView {
    
    var path = NSBezierPath()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        wantsLayer = true
        layer!.borderColor = NSColor.blue.cgColor
        layer!.borderWidth = 1.0
        
        let center = NSPoint(x: frame.midX, y: frame.midY)
        let diameter = frame.size.height < frame.size.width
            ? frame.size.height
            : frame.size.width
        let radius = diameter / 4.0
        
        
        let arcAngleWidthDegrees: CGFloat = 360.0 / 3.0
        
        let arcTopAngleDegrees: CGFloat = 180.0 - (arcAngleWidthDegrees / 2.0)
        let arcBottomAngleDegrees: CGFloat = 180.0 + (arcAngleWidthDegrees / 2.0)
        
        path.appendArc(withCenter: center,
                            radius: radius,
                            startAngle: arcBottomAngleDegrees,
                            endAngle: arcTopAngleDegrees,
                            clockwise: true)
        
        let arcTopAngle: CGFloat = Trig.degreeToRadianFactor * arcTopAngleDegrees
        let arcBottomAngle: CGFloat = Trig.degreeToRadianFactor * arcBottomAngleDegrees
        
        let topPoint: CGPoint = Trig.pointAt(diameter, heading: arcTopAngle, fromPoint: center)
        let bottomPoint: CGPoint = Trig.pointAt(diameter, heading: arcBottomAngle, fromPoint: center)
        
        // Smaller circle: arc forms bulging back of the concave shape: shorten
        // the radius and move the center closer to the arc points. Create
        // back as a separate shape then append to the final shape to avoid
        // any extraneous lines caused by continuing the same shape.
        //
        let backRadius: CGFloat = radius / 2.0
        let backCenter: CGPoint = Trig.pointAt(50.0,
                                               heading: Trig.pi,
                                               fromPoint: center)
        let backTopAngle: CGFloat = Trig.angle(backCenter, toPoint: topPoint)
        let backBottomAngle: CGFloat = Trig.angle(backCenter, toPoint: bottomPoint)
        
        let backTopAngleDegrees: CGFloat = Trig.degrees(backTopAngle)
        let backBottomAngleDegrees: CGFloat = Trig.degrees(backBottomAngle)
        
        let backPath = NSBezierPath()
        backPath.appendArc(withCenter: backCenter,
                           radius: backRadius,
                           startAngle: backBottomAngleDegrees,
                           endAngle: backTopAngleDegrees,
                           clockwise: true)
        
        path.append(backPath)
        
    } // end init
    
    
    
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor.red.setStroke()
        path.stroke()
        
        Swift.print(path)
    }
}

let dia = 200

PlaygroundPage.current.needsIndefiniteExecution = true
let containerView = ArcView(frame: NSRect(x: 0, y: 0, width: dia, height: dia))
PlaygroundPage.current.liveView = containerView






