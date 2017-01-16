//
//  RegularShapeProtocol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 10/12/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation




// RegularShapeProtocol
//
// Basic interface for shapes akin to regular polygons. The supported shapes
// fill a square, and the radius of the shape will be the height (or width)
// of the square.
//
// All angles are in radians, with zero (0) radians pointing "east" and counting
// clockwise within the range 0 - 2π radians. 
//
// Conversion between full-circle style and atan2 style radians:
//
//      Trig.convertAtan2AngleToFullCircle()
//      Trig.convertFullCircleAngleToAtan2()
//
public protocol RegularShapeProtocol: AnyObject {
    
    // MARK: Data
    
    var shapeType: Identifier { get }
    
    // Logical bounds of the shape, that is, the bounds that dictated the
    // size of the shape rather than the bounds returned by the underlying
    // NSBezierPath which may be quite different (e.g., may include control
    // points).
    //
    // Note that the bounds will always be a square.
    //
    var bounds: CGRect { get }
    
    // Change in scale across all scalings. A shape's size is never modified
    // by scale() since scale() creates a new version of the shape. So the
    // cumulativeScalingFactor reflects scaling through generations of a shape.
    //
    var cumulativeScalingFactor: CGFloat { get }
    
    
    // Width of the line drawn by the stroke() method.
    //
    var lineWidth: CGFloat { get set }
    
    
    // MARK: From Center
    
    // Center of symbol to the center of the path that marks the boundary of the
    // shape at that point.
    //
    func distanceToPath(_ headingRadians: CGFloat) -> CGFloat
    
    
    
    // MARK: Copy
    
    func clone() -> RegularShapeProtocol
    
    
    // MARK: Resize
    
    func scale(_ scalingFactor: CGFloat) -> Void
    
    
    // MARK: Reposition
    
    func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) -> Void
    
    
    // MARK: Draw
    
    func fill() -> Void
    func stroke() -> Void
    
    
} // end protocol RegularShapeProtocol





public extension RegularShapeProtocol {
    
    public var size: CGSize {
        return bounds.size
    }
    public var radius: CGFloat {
        return bounds.size.width / 2.0
    }
    public var center: CGPoint {
        return CGPoint(x: bounds.midX,
                       y: bounds.midY)
    }
    public var diameter: CGFloat {
        return radius * 2.0
    }
    
    
    
    public func contains(point: CGPoint) -> Bool{
        let distanceToPoint = Trig.distance(fromPoint: center, toPoint: point)
        return distanceToPoint <= radius
    }
    
    // Radian angle from center in the direction of a point.
    //
    public func headingToPoint(_ towardPoint: CGPoint) -> CGFloat {
        return Trig.angle(fromPoint: center, toPoint: towardPoint)
    }
    
    // Point at the specified distance from the center of the shape on the
    // specified outbound heading from due east.
    //
    public func pointAt(_ outboundHeading: CGFloat, distanceFromCenter: CGFloat) -> CGPoint {
        return Trig.pointAt(distance: distanceFromCenter,
                            heading: outboundHeading,
                            fromPoint: center)
    }
    
    // Point offset from the shape's path in the direction of a particular point.
    //
    public func pointAtOffsetFromPath(_ towardPoint: CGPoint, offset: CGFloat) -> CGPoint {
        let heading = headingToPoint(towardPoint)
        return pointAtOffsetFromPath(heading, offset: offset)
    }
    
    // Point offset from the shape's path in on the specified heading.
    //
    public func pointAtOffsetFromPath(_ headingRadians: CGFloat, offset: CGFloat) -> CGPoint {
        let distance = distanceToPath(headingRadians)
        let distanceToOffset = distance + offset
        return Trig.pointAt(distance: distanceToOffset,
                            heading: headingRadians,
                            fromPoint: center)
    }
    
} // end extension RegularShapeProtocol




