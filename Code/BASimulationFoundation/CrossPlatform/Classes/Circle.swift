//
//  Circle.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 12/22/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//





// CGFloat is declared in Foundation on MacOS, but in UIKit on iOS,
// even though iOS has a Foundation framework.
//
#if os(OSX)
    import Foundation
#elseif os(iOS)
    import UIKit
#endif




public struct Circle {
    
    public static func determinant(point1: CGPoint, point2: CGPoint, point3: CGPoint) -> CGFloat {
        let bx = point1.x
        let cx = point2.x
        let dx = point3.x
        
        let by = point1.y
        let cy = point2.y
        let dy = point3.y
        
        let det = ((bx - cx) * (cy - dy)) - ((cx - dx) * (by - cy))
        return det

    } // end determinant
    
    
    
    public static func isStraightLine(point1 a: CGPoint, point2 b: CGPoint, point3 c: CGPoint) -> Bool {
        let mab = (b.y - a.y) / (b.x - a.x)
        let mbc = (c.y - b.y) / (c.x - b.x)
        return mab == mbc
    }
    
    
    
    public let radius: CGFloat
    public let center: CGPoint
    
    
    public init(center: CGPoint, radius: CGFloat) {
        self.radius = radius
        self.center = center
    }
    
    // http://mathforum.org/library/drmath/view/54323.html
    //
    // Args are three points on the circle's circumference.
    //
    // Precondition: the three points cannot be on a straight line.
    //
    public init(point1: CGPoint, point2: CGPoint, point3: CGPoint) {

        precondition(!Circle.isStraightLine(point1: point1, point2: point2, point3: point3),
                     "points are straight line: \(point1), \(point2), \(point3)")

        let bx = point1.x
        let cx = point2.x
        let dx = point3.x
        
        let by = point1.y
        let cy = point2.y
        let dy = point3.y
        
        let temp = (cx * cx) + (cy * cy)
        
        let bc = ((bx * bx) + (by * by) - temp) / 2.0
        let cd = (temp - (dx * dx) - (dy * dy)) / 2.0
        
        // var det = ((bx - cx) * (cy - dy)) - ((cx - dx) * (by - cy))
        //
        var det = Circle.determinant(point1: point1, point2: point2, point3: point3)
        
        det = 1 / det
        
        let centerX = ((bc * (cy - dy)) - (cd * (by - cy))) * det
        let centerY = (((bx - cx) * cd) - ((cx - dx ) * bc)) * det
        
        center = CGPoint(x: centerX, y: centerY)
        //
        // Looks like the original radius calculation assumes a right triangle
        // is formed by points 1 & 2 & the center. That is a special case that
        // rarely applies.
        //
        // radius = sqrt(((cx - bx) * (cx - bx)) + ((cy - by) * (cy - by)))
        //
        // So use this more general purpose calculation.
        //
        radius = Trig.distance(fromPoint: center, toPoint: point1)
        
    } // end init(three circumference points)
    
    

    // Point on the circumference at the specified location. The angle is
    // measured clockwise from 0º (i.e., due east).
    //
    public func pointAt(degrees: CGFloat) -> CGPoint {
        let radians = degrees * Trig.degreeToRadianFactor
        return pointAt(radians: radians)
    }
    
    
    // Point on the circumference at the specified location. The angle is
    // measured clockwise from 0 radians (i.e., due east).
    //
    public func pointAt(radians: CGFloat) -> CGPoint {
        return Trig.pointAt(distance: radius,
                            heading: radians,
                            fromPoint: center)
    }
    
    
    // Angle from center of circle to point. Point may be anywhere on or off
    // the circle.
    //
    public func radians(toPoint: CGPoint) -> CGFloat {
        return Trig.angle(fromPoint: center, toPoint: toPoint)
    }
    public func degrees(toPoint: CGPoint) -> CGFloat {
        return radians(toPoint: toPoint) * Trig.radianToDegreeFactor
    }
    
    public func radians(fromPoint: CGPoint) -> CGFloat {
        return Trig.angle(fromPoint: fromPoint, toPoint: center)
    }
    public func degrees(fromPoint: CGPoint) -> CGFloat {
        return radians(fromPoint: fromPoint) * Trig.radianToDegreeFactor
    }
    
    
    public func segment(fromDegrees: CGFloat, toDegrees: CGFloat) -> CircularSegment {
        let fromRadians = Trig.degreeToRadianFactor * fromDegrees
        let toRadians = Trig.degreeToRadianFactor * toDegrees
        return segment(fromRadians: fromRadians, toRadians: toRadians)
    }
    
    public func segment(fromRadians: CGFloat, toRadians: CGFloat) -> CircularSegment {
        return CircularSegment(circle: self, fromRadians: fromRadians, toRadians: toRadians)
    }
    
    
} // end struct Circle

