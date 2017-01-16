//
//  Effector.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 3/3/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import BASimulationFoundation



// Effector 
//
// Noun: person or thing that "brings about", "implements", 
//       or "effects" an action. Something that is effective, versus
//       merely influential, in a process.
//
// Effectors are the output transducers for the neural network. 
//
// Internally the activation level signals among neurons are scaled values
// in the 0...1 range (i.e., class Scaled0to1Value). Outputs "in the real
// world" are likely to be some other type of data, or an action. It is the job
// of the Effector to translate from the internal scaled activation level
// to whatever is necessary to effect the "motor" action to be controlled by the
// motor neuron.
//
// prepareActivation() latches the activation level from the motor output 
// neuron. Internally this value remains the same even if the activation level
// of the motor neuron changes.
//
// commitActivation() pushes the previously motor neuron activation level to the
// activationLevel attribute of the effector. It is at this point that an effector
// tied to an external system would be operated (e.g., step a stepper motor).
//
// resetActivation() returns the internal activation level to whatever its base
// level is. Note that this base level will not get pushed to the activationLevel
// attribute, and therefore, external systems, until commitActivation() is called.
//
public protocol Effector: ActivatableNode {

    // The motor output neuron from which to fetch activation when the
    // prepareActivation() method is called.
    //
    var receiveFrom: MotorOutputNeuron { get set }
    
    // Require initialization. If you will want to look up the effector
    // using the Network's findNode() interface, provide an identifier. If
    // not, then leave it nil to save space (most nodes in the neural network
    // are unnamed).
    //
    init(network: Network, identifier: Identifier?)
    
    
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
    
} // end protocol Effector




