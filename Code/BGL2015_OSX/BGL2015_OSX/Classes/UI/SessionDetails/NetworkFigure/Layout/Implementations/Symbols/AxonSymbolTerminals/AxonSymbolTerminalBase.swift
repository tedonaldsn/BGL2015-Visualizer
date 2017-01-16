//
//  AxonSymbolTerminalBase.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/16/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//



import Cocoa
import BASimulationFoundation


open class AxonSymbolTerminalBase {
    
    open class func axonTerminalType() -> Identifier {
        return Identifier(idString: "AxonSymbolTerminalBase_Derived_class_responsibility")
    }
    
    
    // Non-content display settings
    //
    open class BaseTerminalAppearance {
        open var terminalType: Identifier
        open var fillColor: StrengthColor
        open var lineStyle: StrengthLineStyle
        
        public init(terminalType: Identifier,
                    fillColor: StrengthColor,
                    lineStyle: StrengthLineStyle) {
            
            self.terminalType = terminalType
            self.fillColor = fillColor
            self.lineStyle = lineStyle
        }
    }
    
    open class func defaultAppearance() -> AxonSymbolTerminalBase.BaseTerminalAppearance {
        return AxonSymbolTerminalBase.BaseTerminalAppearance (
            terminalType: axonTerminalType(),
            fillColor: StrengthColor(colorAtWeakest: NSColor.lightGray.cgColor,
                                     colorAtStrongest: NSColor.black.cgColor),
            lineStyle: StrengthLineStyle(colorAtWeakest: NSColor.lightGray.cgColor,
                                         colorAtStrongest: NSColor.black.cgColor,
                                         widthAtWeakest: 0.5,
                                         widthAtStrongest: 2.5,
                                         dashPattern: nil,
                                         dashPatternPhase: 0.0)
        )
    }
    
    
    
    open unowned let axonSymbol: AxonSymbol
    
    open var terminalType: Identifier {
        return type(of: self).axonTerminalType()
    }
    
    
    
    // MARK: Geometry
    
    // Point at which an axon visually attaches to the terminal. This is
    // also the point around which the terminal will rotate().
    //
    
    // Logical direction in which the terminal is "pointing", in radians.
    // On creation the heading is 0.0, which is due east in radian-world.
    //
    open var heading: CGFloat {
        return priv_heading
    }
    
    
    
    // MARK: Visual Settings
    
    // When drawing, fill then stroke. The line width will vary with
    // activation level, and may cover part of the fill (versus the
    // fill overwriting part of the line).
    //
    open var fillColor: StrengthColor {
        get { return priv_fillColor }
        set { priv_fillColor = newValue.clone() }
    }
    open var lineStyle: StrengthLineStyle {
        get { return priv_lineStyle }
        set { priv_lineStyle = newValue.clone() }
    }
    
    
    // MARK: Initialization
    
    
    public required init(parentAxonSymbol: AxonSymbol,
                         appearance: AxonSymbolTerminalBase.BaseTerminalAppearance? = nil) {
        
        self.axonSymbol = parentAxonSymbol
        
        let myAppearance = appearance != nil
            ? appearance!
            : AxonSymbolTerminalBase.defaultAppearance()
        
        self.fillColor = myAppearance.fillColor.clone()
        self.lineStyle = myAppearance.lineStyle.clone()
    }
    
    
    
    // MARK: Search
    
    open func contains(point: CGPoint) -> Bool {
        return false
    }
    
    
    
    // MARK: Transforms
    
    open func scale(_ scalingFactor: CGFloat) -> Void {
        guard scalingFactor != 1.0 else { return }
        
        priv_lineStyle.scale(scalingFactor)
        
    } // end scale
    
    
    
    open func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) -> Void {
        guard deltaX != 0.0 || deltaY != 0.0 else { return }
    }
    
    
    
    
    // MARK: Turning
    
    open func rotate(byRadians: CGFloat) -> Void {
        guard byRadians != 0.0 else { return }
        
        priv_heading = priv_heading + byRadians
    }
    
    open func rotate(toHeading: CGFloat) -> Void {
        rotate(byRadians: toHeading - priv_heading)
    }
    
    
    
    
    
    

    
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_heading: CGFloat = 0.0
    
    fileprivate var priv_lineStyle = StrengthLineStyle()
    fileprivate var priv_fillColor = StrengthColor()
    
} // end class AxonSymbolTerminalBase

