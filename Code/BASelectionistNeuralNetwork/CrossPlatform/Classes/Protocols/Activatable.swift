//
//  Activatable.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 9/5/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//


import Foundation
import BASimulationFoundation


public protocol Activatable: AnyObject, NSCoding {
    
    // The main output: the neural unit's activation level. The 
    // activationLevel is the result of calling prepareActivation() followed 
    // at some point by commitActivation().
    //
    var activationLevel: Scaled0to1Value { get }
    
    
    // MARK: Activation
    //
    // Activation is the usually the main output of an activatable neural unit.
    // The exceptions are the dopaminergic and hippocampal feedback units.
    // 
    // Activation is performed in two steps: computation of the new activation
    // level via the prepareActivation() call, then commitment of the new level
    // via the commitActivation() call.
    //
    // This activate-commit cycle is modelled on database commit processing, 
    // and serves a similar isolating and "response unitizing" function (but
    // includes NO type of rollback). The activate-commit cycle supports both
    // the original Donahoe, Palmer, and Burgos model, and a concurrent model.
    // 
    // The original model: new activation levels are available as inputs on
    // downstream neural units as soon as they are computed. This raises the
    // possibility of order artifacts. The solution was to compute activations
    // serially on randomized orderings of neural units. This is implemented
    // here by calling prepareActivation() immediately followed by 
    // commitActivation() before proceeding to the next neural unit in the 
    // random sequence.
    //
    // The supported concurrency model: blocks of activatables can be
    // prepareActivation()'d simultaneously on different threads (e.g., in 
    // concurrent queues). After ALL activations are recomputed, call
    // commitActivation() on all activatables. Once activations have been
    // propogated on all  activatables, the activations may be used (e.g., in
    // "learning": adjusting connection weights).
    //
    // Note that in the concurrent model order effects are NOT a possibility
    // because all freshly computed activation levels are available to all 
    // downstream neural units simultaneously. It does, however, delay usage
    // of a randomize 50% of activation levels by one time step compared to the
    // original randomized-immediate-usage model.
    
    
    
    // Recompute activation level. The new activation level is not visible
    // on the activationLevel output attribute until commitActivation()
    // is called.
    //
    func prepareActivation() -> Void
    
    // Make the last-computed activation level visible via the activationLevel 
    // attribute of this activatable. This is the commit phase of the 
    // activate-commit cycle. After commitActivation() has returned, actions
    // that use the output activationLevel may be performed.
    //
    // Note that this method should do nothing more than copy the last
    // computed activation level to the activationLevel attribute.
    //
    func commitActivation() -> Void
    
    // Resets activation to its baseline value, whatever that is for the 
    // particular type of activatable. For most neural units this is
    // is the value output by the logistic function when passed 0.0 as the 
    // excitation. But it may simply be 0.0.
    //
    // Note that as for prepareActivation(), the new value is not visible on
    // the output activationLevel attribute until commitActivation() is called.
    //
    func resetActivation() -> Void
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    //
    // @objc init?(coder aDecoder: NSCoder)
    // @objc func encodeWithCoder(aCoder: NSCoder)
    
} // end protocol Activatable
