//
//  TestArchiving.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 7/29/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import XCTest
import BASimulationFoundation

class TestArchiving: XCTestCase {
    
    let brainId = Identifier(idString: "TestArchiving")
    let xSensorId = Identifier(idString: "X")
    var brain: Network!

    override func setUp() {
        super.setUp()
        
        brain = Network(identifier: brainId, logger: nil)
        let sensor = brain.appendSensor(SimpleBinarySensor(network: brain, identifier: xSensorId))
        let inputNeuron = brain.createSensoryInputNeuron("X_input")
        inputNeuron.sensor = sensor
    }
    
    override func tearDown() {
        brain = nil
        super.tearDown()
    }

    
    
    func testSensor() {
        
        let xSensor: SimpleBinarySensor = brain.findBinarySensor(xSensorId)as! SimpleBinarySensor
        xSensor.isOff = true
        xSensor.prepareActivation()
        xSensor.commitActivation()
        
        var archivedBrain: Data = NSKeyedArchiver.archivedData(withRootObject: brain)
        var restoredBrain: Network = NSKeyedUnarchiver.unarchiveObject(with: archivedBrain) as! Network
        var restoredSensor: SimpleBinarySensor = restoredBrain.findBinarySensor(xSensorId) as! SimpleBinarySensor
        
        XCTAssertTrue(restoredSensor.isOff)
        
        xSensor.isOn = true
        xSensor.prepareActivation()
        xSensor.commitActivation()
        
        archivedBrain = NSKeyedArchiver.archivedData(withRootObject: brain)
        restoredBrain = NSKeyedUnarchiver.unarchiveObject(with: archivedBrain) as! Network
        restoredSensor = restoredBrain.findBinarySensor(xSensorId) as! SimpleBinarySensor
        
        XCTAssertTrue(restoredSensor.isOn)

    } // end testSensor


} // end class TestArchiving

