//
//  LabelLayout.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 11/28/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation



public class LabelLayout: BaseLayout {
    
    // Non-content display settings
    //
    open class LabelAppearance: BaseLayout.BaseAppearance {
        open var atStrength: Scaled0to1Value
        
        public init(atStrength: Scaled0to1Value,
                    padding: CGFloat) {
            self.atStrength = atStrength
            super.init(padding: padding)
        }
        
        public convenience init(appearance: LabelAppearance) {
            self.init(atStrength: appearance.atStrength,
                      padding: appearance.padding)
        }
    }
    
    public override class func defaultAppearance() -> BaseLayout.BaseAppearance {
        return LabelAppearance(atStrength: Scaled0to1Value.maximum, padding: 0.0)
    }
    
    
    
    
    
    // Labels are displayed in a square area. Initial dimension is the length
    // of the sides at the time a symbol is created.
    //
    // Labels are initially the same size as a spacer.
    //
    public static let initialSize = SpacerLayout.initialSize
    
    
    
    open var text: StrengthText
    
    open var atStrength = Scaled0to1Value.maximum
    
    // CustomStringConvertible
    open var description: String {
        return text.description
    }
    
    // CustomDebugStringConvertible
    open var debugDescription: String {
        return "\(text.debugDescription)@\(atStrength.rawValue)"
    }
    
    
    public init(text: StrengthText,
                appearance: BaseLayout.BaseAppearance? = nil) {
        
        let myAppearance = appearance != nil
            ? appearance!
            : LabelLayout.defaultAppearance()
        
        self.text = text
        super.init(appearance: myAppearance)
        
        extendFrameToInclude(rect: CGRect(origin: frame.origin,
                                          size: LabelLayout.initialSize))
    }
    
    open override func scale(_ scalingFactor: CGFloat) {
        super.scale(scalingFactor)
        text.scale(scalingFactor)
    }
    
    open override func draw() -> Void {
        super.draw()
        text.draw(inRect: frame, atStrength: CGFloat(atStrength.rawValue))
    }
    
} // end class LabelLayout

