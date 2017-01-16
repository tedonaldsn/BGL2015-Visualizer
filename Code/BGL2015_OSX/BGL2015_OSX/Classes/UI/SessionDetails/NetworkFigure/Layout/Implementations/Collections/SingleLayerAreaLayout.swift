//
//  SingleLayerAreaLayout.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 11/13/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



open class SingleLayerAreaLayout: LayerLayout {
    
    // MARK: Data
    
    // MARK: Initialization
    
    public init(rootLayout: NeuralNetworkLayout, areaNode: Node) {
        
        assert(areaNode is NeuralArea)
        
        super.init(rootLayout: rootLayout, node: areaNode)
    }
    
    
    
    
    
    // MARK: Drawing
    
    open override func draw() -> Void {
        super.draw()
    }
    
    
} // end class SingleLayerAreaLayout

