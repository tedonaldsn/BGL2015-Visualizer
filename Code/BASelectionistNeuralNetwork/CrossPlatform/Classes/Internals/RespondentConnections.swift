//
//  RespondentConnections.swift
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



public struct RespondentConnections: CustomDebugStringConvertible {
    
    public var excitatory: UnweightedConnections { return priv_excitatory }
    public var inhibitory: UnweightedConnections { return priv_inhibitory }
    
    // MARK: Debug
    
    public var debugDescription: String {
        let desc = "\nRespondentConnections:\nexcitatory: \(priv_excitatory)\ninhibitory: \(priv_inhibitory)"
        return desc
    }
    
    // MARK: Data
    
    public var excitatoryAxons: [Axon] {
        return priv_excitatory.preSynapticAxons
    }
    
    public var inhibitoryAxons: [Axon] {
        return priv_inhibitory.preSynapticAxons
    }
    
    public var preSynapticExcitatoryActivationLevels: [Double] {
        return priv_excitatory.preSynapticActivationLevels
    }
    public var preSynapticInhibitoryActivationLevels: [Double] {
        return priv_inhibitory.preSynapticActivationLevels
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
        priv_excitatory = UnweightedConnections(coder: aDecoder, isExcitatory: true)!
        priv_inhibitory = UnweightedConnections(coder: aDecoder, isExcitatory: false)!
    }
    public func encodeWithCoder(_ aCoder: NSCoder) {
        priv_excitatory.encodeWithCoder(aCoder)
        priv_inhibitory.encodeWithCoder(aCoder)
    }
    
    
    // MARK: Connect
    
    public mutating func receiveExcitation(_ sensor: RespondentSensoryInputNeuron) -> Void {
        priv_excitatory.append(sensor)
    }
    
    public mutating func receiveInhibition(_ sensor: RespondentSensoryInputNeuron) -> Void {
        priv_inhibitory.append(sensor)
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
    
    
    // MARK: Activation
    
    public var activation: Scaled0to1Value {
        var rawActivation = priv_excitatory.activation.rawValue - priv_inhibitory.activation.rawValue
        if rawActivation < 0.0 {
            rawActivation = 0.0
        }
        return Scaled0to1Value(rawValue: rawActivation)
    }
    
    public var excitation: Scaled0to1Value {
        var rawExcitation = priv_excitatory.excitation.rawValue - priv_inhibitory.excitation.rawValue
        if rawExcitation < 0.0 {
            rawExcitation = 0.0
        }
        return Scaled0to1Value(rawValue: rawExcitation)
    }
    
    // MARK: *Private*
    
    fileprivate var priv_excitatory = UnweightedConnections(isExcitatory: true)
    fileprivate var priv_inhibitory = UnweightedConnections(isExcitatory: false)
    
} // end struct RespondentConnections

