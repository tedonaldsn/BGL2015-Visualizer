//
//  NeuralNetworkLayout.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 11/13/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork


// NeuralNetworkLayout
//
// Display layout for the neural net passed into the constructor. All subsequent
// updateForTimestep() calls must be passed the same logical neural network,
// that is, same exact structure, but different state (e.g., activation levels,
// connection weights).
//
// FUTURE: This is a prototype that is hand built for the BGL2015 neural 
//      network. The layout is hand coded to produce a graph very similar
//      to Figure 2 in that article.
//
//      In the future a user will create networks via an editor that
//      both edits the neural net and the layout.
//
final public class NeuralNetworkLayout: BaseCollectionLayout {
    
    
    // MARK: BGL2015 Layout Constants
    
    // Maximum number of layers contributed by the actual neural net, and
    // maximum number of nodes in a logical layer.
    //
    public static let overallLayerDepth: CGFloat = 8.0
    public static let overallNodeWidth: CGFloat = 3.0
    
    // Spacers per logical layer to get the appearance of BGL2015 Figure 2.
    //
    public static let inputSpacerNodes: CGFloat = 2.0
    public static let hippocampalSpacerNodes: CGFloat = 0.5
    public static let vtaSpacerNodes: CGFloat = 2.5
    public static let overallSpacerNodeWidth: CGFloat =
        max(inputSpacerNodes, hippocampalSpacerNodes, vtaSpacerNodes)

    // Total maximum "nodes" in the widest logical layer.
    //
    public static let overallNodeWidthWithSpacers: CGFloat =
        overallNodeWidth + overallSpacerNodeWidth
    
    
    

    
    
    
    // MARK: Global Network State
    
    public var neuralNetwork: BASelectionistNeuralNetwork.Network {
        return node as! Network
    }
    
    public let updatableNodeLayouts = UpdatableNodeLayoutRegistry()
    
    
    public var dopaminergicSignal: Scaled0to1Value {
        let rawSignal = neuralNetwork.dopaminergicSignal
        if rawSignal > 1.0 { return Scaled0to1Value.maximum }
        if rawSignal < 0.0 { return Scaled0to1Value.minimum }
        return Scaled0to1Value(rawValue: rawSignal)
    }
    public var hippocampalSignal: Scaled0to1Value {
        let rawSignal = neuralNetwork.hippocampalSignal
        if rawSignal > 1.0 { return Scaled0to1Value.maximum }
        if rawSignal < 0.0 { return Scaled0to1Value.minimum }
        return Scaled0to1Value(rawValue: rawSignal)
    }
    
    

    // MARK: Regions
    
    public var sensors: SingleLayerRegionLayout!
    public var sensoryInputNeurons: SingleLayerRegionLayout!
    public var sensoryAssociationNeurons: AssociationRegionLayout!
    public var hippocampus: FeedbackLayer!
    
    public var motorAssociationNeurons: AssociationRegionLayout!
    public var vta: FeedbackLayer!
    public var motorOutputNeurons: MotorOutputRegionLayout!
    public var effectors: SingleLayerRegionLayout!
    
    
    
    
    // MARK: Initialization
    
    public init(node: Node) {
        assert(node is Network)
        
        super.init(node: node, collectionAxis: CollectionAxis.YMajor)
        
        priv_populateRegions()
        priv_customizeRegions()
        
        connectNeuralUnits()
        
        let sensoryConsumerFeedbackPath = sensoryAssociationNeurons.createFeedbackPath()
        let hippocampalConsumerFeedbackPath = FeedbackConsumerPath(feedbackLayer: hippocampus)
        
        if let sensoryConsumerFeedbackPath = sensoryConsumerFeedbackPath {
            sensoryConsumerFeedbackPath.appendHorizontally(pathOnRight: hippocampalConsumerFeedbackPath)
            priv_feedbackPathDisplayList.append(sensoryConsumerFeedbackPath)
            
        } else {
            priv_feedbackPathDisplayList.append(hippocampalConsumerFeedbackPath)
        }
        
        let hippocampalProducerPaths = hippocampus.createFeedbackProducerPaths()
        for path in hippocampalProducerPaths {
            priv_feedbackPathDisplayList.append(path)
        }
        
        let motorAssociationConsumerFeedbackPath = motorAssociationNeurons.createFeedbackPath()
        let vtaConsumerFeedbackPath = FeedbackConsumerPath(feedbackLayer: vta)
        let motorOutputConsumerFeedbackPath = motorOutputNeurons.createFeedbackPath()
        //
        // Combine these three motor area feedback consumer paths into one.
        // Note that during development they may not all exist.
        //
        var motorConsumerFeedback = motorAssociationConsumerFeedbackPath
        if motorConsumerFeedback != nil {
            motorConsumerFeedback?.appendHorizontally(pathOnRight: vtaConsumerFeedbackPath)
        } else {
            motorConsumerFeedback = vtaConsumerFeedbackPath
        }
        if let motorOutputConsumerFeedbackPath = motorOutputConsumerFeedbackPath {
            motorConsumerFeedback!.appendHorizontally(pathOnRight: motorOutputConsumerFeedbackPath)
        }
        priv_feedbackPathDisplayList.append(motorConsumerFeedback!)
        
        
        let vtaProducerPaths = vta.createFeedbackProducerPaths()
        for path in vtaProducerPaths {
            priv_feedbackPathDisplayList.append(path)
        }
        
        
    } // end init
    

    
    // Axons are displayed last, after the diffuse feedback signals and after
    // the neurons. Drawing last causes the axons to be drawn on top of all
    // other symbols.
    //
    open func appendToAxonSymbolDisplayList(axonSymbol: AxonSymbol) -> Void {
        priv_axonSymbolDisplayList.append(axonSymbol)
    }
    
    
    
   
    

    
    
    
    // MARK: Search
    
    open override func find(identifier: Identifier) -> BaseLayout? {
        //
        // Find region with the specified identifier
        //
        if let layout = super.find(identifier: identifier) {
            return layout
        }
        //
        // Search region layouts for item
        //
        for layout in layouts {
            if let collection = layout as? BaseCollectionLayout,
                let targetLayout = collection.find(identifier: identifier) {
                return targetLayout
            }
        }
        
        return nil
    }
    
    
    
    open override func deepestSymbolLayoutContaining(point: CGPoint) -> BaseSymbol? {
        //
        // Do no rely on super because its last ditch check is against its
        // own frame, which is guaranteed to return this overall neural net
        // which stretches over the entire neural network view.
        //
        for layout in layouts {
            if let container = layout as? BaseCollectionLayout {
                if let target = container.deepestSymbolLayoutContaining(point: point) {
                    return target
                }
            }
        }
        
        for feedbackPath in priv_feedbackPathDisplayList {
            if let target = feedbackPath.deepestSymbolLayoutContaining(point: point) {
                return target
            }
        }
        
        for axon in priv_axonSymbolDisplayList {
            if let target = axon.deepestSymbolLayoutContaining(point: point) {
                return target
            }
        }
        
        // If no subcomponents contain the point, just return nil. Do NOT 
        // return self.
        //
        return nil
    }
    
    
    
    // MARK: Scaling
    
    open override func scale(_ scalingFactor: CGFloat) {
        super.scale(scalingFactor)
        for feedbackPath in priv_feedbackPathDisplayList {
            feedbackPath.scale(scalingFactor)
        }
    }
    
    // MARK: Repositioning
    
    open override func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) {
        super.translate(xBy: deltaX, yBy: deltaY)
        for feedbackPath in priv_feedbackPathDisplayList {
            feedbackPath.translate(xBy: deltaX, yBy: deltaY)
        }
    }
    
    
    // MARK: Drawing
    
    open override func draw() -> Void {
        //
        // Draw the hippocampal and dopaminergic feedback signal paths
        // as the first, and bottommost, layer.
        //
        for feedbackPath in priv_feedbackPathDisplayList {
            feedbackPath.draw()
        }
        //
        // Draw neural regions, areas, layers, and the neurons themselves with
        // their dendrites, plus any labels.
        //
        super.draw()
        
        // Draw the axons as the topmost/frontmost layer.
        //
        for axonSymbol in priv_axonSymbolDisplayList {
            axonSymbol.draw()
        }
    }
    
    
    // MARK: Update
    
    open override func isValidNodeForTimestepUpdate(_ nodeState: Node) -> Bool {
        if let _ = nodeState as? Network {
            return super.isValidNodeForTimestepUpdate(nodeState)
        }
        return false
    }
    
    open override func updateForTimestep(_ nodeState: Node) -> Void {
        super.updateForTimestep(nodeState)
        
        sensors.updateForTimestep(neuralNetwork.sensorRegion)
        sensoryInputNeurons.updateForTimestep(neuralNetwork.sensoryInputRegion)
        sensoryAssociationNeurons.updateForTimestep(neuralNetwork.sensoryAssociationRegion)
        
        hippocampus.updateForTimestep(neuralNetwork.hippocampus)
        
        motorAssociationNeurons.updateForTimestep(neuralNetwork.motorAssociationRegion)
        vta.updateForTimestep(neuralNetwork.vta)
        motorOutputNeurons.updateForTimestep(neuralNetwork.motorOutputRegion)
        effectors.updateForTimestep(neuralNetwork.effectorRegion)
    }
    
    
    
    
    // MARK: *Private* Data

    fileprivate var priv_axonSymbolDisplayList = [AxonSymbol]()
    fileprivate var priv_feedbackPathDisplayList = [FeedbackPathBase]()
    
    
    
    // MARK: *Private* Methods
    
    
    fileprivate func priv_populateRegions() {
        
        // Sensors
        
        sensors =
            SingleLayerRegionLayout(rootLayout: self,
                                    regionNode: neuralNetwork.sensorRegion)
        
        // Prepend spacer in same location as label for other regions. Causes
        // symbols in this sensor region to line up with symbols in sensory
        // input region.
        //
        var spacer = SpacerLayout(collectionAxis: CollectionAxis.XMajor)
        sensors.prepend(layout: spacer)
        
        // Also need a spacer at the beginning of the second sensor area to
        // give a gap between the conditioned stimuli and the unconditioned
        // stimuli as shown in Figure 1 of BGL2015.
        //
        spacer = SpacerLayout(collectionAxis: CollectionAxis.XMajor)
        var path = DataKeyPathSearchIterator(dotDelimitedKeyPath: "SensorArea_1")
        let _ = sensors.prepend(layout: spacer, toCollectionAt: path)
        
        append(layout: sensors)
        
        
        // Sensory Input Neurons
        
        
        sensoryInputNeurons =
            SingleLayerRegionLayout(rootLayout: self,
                                    regionNode: neuralNetwork.sensoryInputRegion)
        
        var regionLabel = StrengthText(string: "S'")
        var regionLabelLayout = LabelLayout(text: regionLabel)
        sensoryInputNeurons.prepend(layout: regionLabelLayout)
        
        // Spacer to leave gap between conditioned stimuli input neurons and
        // the unconditioned input neuron, as in Figure 1 of BGL2015.
        //
        spacer = SpacerLayout(collectionAxis: CollectionAxis.XMajor)
        path = DataKeyPathSearchIterator(dotDelimitedKeyPath: "SensoryInputArea_1")
        let _ = sensoryInputNeurons.prepend(layout: spacer, toCollectionAt: path)
        
        append(layout: sensoryInputNeurons)
        
        
        // Sensory Association Neurons
        
        sensoryAssociationNeurons =
            AssociationRegionLayout(rootLayout: self,
                                    regionNode: neuralNetwork.sensoryAssociationRegion)
        
        regionLabel = StrengthText(string: "S''")
        regionLabelLayout = LabelLayout(text: regionLabel)
        sensoryAssociationNeurons.prepend(layout: regionLabelLayout)
        
        append(layout: sensoryAssociationNeurons)
        
        
        // Hippocampus
        
        hippocampus =
            FeedbackLayer(rootLayout: self,
                          hippocampus: neuralNetwork.hippocampus)
        
        // No label for the hippocampus, but it needs to be spaced down
        // to account for the labels in other regions, plus half a space
        // to get an alignment approximating that of BGL2015 Fig. 1
        //
        spacer = SpacerLayout(collectionAxis: CollectionAxis.XMajor,
                              scalingFactor: 1.6)
        hippocampus.prepend(layout: spacer)
        append(layout: hippocampus)
        
        
        // Motor Association Neurons
        
        motorAssociationNeurons =
            AssociationRegionLayout(rootLayout: self,
                                    regionNode: neuralNetwork.motorAssociationRegion)
        
        regionLabel = StrengthText(string: "M''")
        regionLabelLayout = LabelLayout(text: regionLabel)
        motorAssociationNeurons.prepend(layout: regionLabelLayout)
        
        append(layout: motorAssociationNeurons)
        
        
        // Ventral Tegmental Area (VTA)
        
        vta =
            FeedbackLayer(rootLayout: self,
                          vta: neuralNetwork.vta)
        
        // No label for the hippocampus, but it needs to be spaced down
        // to account for the labels in other regions, plus half a space
        // to get an alignment approximating that of BGL2015 Fig. 1
        //
        spacer = SpacerLayout(collectionAxis: CollectionAxis.XMajor,
                              scalingFactor: 3.0)
        vta.prepend(layout: spacer)
        append(layout: vta)
        
        
        // Motor Output Neurons
        
        motorOutputNeurons =
            MotorOutputRegionLayout(rootLayout: self,
                                    regionNode: neuralNetwork.motorOutputRegion)
        
        regionLabel = StrengthText(string: "M'")
        regionLabelLayout = LabelLayout(text: regionLabel)
        motorOutputNeurons.prepend(layout: regionLabelLayout)
        
        append(layout: motorOutputNeurons)
        
        
        // Effectors
        
        effectors =
            SingleLayerRegionLayout(rootLayout: self,
                                    regionNode: neuralNetwork.effectorRegion)
        
        // Prepend spacer in same location as label for other regions. Causes
        // symbols in this sensor region to line up with symbols in sensory
        // input region.
        //
        spacer = SpacerLayout(collectionAxis: CollectionAxis.XMajor)
        effectors.prepend(layout: spacer)
        
        append(layout: effectors)
        
        
    } // end priv_populateRegions

    
    
    
    
    
    

    
    
    
    fileprivate func priv_customizeRegions() {
        
        // Note forced option unwrap: it is a programmer error if the target
        // does not exist.
        //
        let xSensor = find(idString: "X") as! SensorSymbol
        xSensor.label = StrengthText(string: "X")
        xSensor.fillColor = StrengthColor(colorAtWeakest: NSColor.clear.cgColor,
                                          colorAtStrongest: NSColor.red.cgColor)
        xSensor.lineStyle = StrengthLineStyle(colorAtWeakest: NSColor.clear.cgColor,
                                              colorAtStrongest: NSColor.red.cgColor)
        
        let ySensor = find(idString: "Y") as! SensorSymbol
        ySensor.label = StrengthText(string: "Y")
        ySensor.fillColor = StrengthColor(colorAtWeakest: NSColor.clear.cgColor,
                                          colorAtStrongest: NSColor.yellow.cgColor)
        ySensor.lineStyle = StrengthLineStyle(colorAtWeakest: NSColor.clear.cgColor,
                                              colorAtStrongest: NSColor.yellow.cgColor)
        
        let srSensor = find(idString: "Sr") as! SensorSymbol
        srSensor.label = StrengthText(string: "S").appendSuperscript("r")
        srSensor.changeShape(toShapeType: Identifier(idString: "hexagon"))
        srSensor.fillColor = StrengthColor(colorAtWeakest: NSColor.clear.cgColor,
                                          colorAtStrongest: NSColor.purple.cgColor)
        srSensor.lineStyle = StrengthLineStyle(colorAtWeakest: NSColor.clear.cgColor,
                                              colorAtStrongest: NSColor.purple.cgColor)
        
        
        let sPrime1 = find(idString: "S_Prime_1") as! RegularShapeSymbol
        sPrime1.label = StrengthText(string: "S'").appendSubscript("1")
        sPrime1.fillColor = StrengthColor(colorAtWeakest: NSColor.lightGray.cgColor,
                                          colorAtStrongest: NSColor.red.cgColor)
        sPrime1.lineStyle = StrengthLineStyle(colorAtWeakest: NSColor.lightGray.cgColor,
                                              colorAtStrongest: NSColor.black.cgColor)
        
        
        let sPrime2 = find(idString: "S_Prime_2") as! RegularShapeSymbol
        sPrime2.label = StrengthText(string: "S'").appendSubscript("2")
        sPrime2.fillColor = StrengthColor(colorAtWeakest: NSColor.lightGray.cgColor,
                                          colorAtStrongest: NSColor.yellow.cgColor)
        sPrime2.lineStyle = StrengthLineStyle(colorAtWeakest: NSColor.lightGray.cgColor,
                                              colorAtStrongest: NSColor.black.cgColor)
        
        
        let sStar = find(idString: "S_Star") as! RegularShapeSymbol
        sStar.label = StrengthText(string: "S").appendSuperscript("*")
        sStar.changeShape(toShapeType: Identifier(idString: "hexagon"))
        sStar.fillColor = StrengthColor(colorAtWeakest: NSColor.lightGray.cgColor,
                                           colorAtStrongest: NSColor.purple.cgColor)
        sStar.lineStyle = StrengthLineStyle(colorAtWeakest: NSColor.lightGray.cgColor,
                                               colorAtStrongest: NSColor.black.cgColor)
        
        
        let sPrimePrime1 = find(idString: "S_Prime_Prime_1") as! RegularShapeSymbol
        sPrimePrime1.label = StrengthText(string: "S''").appendSubscript("1")
        
        let sPrimePrime2 = find(idString: "S_Prime_Prime_2") as! RegularShapeSymbol
        sPrimePrime2.label = StrengthText(string: "S''").appendSubscript("2")
        
        
        let h1 = find(idString: "h1") as! RegularShapeSymbol
        h1.label = StrengthText(string: "H").appendSubscript("1")
        
        let h2 = find(idString: "h2") as! RegularShapeSymbol
        h2.label = StrengthText(string: "H").appendSubscript("2")
        
        
        let mPrimePrime1 = find(idString: "M_Prime_Prime_1") as! RegularShapeSymbol
        mPrimePrime1.label = StrengthText(string: "M''").appendSubscript("1")
        
        let mPrimePrime2 = find(idString: "M_Prime_Prime_2") as! RegularShapeSymbol
        mPrimePrime2.label = StrengthText(string: "M''").appendSubscript("2")
        
        let vta = find(idString: "d") as! RegularShapeSymbol
        vta.label = StrengthText(string: "D")
        
        
        let mPrime1 = find(idString: "M_Prime_1") as! RegularShapeSymbol
        mPrime1.label = StrengthText(string: "M'").appendSubscript("1")
        
        let mPrime2 = find(idString: "M_Prime_2") as! RegularShapeSymbol
        mPrime2.label = StrengthText(string: "M'").appendSubscript("2")
        
        
        let r1 = find(idString: "r1") as! RegularShapeSymbol
        r1.label = StrengthText(string: "R").appendSubscript("1")
        r1.fillColor = StrengthColor(colorAtWeakest: NSColor.clear.cgColor,
                                     colorAtStrongest: NSColor.red.cgColor)
        r1.lineStyle = StrengthLineStyle(colorAtWeakest: NSColor.clear.cgColor,
                                         colorAtStrongest: NSColor.red.cgColor)
        
        let r2 = find(idString: "r2") as! RegularShapeSymbol
        r2.label = StrengthText(string: "R").appendSubscript("2")
        r2.fillColor = StrengthColor(colorAtWeakest: NSColor.clear.cgColor,
                                     colorAtStrongest: NSColor.yellow.cgColor)
        r2.lineStyle = StrengthLineStyle(colorAtWeakest: NSColor.clear.cgColor,
                                         colorAtStrongest: NSColor.yellow.cgColor)
        
    } // end priv_customizeRegions
    
    

    
    
    
    
    
    
} // end class NeuralNetworkLayout

