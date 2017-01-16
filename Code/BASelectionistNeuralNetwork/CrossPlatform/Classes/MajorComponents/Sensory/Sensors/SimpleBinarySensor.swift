//
//  SimpleBinarySensor.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 11/18/15.
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



final public class SimpleBinarySensor: NSObject, NSCoding, BinarySensor {
    
    // Mid-range is on.
    public static let onThreshold = Scaled0to1Value(rawValue: 0.5)
    
    // "On" will always be 1.0, "off" will be 0.0.
    //
    public static let activationLevelWhenOn = Scaled0to1Value(rawValue: 1.0)
    public static let activationLevelWhenOff = Scaled0to1Value()
    
    // MARK: Node Protocol
    
    public var hasIdentifier: Bool { return priv_node.hasIdentifier }
    public var identifier: Identifier? { return priv_node.identifier }
    public var network: Network { return priv_node.network }
    public var logger: Logger { return priv_node.logger }
    
    
    // MARK: Axon Protocol
    
    public var neuron: Neuron { return self }
    
    
    
    // MARK: Activatable Protocol
    
    public var activationLevel: Scaled0to1Value {
        get { return priv_outputActivationLevel }
        set { priv_outputActivationLevel = newValue }
    }
    
    
    // MARK: Data
    
    public var isOn: Bool {
        get {
            return priv_outputActivationLevel >= SimpleBinarySensor.onThreshold
        }
        set {
            priv_inputActivationLevel = newValue
                ? SimpleBinarySensor.activationLevelWhenOn
                : SimpleBinarySensor.activationLevelWhenOff
        }
    }
    
    // MARK: Initialization
    
    public required init(network: Network, identifier: Identifier?) {
        priv_node = NodeBody(network: network, identifier: identifier)
        super.init()
    }
    public convenience init(network: Network, idString: String) {
        self.init(network: network, identifier: Identifier(idString: idString))
    }
    
    
    // MARK: Neuron
    //
    // Sensors have no presynaptic connections. Sensor are the start of the
    // input.
    //
    public func containsPresynapticConnection(_ targetIdentifier: Identifier) -> Bool {
        return false
    }
    public func findPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return nil
    }
    
    
    // MARK: Activation/Sensing
    
    public func prepareActivation() -> Void {
        //
        // Normalize the input in preparation for output.
        //
        priv_inputActivationLevel = priv_inputActivationLevel >= SimpleBinarySensor.onThreshold
            ? SimpleBinarySensor.activationLevelWhenOn
            : SimpleBinarySensor.activationLevelWhenOff
    }
    
    public func commitActivation() -> Void {
        priv_outputActivationLevel = priv_inputActivationLevel
    }
    
    public func resetActivation() -> Void {
        isOn = false
    }
    
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public struct Key {
        public static let inputActivation = "input"
        public static let outputActivation = "output"
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        priv_node = NodeBody(coder: aDecoder)!
        
        priv_inputActivationLevel.rawValue = aDecoder.decodeDouble(forKey: Key.inputActivation)
        priv_outputActivationLevel.rawValue = aDecoder.decodeDouble(forKey: Key.outputActivation)
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        
        aCoder.encode(priv_inputActivationLevel.rawValue, forKey: Key.inputActivation)
        aCoder.encode(priv_outputActivationLevel.rawValue, forKey: Key.outputActivation)
    }
    
    
    
    // MARK: *Private*
    
    fileprivate var priv_node: NodeBody
    
    fileprivate var priv_inputActivationLevel = Scaled0to1Value()
    fileprivate var priv_outputActivationLevel = Scaled0to1Value()
    
    
} // end class SimpleBinarySensor

