//
//  CircleShape.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 10/13/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation



final public class CircleShape: RegularShapeProtocol {
    
    // MARK: RegularShapeProtocol
    
    public var shapeType: Identifier
    
    public var bounds: CGRect {
        return priv_bounds
    }
    
    public var cumulativeScalingFactor: CGFloat {
        return priv_cumulativeScalingFactor
    }
    
    public var lineWidth: CGFloat {
        get { return priv_path.lineWidth }
        set { priv_path.lineWidth = newValue }
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
    
    
    
    // MARK: Initialization
    
    public init(shapeType: Identifier, centeredInRect: CGRect) {
        self.shapeType = shapeType
        priv_bounds = CGRectCenteredSquare(centeredInRect)
        priv_path.appendOval(in: priv_bounds)
        priv_path.close()
    }
    
    
    
    
    // MARK: Bearing Relative Attributes
    
    // Distance from center point to the center of the shape's line on
    // the specified heading.
    //
    public func distanceToPath(_ headingRadians: CGFloat) -> CGFloat {
        
        return radius
        
    } // end distanceToPath
    
    
    
    // MARK: Copy
    
    public func clone() -> RegularShapeProtocol {
        let copy = CircleShape(shapeType: shapeType, centeredInRect: priv_bounds)
        copy.priv_cumulativeScalingFactor = priv_cumulativeScalingFactor
        return copy
    }
    
    
    // MARK: Resize
    
    // Return copy of the shape scaled by factor.
    //
    public func scale(_ scalingFactor: CGFloat) -> Void {
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
        var transform = AffineTransform.identity
        transform.translate(x: deltaX, y: deltaY)
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
    
    
    
    
} // end class CircleShape


