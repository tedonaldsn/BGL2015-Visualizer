//
//  NetworkUpdater.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 3/4/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation
import BASimulationFoundation



// NetworkUpdater defines the interface used by the Network to recompute
// neuron activations and connection weights.
//
// Some parts of the network are updated by the Network object itself,
// specifically, the discrepancy areas (hippocampus and dopaminergic areas).
//
// The updater is permitted only to update "operant neurons". These are the
// non-discrepancy signal neurons that can "learn" via feedback from the
// discrepancy signals.
//
// That is, the updater object is only responsible for the neurons of the areas
// listed below. These are the same neurons that are returned by the Network's
// getOperantNeurons() method, which returns them in the order listed below.
//
//      SensoryAssociationRegion
//      MotorAssociationRegion
//      MotorOutputRegion
//
// The updater update steps should not be called directly. They will be called
// by the neural net at the appropriate times during update, and with the
// appropriate setup. Calling update steps directly will produce undefined
// results.
//
@objc public protocol NetworkUpdater: NSCoding {
    
    // MARK: Data
    
    weak var network: Network? { get set }
    
    
    // MARK: Standard Update Steps
    
    // operantNeuronsActivate()
    //
    // THE ONLY REQUIRED METHOD other than those supporting NSCoding.
    //
    // Recompute activation on all neurons that would be returned by
    // the Network's getOperantNeurons(). This does not include neurons
    // of the discrepancy signal areas (hippocampus and dopamineric), which
    // are handled by the Network update() at the appropriate times.
    //
    // If your updater propogates activations from the preSynaptic units to the
    // postSynaptic units during activation, do not implement the optional
    // operantNeuronPropogateActivation() method.
    //
    // Called by Network's update()
    //
    func operantNeuronsActivate() -> Void
    
    // MARK: NSCoding
    //
    // Used for archiving and unarchiving the neural network. Used in iOS
    // when the app moves between foreground and background. May also be
    // used to record network state as data.
    //
    // NSCoding requires that the object inherit from NSObject
    //
    // init?(coder aDecoder: NSCoder)
    // func encodeWithCoder(aCoder: NSCoder)
    
} // end protocol NetworkUpdater


