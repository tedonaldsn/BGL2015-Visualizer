//
//  NeuralLayer.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 7/21/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import BASimulationFoundation


// NeuralLayer
//
// The basic collection of neurons within the neural network is a layer.
// A layer is a container that contains only neurons.
//
public protocol NeuralLayer: Node {
    
    // Number of nodes in this layer.
    //
    var nodeCount: Int { get }
    
    var nodes: [ActivatableNode] { get }
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    //
    // init?(coder aDecoder: NSCoder)
    // func encodeWithCoder(aCoder: NSCoder)
    
} // end protocol NeuralLayer


