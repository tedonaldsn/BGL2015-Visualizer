//
//  BinaryEffector.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 3/14/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import BASimulationFoundation



public protocol BinaryEffector: Effector {
    
    var isOn: Bool { get }
}

