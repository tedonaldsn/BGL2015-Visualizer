//
//  AssociationLayerLayout.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/18/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



open class AssociationLayerLayout: LayerLayout {
    
    // MARK: Data
    
    open let isSensory: Bool
    open var isMotor: Bool { return !isSensory }
    

    
    
    // MARK: Initialization
    
    public init(rootLayout: NeuralNetworkLayout,
                isSensory: Bool,
                layerNode: Node) {
        
        assert(layerNode is NeuralLayer)
        
        self.isSensory = isSensory
        
        super.init(rootLayout: rootLayout, node: layerNode)
        
    } // end init
    
    
    
} // end class AssociationLayerLayout

