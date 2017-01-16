//
//  RespondentNeuron.swift
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
//  RespondentNeuron may accept connection from Respondent sensory preSynaptic
//  neurons. When such a preSynaptic neuron has an activation level above 0
//  it completely determines the output activation of a Respondent neuron.
//
//  If there are is no UCS connected, or there is no active UCS, then a 
//  RespondentNeuron will behave exactly as an OperantNeuron.




import Foundation
import BASimulationFoundation



public protocol RespondentNeuron: OperantNeuron {
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    //
    // init?(coder aDecoder: NSCoder)
    // func encodeWithCoder(aCoder: NSCoder)
    
    // MARK: Inputs
    //
    func receiveExcitation(_ unconditionedStimulus: RespondentSensoryInputNeuron) -> Void
    func receiveInhibition(_ unconditionedStimulus: RespondentSensoryInputNeuron) -> Void
    
    // MARK: Access
    
    var respondentExcitatoryAxons: [Axon] { get }
    var respondentInhibitoryAxons: [Axon] { get }
    
    func findPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron?
    func findExcitatoryPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron?
    func findInhibitoryPresynapticConnection(_ targetIdentifier: Identifier) -> Neuron?
    
    func findOperantConnection(_ targetIdentifier: Identifier) -> Neuron?
    func findOperantExcitatoryConnection(_ targetIdentifier: Identifier) -> Neuron?
    func findOperantInhibitoryConnection(_ targetIdentifier: Identifier) -> Neuron?
    
    func findRespondentConnection(_ targetIdentifier: Identifier) -> Neuron?
    func findRespondentExcitatoryConnection(_ targetIdentifier: Identifier) -> Neuron?
    func findRespondentInhibitoryConnection(_ targetIdentifier: Identifier) -> Neuron?
    
    // MARK: *Test Inputs*
    //
    // func receiveExcitation(unconditionedTestStimulus: RespondentTestInput) -> Void
    // func receiveInhibition(unconditionedTestStimulus: RespondentTestInput) -> Void
    
    // MARK: *Test Outputs*
    
    var respondentPresynapticExcitatoryActivation: [Double] { get }
    var respondentPresynapticInhibitoryActivation: [Double] { get }
    
} // end protocol RespondentNeuron



public extension RespondentNeuron {
    
    
    // The respondent weight is fixed at its maximum value: 1.0
    //
    public func respondentConnectionWeightAt(_ stimulationType: Stimulation,
                                             index: Int) -> Double {
        assert(index >= 0)
        
        if stimulationType == Stimulation.Excitatory && index < respondentExcitatoryAxons.count {
            return 1.0
        }
        if stimulationType == Stimulation.Inhibitory && index < respondentInhibitoryAxons.count {
            return 1.0
        }
        return Double(NSNotFound)
    }

    
    public func connectionAttributes(_ forPresynapticUnit: Neuron) -> ConnectionAttributes? {
        if let attributes = respondentConnectionAttributes(forPresynapticUnit) {
            return attributes
        }
        return operantConnectionAttributes(forPresynapticUnit)
    }
    
    public func respondentConnectionAttributes(_ forPresynapticUnit: Neuron) -> ConnectionAttributes? {
        var index = indexOfRespondentExcitatoryPresynaptic(forPresynapticUnit)
        if index != NSNotFound {
            return ConnectionAttributes(
                preSynapticUnit: forPresynapticUnit,
                postSynapticUnit: self,
                learning: Learning.Respondent,
                stimulation: Stimulation.Excitatory,
                index: index
            )
        }
        index = indexOfRespondentInhibitoryPresynaptic(forPresynapticUnit)
        if index != NSNotFound {
            return ConnectionAttributes(
                preSynapticUnit: forPresynapticUnit,
                postSynapticUnit: self,
                learning: Learning.Respondent,
                stimulation: Stimulation.Inhibitory,
                index: index
            )
        }
        return nil
    }
    
    public func indexOfRespondentExcitatoryPresynaptic(_ target: Neuron) -> Int {
        let axons = respondentExcitatoryAxons
        for ix in 0..<axons.count {
            let candidateNeuron = axons[ix].neuron
            if candidateNeuron === target {
                return ix
            }
        }
        return NSNotFound
    }
    public func indexOfRespondentInhibitoryPresynaptic(_ target: Neuron) -> Int {
        let axons = respondentInhibitoryAxons
        for ix in 0..<axons.count {
            let candidateNeuron = axons[ix].neuron
            if candidateNeuron === target {
                return ix
            }
        }
        return NSNotFound
    }
    
} // end extension RespondentNeuron

