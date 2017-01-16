//
//  OperantNeuron.swift
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
//  OperantNeuron is the base level computational neuron defined by not
//  only activation, but the ability to learn.



import Foundation
import BASimulationFoundation



public protocol OperantNeuron: Neuron, ComputationalNode {
    
    // MARK: Initialization
    
    init(environment: ComputationalNode, identifier: Identifier?)
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    //
    // init?(coder aDecoder: NSCoder)
    // func encodeWithCoder(aCoder: NSCoder)
    
    // MARK: Access
    
    var operantExcitatoryAxons: [Axon] { get }
    var operantInhibitoryAxons: [Axon] { get }
    
    func findPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron?
    func findExcitatoryPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron?
    func findInhibitoryPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron?
    
    
    // MARK: Activation
    
    // Recompute activation level based on preSynaptic inputs, weights
    // of for preSynaptic connections and settings. The new activation level
    // is not visible to any postSynaptic neurons until commitActivation()
    // is called. This compute-activation-then-commit cycle permits concurrent
    // update of neurons so long as commitActivation() is not called until
    // after prepareActivation() has exited in all neurons.
    //
    func prepareActivation() -> Void
    
    // Make the last-computed activation level visible via the axon of this
    // neuron. This is the commit phase of the compute-activation-then-commit
    // cycle. After commitActivation() has returned it is then safe to
    // call learn() or prepareActivation() again.
    //
    // Note that this method should do nothing more than copy the last
    // computed activation level to the output activation level of the Axon.
    //
    func commitActivation() -> Void
    
    // Resets activations to their baseline value, which is whatever value
    // is output by the logistic function when passed 0.0 as the excitation.
    //
    func resetActivation() -> Void
    
    // MARK: Learning
    
    // Recompute preSynaptic connection weights. Adjusts efficacy of incoming
    // signals based on activation levels and discrepancy signals.
    //
    func learn() -> Void
    
    // Zeroes out the connection weights.
    //
    func unlearn() -> Void
    
    // Throws exception if the new weight value when applied to all
    // connection weights for the particular type of connection would
    // exceed 1.0
    //
    func setExcitatoryWeights(_ newValue: Scaled0to1Value) throws -> Void
    func setInhibitoryWeights(_ newValue: Scaled0to1Value) throws -> Void
    
    // MARK: *Debug/Test*
    
    // L(exc(j,t-1)
    var previousTimeStepExcitation: Scaled0to1Value { get }
    
    // MARK: *Test Inputs*
    //
    func receiveExcitation(_ testStimulus: SensoryTestInput) -> Void
    func receiveInhibition(_ testStimulus: SensoryTestInput) -> Void
    
    // MARK: *Test Outputs*
    
    var excitatoryExcitation: Double { get }
    var inhibitoryExcitation: Double { get }
    
    var excitatoryWeights: [Double] { get }
    var inhibitoryWeights: [Double] { get }
    
    var operantPresynapticExcitatoryActivation: [Double] { get }
    var operantPresynapticInhibitoryActivation: [Double] { get }

} // end protocol OperantNeuron



public extension OperantNeuron {
    
    
    public init(environment: ComputationalNode, idString: String) {
        self.init(environment: environment, identifier: Identifier(idString: idString))
    }
    
    public func activateAndPropogate() -> Void {
        prepareActivation()
        commitActivation()
    }
    
    public func activatePropogateLearn() -> Void {
        activateAndPropogate()
        learn()
    }
    
    public func setExcitatoryWeights(_ newRawValue: Double) throws -> Void {
        try setExcitatoryWeights(Scaled0to1Value(rawValue: newRawValue))
    }
    public func setInhibitoryWeights(_ newRawValue: Double) throws -> Void {
        try setInhibitoryWeights(Scaled0to1Value(rawValue: newRawValue))
    }
    
    public func setConnectionWeights(_ newValue: Scaled0to1Value) throws -> Void {
        try setExcitatoryWeights(newValue)
        try setInhibitoryWeights(newValue)
    }
    public func setConnectionWeights(_ newRawValue: Double) throws -> Void {
        try setConnectionWeights(Scaled0to1Value(rawValue: newRawValue))
    }
    
    public func unlearnExcitation() -> Void {
        try! setExcitatoryWeights(Scaled0to1Value.minimum)
    }
    
    public func unlearnInhibition() -> Void {
        try! setInhibitoryWeights(Scaled0to1Value.minimum)
    }
    
    
    // Return the aggregate syntax efficacy at the specified combination
    // of stimulation type, learning type, and index within that combination.
    // If found, the returned connection weight will be in the range 0-1.
    // If not found, it will be == Double(NSNotFound)
    //
    // An instance of OperantNeuron will only find Learning.Operant connections.
    //
    public func operantConnectionWeightAt(_ stimulationType: Stimulation,
                                          index: Int) -> Double {
        assert(index >= 0)
        
            if stimulationType == Stimulation.Excitatory {
                if index < excitatoryWeights.count {
                    return excitatoryWeights[index]
                }
            }
            if index < inhibitoryWeights.count {
                return inhibitoryWeights[index]
            }
        return Double(NSNotFound)
    }
    
    public func connectionAttributes(_ forPresynapticUnit: Neuron) -> ConnectionAttributes? {
        return operantConnectionAttributes(forPresynapticUnit)
    }
    
    public func operantConnectionAttributes(_ forPresynapticUnit: Neuron) -> ConnectionAttributes? {
        var index = indexOfOperantExcitatoryPresynaptic(forPresynapticUnit)
        if index != NSNotFound {
            return ConnectionAttributes(
                preSynapticUnit: forPresynapticUnit,
                postSynapticUnit: self,
                learning: Learning.Operant,
                stimulation: Stimulation.Excitatory,
                index: index
            )
        }
        index = indexOfOperantInhibitoryPresynaptic(forPresynapticUnit)
        if index != NSNotFound {
            return ConnectionAttributes(
                preSynapticUnit: forPresynapticUnit,
                postSynapticUnit: self,
                learning: Learning.Operant,
                stimulation: Stimulation.Inhibitory,
                index: index
            )
        }
        return nil
    }
    
    
    public func indexOfOperantExcitatoryPresynaptic(_ target: Neuron) -> Int {
        let axons = operantExcitatoryAxons
        for ix in 0..<axons.count {
            let candidateNeuron = axons[ix].neuron
            if candidateNeuron === target {
                return ix
            }
        }
        return NSNotFound
    }
    public func indexOfOperantInhibitoryPresynaptic(_ target: Neuron) -> Int {
        let axons = operantInhibitoryAxons
        for ix in 0..<axons.count {
            let candidateNeuron = axons[ix].neuron
            if candidateNeuron === target {
                return ix
            }
        }
        return NSNotFound
    }
    
} // end extension OperantNeuron

