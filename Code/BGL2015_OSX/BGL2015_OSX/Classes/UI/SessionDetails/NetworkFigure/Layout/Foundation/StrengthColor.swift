//
//  StrengthColor.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 8/10/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation



// NOTE: Uses NSGradient to produce a color for a particular strength level.
// Therefore, cannot use NSColor.colorWithPatternImage() as one of the colors.
//
open class StrengthColor {
    
    open static let defaultColorAtWeakest: CGColor = NSColor.gray.cgColor
    open static let defaultCcolorAtStrongest: CGColor = NSColor.black.cgColor
    
    // MARK: Data
    
    // If colors are changed, delete any pre-existing gradient to ensure
    // that the correct colors are used next time the gradient is used.
    //
    var colorAtWeakest: CGColor {
        didSet { priv_strengthGradient = nil }
    }
    var colorAtStrongest: CGColor {
        didSet { priv_strengthGradient = nil }
    }
    
    // Gradient that returns the color based on strength value is created on
    // demand.
    //
    var gradient: NSGradient {
        if priv_strengthGradient == nil {
            let starting: NSColor = NSColor(cgColor: colorAtWeakest)!
            let ending: NSColor = NSColor(cgColor: colorAtStrongest)!
            priv_strengthGradient = NSGradient(starting: starting,
                                               ending: ending)
        }
        return priv_strengthGradient!
    }
    
    // MARK: Initialization
    
    public init(colorAtWeakest: CGColor = StrengthColor.defaultColorAtWeakest,
                colorAtStrongest: CGColor = StrengthColor.defaultCcolorAtStrongest) {
        self.colorAtWeakest = colorAtWeakest
        self.colorAtStrongest = colorAtStrongest
    }
    
    public init(copyFrom: StrengthColor) {
        self.colorAtWeakest = copyFrom.colorAtWeakest
        self.colorAtStrongest = copyFrom.colorAtStrongest
    }
    
    open func clone() -> StrengthColor {
        return StrengthColor(copyFrom: self)
    }
    
    
    // Strength is truncated to the 0-1 range.
    //
    open func color(_ atStrength: CGFloat) -> CGColor {
        let strength = (atStrength < 0.0
            ? 0.0
            : (atStrength > 1.0
                ? 1.0
                : atStrength))
        
        return gradient.interpolatedColor(atLocation: strength).cgColor
    }
    
    // MARK: *Private*
    
    fileprivate var priv_strengthGradient: NSGradient? = nil
    
} // end class StrengthColor

