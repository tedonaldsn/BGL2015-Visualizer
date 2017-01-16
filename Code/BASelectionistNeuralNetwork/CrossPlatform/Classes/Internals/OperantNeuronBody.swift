//
//  OperantNeuronBody.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 8/15/15.
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




public struct OperantNeuronBody: CustomDebugStringConvertible {
    

    // MARK: Debug
    
    public var debugDescription: String {
        let desc = "\nOperantNeuronBody:\npreSynapticConnections: \(priv_preSynapticConnections)."
        return desc
    }
    
    // MARK: Data
    
    public var operantExcitatoryAxons: [Axon] {
        return priv_preSynapticConnections.operantExcitatoryAxons
    }
    
    public var operantInhibitoryAxons: [Axon] {
        return priv_preSynapticConnections.operantInhibitoryAxons
    }
    
    public var excitatoryExcitation: Double {
        return priv_preSynapticConnections.excitatoryExcitation.rawValue
    }
    
    public var inhibitoryExcitation: Double {
        return priv_preSynapticConnections.inhibitoryExcitation.rawValue
    }
    
    
    public var excitatoryWeights: [Double] {
        return priv_preSynapticConnections.excitatory.weights
    }
    public var inhibitoryWeights: [Double] {
        return priv_preSynapticConnections.inhibitory.weights
    }
    
    
    public var operantPresynapticExcitatoryActivation: [Double] {
        return priv_preSynapticConnections.excitatory.preSynapticActivationLevels
    }
    public var operantPresynapticInhibitoryActivation: [Double] {
        return priv_preSynapticConnections.inhibitory.preSynapticActivationLevels
    }
    
    
    
    public var previousTimeStepExcitation: Scaled0to1Value {
        return priv_previousExcitation
    }


    
    // MARK: Initialization
    
    public init(){}
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_currentActivation = "currentActivation"
    public static var key_previousExcitation = "previousExcitation"
    
    public init?(coder aDecoder: NSCoder) {
        priv_currentActivation.rawValue = aDecoder.decodeDouble(forKey: OperantNeuronBody.key_currentActivation)
        priv_previousExcitation.rawValue = aDecoder.decodeDouble(forKey: OperantNeuronBody.key_previousExcitation)
        priv_preSynapticConnections = OperantConnections(coder: aDecoder)!
    }
    public func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(priv_currentActivation.rawValue, forKey: OperantNeuronBody.key_currentActivation)
        aCoder.encode(priv_previousExcitation.rawValue, forKey: OperantNeuronBody.key_previousExcitation)
        priv_preSynapticConnections.encodeWithCoder(aCoder)
    }
    
    
    
    // MARK: Connect
    
    public mutating func receiveExcitation(_ axon: Axon) -> Void {
        priv_preSynapticConnections.receiveExcitation(axon)
    }
    public mutating func receiveInhibition(_ axon: Axon) -> Void {
        priv_preSynapticConnections.receiveInhibition(axon)
    }
    
    
    
    // MARK: Access
    
    public func containsPresynapticConnection(_ targetIdentifier: Identifier) -> Bool {
        return priv_preSynapticConnections.containsPresynapticConnection(targetIdentifier)
    }
    public func containsExcitatoryPresynapticConnection(_ targetIdentifier: Identifier) -> Bool {
        return priv_preSynapticConnections.containsExcitatoryPresynapticConnection(targetIdentifier)
    }
    public func containsInhibitoryPresynapticConnection(_ targetIdentifier: Identifier) -> Bool {
        return priv_preSynapticConnections.containsInhibitoryPresynapticConnection(targetIdentifier)
    }
    
    
    public func findPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_preSynapticConnections.findPresynapticConnection(targetIdentifier)
    }
    public func findExcitatoryPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_preSynapticConnections.findExcitatoryPresynapticConnection(targetIdentifier)
    }
    public func findInhibitoryPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_preSynapticConnections.findInhibitoryPresynapticConnection(targetIdentifier)
    }
    
    
    
    // MARK: OperantNeuron Protocol
    
    // Updates excitation. Returns activation. Retains excitation because the
    // activation computation relies on the previous excitation value. The
    // returned activation is the final product that is "published" via the 
    // axon of the encompassing neuron.
    //
    // From Burgos & García-Leal (2015)
    // a(j,t) =
    //      L(exc(j,t))+ 𝛕(j)L(exc(j,t−1))[1 − L(exc(j,t))], if L(exc(j,t)) ≥ θ(j,t) (reactivation)
    //  or
    //      a(j,t−1) − 𝜅(j)a(j,t−1)(1 − a(j,t−1)), if L(exc(j,t)) < θj,t (decay)
    //
    public mutating func activate(_ settings: ActivationSettings) -> Scaled0to1Value {
        
        // L(exc(j,t))
        var currentExcitation = Scaled0to1Value()
        var currentInhibition = Scaled0to1Value()
        if priv_preSynapticConnections.hasExcitatoryConnections {
            let rawCurrentExcitation = priv_preSynapticConnections.excitatoryExcitation
            currentExcitation = LogisticSignalClamp.scale(rawCurrentExcitation)
        }
        let hasInhibitoryConnections = priv_preSynapticConnections.hasInhibitoryConnections
        if hasInhibitoryConnections {
            let rawCurrentInhibition = priv_preSynapticConnections.inhibitoryExcitation
            currentInhibition = LogisticSignalClamp.scale(rawCurrentInhibition)
        }
        
        // L(exc(j,t-1)
        let previousExcitation = priv_previousExcitation
        priv_previousExcitation = currentExcitation

        if !hasInhibitoryConnections || currentExcitation > currentInhibition {
            
            // 𝛕(j)
            let reactivationThreshold = settings.reactivationThreshold
            
            // if L(exc(j,t)) ≥ θ(j,t) (reactivation)
            //
            if currentExcitation >= reactivationThreshold { // Reactivation
                
                // L(exc(j,t−1))[1 − L(exc(j,t))]
                let rawDelta = previousExcitation.rawValue * (1.0 - currentExcitation.rawValue)
                
                // 𝛕(j)L(exc(j,t−1))[1 − L(exc(j,t))]
                let rateLimitedDelta = settings.temporalSummation.rawValue * rawDelta
                
                // L(exc(j,t))+ 𝛕(j)L(exc(j,t−1))[1 − L(exc(j,t))]
                let gross = currentExcitation.rawValue + rateLimitedDelta

                priv_currentActivation.rawValue = gross - currentInhibition.rawValue
                
            } else { // L(exc(j,t)) < θ(j,t) -> Decay
                
                // a(j,t−1)
                let previousActivation = priv_currentActivation.rawValue
                
                // a(j,t−1)(1 − a(j,t−1))
                let rawDelta = previousActivation * (1.0 - previousActivation)
                
                // 𝜅(j)a(j,t−1)(1 − a(j,t−1))
                let rateLimitedDelta = settings.decayRate.rawValue * rawDelta

                // a(j,t−1) − 𝜅(j)a(j,t−1)(1 − a(j,t−1))
                let gross = previousActivation - rateLimitedDelta
                
                priv_currentActivation.rawValue = gross
            }
            
        } // end if excitation overrides inhibition
        
        return priv_currentActivation
        
    } // end activate
    
    
    
    
    public mutating func resetActivation() -> Scaled0to1Value {
        priv_previousExcitation = LogisticSignalClamp.scale(Scaled0to1Value.minimum)
        priv_currentActivation = LogisticSignalClamp.scale(Scaled0to1Value.minimum)
        return priv_currentActivation
    }
    
    
    public mutating func respondentOverride(_ rawExcitationActivation: Scaled0to1Value) -> Void {
        priv_previousExcitation = LogisticSignalClamp.scale(rawExcitationActivation)
        priv_currentActivation = LogisticSignalClamp.scale(rawExcitationActivation)
    }

    
    
    // MARK: Learning
    //
    // Learning is the adjusting of the "synaptic efficacies" for each
    // preSynaptic connection. In the case of these simulated neurons, it is
    // the adjusting of the connection weight individually for each
    // preSynaptic connection. These weights determine how much each input
    // connection can affect the output activation level. Presynaptic connections
    // with higher weights affect output more, given any particular input
    // activation level.
    
    
    // Setting the connection weights can be considered "manual" learning
    // or unlearning.
    //
    public mutating func setExcitatoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        try priv_preSynapticConnections.setExcitatoryWeights(newValue)
    }
    
    public mutating func setInhibitoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        try priv_preSynapticConnections.setInhibitoryWeights(newValue)
    }
    
    
    // Adjust preSynaptic connection weights. The discrepancy signal is either
    // the dopaminergic or the hippocampal signal, depending upon the type
    // of operant neuron of which this body-implementation is a component (e.g.,
    // hippocampal for sensory neurons, dopaminergic for motor neurons).
    //
    public mutating func learn(_ discrepancySignal: Double, settings: LearningSettings) -> Void {
            
            priv_preSynapticConnections.learn(priv_currentActivation,
                discrepancySignal: discrepancySignal,
                settings: settings)
            
    } // end learn
    
    public mutating func unlearn() -> Void {
        priv_preSynapticConnections.unlearn()
    }
    

    
    
    // MARK: *Private* Data
    
    fileprivate var priv_currentActivation = Scaled0to1Value()
    fileprivate var priv_preSynapticConnections = OperantConnections()
    
    fileprivate var priv_previousExcitation = Scaled0to1Value()
    
    
} // end struct OperantNeuronBody



