//
//  Step.swift
//  
//
//  Created by Tom Donaldson on 4/29/16.
//
//

import Foundation
import CoreData
import BASimulationFoundation
import BASelectionistNeuralNetwork



open class Step: NSManagedObject {
    open static let entityName = "Step"
    
    open var neuralNetwork: BASelectionistNeuralNetwork.Network? {
        
        if priv_neuralNetwork == nil {
            if let netData = networkState {
                priv_neuralNetwork = NSKeyedUnarchiver.unarchiveObject(with: netData as Data) as? BASelectionistNeuralNetwork.Network
            }
        }
        return priv_neuralNetwork
    }
    
    fileprivate var priv_neuralNetwork: BASelectionistNeuralNetwork.Network? = nil
} // end class Step
