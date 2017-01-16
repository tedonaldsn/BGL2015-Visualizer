//
//  RespondentNeuronBody.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 8/31/15.
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




public struct RespondentNeuronBody: CustomDebugStringConvertible {
    
    // MARK: Debug
    
    public var debugDescription: String {
        let desc = "\nRespondentNeuronBody:\nppriv_respondentConnections: \(priv_respondentConnections),\npriv_operantNeuronBody: \(priv_operantNeuronBody)."
        return desc
    }
    
    // MARK: Data
    
    public var respondentExcitatoryAxons: [Axon] {
        return priv_respondentConnections.excitatoryAxons
    }
    
    public var respondentInhibitoryAxons: [Axon] {
        return priv_respondentConnections.inhibitoryAxons
    }
    
    public var operantExcitatoryAxons: [Axon] {
        return priv_operantNeuronBody.operantExcitatoryAxons
    }
    
    public var operantInhibitoryAxons: [Axon] {
        return priv_operantNeuronBody.operantInhibitoryAxons
    }
    
    
    public var excitatoryExcitation: Double {
        return priv_operantNeuronBody.excitatoryExcitation
    }
    
    public var inhibitoryExcitation: Double {
        return priv_operantNeuronBody.inhibitoryExcitation
    }
    
    
    public var excitatoryWeights: [Double] {
        return priv_operantNeuronBody.excitatoryWeights
    }
    public var inhibitoryWeights: [Double] {
        return priv_operantNeuronBody.inhibitoryWeights
    }
    
    public var operantPresynapticExcitatoryActivation: [Double] {
        return priv_operantNeuronBody.operantPresynapticExcitatoryActivation
    }
    public var operantPresynapticInhibitoryActivation: [Double] {
        return priv_operantNeuronBody.operantPresynapticInhibitoryActivation
    }
    
    // MARK: *Test Outputs*
    
    public var respondentPresynapticExcitatoryActivation: [Double] {
        return priv_respondentConnections.preSynapticExcitatoryActivationLevels
    }
    public var respondentPresynapticInhibitoryActivation: [Double] {
        return priv_respondentConnections.preSynapticInhibitoryActivationLevels
    }
    
    public var previousTimeStepExcitation: Scaled0to1Value {
        return priv_operantNeuronBody.previousTimeStepExcitation
    }
    
    
    
    // MARK: Initialization
    
    public init(){}
    
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public init?(coder aDecoder: NSCoder) {
        priv_respondentConnections = RespondentConnections(coder: aDecoder)!
        priv_operantNeuronBody = OperantNeuronBody(coder: aDecoder)!
    }
    public func encodeWithCoder(_ aCoder: NSCoder) {
        priv_respondentConnections.encodeWithCoder(aCoder)
        priv_operantNeuronBody.encodeWithCoder(aCoder)
    }
    

    // MARK: Connect
    
    public mutating func receiveExcitation(_ sensor: SensoryInputNeuron) -> Void {
        
        if let sensor = sensor as? RespondentSensoryInputNeuron {
            priv_respondentConnections.receiveExcitation(sensor)
        } else {
            priv_operantNeuronBody.receiveExcitation(sensor)
        }
    }
    
    public mutating func receiveInhibition(_ sensor: SensoryInputNeuron) -> Void {
        
        if let sensor = sensor as? RespondentSensoryInputNeuron {
            priv_respondentConnections.receiveInhibition(sensor)
        } else {
            priv_operantNeuronBody.receiveInhibition(sensor)
        }
    }
    
    public mutating func receiveExcitation(_ motorInterneuron: MotorInterneuron) -> Void {
            priv_operantNeuronBody.receiveExcitation(motorInterneuron)
    }
    public mutating func receiveInhibition(_ motorInterneuron: MotorInterneuron) -> Void {
            priv_operantNeuronBody.receiveInhibition(motorInterneuron)
    }
    
    
    
    // MARK: Access
    
    public func containsPresynapticConnection(_ targetIdentifier: Identifier) -> Bool {
        return findPresynapticConnection(targetIdentifier) != nil
    }
    
    public func findPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron? {
        var neuron = findOperantConnection(targetIdentifier)
        if neuron == nil {
            neuron = findRespondentConnection(targetIdentifier)
        }
        return neuron
    }
    
    public func findExcitatoryPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron? {
        var neuron = findOperantExcitatoryConnection(targetIdentifier)
        if neuron == nil {
            neuron = findRespondentExcitatoryConnection(targetIdentifier)
        }
        return neuron
    }
    
    public func findInhibitoryPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron? {
        var neuron = findOperantInhibitoryConnection(targetIdentifier)
        if neuron == nil {
            neuron = findRespondentInhibitoryConnection(targetIdentifier)
        }
        return neuron
    }
    

    
    public func findOperantConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_operantNeuronBody.findPresynapticConnection(targetIdentifier)
    }
    public func findOperantExcitatoryConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_operantNeuronBody.findExcitatoryPresynapticConnection(targetIdentifier)
    }
    public func findOperantInhibitoryConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_operantNeuronBody.findInhibitoryPresynapticConnection(targetIdentifier)
    }
    
    public func findRespondentConnection(_ targetIdentifier: Identifier) -> Neuron? {
        var neuron = findRespondentExcitatoryConnection(targetIdentifier)
        if neuron == nil {
            neuron = findRespondentInhibitoryConnection(targetIdentifier)
        }
        return neuron
    }
    public func findRespondentExcitatoryConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_respondentConnections.findExcitatoryPresynapticConnection(targetIdentifier)
    }
    public func findRespondentInhibitoryConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_respondentConnections.findInhibitoryPresynapticConnection(targetIdentifier)
    }
    
    
    
    // MARK: OperantNeuron Protocol
    
    public mutating func activate(_ settings: ActivationSettings) -> Scaled0to1Value {
            
            var activation: Scaled0to1Value = priv_respondentConnections.activation

            if activation > 0.0 {
                priv_operantNeuronBody.respondentOverride(activation)

            } else {
                activation = priv_operantNeuronBody.activate(settings)
            }
            
            return activation
    }
    
    public mutating func resetActivation() -> Scaled0to1Value {
        return priv_operantNeuronBody.resetActivation()
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
        try priv_operantNeuronBody.setExcitatoryWeights(newValue)
    }
    
    public mutating func setInhibitoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        try priv_operantNeuronBody.setInhibitoryWeights(newValue)
    }
    

    // Learn is still very important in the combined Respondent and operant neurons.
    // In cases in which the UCS is set to its maximum level, it overrides activation
    // and operant activation plays no part. But when learn() is then called while
    // the preSynaptic activation of the UCS is still at a high level its weight
    // grows rapidly and grows very large. 
    //
    // True, the weight never plays a direct role in activation. But it plays an
    // indirect role by "hogging" the available efficacy of the neuron. Thus the
    // strictly operant preSynaptic connections remain at lower efficacies. This
    // increases the contrast in between "reinforced" events and "unreinforced"
    // events in activations and in discrepancy signal output.
    //
    public mutating func learn(_ discrepancySignal: Double, settings: LearningSettings) -> Void {
            priv_operantNeuronBody.learn(discrepancySignal, settings: settings)
    }
    
    
    public mutating func unlearn() -> Void {
        try! priv_operantNeuronBody.setExcitatoryWeights(Scaled0to1Value.minimum)
        try! priv_operantNeuronBody.setInhibitoryWeights(Scaled0to1Value.minimum)
    }
    
    
    // MARK: *Private*
    
    fileprivate var priv_respondentConnections = RespondentConnections()
    fileprivate var priv_operantNeuronBody = OperantNeuronBody()
    
} // end struct RespondentNeuronBody

