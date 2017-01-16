//
//  AxonSymbolTerminalProtocol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/15/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation



public protocol AxonSymbolTerminalProtocol: AnyObject {
    
    // Axon symbol to which the terminal belongs.
    //
    var axonSymbol: AxonSymbol { get }
    
    
    // MARK: Identifier
    
    // Axon terminals will be created by a factory object using only this
    // identifier to specify which type of terminal to create.
    //
    var terminalType: Identifier { get }
    
    
    // MARK: Visual Settings
    
    var fillColor: StrengthColor { get set }
    var lineStyle: StrengthLineStyle { get set }
    
    
    
    // MARK: Geometry
    
    // Point at which an axon visually attaches to the terminal. This is
    // also the point around which the terminal will rotate().
    //
    var connectionPoint: CGPoint { get }
    
    // Logical direction in which the terminal is "pointing", in radians.
    // On creation the heading is 0.0, which is due east in radian-world.
    //
    var heading: CGFloat { get }
    

    // Length of the terminal from the connection point, along the heading,
    // to the point closest to the target destination (a symbol associated
    // with a postsynaptic unit). The axon will have to be shortened by this
    // amount so that the terminal does not intrude on the target's symbol.
    //
    var length: CGFloat { get }
    
    
    // MARK: Initialization
    
    init(parentAxonSymbol: AxonSymbol,
         appearance: AxonSymbolTerminalBase.BaseTerminalAppearance?)
    
    // MARK: Search
    
    func contains(point: CGPoint) -> Bool
    
    
    // MARK: Transforms
    
    func scale(_ scalingFactor: CGFloat) -> Void
    func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) -> Void
    
    // Rotate the symbol around its connection point to the heading in radians.
    // Primarily used by the owning axon symbol to put the terminal on the 
    // same heading as the axon symbol itself.
    //
    // Note that NSAffineTransform rotates around the origin, which leaves the
    // shape in the correct heading, but wrong location. Implementations will
    // have to translate() to put it back into the proper position.
    //
    func rotate(toHeading: CGFloat) -> Void
    
    
    
    // MARK: Drawing
    
    // Draw should use the "strength adjusted" methods defined in the 
    // extension, below.
    //
    func draw() -> Void
    
} // end protocol AxonSymbolTerminalProtocol





public extension AxonSymbolTerminalProtocol {
    
    // MARK: Presentation Strength
    
    // Base level strength is always at max: 1.0. Override this variable
    // to return values appropriate to the type of neural node.
    //
    var presentationStrength: Scaled0to1Value {
        return axonSymbol.presentationStrength
    }
    
    var rawPresentationStrength: CGFloat {
        return CGFloat(presentationStrength.rawValue)
    }
    
    
    var strengthAdjustedFillColor: CGColor {
        return fillColor.color(rawPresentationStrength)
    }
    var strengthAdjustedLineWidth: CGFloat {
        return lineStyle.lineWidth(rawPresentationStrength)
    }
    var strengthAdjustedLineColor: CGColor {
        return lineStyle.color(rawPresentationStrength)
    }
    
} // end extension AxonSymbolTerminalProtocol

