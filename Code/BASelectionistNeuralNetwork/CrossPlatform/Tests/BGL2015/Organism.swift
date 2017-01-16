//
//  Organism.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 4/6/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import BASimulationFoundation
import BASelectionistNeuralNetwork


// An instance of Organism is an experimental subject. It is fundamentally an 
// instance of the selectionist neural network described in this article:
//
//      Burgos, José E., García-Leal, Óscar (2015). Autoshaped
//      choice in artificial neural networks: Implications for behavioral
//      economics and neuroeconomics. Behavioural Processes, 114, 63-71
//
// The Organism init() constructor creates the required nodes and
// interconnects them as shown in Figure 1 (page 65) of the article. Unlike the
// network described in the article, the stimulus and response nodes are
// represented by "convenience" classes here. The X, Y, and Sr stimuli are
// represented by sensor objects that take an on/off signal and output activation
// levels to the sensory input neuron groups. Similarly, the effector instances
// take activation levels from the motor output neuron groups and output 
// on/off signals to indicate whether the R1 and R2 responses occurred on a
// The activation levels used on input/output are as described in the article.
//
// All nodes (e.g., neurons) that are labelled in Figure 1, page 65, of the
// article are so named in the neural network via node info keyed by the
// internal identifiers of those same nodes (see node creation and node info 
// creation, below). The human readable labels/names follow different rules
// from the identifiers used throughout BASimulation code.
//
//
final public class Organism {
    
    // MARK: Class Data

    // See first paragraph under heading "3. A Simulation" on page 66 of article.
    //
    // All units that have weights: set to base connection weight initially:
    //
    public static let baseConnectionWeight = Scaled0to1Value(rawValue: 0.01)
    //
    // Then the sensory neuron connection weights are set to this value:
    //
    public static let sensoryConnectionWeight = Scaled0to1Value(rawValue: 0.2)
    
 
    // MARK: Data
    
    public var brain: Network
    
    public var identifier: Identifier { return brain.identifier! }
    
    // MARK: Boolean Inputs
    
    public var isLearningEnabled: Bool {
        get { return brain.isLearningEnabled }
        set { brain.isLearningEnabled = newValue }
    }
    
    public var x: Bool {
        get { return xSensor.isOn }
        set { xSensor.isOn = newValue }
    }
    public var y: Bool {
        get { return ySensor.isOn }
        set { ySensor.isOn = newValue }
    }
    public var sr: Bool {
        get { return srSensor.isOn }
        set { srSensor.isOn = newValue }
    }
    
    public unowned var xSensor: BinarySensor
    public unowned var ySensor: BinarySensor
    public unowned var srSensor: BinarySensor
    
    // MARK: Boolean Outputs
    
    public var r1: Bool { return r1Effector.isOn }
    public var r2: Bool { return r1Effector.isOn }
    
    public unowned var r1Effector: BinaryEffector
    public unowned var r2Effector: BinaryEffector
    
    // MARK: Sensory Neurons
    
    public unowned var sPrime1: SensoryInputNeuron
    public unowned var sPrime2: SensoryInputNeuron
    public unowned var sStar: SensoryInputNeuron
    
    public unowned var sPrimePrime1: SensoryInterneuron
    public unowned var sPrimePrime2: SensoryInterneuron
    
    
    // MARK: Motor Neurons
    
    public unowned var mPrimePrime1: MotorInterneuron
    public unowned var mPrimePrime2: MotorInterneuron
    
    public unowned var mPrime1: MotorOutputNeuron
    public unowned var mPrime2: MotorOutputNeuron
    
    
    // MARK: Discrepancy Neurons
    
    public unowned var d: DopaminergicNeuron
    
    public unowned var h1: HippocampalNeuron
    public unowned var h2: HippocampalNeuron
    
    
    
    public init(identifier: Identifier) {
        
        // Pristine selectionist neural network to be populated
        //
        brain = Network(identifier: identifier)
        
        // Hold nodes temporarily so that we can interconnect them, below.
        //
        xSensor =
            brain.appendSensor(SimpleBinarySensor(network: brain, idString: "X")) as! BinarySensor
        ySensor =
            brain.appendSensor(SimpleBinarySensor(network: brain, idString: "Y")) as! BinarySensor
        srSensor =
            brain.appendSensor(SimpleBinarySensor(network: brain, idString: "Sr")) as! BinarySensor
        
        sPrime1 = brain.createSensoryInputNeuron("S_Prime_1")
        sPrime2 = brain.createSensoryInputNeuron("S_Prime_2")
        sStar = brain.createRespondentSensoryInputNeuron("S_Star")
        
        sPrimePrime1 = brain.createSensoryInterneuron("S_Prime_Prime_1")
        sPrimePrime2 = brain.createSensoryInterneuron("S_Prime_Prime_2")
        
        mPrimePrime1 = brain.createMotorInterneuron("M_Prime_Prime_1")
        mPrimePrime2 = brain.createMotorInterneuron("M_Prime_Prime_2")
        
        mPrime1 = brain.createMotorOutputNeuron("M_Prime_1")
        mPrime2 = brain.createMotorOutputNeuron("M_Prime_2")
        
        h1 = brain.createHippocampalNeuron("h1")
        h2 = brain.createHippocampalNeuron("h2")
        
        d = brain.createDopaminergicNeuron("d")
        
        r1Effector =
            brain.appendEffector(SimpleBinaryEffector(network: brain, idString: "r1")) as! BinaryEffector
        r2Effector =
            brain.appendEffector(SimpleBinaryEffector(network: brain, idString: "r2")) as! BinaryEffector
        
        
        // Setup Node Info
        // PUT info in separate database.
        /*
        var info = NodeInfo(identifier: xSensor.identifier!)
        info.name = "X"
        info.title = "Discrete exterioceptive cue associated with one trial type."
        info.explanation = "Cue presented on a random 50% of trials. Associated with Sr on 50% of those trials in which it is presented."
        brain.setInfoForNode(info)
        
        info = NodeInfo(identifier: ySensor.identifier!)
        info.name = "Y"
        info.title = "Discrete exterioceptive cue associated with one trial type."
        info.explanation = "Cue presented on a random 50% of trials. Associated with Sr on all trials in which it is presented."
        brain.setInfoForNode(info)
        
        info = NodeInfo(identifier: srSensor.identifier!)
        info.name = "Sr"
        info.title = "Reinforcing stimulus: A biologically significant reward (e.g.,food)."
        info.explanation = "Feeds directly into the dopaminergic unit via its sensory input neuron."
        brain.setInfoForNode(info)
        */

        // Interconnect
        
        sPrime1.sensor = xSensor
        sPrime2.sensor = ySensor
        sStar.sensor = srSensor
        
        let pavSr = sStar as! RespondentInputNeuron
        pavSr.sendExcitation(d)
        
        sPrime1.sendExcitation(sPrimePrime1)
        
        sPrimePrime1.sendExcitation(h1)
        sPrimePrime1.sendExcitation(mPrimePrime1)
        
        mPrimePrime1.sendExcitation(d)
        mPrimePrime1.sendExcitation(mPrime1)
        
        sPrime2.sendExcitation(sPrimePrime2)
        
        sPrimePrime2.sendExcitation(h2)
        sPrimePrime2.sendExcitation(mPrimePrime2)
        
        mPrimePrime2.sendExcitation(d)
        mPrimePrime2.sendExcitation(mPrime2)
        
        r1Effector.receiveFrom = mPrime1
        r2Effector.receiveFrom = mPrime2
        
        
        // Set initial weights
        //
        // All networks were naive in that their initial connection weights
        // were low (0.2 for the S’–S′′ and S′′–H connections, 0.01 for the rest;
        // see Fig. 1) (Burgos & García-Leal, 2015, p 66)
        //
        ////////////////
        
        let baseWeight = Organism.baseConnectionWeight
        let sensoryWeight = Organism.sensoryConnectionWeight
        
        // Start with all neurons at the "0.01 for all the rest"
        try! brain.setConnectionWeights(baseWeight)
        
        // Set connection weight to 0.2 for S_Prime_-S": first layer in first area of sensory association region.
        try! brain.sensoryAssociationRegion[0][0].setConnectionWeights(sensoryWeight)
        
        // and for the S"-H: all connections to the hippocampus are from S"
        try! brain.hippocampus.setConnectionWeights(sensoryWeight)
        
        // Use the updater that implements the Organism randomized 
        // update with immediate propogation of new activation levels.
        //
        // Note that this overrides the built-in updater which computes all
        // activation levels BEFORE propogating the activation levels, done
        // in "natural" order, versus randomized order.
        //
        brain.updater = RandomizedContinuousPropogationUpdater()
        
    } // end class func Organism.create()
    
    
    
    
} // end class Organism


