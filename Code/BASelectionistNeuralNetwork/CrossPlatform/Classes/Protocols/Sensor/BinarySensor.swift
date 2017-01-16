//
//  BinarySensor.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 3/14/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import BASimulationFoundation


public protocol BinarySensor: Sensor {
    
    var isOn: Bool { get set }
}

public extension BinarySensor {

    public var isOff: Bool {
        get { return !isOn }
        set { isOn = !newValue }
    }

}