//
//  RegularPolygonShape.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 10/12/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation

final public class RegularPolygonShape: RegularShapeProtocol {
    
    
    // MARK: Data
    
    public var shapeType: Identifier
    
    public var numberOfSides: Int
    
    public var bounds: CGRect {
        return priv_bounds
    }
    
    public var size: CGSize {
        return priv_bounds.size
    }
    public var radius: CGFloat {
        return priv_bounds.size.width / 2.0
    }
    public var center: CGPoint {
        let centerPoint = CGPoint(x: priv_bounds.midX,
                                  y: priv_bounds.midY)
        return centerPoint
    }
    public var diameter: CGFloat {
        return priv_bounds.size.width
    }
    
    public var cumulativeScalingFactor: CGFloat {
        return priv_cumulativeScalingFactor
    }
    
    public let firstVertexRadians: CGFloat
    
    public var radialAngle: CGFloat {
        return Trig.circle / CGFloat(numberOfSides)
    }
    
    public var lineWidth: CGFloat {
        get { return priv_path.lineWidth }
        set { priv_path.lineWidth = newValue }
    }
    
    
    // MARK: Initialization
    
    //  Note that angles/headings are in radians. The zero point for radians
    //  is "east". "South" is π/2, "west" is π, "north" is 3π/2.
    //
    //  https://en.wikipedia.org/wiki/Radian
    //
    public init(shapeType: Identifier,
                numberOfSides: Int,
                centeredInRect: CGRect,
                firstVertexRadians: CGFloat = 0.0) {
        
        assert(numberOfSides > 2, "Must have more than two sides to form polygon.")
        assert(Trig.circle / CGFloat(numberOfSides) > 0.0, "Too many sides in polygon.")
        
        self.shapeType = shapeType
        self.numberOfSides = numberOfSides
        self.firstVertexRadians = firstVertexRadians
        
        priv_createPolygon(centeredInRect)
    }
    
    public convenience init(shapeType: Identifier,
                            numberOfSides: Int,
                            radius: CGFloat,
                            firstVertexRadians: CGFloat = 0.0) {
        let diameter = radius * 2.0
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        self.init(shapeType: shapeType,
                  numberOfSides: numberOfSides,
                  centeredInRect: rect,
                  firstVertexRadians: firstVertexRadians)
    }
    
    
    
    public func clone() -> RegularShapeProtocol {
        let copy = RegularPolygonShape(shapeType: shapeType,
                                       numberOfSides: numberOfSides,
                                       centeredInRect: priv_bounds,
                                       firstVertexRadians: firstVertexRadians)
        copy.priv_cumulativeScalingFactor = priv_cumulativeScalingFactor
        return copy
    }
    
    
    
    // MARK: Bearing Relative Attributes
    
    // Distance from center point to the center of the shape's line on
    // the specified heading.
    //
    public func distanceToPath(_ headingRadians: CGFloat) -> CGFloat {
        
        // Angle at center of polygon between raidals that connect to vertices.
        //
        let radialsToPath: Int = Int(headingRadians / radialAngle)
        let closestRadial = firstVertexRadians + (CGFloat(radialsToPath) * radialAngle)
        
        // Distance of the requested heading from a radial.
        //
        let deflection: CGFloat = abs(headingRadians - closestRadial)
        
        // If the requested heading is on a radial, then we know the distance
        // from the center to the poly's line.
        //
        if deflection == 0.0 {
            return radius
            
        } else {
            // Else, the requested heading does NOT pass through a vertex, so
            // we must calculate where it does cross the poly's line, and
            // the distance from the center to there.
            //
            // NOTE: If heading is NOT on a radial, then the distance to the
            // path must be less than the radius. The radius is the maximum
            // distance from the center to the path, and that will always be
            // on a vertex. All points between vertices are closer to the center
            // than the radius.
            //
            // Side a: full path segment length
            // Angle A: deflection
            //
            // Side b: distance
            // Angle B: (pi - radialAngle) / 2
            //
            // Side c: radius
            // Angle C: pi - (angle A + angle B)
            //
            let angleA = deflection
            let angleB = (Trig.pi - radialAngle) / 2.0
            let angleC = Trig.pi - (angleA + angleB)
            let sideC = radius
            //
            let distance = Trig.side2TriangleAAS(angle1: angleC, angle2: angleB, side1: sideC)
            assert(distance < radius)
            
            return distance
        }
        
    } // end distanceToPath
    
    
    
    
    // MARK: Resize
    
    // Return copy of the shape scaled by factor.
    //
    public func scale(_ scalingFactor: CGFloat) -> Void {
        guard scalingFactor != 1.0 else { return }
        
        var transform = AffineTransform.identity
        transform.scale(scalingFactor)
        priv_path.transform(using: transform)
        
        priv_bounds = CGRect(x: priv_bounds.origin.x * scalingFactor,
                             y: priv_bounds.origin.y * scalingFactor,
                             width: priv_bounds.size.width * scalingFactor,
                             height: priv_bounds.size.height * scalingFactor)
        
        priv_cumulativeScalingFactor = priv_cumulativeScalingFactor * scalingFactor
    }
    
    
    // MARK: Reposition
    
    
    public func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) {
        guard deltaX != 0.0 || deltaY != 0.0 else { return }
        
        let transform = AffineTransform(translationByX: deltaX, byY: deltaY)
        priv_path.transform(using: transform)
        let newOrigin = CGPoint(x: priv_bounds.origin.x + deltaX,
                                y: priv_bounds.origin.y + deltaY)
        priv_bounds = CGRect(origin: newOrigin, size: priv_bounds.size)
    }
    
    
    // MARK: Draw
    
    public func fill() -> Void {
        priv_path.fill()
    }
    
    public func stroke() -> Void {
        priv_path.stroke()
    }
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_bounds: CGRect = CGRect.zero
    fileprivate var priv_path = NSBezierPath()
    fileprivate var priv_cumulativeScalingFactor: CGFloat = 1.0
    
    
    
    
    // MARK: *Private* Methods
    
    fileprivate func priv_createPolygon(_ rect: CGRect) -> Void {
        
        assert(numberOfSides >= 0, "Polygon must have at least three sides.")
        
        priv_bounds = CGRectCenteredSquare(rect)
        let centerPoint = CGPoint(x: priv_bounds.midX,
                                  y: priv_bounds.midY)
        assert(centerPoint != CGPoint.zero)
        
        // We are drawing in a square, so the radius of the logical circle in
        // which we are drawing is half of either dimension.
        //
        let radius: CGFloat = priv_bounds.size.width / 2.0
        
        assert(radius > 0.0, "Radius of largest circle that will fit in rectangle is zero.")
        
        var headingRadians: CGFloat = firstVertexRadians
        
        // Move to first point without drawing.
        //
        var currentCorner = Trig.pointAt(distance: radius,
                                         heading: headingRadians,
                                         fromPoint: centerPoint)
        priv_path.move(to: currentCorner)
        
        for _ in 1...numberOfSides {
            
            headingRadians = headingRadians + radialAngle
            if headingRadians > Trig.circle {
                headingRadians = headingRadians - Trig.circle
            }
            currentCorner = Trig.pointAt(distance: radius,
                                         heading: headingRadians,
                                         fromPoint: centerPoint)
            
            priv_path.line(to: currentCorner)
        }
        
        priv_path.close()
        
    } // end priv_createPolygon
    
    
    
    
    
} // end class RegularPolygonShape

