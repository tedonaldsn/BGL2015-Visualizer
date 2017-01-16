//
//  RandomizedContinuousPropogationUpdater.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 3/4/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation
import BASimulationFoundation
import GameplayKit // For random distribution


// RandomizedContinuousPropogationUpdater
//
// Implementation of the original Donahoe, Palmer, and Burgos, updater algorithm.
//
// The original Donahoe, Palmer, Burgos algorithm uses continuous immediate
// propogation as activations are recomputed neuron by neuron. This means
// that the computation of activations of neurons earlier in the process
// will affect activation levels of neurons later in the process. The
// algorithm overcomes order bias by randomizing the neuron order on each
// update.
//
// Note that the default update process built-in to the Network overcomes
// order bias in a different way: by splitting the activation calculation and 
// the propogation into two steps. It completes all activation then does all
// propogation. Thus there is no need to fetch a list of neurons to be updated,
// nor to randomize the list on each update.
//
// TO BE DONE: Get the same results with both algorithms?
//
final public class RandomizedContinuousPropogationUpdater: NSObject, NetworkUpdater {
    
    // MARK: Data
    
    public weak var network: Network? = nil {
        didSet { priv_operantNeurons.removeAll() }
    }
    
    
    // MARK: Initialization
    
    public override init() {
        super.init()
    }
    
    
    
    // MARK: Standard Update Steps
    
    public func operantNeuronsActivate() -> Void {
        precondition(network != nil)
        
        if priv_operantNeurons.isEmpty {
            network!.getOperantNeurons(&priv_operantNeurons)
            priv_randomizer =
                GKRandomDistribution(randomSource: GKMersenneTwisterRandomSource(),
                                     lowestValue: 0,
                                     highestValue: priv_operantNeurons.count - 1)
        }
        priv_operantNeurons.randomizeInPlace(priv_randomizer!)
        
        for neuron in priv_operantNeurons {
            neuron.prepareActivation()
            neuron.commitActivation()
        }
    }
    
    // MARK: NSCoding
    //
    // Used for archiving and unarchiving the neural network. Used in iOS
    // when the app moves between foreground and background. May also be
    // used to record network state as data.
    //
    // NSCoding requires that the object inherit from NSObject
    //
    
    public static var key_network = "network"
    
    @objc public required init?(coder aDecoder: NSCoder) {
        network = aDecoder.decodeObject(forKey: RandomizedContinuousPropogationUpdater.key_network) as? Network
        super.init()
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(network, forKey: RandomizedContinuousPropogationUpdater.key_network)
    }
    
    
    // MARK: *Private*
    
    fileprivate var priv_operantNeurons = [OperantNeuron]()
    fileprivate var priv_randomizer: GKRandomDistribution? = nil
    
} // end class RandomizedContinuousPropogationUpdater


