//
//  StrengthLineStyle.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 8/10/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//


import Cocoa
import BASimulationFoundation


//  StrengthLineStyle
//
//  Appearance of lines used in drawing neural net components. 
//
//  Appearance changes based on "strength" of the component being drawn, for
//  components with a notion of being stronger or weaker across time steps.
//
//  Strength is a value scaled from 0-1. Most measures of strength in the 
//  neural network are already scaled to this range: the neuron group's
//  activation level, and the synapse's efficacy (a.k.a., weight). Other
//  components will have to be scaled, such as the dopaminergic and hippocampal
//  signals with can both exceed 1.0 and can go negative.
//
//  NOTE: Additional characteristics will be added later, such as fills, line
//          caps, join style.
//
open class StrengthLineStyle {
    
    open static let defaultColorAtWeakest: CGColor = NSColor.gray.cgColor
    open static let defaultCcolorAtStrongest: CGColor = NSColor.black.cgColor
    
    open static let defaultWidthAtWeakest: CGFloat = 0.5
    open static let defaultWidthAtStrongest: CGFloat = 2.5
    
    // MARK: Data
    
    open var strengthColor: StrengthColor!
    
    open var strengthLineWidth: StrengthScaledValue!
    
    open var joinStyle: NSLineJoinStyle
    
    // See NSBezierPath.setLineDash()
    //
    open var dashPattern: [CGFloat]?
    
    open var dashPatternLength: CGFloat {
        if let dashPattern = dashPattern {
            return dashPattern.reduce(0.0) {
                (total: CGFloat, phaseLength: CGFloat) -> CGFloat in return total + phaseLength
            }
        }
        return 0.0
    }
    open var dashPatternPhase: CGFloat = 0.0 {
        willSet {
            precondition(newValue >= 0.0)
            precondition(newValue <= dashPatternLength)
        }
    }
    
    // MARK: Initialization
    
    public init(colorAtWeakest: CGColor = StrengthLineStyle.defaultColorAtWeakest,
                colorAtStrongest: CGColor = StrengthLineStyle.defaultCcolorAtStrongest,
                widthAtWeakest: CGFloat = StrengthLineStyle.defaultWidthAtWeakest,
                widthAtStrongest: CGFloat = StrengthLineStyle.defaultWidthAtStrongest,
                dashPattern: [CGFloat]? = nil,
                dashPatternPhase: CGFloat = 0.0,
                joinStyle: NSLineJoinStyle = NSLineJoinStyle.miterLineJoinStyle) {
        
        self.strengthColor = StrengthColor(colorAtWeakest: colorAtWeakest,
                                           colorAtStrongest: colorAtStrongest)
        
        self.strengthLineWidth = StrengthScaledValue(valueAtWeakest: widthAtWeakest,
                                                     valueAtStrongest: widthAtStrongest)
        self.dashPattern = dashPattern
        self.dashPatternPhase = dashPatternPhase
        
        self.joinStyle = joinStyle
    }
    
    public convenience init(copyColorFrom: StrengthColor,
                            copyLineWidthFrom: StrengthScaledValue,
                            dashPattern: [CGFloat]?,
                            dashPatternPhase: CGFloat,
                            joinStyle: NSLineJoinStyle) {
        
        self.init(colorAtWeakest: copyColorFrom.colorAtWeakest,
                  colorAtStrongest: copyColorFrom.colorAtStrongest,
                  widthAtWeakest: copyLineWidthFrom.valueAtWeakest,
                  widthAtStrongest: copyLineWidthFrom.valueAtStrongest,
                  dashPattern: dashPattern,
                  dashPatternPhase: dashPatternPhase,
                  joinStyle: joinStyle)
    }
    
    public convenience init(copyFrom: StrengthLineStyle) {
        self.init(copyColorFrom: copyFrom.strengthColor,
                  copyLineWidthFrom: copyFrom.strengthLineWidth,
                  dashPattern: copyFrom.dashPattern,
                  dashPatternPhase: copyFrom.dashPatternPhase,
                  joinStyle: copyFrom.joinStyle)
    }
    
    
    open func clone() -> StrengthLineStyle {
        return StrengthLineStyle(copyFrom: self)
    }
    
    
    
    open func scale(_ scalingFactor: CGFloat) -> Void {
        strengthLineWidth.scale(scalingFactor)
        
        if let oldDashPattern = dashPattern {
            let scaled = oldDashPattern.map() {
                (dashLength: CGFloat) -> CGFloat in dashLength * scalingFactor
            }
            dashPattern = scaled
        }
    }
    
    
    open func color(_ atStrength: CGFloat) -> CGColor {
        return strengthColor.color(atStrength)
    }
    open func lineWidth(_ atStrength: CGFloat) -> CGFloat {
        return strengthLineWidth.value(atStrength)
    }
    
    

    
}// end class StrengthLineStyle

