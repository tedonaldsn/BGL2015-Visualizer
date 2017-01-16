//
//  AssociationAreaLayout.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/18/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



open class AssociationAreaLayout: BaseCollectionLayout {
    
    // MARK: Data
    
    public unowned let rootLayout: NeuralNetworkLayout
    
    public var area: NeuralMultiLayerArea {
        return node as! NeuralMultiLayerArea
    }
    
    public let isSensoryArea: Bool
    public let isMotorArea: Bool
    
    
    
    // MARK: Initialization
    
    public init(rootLayout: NeuralNetworkLayout, areaNode: Node) {
        
        assert(areaNode is NeuralMultiLayerArea)
        
        self.rootLayout = rootLayout
        
        isSensoryArea = areaNode is SensoryAssociationArea
        isMotorArea = areaNode is MotorAssociationArea
        
        super.init(node: areaNode, collectionAxis: CollectionAxis.YMajor)
        
        assert(isSensoryArea || isMotorArea)
        assert(!isSensoryArea || !isMotorArea)
        
        priv_populate()
        
    } // end init
    
    
    // Called by NeuralNetworkLayout after all neural units, including their
    // dendrites and axons, have been created.
    //
    open func createFeedbackPath() -> FeedbackConsumerPath? {
        
        var areaPath: FeedbackConsumerPath? = nil
        
        for layout in layouts {
            
            if let layer = layout as? AssociationLayerLayout {
                let layerPath = FeedbackConsumerPath(associationLayer: layer)
                
                if layerPath.hasPoints {
                    if let areaPath = areaPath {
                        areaPath.appendHorizontally(pathOnRight: layerPath)
                    } else {
                        areaPath = layerPath
                    }
                }
            }
        }
        
        return areaPath
        
    } // end createFeedbackPaths
    
    
    
    
    
    // MARK: Search
    
    open override func find(identifier: Identifier) -> BaseLayout? {
        //
        // Find area with the specified identifier
        //
        if let layout = super.find(identifier: identifier) {
            return layout
        }
        //
        // Find symbol with the specified identifier
        //
        for layout in layouts {
            if let collection = layout as? BaseCollectionLayout,
                let targetLayout = collection.find(identifier: identifier) {
                return targetLayout
            }
        }
        
        return nil
    }
    
    
    
    // MARK: Update
    
    open override func isValidNodeForTimestepUpdate(_ nodeState: Node) -> Bool {
        if let newArea = nodeState as? NeuralMultiLayerArea {
            return newArea.layerCount == area.layerCount
                && super.isValidNodeForTimestepUpdate(nodeState)
        }
        return false
    }
    
    open override func updateForTimestep(_ nodeState: Node) -> Void {
        super.updateForTimestep(nodeState)
        
        let areas: [NeuralLayer] = area.layers
        var areaIx: Int = 0
        
        for layout in layouts {
            if let nodeLayout = layout as? BaseNodeLayout {
                let area = areas[areaIx]
                nodeLayout.updateForTimestep(area)
                areaIx = areaIx + 1
            }
        }
        
        assert(areaIx == areas.count)
        
    } // end updateForTimestep
    
    
    // MARK: Scaling
    
    open override func scale(_ scalingFactor: CGFloat) -> Void{
        super.scale(scalingFactor)
    }
    
    
    
    // MARK: Repositioning
    
    open override func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) -> Void {
        super.translate(xBy: deltaX, yBy: deltaY)
    }
    
    
    // MARK: Drawing
    
    open override func draw() -> Void {
        super.draw()
    }
    
    
    
    // MARK: *Private* Data
    
    
    
    // MARK: *Private* Methods
    
    
    fileprivate func priv_populate() {
        
        let layers: [NeuralLayer] = area.layers
        
        for layer in layers {
            
            let layout = AssociationLayerLayout(rootLayout: rootLayout,
                                                isSensory: isSensoryArea,
                                                layerNode: layer)
            append(layout: layout)
        }
        
    } // end priv_populate
    
    
} // end class AssociationAreaLayout

