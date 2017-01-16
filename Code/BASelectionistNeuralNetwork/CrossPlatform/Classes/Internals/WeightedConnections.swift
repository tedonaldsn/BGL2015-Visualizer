//
//  WeightedConnections.swift
//  BASimulationModel
//
//  Created by Tom Donaldson on 7/9/15.
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




public struct WeightedConnections: CustomDebugStringConvertible {
    
    enum Errors: Error {
        case SumOfWeightsOverflow(sumOfweights: Double)
    }
    
    
    
    // MARK: Data
    
    public var isExcitatory: Bool { return priv_isExcitatory }
    public var isInhibitory: Bool { return !priv_isExcitatory }
    
    public var count: Int { return priv_axons.count }
    public var isEmpty: Bool { return priv_axons.isEmpty }
    
    public var preSynapticAxons: [Axon] { return priv_axons }
    public var preSynapticActivationLevels: [Double] {
        var levels = [Double]()
        for axon in priv_axons {
            levels.append(axon.activationLevel.rawValue)
        }
        return levels
    }

    public var preSynapticExcitation: Scaled0to1Value {
        var excitation: Double = 0.0
        for ix in 0..<count {
            
            // exc(i,j,t) = a(i,t) * w(i,j,t)
            //
            let a_i_t = priv_axons[ix].activationLevel.rawValue
            let w_i_j_t = priv_weights[ix]
            let exc_i_j_t = a_i_t * w_i_j_t
            
            excitation += exc_i_j_t
        }
        return Scaled0to1Value(rawValue: excitation)
    }
    
    

    
    public var weights: [Double] { return priv_weights }
    public var sumOfWeights: Double { return priv_sumOfWeights.rawValue }
    
    
    public var weightsAsNSArray: NSArray {
        get {
            let array = NSMutableArray()
            for weight in priv_weights {
                array.add(weight)
            }
            return array
        }
    }
    public var axonsAsNSArray: NSArray {
        get {
            let array = NSMutableArray()
            for axon in priv_axons {
                array.add(axon)
            }
            return array
        }
    }
    
    
    
    // MARK: Debug
    
    public var debugDescription: String {
        var desc = "\nWeightedConnections (count: \(count)): ["
        
        for ix in 0..<priv_weights.count {
            let activation: Double = priv_axons[ix].activationLevel.rawValue
            let weight = priv_weights[ix]
            if ix > 0 { desc += ", " }
            desc += "(a: \(activation), w: \(weight))"
        }
        desc += "]"
        return desc
    }
    
    
    // MARK: Initialization
    
    public init(isExcitatory: Bool) {
        priv_isExcitatory = isExcitatory
    }
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_axons = "axons"
    public static var key_weights = "weights"
    
    // Assumption here is that an object has, at most, two instances of the
    // WeightedConnections structure, and that one is for excitatory connections
    // and the other is for inhibitory. Because structs do not save an id that is
    // used to qualify dictionary entries in the archive, we fake it using a
    // qualifier that indicates to which of the two sets of connections an
    // archived field belongs.
    //
    public func axonsKey() -> String {
        let qualifier = priv_isExcitatory ? "exc" : "inh"
        return "\(WeightedConnections.key_axons).\(qualifier)"
    }
    public func weightsKey() -> String {
        let qualifier = priv_isExcitatory ? "exc" : "inh"
        return "weighted_\(WeightedConnections.key_weights)_\(qualifier)"
    }
    
    public init?(coder aDecoder: NSCoder, isExcitatory: Bool) {
        priv_isExcitatory = isExcitatory
        
        let nsArrayAxons: NSArray =
        aDecoder.decodeObject(forKey: axonsKey()) as! NSArray
        
        let nsArrayWeights: NSArray =
        aDecoder.decodeObject(forKey: weightsKey()) as! NSArray

        setFromNSArrays(nsArrayAxons, weightList: nsArrayWeights)
    }
    
    public func encodeWithCoder(_ aCoder: NSCoder) {
        aCoder.encode(axonsAsNSArray, forKey: axonsKey())
        aCoder.encode(weightsAsNSArray, forKey: weightsKey())
    }
    
    
    // MARK: Build
    
    public mutating func append(_ afferent: Axon) -> Void {
        
        priv_axons.append(afferent)
        priv_weights.append(0.0)
        
        priv_computeTotalEfficacy()
        
        priv_assertInvariants()
    }
    
    public mutating func setFromNSArrays(_ axonList: NSArray, weightList: NSArray) {
        precondition(axonList.count == weightList.count)
        
        priv_axons = [Axon]()
        for axon in axonList {
            priv_axons.append(axon as! Axon)
        }
        
        priv_weights = [Double]()
        for ix in 0..<weightList.count {
            let weight: Double = (weightList[ix] as AnyObject).doubleValue
            priv_weights.append(weight)
        }
        priv_computeTotalEfficacy()
        
        priv_assertInvariants()
        
    } // end setFromNSArrays
    
    
    // MARK: Access
    
    public func hasPresynapticNeuron(_ targetIdentifier: Identifier) -> Bool {
        return findPresynapticNeuron(targetIdentifier) != nil
    }
    
    public func findPresynapticNeuron(_ targetIdentifier: Identifier) -> Neuron? {
        for axon in priv_axons {
            if let identifier = axon.neuron.identifier {
                if identifier == targetIdentifier {
                    let target = axon.neuron
                    return target
                }
            }
        }
        return nil
    }
    
    
    
    // MARK: Learn
    
    public mutating func setWeights(_ weight: Scaled0to1Value) throws -> Void {
        
        let sumOfNewWeights = weight.rawValue * Double(priv_weights.count)
        if  sumOfNewWeights > 1.0 {
            throw WeightedConnections.Errors.SumOfWeightsOverflow(sumOfweights: sumOfNewWeights)
        }
        
        for ix in 0..<priv_weights.count {
            priv_weights[ix] = weight.rawValue
        }
        
        // In lieu of priv_computeTotalEfficacy()
        //
        priv_sumOfWeights.rawValue = sumOfNewWeights
        
        priv_assertInvariants()
    }
    
    
    public mutating func clearWeights() throws -> Void {
        try setWeights(Scaled0to1Value.minimum)
    }
    
    // Function: learn
    //
    // Arguments:
    //
    //      neuronActivation: Overall net output activation level of the neuron
    //          of which these weighted connections are a component.
    //
    //      discrepancySignal: The feedback signal associated with reinforcement.
    //          The source will depend upon the type of neuron of which these
    //          weighted connections are a part: dopaminergic for motor area 
    //          neurons, or hippocampal for sensory area neurons.
    //
    //      settings: "Free parameters" that govern the "learning rule" 
    //          computations.
    //
    public mutating func learn(_ neuronActivation: Scaled0to1Value,
        discrepancySignal: Double,
        settings: LearningSettings) -> Void {
            
            if count > 0 {
                if discrepancySignal >= settings.weightGainThreshold.rawValue {
                    priv_strengthenConnections(neuronActivation,
                        discrepancySignal: discrepancySignal,
                        settings: settings)
                    
                } else {
                    priv_weakenConnections(neuronActivation, settings: settings)
                    
                }
            }
            
    } // end learn
    
    
    
    
    
    
    // MARK: *Private* Methods
    
    
    
    // “The pi,t and rj,t factors introduce a “rich get richer, poor get poorer”
    // sort of competition among connections for a limited amount of weight on a
    // common target unit.” (Burgos & Leal-García, 2015, p. 70)
    //
    fileprivate mutating func priv_strengthenConnections(_ neuronActivation: Scaled0to1Value,
        discrepancySignal: Double,
        settings: LearningSettings) -> Void {
            
            // a(j,t): neuronActivation
            // d(t): discrepancySignal
            
            // α
            let weightGainRate: Double = priv_isExcitatory
                ? settings.excitationGainRate.rawValue
                : settings.inhibitionGainRate.rawValue
            
            // exc(j,t) for the current type of connection (excitatory or inhibitory)
            
            // N
            let excitation = preSynapticExcitation
            
            // Function r(j,t), a.k.a., "remaining weight"
            //
            let richGetRicher = 1.0 - priv_sumOfWeights.rawValue
            assert(richGetRicher >= 0.0)
            
            let commonFactors = // α * a(j,t) * d(t) * r(j,t)
            weightGainRate * neuronActivation.rawValue * discrepancySignal * richGetRicher
            
            
            for ix in 0..<priv_weights.count {
                
                // Function p(i,t)
                //
                // a(i,t)
                let preSynapticActivation = priv_axons[ix].activationLevel.rawValue // a(i,t)
                //
                // w(i,j,t-1)
                let currentWeight = priv_weights[ix] // w(i,j,t-1)
                //
                // a(i,t) * w(i,j,t-1)
                let preSynapticExcitation = (preSynapticActivation * currentWeight)
                
                // Weird bug: if numerator is zero, then result should be zero.
                // However, there are cases in which a zero numerator is accompanied
                // by a zero denominator. Instead of the result being zero, the
                // system gives precedence to the denominator and produces NaN.
                // So: a manual check for a zero numerator. Then if the numerator
                // is anything other than zero, we have a legitimate divide by
                // zero error.
                //
                // p(i,t)
                let poorGetPoorer: Double =
                preSynapticExcitation == 0.0
                    ? 0.0
                    : preSynapticExcitation / excitation.rawValue
                
                // Δw(i,j,t)
                let weightDelta: Double = commonFactors * poorGetPoorer
                
                // w(i,j,t)
                let newWeight: Double = currentWeight + weightDelta
                
                priv_weights[ix] = newWeight
            }
            
            priv_computeTotalEfficacy()
            
            priv_assertInvariants()
            
    } // end priv_strengthenConnections
    
    
    
    
    // In Burgos & García-Leal 2015: Δw(i,j,t) = -βw(i,j,t-1)a(i,t)a(j,t)
    //
    // Refactored to compute as much as posible outside loop:
    //
    //      Before loop: commonFactors = -βa(j,t)
    //
    //      Inside loop: Δw(i,j,t) = commonFactors * w(i,j,t-1)a(i,t)
    //
    fileprivate mutating func priv_weakenConnections(_ neuronActivation: Scaled0to1Value,
        settings: LearningSettings) -> Void {
            
            // β
            let weightLossRate = priv_isExcitatory
                ? settings.excitationLossRate.rawValue
                : settings.inhibitionLossRate.rawValue
            
            // -βa(j,t)
            let commonFactors = -weightLossRate * neuronActivation.rawValue
            
            for ix in 0..<priv_weights.count {
                
                // w(i,j,t-1)
                let currentWeight = priv_weights[ix]
                
                // a(i,t)
                let preSynapticActivation = priv_axons[ix].activationLevel.rawValue
                
                // w(i,j,t-1)a(i,t)
                let preSynapticExcitation = currentWeight * preSynapticActivation
                
                // commonFactors * w(i,j,t-1)a(i,t)
                let weightDelta = commonFactors * preSynapticExcitation
                
                let newWeight = currentWeight + weightDelta
                
                assert(Scaled0to1Value.isWithinLimits(newWeight))
                priv_weights[ix] = newWeight
            }
            
            priv_computeTotalEfficacy()
            
            priv_assertInvariants()
            
    } // end priv_weakenConnections
    
    


    
    

    
    // MARK: Invariants
    
    // Assertions are optimized out of release code, as will be the then
    // empty method priv_assertInvariants()
    //
    fileprivate func priv_assertInvariants() -> Void {
        assert(priv_axons.count == priv_weights.count)
        assert(Scaled0to1Value.isWithinLimits(priv_weights))
    }
    
    
    
    
    
    
    // MARK: *Private*
    
    fileprivate var priv_isExcitatory: Bool = true
    fileprivate var priv_axons = [Axon]()
    fileprivate var priv_weights = [Double]()
    
    
    fileprivate mutating func priv_computeTotalEfficacy() -> Void {
        priv_sumOfWeights.rawValue = priv_weights.reduce(0.0) {
            (sum: Double, weight: Double) in sum + weight
        }
    }
    fileprivate var priv_sumOfWeights = Scaled0to1Value()
    
    
    
} // end struct WeightedConnections

