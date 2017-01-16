//
//  Trig.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 10/12/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//
//  https://en.wikipedia.org/wiki/Trigonometric_functions
//  https://en.wikipedia.org/wiki/Radian
// 
//  http://2000clicks.com/mathhelp/GeometryLawOfSines.aspx





// CGFloat is declared in Foundation on MacOS, but in UIKit on iOS,
// even though iOS has a Foundation framework.
//
#if os(OSX)
    import Foundation
#elseif os(iOS)
    import UIKit
#endif




public struct Trig {
    
    public static let degreeToRadianFactor: CGFloat = CGFloat(Trig.pi/180.0)
    public static let radianToDegreeFactor: CGFloat = 1.0 / Trig.degreeToRadianFactor
    
    public static let pi: CGFloat = CGFloat(M_PI)
    public static let triangle: CGFloat = pi
    public static let square: CGFloat = pi * 2.0
    public static let circle: CGFloat = pi * 2.0
    
    public static let degrees360: CGFloat = circle
    public static let degrees270: CGFloat = pi * 1.5
    public static let degrees180: CGFloat = pi
    public static let degrees120: CGFloat = circle / 3.0
    public static let degrees90: CGFloat = pi / 2.0
    public static let degrees60: CGFloat = pi / 3.0
    public static let degrees45: CGFloat = pi / 4.0
    public static let degrees30: CGFloat = pi / 6.0
    
    public static func radians(fromDegrees: CGFloat) -> CGFloat {
        return fromDegrees * Trig.degreeToRadianFactor
    }
    public static func degrees(fromRadians: CGFloat) -> CGFloat {
        return fromRadians * Trig.radianToDegreeFactor
    }
    
    
    public static func reciprocalHeading(heading: CGFloat) -> CGFloat {
        assert(heading >= 0.0)
        assert(heading <= circle)
        
        return fabs(heading - Trig.pi)
    }
    
    
    // If heading is outside the range 0-circle, return the equivalent
    // value in range.
    //
    public static func normalize(heading: CGFloat) -> CGFloat {
        let rangedHeading = fmod(heading, circle)
        if rangedHeading >= 0 {
            return rangedHeading
        }
        let positiveHeading = circle + rangedHeading
        return positiveHeading
    }
    
    
    
    // Heading is measured clockwise from due east in the range 0 ≤ r ≤ 2π.
    //
    public static func pointAt(distance: CGFloat,
                               heading: CGFloat,
                               fromPoint: CGPoint) -> CGPoint {
        assert(heading >= 0)
        assert(heading <= Trig.circle)
        //
        // Convert heading to what would have been returned by atan2(). See
        // angle(), below.
        //
        let atanHeading = convertFullCircleAngleToAtan2(compassAngle: heading)
        
        let xDelta = distance * cos(atanHeading)
        let yDelta = distance * sin(atanHeading)
        let point = CGPoint(x: xDelta + fromPoint.x,
                            y: yDelta + fromPoint.y)
        
        // Swift.print("Distance \(distance) on heading \(heading) from \(fromPoint) -> \(point)")
        
        return point
    }
    
    
    
    // Distance between two points.
    //
    public static func distance(fromPoint: CGPoint, toPoint: CGPoint) -> CGFloat {
        return sqrt(
            pow(toPoint.x - fromPoint.x, 2.0) + pow(toPoint.y - fromPoint.y, 2.0)
        )
    }
    
    
    
    
    // Returns a clockwise angle from the "east" zero point. Range is
    // 0 ≤ r ≤ 2π.
    //
    // atan2(): https://en.wikipedia.org/wiki/Atan2
    //
    public static func angle(fromPoint: CGPoint, toPoint: CGPoint) -> CGFloat {
        
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
        
        return convertAtan2AngleToFullCircle(atan2Angle: rawRads)
        
    } // end angle
    
    
    // Full-circle angle is clockwise from due east in the full range of
    // 2π radians, akin to compass angles, but with the zero point at east
    // instead of north.
    //
    // Atan2() angle is from due east. Positive values are counterclockwise
    // and negative angles are clockwise, limited to an abolute value of pi.
    //
    public static func convertFullCircleAngleToAtan2(compassAngle: CGFloat) -> CGFloat {
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
    public static func convertAtan2AngleToFullCircle(atan2Angle: CGFloat) -> CGFloat {
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
    public static func side2TriangleAAS(angle1: CGFloat, angle2: CGFloat, side1: CGFloat) -> CGFloat {
        assert(triangle - (angle1 + angle2) > 0.0)
        let side2 = (side1 * sin(angle2)) / sin(angle1)
        return side2
    }
    
    // Case SAS: knowns are two sides and the angle in between them -> returns
    // the third side, the one opposite the known angle.
    //
    public static func side3TriangleSAS(side1 sideA: CGFloat,
                                        angle3 vertexC: CGFloat,
                                        side2 sideB: CGFloat) -> CGFloat {
        
        let sideCsquared = (sideA * sideA) + (sideB * sideB) - (2 * sideA * sideB * cos(vertexC))
        let sideC = sqrt(sideCsquared)
        
        return sideC
    }
    
    // Case SSA: knowns are two sides and either of the two angles that are NOT
    // between the two sides -> returns angle opposite side2.
    //
    // Only implemented for the case in which side1 is larger than side2 (the
    // only situation that returns only one possible angle2).
    //
    public static func angle2TriangleSSA(side1: CGFloat, side2: CGFloat, angle1: CGFloat) -> CGFloat {
        assert(side1.rounded6 >= side2.rounded6)
        
        let sin2: CGFloat = (side2/side1) * sin(angle1)
        let angle2: CGFloat = asin(sin2)
        return angle2
    }
    
    
} // end struct Trig



