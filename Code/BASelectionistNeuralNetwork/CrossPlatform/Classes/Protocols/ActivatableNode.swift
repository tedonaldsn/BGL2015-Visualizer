//
//  ActivatableNode.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/8/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation
import BASimulationFoundation


//  Objects that are both nodes, and are activatable. Examples: sensors,
//  effectors, neurons.
//
//  Excludes Axon's, which are activatable but are not nodes.
//
//  Excludes NodeContainers and NeuralLayers, which are nodes but which are
//  not activatable.
//
public protocol ActivatableNode: Node, Activatable {
    
}