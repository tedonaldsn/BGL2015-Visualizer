//
//  MotorNeuron.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/2/15.
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



final public class MotorNeuron: NSObject, MotorOutputNeuron {
    
    // MARK: Node Protocol
    
    public var hasIdentifier: Bool { return priv_node.hasIdentifier }
    public var identifier: Identifier? { return priv_node.identifier }
    public var environment: ComputationalNode { return priv_node.environment }
    public var logger: Logger { return priv_node.logger }
    
    public var network: Network { return priv_node.network }
    
    public var activationSettings: ActivationSettings {
        get { return priv_node.activationSettings }
        set { priv_node.activationSettings = newValue }
    }
    public var learningSettings: LearningSettings {
        get { return priv_node.learningSettings }
        set { priv_node.learningSettings = newValue }
    }
    
    // MARK: Debug
    
    override public var debugDescription: String {
        let desc = "\nMotorNeuron:\npriv_node: \(priv_node)\npriv_neuronBody: \(priv_neuronBody)\nactivationLevel: \(activationLevel.rawValue)"
        return desc
    }
    
    // MARK: Axon Protocol
    
    public var neuron: Neuron { return self }
    public var activationLevel: Scaled0to1Value { return priv_publishedActivationLevel }
    
    
    // MARK: OperantNeuron Protocol
    
    public func prepareActivation() -> Void {
        let settings = activationSettings
        priv_newActivationLevel = priv_neuronBody.activate(settings)
    }
    
    public func resetActivation() -> Void {
        priv_newActivationLevel = priv_neuronBody.resetActivation()
    }
    
    public func commitActivation() {
        priv_publishedActivationLevel = priv_newActivationLevel
    }
    
    // MARK: OperantNeuron
    
    public var operantExcitatoryAxons: [Axon] {
        return priv_neuronBody.operantExcitatoryAxons
    }
    public var operantInhibitoryAxons: [Axon] {
        return priv_neuronBody.operantInhibitoryAxons
    }
    
    public func setExcitatoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        try priv_neuronBody.setExcitatoryWeights(newValue)
    }
    public func setInhibitoryWeights(_ newValue: Scaled0to1Value) throws -> Void {
        try priv_neuronBody.setInhibitoryWeights(newValue)
    }
    
    public func learn() -> Void {
        let settings = learningSettings
        let discrepancySignal: Double = network.dopaminergicSignal
        
        priv_neuronBody.learn(discrepancySignal, settings: settings)
    }
    
    public func unlearn() -> Void {
        priv_neuronBody.unlearn()
    }
    
    
    // MARK: Initialization
    
    public init(environment: ComputationalNode, identifier: Identifier? = nil) {
        priv_node = ComputationalNodeBody(environment: environment, identifier: identifier)
        super.init()
    }
    
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_publishedActivation = "pubActivation"
    public static var key_newActivation = "newActivation"
    
    @objc public required init?(coder aDecoder: NSCoder) {
        priv_node = ComputationalNodeBody(coder: aDecoder)!
        priv_neuronBody = RespondentNeuronBody(coder: aDecoder)!
        
        priv_publishedActivationLevel.rawValue =
            aDecoder.decodeDouble(forKey: MotorNeuron.key_publishedActivation)
        priv_newActivationLevel.rawValue =
            aDecoder.decodeDouble(forKey: MotorNeuron.key_newActivation)
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        priv_neuronBody.encodeWithCoder(aCoder)
        
        aCoder.encode(priv_publishedActivationLevel.rawValue,
            forKey: MotorNeuron.key_publishedActivation)
        aCoder.encode(priv_newActivationLevel.rawValue,
            forKey: MotorNeuron.key_newActivation)
    }
    

    
    // MARK: RespondentNeuron Protocol
    
    public var respondentExcitatoryAxons: [Axon] {
        return priv_neuronBody.respondentExcitatoryAxons
    }
    
    public var respondentInhibitoryAxons: [Axon] {
        return priv_neuronBody.respondentInhibitoryAxons
    }
    
    public func receiveExcitation(_ unconditionedStimulus: RespondentSensoryInputNeuron) -> Void {
            priv_neuronBody.receiveExcitation(unconditionedStimulus)
    }
    
    public func receiveInhibition(_ unconditionedStimulus: RespondentSensoryInputNeuron) -> Void {
            priv_neuronBody.receiveInhibition(unconditionedStimulus)
    }
    
    
    // MARK: MotorOutputNeuron Protocol
    
    public func receiveExcitation(_ motorInterneuron: MotorInterneuron) -> Void {
            priv_neuronBody.receiveExcitation(motorInterneuron)
    }
    public func receiveInhibition(_ motorInterneuron: MotorInterneuron) -> Void {
            priv_neuronBody.receiveInhibition(motorInterneuron)
    }
    
    
    
    // MARK: Access
    
    
    
    public func containsPresynapticConnection(_ targetIdentifier: Identifier) -> Bool {
        return priv_neuronBody.containsPresynapticConnection(targetIdentifier)
    }
    
    public func findPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_neuronBody.findPresynapticConnection(targetIdentifier)
    }
    
    public func findExcitatoryPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_neuronBody.findExcitatoryPresynapticConnection(targetIdentifier)
    }
    
    public func findInhibitoryPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_neuronBody.findInhibitoryPresynapticConnection(targetIdentifier)
    }
    
    
    
    public func findOperantConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_neuronBody.findPresynapticConnection(targetIdentifier)
    }
    public func findOperantExcitatoryConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_neuronBody.findExcitatoryPresynapticConnection(targetIdentifier)
    }
    public func findOperantInhibitoryConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_neuronBody.findInhibitoryPresynapticConnection(targetIdentifier)
    }
    
    public func findRespondentConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_neuronBody.findRespondentConnection(targetIdentifier)
    }
    public func findRespondentExcitatoryConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_neuronBody.findRespondentExcitatoryConnection(targetIdentifier)
    }
    public func findRespondentInhibitoryConnection(_ targetIdentifier: Identifier) -> Neuron? {
        return priv_neuronBody.findRespondentInhibitoryConnection(targetIdentifier)
    }
    
    
    
    // MARK: *Test Inputs*
    
    public func receiveExcitation(_ testStimulus: SensoryTestInput) -> Void {
        priv_neuronBody.receiveExcitation(testStimulus)
    }
    public func receiveInhibition(_ testStimulus: SensoryTestInput) -> Void {
        priv_neuronBody.receiveInhibition(testStimulus)
    }
    
    
    // MARK: *Test Outputs*
    
    public var excitatoryExcitation: Double {
        return priv_neuronBody.excitatoryExcitation
    }
    public var inhibitoryExcitation: Double {
        return priv_neuronBody.inhibitoryExcitation
    }
    
    public var excitatoryWeights: [Double] {
        return priv_neuronBody.excitatoryWeights
    }
    public var inhibitoryWeights: [Double] {
        return priv_neuronBody.inhibitoryWeights
    }
    
    public var operantPresynapticExcitatoryActivation: [Double] {
        return priv_neuronBody.operantPresynapticExcitatoryActivation
    }
    public var operantPresynapticInhibitoryActivation: [Double] {
        return priv_neuronBody.operantPresynapticInhibitoryActivation
    }
    
    public var respondentPresynapticExcitatoryActivation: [Double] {
        return priv_neuronBody.respondentPresynapticExcitatoryActivation
    }
    public var respondentPresynapticInhibitoryActivation: [Double] {
        return priv_neuronBody.respondentPresynapticInhibitoryActivation
    }
    
    public var previousTimeStepExcitation: Scaled0to1Value {
        return priv_neuronBody.previousTimeStepExcitation
    }
    
    
    // MARK: *Private*
    
    fileprivate var priv_node: ComputationalNodeBody
    fileprivate var priv_neuronBody = RespondentNeuronBody()
    
    fileprivate var priv_publishedActivationLevel = Scaled0to1Value()
    fileprivate var priv_newActivationLevel = Scaled0to1Value()
    
} // end class MotorNeuron


