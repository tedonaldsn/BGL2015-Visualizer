//
//  AssociationRegionLayout.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/18/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



open class AssociationRegionLayout: BaseCollectionLayout {
    
    // MARK: Data
    
    public unowned let rootLayout: NeuralNetworkLayout
    
    public var region: NeuralRegion {
        return node as! NeuralRegion
    }
    
    public let isSensoryRegion: Bool
    public let isMotorRegion: Bool
    
    
    
    // MARK: Initialization
    
    public init(rootLayout: NeuralNetworkLayout, regionNode: Node) {
        
        assert(regionNode is NeuralRegion)
        
        self.rootLayout = rootLayout
        
        isSensoryRegion = regionNode is SensoryAssociationRegion
        isMotorRegion = regionNode is MotorAssociationRegion
        
        super.init(node: regionNode, collectionAxis: CollectionAxis.XMajor)
        
        assert(isSensoryRegion || isMotorRegion)
        assert(!isSensoryRegion || !isMotorRegion)
        
        priv_populate()
        
    } // end init
    
    
    
    // Called by NeuralNetworkLayout after all neural units, including their
    // dendrites and axons, have been created.
    //
    open func createFeedbackPath() -> FeedbackConsumerPath? {
        
        var regionPath: FeedbackConsumerPath? = nil
        
        for layout in layouts {
            if let area = layout as? AssociationAreaLayout {
                let areaPath = area.createFeedbackPath()
                
                if let areaPath = areaPath {
                    if let regionPath = regionPath {
                        regionPath.appendVertically(pathBelow: areaPath)
                    } else {
                        regionPath = areaPath
                    }
                }
            }
        }
        
        return regionPath
        
    } // end createFeedbackPath
    
    
    
    
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
        if let newRegion = nodeState as? NeuralRegion {
            return newRegion.areaCount == region.areaCount
                && super.isValidNodeForTimestepUpdate(nodeState)
        }
        return false
    }
    
    open override func updateForTimestep(_ nodeState: Node) -> Void {
        super.updateForTimestep(nodeState)
        
        let areas: [NeuralArea] = region.areas
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
        
        let areas: [NeuralArea] = region.areas
        
        for area in areas {
            assert(area is NeuralMultiLayerArea)
            
            let layout = AssociationAreaLayout(rootLayout: rootLayout, areaNode: area)
            append(layout: layout)
        }
        
    } // end priv_populate
    
    
    
    
    
} // end class AssociationRegionLayout

