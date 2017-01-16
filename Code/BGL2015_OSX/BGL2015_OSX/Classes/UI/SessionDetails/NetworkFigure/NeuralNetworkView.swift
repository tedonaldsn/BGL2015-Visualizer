//
//  NeuralNetworkView.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 9/28/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



final class NeuralNetworkView: NSView {
    
    // MARK: Data
    
    // The natural display order for neural net elements is left to right, 
    // top to bottom. This is the same order as for the journal articles
    // in which the neural network figures are published.
    //
    // However, the coordinate system for NSView has the origin in the lower
    // left corner: Cartesian Quadrant I. The solution: override isFlipped
    // and return true. This gives the top-down-left-to-right coordinate
    // system that matches the content.
    //
    override var isFlipped: Bool { return true }
    
    
    
    
    // Root layout object.
    //
    var neuralNetworkLayout: NeuralNetworkLayout!
    


    // MARK: Initialization
    
    
    // This one is called when loaded via xib.
    //
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        priv_setup()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        priv_setup()
    }
    
    
    fileprivate func priv_setup() {
        autoresizingMask = [
            NSAutoresizingMaskOptions.viewHeightSizable,
            NSAutoresizingMaskOptions.viewWidthSizable
        ]
        priv_previousSize = frame.size
    }
    
    

    
    // MARK: Draw
    
    public override func draw(_ dirtyRect: NSRect) {
        assert(neuralNetworkLayout != nil)
        super.draw(dirtyRect)
        
        priv_resize()
        priv_recenter()
        /*
        let scalingFactor: CGFloat = frame.size.width / priv_previousSize.width
        // assert(scalingFactor == frame.size.height / priv_previousSize.height)
        
        priv_previousSize = frame.size
        
        if scalingFactor != 1.0 {
            neuralNetworkLayout.scale(scalingFactor)
        }
        */
        neuralNetworkLayout.draw()

    
    } // end draw
    
    

    
    // MARK: Update
    
    public func updateForTimestep(_ network: Network) -> Void {
        
        if neuralNetworkLayout == nil {
            neuralNetworkLayout = NeuralNetworkLayout(node: network)
            priv_resize()
            priv_recenter()
            
        } else {
            neuralNetworkLayout.updateForTimestep(network)
            needsDisplay = true
        }
        
        // If mouse over information is showing, update it to reflect new
        // node states.
        //
        updateMouseOverInfoDisplay()

    } // end updateForTimestep
    
    
    
    
    // MARK: Mouse Tracking
    
    

    public override func mouseMoved(with event: NSEvent) {
        let mouseLocation = event.locationInWindow
        var cursorLocation = self.convert(mouseLocation, to: nil)
        
        // The neural net view is flipped to make handling of top-down
        // arrangement of graphics.
        //
        // But this seems to introduce some asymmetrical miscalculation
        // of screen-to-view coordinates. The Y axis is correctly converted,
        // but the X axis is off by exactly twice the X origin of the view.
        //
        assert(self.isFlipped)
        let flippingFrameXOffset: CGFloat = self.frame.origin.x * 2.0
        cursorLocation.x = cursorLocation.x - flippingFrameXOffset
        
        let mouseOverLayout =
            neuralNetworkLayout.deepestSymbolLayoutContaining(point: cursorLocation)
        
        if priv_mouseOverLayout !== mouseOverLayout {
            priv_mouseOverLayout = mouseOverLayout
            priv_lastMouseOverPoint = cursorLocation
            
            updateMouseOverInfoDisplay()
        }
        
        
    } // end mouseMoved
    
    

    

    
    open func updateMouseOverInfoDisplay() -> Void {
        
        if let mouseOverLayout = priv_mouseOverLayout,
            let info: NSAttributedString = mouseOverLayout.statusSummary {

            priv_mouseOverTextField.attributedStringValue = info
            priv_mouseOverTextField.sizeToFit()
            
            // Cheat: we know that the labels are taking up a lot of space
            // at the top of the figure, so always put the popup at the top
            // where they will not cover anything of import.
            //
            let fieldRect = priv_mouseOverTextField.frame
            let layoutRect = mouseOverLayout.frame
            
            var fieldX: CGFloat = layoutRect.midX - (fieldRect.size.width / 2.0)
            if fieldX < 0.0 {
                fieldX = 0.0
            }
            if fieldX + fieldRect.size.width > bounds.size.width {
                fieldX = bounds.size.width - fieldRect.size.width
            }
            let fieldY: CGFloat = 4.0
            
            priv_mouseOverTextField.frame.origin = CGPoint(x: fieldX,
                                                           y: fieldY)

            priv_mouseOverTextField.isHidden = false
            
        } else {
            priv_mouseOverTextField.isHidden = true
        }
        
    } // end updateMouseOverInfoDisplay
    

    
    
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_previousSize = CGSize()
    
    fileprivate var priv_mouseTracker: NSTrackingArea? = nil
    fileprivate var priv_mouseOverLayout: BaseLayout? = nil
    fileprivate var priv_lastMouseOverPoint = CGPoint()
    fileprivate lazy var priv_mouseOverTextField: NSTextField = {
        
        let field = NSTextField(frame: NSRect(x: 0.0,
                                              y: 0.0,
                                              width: 100.0,
                                              height: 50.0))
        field.alignment = NSTextAlignment.center
        field.isEditable = false
        
        self.addSubview(field)
        return field
    }()
    
    
    // MARK: *Private* Methods
    
    
    fileprivate func priv_resize() -> Void {
        
        let availableSize: CGSize = bounds.size
        let initialLayoutSize: CGSize = neuralNetworkLayout.frame.size
        
        // Shrink or grow the layout to fit the available view space, filling
        // the view to the maximum without any part of the layout falling outside
        // the view.
        //
        let widthRatio: CGFloat = availableSize.width / initialLayoutSize.width
        let heightRatio: CGFloat = availableSize.height / initialLayoutSize.height
        let minRatio: CGFloat = min(widthRatio, heightRatio)
        
        neuralNetworkLayout.scale(minRatio)
        
        priv_resizeMouseTracking(scalingFactor: minRatio)
        
    } // end priv_resize
    
    
    // Assumes that layout has been appropriately resized first via priv_resize().
    //
    fileprivate func priv_recenter() -> Void {
        
        let viewSize: CGSize = bounds.size
        let layoutRect = neuralNetworkLayout.frame
        let layoutSize = layoutRect.size
        
        let borderSize = CGSize(width: (viewSize.width - layoutSize.width) / 2.0,
                                height: (viewSize.height - layoutSize.height) / 2.0)
        
        let deltaX = borderSize.width - layoutRect.origin.x
        let deltaY = borderSize.height - layoutRect.origin.y
        
        neuralNetworkLayout.translate(xBy: deltaX, yBy: deltaY)
        
        
    } // end priv_recenter
    
    
    
    
    fileprivate func priv_resizeMouseTracking(scalingFactor: CGFloat) -> Void {
        
        if let existingArea = priv_mouseTracker {
            removeTrackingArea(existingArea)
        }
        
        priv_mouseTracker = NSTrackingArea(
            rect: bounds,
            options: [NSTrackingAreaOptions.activeInKeyWindow, NSTrackingAreaOptions.mouseMoved],
            owner: self,
            userInfo: nil
        )
        
        self.addTrackingArea(priv_mouseTracker!)
        
        let oldFrame = priv_mouseOverTextField.frame
        let scaledFrame = CGRect(x: oldFrame.origin.x * scalingFactor,
                                 y: oldFrame.origin.y * scalingFactor,
                                 width: oldFrame.size.width * scalingFactor,
                                 height: oldFrame.size.height * scalingFactor)
        
        priv_mouseOverTextField.frame = scaledFrame
        
    } // end priv_resizeMouseTracking
    
    
    
} // end class NeuralNetworkView
