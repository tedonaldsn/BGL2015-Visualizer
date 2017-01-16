//
//  RegularShapeSymbolProtocol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/12/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation



public protocol RegularShapeSymbolProtocol: BaseSymbolProtocol {
    
    var shape: RegularShapeProtocol { get }
    var size: CGSize { get }
    var radius: CGFloat { get }
    var center: CGPoint { get }
    var diameter: CGFloat { get }
    
    // MARK: Trigonometry
    //
    // Shape-related functions for placement of the shape and other graphics
    // that related to it.
    
    // Radian angle from center in the direction of a point.
    //
    func headingToPoint(_ towardPoint: CGPoint) -> CGFloat
    
    // Point at the specified distance from the center of the shape on the
    // specified outbound heading from due east.
    //
    func pointAt(_ outboundHeading: CGFloat, distanceFromCenter: CGFloat) -> CGPoint
    
    // Point offset from the shape's path in the direction of a particular point.
    //
    func pointAtOffsetFromPath(_ towardPoint: CGPoint, offset: CGFloat) -> CGPoint
    
    // Point offset from the shape's path in on the specified heading.
    //
    func pointAtOffsetFromPath(_ headingRadians: CGFloat, offset: CGFloat) -> CGPoint

} // end protocol RegularShapeSymbolProtocol





public extension RegularShapeSymbolProtocol {
    
} // end extension RegularShapeSymbolProtocol

