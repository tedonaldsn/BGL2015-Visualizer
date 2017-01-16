//
//  FeedbackConsumerPath.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/28/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//



import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork




open class FeedbackConsumerPath: FeedbackPathBase {
    
    // MARK: Data
    
    open var hasPoints: Bool {
        return priv_topPoint.x != 0.0 && priv_topPoint.y != 0.0
    }
    

    open var topPoint: CGPoint {
        return priv_topPoint
    }
    open var bottomPoint: CGPoint {
        return priv_bottomPoint
    }
    
    
    open override var statusSummary: NSAttributedString? {
        let info = NSMutableAttributedString(attributedString: label!.text)
        
        let strength = BaseSymbol.format(scaledValue: presentationStrength)
        info.append(NSAttributedString(string: "\nSignal strength: \(strength)"))
        
        return info
    }
    
    // MARK: Initialization
    

    public convenience init(associationLayer: AssociationLayerLayout,
                            appearance: FeedbackConsumerPath.FeedbackPathAppearance? = nil) {
        
        // Calls *Private* Init
        self.init(rootLayout: associationLayer.rootLayout,
                  isSensory: associationLayer.isSensory,
                  layer: associationLayer,
                  appearance: appearance)
    }
    
    
    public convenience init(feedbackLayer: FeedbackLayer,
                            appearance: FeedbackConsumerPath.FeedbackPathAppearance? = nil) {
        
        // Calls *Private* Init
        self.init(rootLayout: feedbackLayer.rootLayout,
                  isSensory: feedbackLayer.isSensory,
                  layer: feedbackLayer,
                  appearance: appearance)
    }
    
    
    public convenience init(motorOutputLayer: MotorOutputAreaLayout,
                            appearance: FeedbackConsumerPath.FeedbackPathAppearance? = nil) {
        
        // Calls *Private* Init
        self.init(rootLayout: motorOutputLayer.rootLayout,
                  isSensory: false,
                  layer: motorOutputLayer,
                  appearance: appearance)
    }
    
    
    
    // Assumes all paths horizontally are appended before any vertical
    // appends are done. The difference is in top/bottom points afterward.
    //
    // If the connecting path to the right is angled upward, we know that it
    // will pass under/through a neuron. So extend it due east first before
    // starting the upward connection.
    //
    open func appendHorizontally(pathOnRight: FeedbackConsumerPath) -> Void {
        assert(priv_bottomPoint.x < pathOnRight.bottomPoint.x)
        
        path.append(pathOnRight.path)
        
        path.move(to: bottomPoint)
        
        // Coordinate system is flipped, so angle of less than pi is up.
        //
        let departureAngle = Trig.angle(fromPoint: bottomPoint,
                                        toPoint: pathOnRight.bottomPoint)
        if departureAngle < Trig.pi {
            let byPassPoint = CGPoint(x: bottomPoint.x + BaseSymbol.initialSize.width,
                                      y: bottomPoint.y)
            path.line(to: byPassPoint)
        }
        path.line(to: pathOnRight.bottomPoint)
        
        priv_topPoint = pathOnRight.topPoint
        priv_bottomPoint = pathOnRight.bottomPoint
        
        extendFrameToInclude(rect: pathOnRight.frame)
    }
    
    
    // Assumes all paths horizontally are appended before any vertical
    // appends are done. The difference is in top/bottom points afterward.
    //
    open func appendVertically(pathBelow: FeedbackConsumerPath) -> Void {
        assert(priv_topPoint.y > pathBelow.topPoint.y)
        
        path.append(pathBelow.path)
        
        path.move(to: bottomPoint)
        path.line(to: pathBelow.topPoint)

        priv_bottomPoint = pathBelow.bottomPoint
        
        extendFrameToInclude(rect: pathBelow.frame)
    }
    
    

    

    
    // MARK: *Private* Data
    
    fileprivate var priv_bottomPoint = CGPoint()
    fileprivate var priv_topPoint = CGPoint()
    
    
    
    
    // MARK: *Private* Methods
    
    // This private initializer does all of the actual work of setting up a
    // path for a layer.
    //
    private init(rootLayout: NeuralNetworkLayout,
                 isSensory: Bool,
                 layer: LayerLayout,
                 appearance: FeedbackPathBase.FeedbackPathAppearance? = nil) {
        
        var myAppearance: FeedbackPathBase.FeedbackPathAppearance? = appearance
        if myAppearance == nil {
            myAppearance = isSensory
                ? FeedbackPathBase.defaultHippocampalSignalAppearance()
                : FeedbackPathBase.defaultDopaminergicSignalAppearance()
        }
        
        super.init(rootLayout: rootLayout,
                   isSensory: isSensory,
                   appearance: myAppearance)
        
        let _ = label!.appendString("d")
        if isSensory {
            let _ = label!.appendSubscript("H,t")
        } else {
            let _ = label!.appendSubscript("D,t")
        }
        
        priv_connectToDendrites(layer: layer)

    } // end init
    
    

    
    
    
    
    // NOTE: The coordinate system is flipped because we process from the top
    // down. Thus, the top left point in the view is (0,0), and the lower
    // right is (width,height). This means that the top neuron is first in
    // the list, and the bottom one is last. It also changes the math in
    // calculating top and bottom, since the top has lower y values than the
    // bottom.
    //
    fileprivate func priv_connectToDendrites(layer: LayerLayout) -> Void {
        
        let pathOffsetFromDendrite: CGFloat = lineStyle.strengthLineWidth.minimum / 3.0
        
        var dendrites = [DendriteSymbol]()
        
        let bottomUpLayouts = layer.layouts
        
        for layout in bottomUpLayouts {
            if let neuron = layout as? NeuronSymbol {
                dendrites.append(contentsOf: neuron.dendriteSymbols)
            }
        }
        
        guard dendrites.count > 0 else { return }
        
        // Extend the path from a point even with the top of the topmost
        // neuron to the bottom of the bottommost neuron.
        //
        
        let topDendrite = dendrites.first!
        let topNeuron = topDendrite.parentSymbol
        let topPoint = CGPoint(x: topDendrite.center.x - pathOffsetFromDendrite,
                               y: topNeuron.frame.origin.y)
        
        let bottomDendrite = dendrites.last!
        let bottomNeuron = bottomDendrite.parentSymbol
        let bottomPoint = CGPoint(x: bottomDendrite.center.x - pathOffsetFromDendrite,
                                  y: bottomNeuron.frame.origin.y + bottomNeuron.frame.size.height)
        
        path.move(to: topPoint)
        for dendrite in dendrites {
            let dendritePoint = CGPoint(x: dendrite.center.x - pathOffsetFromDendrite,
                                        y: dendrite.center.y)
            path.line(to: dendritePoint)
        }
        path.line(to: bottomPoint)
        
        priv_topPoint = topPoint
        priv_bottomPoint = bottomPoint
        
        setFrameTo(rect: path.bounds)

        
    } // end priv_appendDendrites
    
    
    

    
} // end class FeedbackConsumerPath

