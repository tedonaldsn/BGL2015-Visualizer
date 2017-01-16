//
//  BaseLayout.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 11/13/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork


open class BaseLayout {
    
    // Non-content display settings
    //
    open class BaseAppearance {
        open var padding: CGFloat
        
        public init(padding: CGFloat) {
            self.padding = padding
        }
        
        public convenience init(appearance: BaseAppearance) {
            self.init(padding: appearance.padding)
        }
    }
    
    open class func defaultAppearance() -> BaseAppearance {
        return BaseAppearance(padding: 0.0)
    }
    

    // Amount of space to leave for insets, between-item spacing, etc.
    //
    open var padding: CGFloat = 0.0

    
    // MARK: Placement
    
    open var frame: CGRect {
        return priv_frame
    }
    
    
    // Very short explanation similar to "tooltips". Generally used along
    // with deepestSymbolLayoutContaining() to present info to user when mousing
    // around the neural net diagram.
    //
    // Should contain dynamic state info when appropriate (e.g., current
    // activation or connection weight).
    //
    // Uses attributed string to preserve any formatting in any labels returned.
    //
    open var statusSummary: NSAttributedString? {
        return nil
    }
    
    
    // MARK: Initialization
    
    public init(appearance: BaseAppearance? = nil) {
        if let appearance = appearance {
            self.padding = appearance.padding
        }
        priv_frame = CGRect()
    }
    
    
    
    open func extendFrameToInclude(rect: CGRect) -> Void {
        priv_frame = priv_frame.union(rect)
    }
    
    // In a few specific cases involving path creation, extending the frame does
    // not work. Must set it to a specific area.
    //
    open func setFrameTo(rect: CGRect) -> Void {
        priv_frame = rect
    }
    
    

    
    
    // MARK: Scaling
    
    // Scales all known components. Derived classes must override and call
    // super, then scale their own components. Scale must be invoked before
    // draw() by the view when it detects resizing.
    //
    open func scale(_ scalingFactor: CGFloat) -> Void {
        
        if scalingFactor != 1.0 {
            
            priv_frame = CGRect(x: priv_frame.origin.x * scalingFactor,
                                y: priv_frame.origin.y * scalingFactor,
                                width: priv_frame.size.width * scalingFactor,
                                height: priv_frame.size.height * scalingFactor)
        }
        
    } // end scale
    
    
    
    // MARK: Repositioning
    
    // Change the origin of the layout, and thereby its displayed graphics,
    // by the specified X and Y amounts.
    //
    // All subcomponents of the layout item are translated along with the parent
    // item.
    //
    // Does NOT change the size of the item.
    //
    open func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) -> Void {
        guard deltaX != 0.0 || deltaY != 0.0 else { return }
        
        let newOrigin = CGPoint(x: priv_frame.origin.x + deltaX,
                                y: priv_frame.origin.y + deltaY)
        
        priv_frame = CGRect(origin: newOrigin,
                            size: priv_frame.size)
    }
    
    
    func translate(byDelta: CGPoint) -> Void {
        translate(xBy: byDelta.x, yBy: byDelta.y)
    }
    
    func translateOrigin(to translation: CGPoint) {
        let currentOrigin = frame.origin
        let deltaX: CGFloat = translation.x - currentOrigin.x
        let deltaY: CGFloat = translation.y - currentOrigin.y
        translate(xBy: deltaX, yBy: deltaY)
    }
    
    
    
    
    // MARK: Drawing
    
    // Base level draw does nothing, but calling it is harmless.
    //
    open func draw() -> Void {
    }
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_frame: CGRect
    
} // end class BaseLayout

