//
//  NeuralArea.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/13/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import BASimulationFoundation


// Segment of a region. Segments within a region are parallel sections of the
// containing region.
//
// Some neural areas are a single layer deep, in which case they will also
// implement the NeuralLayer protocol.
//
// Neural areas that have more than one layer implement the NeuralMultiLayerArea
// instead of NeuralLayer.
//
public protocol NeuralArea: Node {
    
    // Maximum depth and width. Indicators of complexity of the net. Also useful
    // in creating grid for graphic representation.
    //
    // Number of layers at "deepest" point in order from input to output nodes.
    //
    var maxLayerDepth: Int { get }
    //
    // Number of nodes in a single-layer area, or number of nodes in the layer
    // having the most nodes in a multiple-layer area.
    //
    var maxNodeWidth: Int { get }
    
} // end protocol NeuralArea

