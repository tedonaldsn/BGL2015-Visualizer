//
//  ComputationalNode.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/21/15.
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



import BASimulationFoundation


// ComputationalNode: Node capable of learning, either itself or via other
// computational nodes that it contains.
//
public protocol ComputationalNode: Node {
    
    var environment: ComputationalNode { get }
    
    var activationSettings: ActivationSettings { get set }
    var learningSettings: LearningSettings { get set }
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    //
    // init?(coder aDecoder: NSCoder)
    // func encodeWithCoder(aCoder: NSCoder)
    
} // end protocol ComputationalNode







