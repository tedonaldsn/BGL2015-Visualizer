//
//  FindIdentifiedNode.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 3/2/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import BASimulationFoundation


// Build and search a collection of "named" nodes in the neural network.
//
// Most nodes in a neural network will NOT have identifiers, or should not.
// But a few will have special meaning in the context of the research project
// or the application, and will have identifiers. Only these nodes may be
// found later.
//
// Restrictions: a node identifier must be unique within the neural network.
//
public protocol FindIdentifiedNode {
    
    // Register a named node to make if findable.
    //
    // Preconditions: node.hasIdentifier && !isRegisteredNode
    //
    func registerNode(_ node: Node) -> Void
    
    // Can only find nodes that have an identifier (obviously). Will
    // always return nil if identifier is nil.
    //
    func findNode(_ identifier: Identifier?) -> Node?
}



public extension FindIdentifiedNode {
    
    // MARK: Tests
    
    public func isRegisteredNode(_ node: Node) -> Bool {
        return findNode(node.identifier) != nil
    }
    
    public func isRegisteredNode(_ identifier: Identifier?) -> Bool {
        if let identifier = identifier {
            return findNode(identifier) != nil
        }
        return false
    }
    
    
    
    // MARK: General
    
    public func findNeuron(_ identifier: Identifier?) -> Neuron? {
        return findNode(identifier) as? Neuron
    }
    
    public func findComputationalNode(_ identifier: Identifier?) -> ComputationalNode? {
        return findNode(identifier) as? ComputationalNode
    }
    
    public func findComputational(_ identifier: Identifier?) -> ComputationalNode? {
        return findNode(identifier) as? ComputationalNode
    }
    
    public func findInterneuron(_ identifier: Identifier?) -> Interneuron? {
        return findNode(identifier) as? Interneuron
    }
    
    public func findOperantNeuron(_ identifier: Identifier?) -> OperantNeuron? {
        return findNode(identifier) as? OperantNeuron
    }
    
    public func findRespondentNeuron(_ identifier: Identifier?) -> RespondentNeuron? {
        return findNode(identifier) as? RespondentNeuron
    }
    
    
    // MARK: Sensors
    
    public func findSensor(_ identifier: Identifier?) -> Sensor? {
        return findNode(identifier) as? Sensor
    }
    
    public func findBinarySensor(_ identifier: Identifier?) -> BinarySensor? {
        return findNode(identifier) as? BinarySensor
    }
    
    public func findSimpleBinarySensor(_ identifier: Identifier?) -> SimpleBinarySensor? {
        return findNode(identifier) as? SimpleBinarySensor
    }
    
    
    // MARK: Sensory Neurons
    
    public func findHippocampalNeuron(_ identifier: Identifier?) -> HippocampalNeuron? {
        return findNode(identifier) as? HippocampalNeuron
    }
    
    public func findSensoryInputNeuron(_ identifier: Identifier?) -> SensoryInputNeuron? {
        return findNode(identifier) as? SensoryInputNeuron
    }
    
    public func findSensoryInterneuron(_ identifier: Identifier?) -> SensoryInterneuron? {
        return findNode(identifier) as? SensoryInterneuron
    }
    
    public func findRespondentSensoryInputNeuron(_ identifier: Identifier?) -> RespondentSensoryInputNeuron? {
        return findNode(identifier) as? RespondentSensoryInputNeuron
    }
    
    
    // MARK: Motor
    
    public func findDopaminergicNeuron(_ identifier: Identifier?) -> DopaminergicNeuron? {
        return findNode(identifier) as? DopaminergicNeuron
    }
    
    public func findMotorInterneuron(_ identifier: Identifier?) -> MotorInterneuron? {
        return findNode(identifier) as? MotorInterneuron
    }
    
    public func findMotorOutputNeuron(_ identifier: Identifier?) -> MotorOutputNeuron? {
        return findNode(identifier) as? MotorOutputNeuron
    }
    
    public func findEffector(_ identifier: Identifier?) -> Effector? {
        return findNode(identifier) as? Effector
    }
    
    public func findBinaryEffector(_ identifier: Identifier?) -> BinaryEffector? {
        return findNode(identifier) as? BinaryEffector
    }
    
    public func findSimpleBinaryEffector(_ identifier: Identifier?) -> SimpleBinaryEffector? {
        return findNode(identifier) as? SimpleBinaryEffector
    }
    
    
} // end extension FindIdentifiedNode


