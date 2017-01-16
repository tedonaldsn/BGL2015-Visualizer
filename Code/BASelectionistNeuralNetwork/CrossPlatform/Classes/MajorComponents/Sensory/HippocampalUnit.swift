//
//  HippocampalUnit.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/4/15.
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



final public class HippocampalUnit: NSObject, HippocampalNeuron {
    
    // MARK: Node Protocol
    
    public var hasIdentifier: Bool { return priv_node.hasIdentifier }
    public var identifier: Identifier? { return priv_node.identifier }
    public var environment: ComputationalNode { return priv_node.environment }
    public var network: Network { return priv_node.network }
    public var logger: Logger { return priv_node.logger }
    
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
        let desc = "\nHippocampalUnit:\npriv_node: \(priv_node)\npriv_neuronBody: \(priv_neuronBody)\nactivationLevel: \(activationLevel.rawValue)"
        return desc
    }
    
    // MARK: Axon Protocol
    
    public var neuron: Neuron { return self }
    public var activationLevel: Scaled0to1Value { return priv_publishedActivationLevel }
    
    
    // MARK: OperantNeuron Protocol
    
    // prepareActivation()
    //
    // Besides the usual activation calculation we also compute the hippocampal
    // signal output by this hippocampal neuron. We do it here for the simple
    // reason that this is where we have all of the required information, 
    // including the newly computed activation of the hippocampal neuron and
    // its previous (i.e., current) value.
    //
    // The signal calculation is spelled out in detail here because I encountered
    // bugs in the computation, that is, the newly computed signal is sometimes
    // out of range. 
    //
    // Signal formula: dt = d(H,t) = |a(H,t) - a(H,t-1)| + d(D,t)(1-d(H,t-1))
    //
    // That is: abs(activation - previousActivation) + (dopaSignal * (1-previousDopaSignal))
    //
    public func prepareActivation() -> Void {
        let settings = activationSettings
        
        // Note that priv_publishedActivationLevel is the a(H,t-1) term. The new
        // value stored in priv_newActivationLevel will not replace the value of
        // priv_publishedActivationLevel until commitActivation() is called after
        // exit of prepareActivation().
        
        // Compute the new activation, which will be the a(H,t) term.
        //
        priv_newActivationLevel = priv_neuronBody.activate(settings)
        
        // Compute the absolute difference between the previous hippocampal activation
        // and the new level as the |a(H,t) - a(H,t-1)| term.
        //
        let activationDelta: Double =
        abs(priv_newActivationLevel.rawValue - priv_publishedActivationLevel.rawValue)
        
        // This is the d(D,t) term.
        let dopaminergicSignal: Double = environment.network.dopaminergicSignal
        
        // d(H,t-1) term
        let previousHippocampalSignal: Double = priv_hippocampalDiscrepancySignal
        
        // d(D,t)(1-d(H,t-1))
        let dopaminergicFactor = dopaminergicSignal * (1 - previousHippocampalSignal)
        
        // Now compute the new d(H,T) result.
        //
        // d(H,T) = |a(H,t) - a(H,t-1)| + d(D,t)(1-d(H,t-1))
        //
        let newSignal: Double = activationDelta + dopaminergicFactor
        
        priv_hippocampalDiscrepancySignal = newSignal

    } // end activate
    
    public func resetActivation() -> Void {
        priv_newActivationLevel = priv_neuronBody.resetActivation()
        priv_hippocampalDiscrepancySignal = 0.0
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
        let discrepancySignal: Double = network.hippocampalSignal
        
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
    public static var key_hippocampalDiscrepancySignal = "hippoSignal"
    
    @objc public required init?(coder aDecoder: NSCoder) {
        priv_node = ComputationalNodeBody(coder: aDecoder)!
        priv_neuronBody = OperantNeuronBody(coder: aDecoder)!
        
        priv_publishedActivationLevel.rawValue =
            aDecoder.decodeDouble(forKey: HippocampalUnit.key_publishedActivation)
        priv_newActivationLevel.rawValue =
            aDecoder.decodeDouble(forKey: HippocampalUnit.key_newActivation)
        priv_hippocampalDiscrepancySignal =
            aDecoder.decodeDouble(forKey: HippocampalUnit.key_hippocampalDiscrepancySignal)
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        priv_neuronBody.encodeWithCoder(aCoder)
        
        aCoder.encode(priv_publishedActivationLevel.rawValue,
            forKey: HippocampalUnit.key_publishedActivation)
        aCoder.encode(priv_newActivationLevel.rawValue,
            forKey: HippocampalUnit.key_newActivation)
        aCoder.encode(priv_hippocampalDiscrepancySignal,
            forKey: HippocampalUnit.key_hippocampalDiscrepancySignal)
    }
    
    
    // MARK: HippocampalNeuron Protocol
    
    public var discrepancySignal: Double {
        return priv_hippocampalDiscrepancySignal
    }
    
    public func clearDiscrepancySignal() -> Void {
        priv_hippocampalDiscrepancySignal = 0.0
    }
    
    public func receiveExcitation(_ sensoryInterneuron: SensoryInterneuron) -> Void {
        priv_neuronBody.receiveExcitation(sensoryInterneuron)
    }
    public func receiveInhibition(_ sensoryInterneuron: SensoryInterneuron) -> Void {
        priv_neuronBody.receiveInhibition(sensoryInterneuron)
    }
    
    
    
    // MARK: Access
    
    public func containsPresynapticConnection(_ targetIdentifier: Identifier) -> Bool {
        return priv_neuronBody.containsPresynapticConnection(targetIdentifier)
    }
    public func containsExcitatoryPresynapticConnection(_ targetIdentifier: Identifier) -> Bool {
        return priv_neuronBody.containsExcitatoryPresynapticConnection(targetIdentifier)
    }
    public func containsInhibitoryPresynapticConnection(_ targetIdentifier: Identifier) -> Bool {
        return priv_neuronBody.containsInhibitoryPresynapticConnection(targetIdentifier)
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
    
    public var previousTimeStepExcitation: Scaled0to1Value {
        return priv_neuronBody.previousTimeStepExcitation
    }
    
    
    
    
    // MARK: *Private*
    
    fileprivate var priv_node: ComputationalNodeBody
    fileprivate var priv_neuronBody = OperantNeuronBody()
    
    fileprivate var priv_publishedActivationLevel = Scaled0to1Value()
    fileprivate var priv_newActivationLevel = Scaled0to1Value()
    
    fileprivate var priv_hippocampalDiscrepancySignal: Double = 0.0
    
    
} // end class HippocampalUnit

