//
//  OperantConnections.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 8/14/15.
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



public struct OperantConnections: CustomDebugStringConvertible {
    
    public var operantExcitatoryAxons: [Axon] { return priv_excitatory.preSynapticAxons }
    public var operantInhibitoryAxons: [Axon] { return priv_inhibitory.preSynapticAxons }
    
    public var hasExcitatoryConnections: Bool {
        return priv_excitatory.count > 0
    }
    public var excitatoryExcitation: Scaled0to1Value {
        return priv_excitatory.preSynapticExcitation
    }
    public var excitatory: WeightedConnections {
        return priv_excitatory
    }
    
    public var hasInhibitoryConnections: Bool {
        return priv_inhibitory.count > 0
    }
    public var inhibitoryExcitation: Scaled0to1Value {
        return priv_inhibitory.preSynapticExcitation
    }
    public var inhibitory: WeightedConnections {
        return priv_inhibitory
    }
    
    // MARK: Debug
    
    public var debugDescription: String {
        let desc = "\nOperantConnections:\nexcitatory: \(priv_excitatory)\ninhibitory: \(priv_inhibitory)"
        return desc
    }
    
    
    // MARK: Initialization
    
    public init() {
    }
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    //
    // Structures are a problem for encoding because there is no object id
    // stored to qualify fields per structure. Thus, the weighted connections
    // internally do the qualification based on whether an instance is
    // for excitatory or inhibitory connections.
    //
    public init?(coder aDecoder: NSCoder) {
        priv_excitatory = WeightedConnections(coder: aDecoder, isExcitatory: true)!
        priv_inhibitory = WeightedConnections(coder: aDecoder, isExcitatory: false)!
    }
    public func encodeWithCoder(_ aCoder: NSCoder) {
        priv_excitatory.encodeWithCoder(aCoder)
        priv_inhibitory.encodeWithCoder(aCoder)
    }
    
    
    
    // MARK: Connect
    
    public mutating func receiveExcitation(_ axon: Axon) -> Void {
        priv_excitatory.append(axon)
    }
    public mutating func receiveInhibition(_ axon: Axon) -> Void {
        priv_inhibitory.append(axon)
    }
    
    // MARK: Access
    
    public func containsPresynapticConnection(_ targetIdentifier: Identifier) -> Bool {
        return containsExcitatoryPresynapticConnection(targetIdentifier)
            || containsInhibitoryPresynapticConnection(targetIdentifier)
    }
    public func containsExcitatoryPresynapticConnection(_ targetIdentifier: Identifier) -> Bool {
        return priv_excitatory.hasPresynapticNeuron(targetIdentifier)
    }
    public func containsInhibitoryPresynapticConnection(_ targetIdentifier: Identifier) -> Bool {
        return priv_inhibitory.hasPresynapticNeuron(targetIdentifier)
    }
    
    
    public func findPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron? {
        var neuron = findExcitatoryPresynapticConnection(targetIdentifier)
        if neuron == nil {
            neuron = findInhibitoryPresynapticConnection(targetIdentifier)
        }
        return neuron
    }
    public func findExcitatoryPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_excitatory.findPresynapticNeuron(targetIdentifier)
    }
    public func findInhibitoryPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_inhibitory.findPresynapticNeuron(targetIdentifier)
    }
    
    // MARK: Learning
    
    public mutating func learn(_ neuronActivation: Scaled0to1Value,
        discrepancySignal: Double,
        settings: LearningSettings) -> Void {
            
            priv_excitatory.learn(neuronActivation,
                discrepancySignal: discrepancySignal,
                settings: settings)
            
            priv_inhibitory.learn(neuronActivation,
                discrepancySignal: discrepancySignal,
                settings: settings)
            
    } // end learn
    
    public mutating func setExcitatoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        try priv_excitatory.setWeights(newValue)
    }
    
    public mutating func setInhibitoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        try priv_excitatory.setWeights(newValue)
    }
    
    public mutating func unlearn() -> Void {
        try! priv_excitatory.setWeights(Scaled0to1Value.minimum)
        try! priv_inhibitory.setWeights(Scaled0to1Value.minimum)
    }
    
    
    // MARK: *Private* 
    fileprivate var priv_excitatory = WeightedConnections(isExcitatory: true)
    fileprivate var priv_inhibitory = WeightedConnections(isExcitatory: false)
    
    
} // end struct OperantConnections



