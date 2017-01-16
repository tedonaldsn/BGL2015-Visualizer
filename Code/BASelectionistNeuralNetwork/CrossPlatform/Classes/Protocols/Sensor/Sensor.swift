//
//  Sensor.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 3/3/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import BASimulationFoundation


// Sensor
//
// Sensors are the input transducers for the neural network. Internally the 
// activation level signals among neurons are scaled values in the 0...1 range
// (i.e., class Scaled0to1Value). Very few "real world" stimuli produce values
// within that range. It is the job of sensors to convert "real world" values
// to the scaled values that the neural network uses as its primary signal.
//
// The scaled value is sent to a sensory input neuron via an attribute:
//
//      sendTo.inputActivationLevel
//
// You may set the input activation level at any time, but note that this 
// interface is NOT thread safe.
//
// The prepareActivation() method is your notification that the network is about to perform
// update(), which will use your input. If your sensor actively fetches data
// from elsewhere, your implementation of prepareActivation() is the logical place to do it.
// However, avoid all but the shortest, lowest computation, processing to
// get and convert your data.
//
public protocol Sensor: Neuron {
    
    // MARK: Initialization
    
    // Require initialization. If you will want to look up the sensor
    // using the Network's findNode() interface, provide an identifier. If
    // not, then leave it nil to save space (most nodes in the neural network
    // are unnamed).
    //
    init(network: Network, identifier: Identifier?)
    

    // MARK: Activation
    
    // Read the input and normalize it to the 0-1 activation level range.
    // At this point it is held internally, and will not be passed on
    // downstream via the axon until commitActivation() is called.
    //
    func prepareActivation() -> Void
    
    // Send the activation level computed by prepareActivation() downstream via the 
    // axon.
    //
    func commitActivation() -> Void
    
    // Resets activation to the baseline value of the sensor, whatever that
    // might be so long as it is in the range 0-1.
    //
    // Because a sensor represents raw input that has ONLY been normalized to 
    // a range of 0-1, we reset to zero instead of logicstic(zero).
    //
    func resetActivation() -> Void

    
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
    
} // end protocol Sensor



public extension Sensor {
}


