//
//  OperantTestInput.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 10/17/15.
//  
//  Copyright © 2017 Tom Donaldson.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

//



import Foundation
import BASimulationFoundation




final public class OperantTestInput: NSObject, NSCoding, SensoryInputNeuron {
    
    // MARK: Node Protocol
    
    public var hasIdentifier: Bool { return priv_node.hasIdentifier }
    public var identifier: Identifier? { return priv_node.identifier }
    public var network: Network { return priv_node.network }
    public var logger: Logger { return priv_node.logger }
    
    
    // MARK: Axon Protocol
    
    public var neuron: Neuron { return self }
    public var activationLevel: Scaled0to1Value {
        return priv_activationLevel
    }
    
    
    // MARK: SensoryInputNeuron Protocol
    
    public var sensor: Sensor {
        get {
            assert(priv_sensor != nil)
            return priv_sensor!
        }
        set {
            precondition(priv_sensor == nil)
            priv_sensor = newValue
        }
    }
    
    // MARK: Initialization
    
    
    public required init(environment: Node, identifier: Identifier? = nil) {
        priv_node = NodeBody(network: environment.network, identifier: identifier)
        super.init()
    }
    
    
    // MARK: Activation
    
    public func prepareActivation() {
        priv_inputActivationLevel = sensor.activationLevel
    }
    
    public func commitActivation() -> Void {
        priv_activationLevel = priv_inputActivationLevel
    }
    
    
    public func resetActivation() -> Void {
        priv_inputActivationLevel.rawValue = 0.0
    }
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public struct Key {
        public static let sensor = "sensor"
        public static let inputActivation = "input"
        public static let outputActivation = "output"
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        priv_node = NodeBody(coder: aDecoder)!
        
        priv_sensor = aDecoder.decodeObject(forKey: Key.sensor) as? Sensor
        priv_inputActivationLevel.rawValue =
            aDecoder.decodeDouble(forKey: Key.inputActivation)
        priv_activationLevel.rawValue =
            aDecoder.decodeDouble(forKey: Key.outputActivation)
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        
        aCoder.encode(priv_sensor, forKey: Key.sensor)
        aCoder.encode(priv_inputActivationLevel.rawValue,
                            forKey: Key.inputActivation)
        aCoder.encode(priv_activationLevel.rawValue,
                            forKey: Key.outputActivation)
    }
    
    
    
    // MARK: Neuron Protocol
    
    public func containsPresynapticConnection(_ targetIdentifier: Identifier) -> Bool {
        if let sensor = priv_sensor {
            return sensor.hasIdentifier && sensor.identifier! == targetIdentifier
        }
        return false
    }
    public func findPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron? {
        if containsPresynapticConnection(targetIdentifier) {
            return priv_sensor
        }
        return nil
    }
    
    
    // MARK: *Private*
    
    fileprivate var priv_node: NodeBody
    
    fileprivate var priv_sensor: Sensor? = nil
    
    // Currently propogated/published activation level
    //
    fileprivate var priv_activationLevel = Scaled0to1Value()
    
    // Last latched input activation level from sensor.
    //
    fileprivate var priv_inputActivationLevel = Scaled0to1Value()
    
    
} // end class OperantTestInput
