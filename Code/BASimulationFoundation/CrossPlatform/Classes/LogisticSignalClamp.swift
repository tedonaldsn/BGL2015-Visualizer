//
//  LogisticSignalClamp.swift
//  BASimulationFoundation
//
//  Created by Tom Donaldson on 11/2/15.
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

// This is the logistic function of Burgos & García-Leal (2015) and preceeding
// publications going back to Donahoe, Palmer, and Burgos (1993).
//
//  From Donahoe, Palmer, and Burgos (1993, p 39, equation 4)
//      L(𝝌) = 1/ (1 + exp[(-𝝌+μ)/σ])
//
//  From Burgos & García-Leal (2015, p 69)
//      L(𝝌) = 1 / (1 + e((-𝝌+μ)/σ)
//
// The Donahoe et al version uses exp(), which happens to be the standard Unix
// function call for raising e (i.e., base-e) to a power.
//
// Also see: https://en.wikipedia.org/wiki/Logistic_function#Neural_networks
//
// It is used in activation equations to generate neuron activation levels from
// raw preSynaptic excitation. The input is the dot product of preSynaptic
// connection activations and the corresponding connection weights (efficacies)
// of each connection. Note that the raw input will ALWAYS be in the range of
// 0...1 because the incoming activations are limited to that range and the
// total efficacy (sum of weights) of the postSynaptic neuron is also limited
// to the range of 0...1.
//
// Its purpose appears to be to attenuate changes at the extremes of the
// 0...1 range and amplify changes around the mean of the range. Thus, changes
// in raw excitation near the boundaries (0 or 1) move the output signal
// much less than changes in the center of the range do. Thus the extremes
// of raw excitation produce relatively stable activation outputs that never
// reach the limits, while the central values are more dynamic.
//
// Why a struct instead of just a function? Expectation: will add methods for
// testing and debugging. Plus, tidies up the namespace.


public struct LogisticSignalClamp {
    
    // In equations: 𝜇
    //
    // Mean of the accepted range of 0...1
    //
    public static var mean: Double = 0.5

    // In equations: 𝜎
    //
    public static var standardDeviation: Double = 0.1
    
    
    
    
    public static func scale(_ preSynapticExcitation: Scaled0to1Value) -> Scaled0to1Value {
        
        let quasiZScore =
        (-preSynapticExcitation.rawValue + LogisticSignalClamp.mean)
            / LogisticSignalClamp.standardDeviation
        
        let logOfZ = exp(quasiZScore)
        
        let scaledExcitation = 1.0 / (1.0 + logOfZ)
        
        return Scaled0to1Value(rawValue: scaledExcitation)
    }
    
} // end struct LogisticSignalClamp

