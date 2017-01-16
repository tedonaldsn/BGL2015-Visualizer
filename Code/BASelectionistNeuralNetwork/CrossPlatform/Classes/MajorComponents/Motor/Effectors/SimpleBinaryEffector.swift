//
//  SimpleBinaryEffector.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 3/4/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation
import BASimulationFoundation



final public class SimpleBinaryEffector: NSObject, NSCoding, BinaryEffector {
    
    // Effector is "on" if the activation level from the source neuron
    // is at or above this level.
    //
    public static let onThreshold = Scaled0to1Value(rawValue: 0.5)
    
    // MARK: Node Protocol
    
    public var hasIdentifier: Bool { return priv_node.hasIdentifier }
    public var identifier: Identifier? { return priv_node.identifier }
    public var network: Network { return priv_node.network }
    public var logger: Logger { return priv_node.logger }
    
    
    
    // MARK: Activatable Protocol
    
    public var activationLevel: Scaled0to1Value {
        return priv_outputActivationLevel
    }
    
    
    // MARK: Sensor Protocol
    
    // Sensory input neuron to which output of this sensor is sent as
    // its input activation level.
    //
    public var hasSourceNeuron: Bool { return priv_sourceNeuron != nil }
    public unowned var receiveFrom: MotorOutputNeuron {
        get {
            precondition(hasSourceNeuron)
            return priv_sourceNeuron!
        }
        set {
            precondition(!hasSourceNeuron)
            priv_sourceNeuron = newValue
        }
    }
    
    
    // MARK: Data
    
    public var isOn: Bool {
        precondition(hasSourceNeuron)
        return priv_outputActivationLevel >= SimpleBinaryEffector.onThreshold
    }
    
    
    
    
    
    // MARK: Initialization
    
    public required init(network: Network, identifier: Identifier?) {
        priv_node = NodeBody(network: network, identifier: identifier)
        super.init()
    }
    public convenience init(network: Network, idString: String) {
        self.init(network: network, identifier: Identifier(idString: idString))
    }
    
    
    // MARK: Activation/Effecting
    
    public func prepareActivation() {
        priv_inputActivationLevel = priv_sourceNeuron!.activationLevel
    }
    public func commitActivation() {
        priv_outputActivationLevel = priv_inputActivationLevel
    }
    public func resetActivation() {
        priv_inputActivationLevel.rawValue = 0.0
    }
    
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public struct Key {
        public static let sourceNeuron = "source"
        public static let inputActivation = "input"
        public static let outputActivation = "output"
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {
        priv_node = NodeBody(coder: aDecoder)!
        
        priv_sourceNeuron =
            aDecoder.decodeObject(forKey: Key.sourceNeuron) as? MotorOutputNeuron
        priv_inputActivationLevel.rawValue =
            aDecoder.decodeDouble(forKey: Key.inputActivation)
        priv_outputActivationLevel.rawValue =
            aDecoder.decodeDouble(forKey: Key.outputActivation)
        
        /*
        if priv_node.identifier!.asString == "r2" {
            Swift.print("Decoding. Input: \(priv_inputActivationLevel), output: \(priv_outputActivationLevel)")
        }
        */
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        
        /*
        if identifier!.asString == "r2" {
            Swift.print("Encoding. Input: \(priv_inputActivationLevel), output: \(priv_outputActivationLevel)")
        }
        */
        
        aCoder.encode(priv_sourceNeuron,
                            forKey: Key.sourceNeuron)
        aCoder.encode(priv_inputActivationLevel.rawValue,
                            forKey: Key.inputActivation)
        aCoder.encode(priv_outputActivationLevel.rawValue,
                            forKey: Key.outputActivation)
    }
    
    
    
    // MARK: *Private*
    
    fileprivate var priv_node: NodeBody
    fileprivate var priv_sourceNeuron: MotorOutputNeuron? = nil
    
    fileprivate var priv_inputActivationLevel = Scaled0to1Value()
    fileprivate var priv_outputActivationLevel = Scaled0to1Value()
    
    
} // end class SimpleBinaryEffector

