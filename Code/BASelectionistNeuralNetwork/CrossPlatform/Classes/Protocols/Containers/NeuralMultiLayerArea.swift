//
//  NeuralMultiLayerArea.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/13/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import BASimulationFoundation


public protocol NeuralMultiLayerArea: NeuralArea {
    
    var layerCount: Int { get }
    var layers: [NeuralLayer] { get }
    
} // end protocol NeuralMultiLayerArea



