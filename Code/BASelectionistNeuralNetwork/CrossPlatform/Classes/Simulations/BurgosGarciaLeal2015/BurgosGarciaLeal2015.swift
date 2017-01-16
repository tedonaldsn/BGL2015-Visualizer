//
//  BurgosGarciaLeal2015.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 4/6/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import BASimulationFoundation


// Virtual constructors for network described in this article:
//
//      Burgos, José E., García-Leal, Óscar (2015). Autoshaped
//      choice in artificial neural networks: Implications for behavioral
//      economics and neuroeconomics. Behavioural Processes, 114, 63-71
//
//
final public class BurgosGarciaLeal2015 {
    
    // DEFAULTS
    //
    // See below for changing from default values.
    //
    // See first paragraph under heading "3. A Simulation" on page 66 of article.
    //
    // All units that have weights: set to base connection weight initially:
    //
    public static let defaultBaseConnectionWeight = Scaled0to1Value(rawValue: 0.01)
    //
    // Then the sensory neuron connection weights are set to this value:
    //
    public static let defaultSensoryConnectionWeight = Scaled0to1Value(rawValue: 0.2)
    
    
    // Set custom initial weights for next network create()'ed.
    //
    public class func initialBaseConnectionWeight() -> Scaled0to1Value {
        return priv_baseWeight
    }
    public class func setInitialBaseConnectionWeight(initialBaseWeight: Scaled0to1Value) -> Void {
        priv_baseWeight = initialBaseWeight
    }
    
    public class func initialSensoryConnectionWeight() -> Scaled0to1Value {
        return priv_sensoryWeight
    }
    public class func setInitialSensoryConnectionWeight(initialSensoryWeight: Scaled0to1Value) -> Void {
        priv_sensoryWeight = initialSensoryWeight
    }
    
    
    
    private static var priv_baseWeight = BurgosGarciaLeal2015.defaultBaseConnectionWeight
    private static var priv_sensoryWeight = BurgosGarciaLeal2015.defaultSensoryConnectionWeight
    
    
    public class func create(identifierString: String) -> Network {
        return BurgosGarciaLeal2015.create(Identifier(idString: identifierString))
    }
    
    public class func create(identifier: Identifier) -> Network {
        
        // Pristine network to be populated
        //
        let network = Network(identifier: identifier)
        
        // Hold nodes temporarily so that we can interconnect them, below.
        //
        let xSensor =
            network.appendSensor(SimpleBinarySensor(network: network, idString: "X")) as! BinarySensor
        let ySensor =
            network.appendSensor(SimpleBinarySensor(network: network, idString: "Y")) as! BinarySensor
        let srSensor =
            network.appendSensor(SimpleBinarySensor(network: network, idString: "Sr")) as! BinarySensor
        
        let sPrime1 = network.createSensoryInputNeuron("S_Prime_1")
        let sPrime2 = network.createSensoryInputNeuron("S_Prime_2")
        let sStar = network.createPavlovianSensoryInputNeuron("S_Star")
        
        let sPrimePrime1 = network.createSensoryInterneuron("S_Prime_Prime_1")
        let sPrimePrime2 = network.createSensoryInterneuron("S_Prime_Prime_2")
        
        let mPrimePrime1 = network.createMotorInterneuron("M_Prime_Prime_1")
        let mPrimePrime2 = network.createMotorInterneuron("M_Prime_Prime_2")
        
        let mPrime1 = network.createMotorOutputNeuron("M_Prime_1")
        let mPrime2 = network.createMotorOutputNeuron("M_Prime_2")
        
        let h1 = network.createHippocampalNeuron("h1")
        let h2 = network.createHippocampalNeuron("h2")
        
        let d = network.createDopaminergicNeuron("d")
        
        let r1Effector =
            network.appendEffector(SimpleBinaryEffector(network: network, idString: "r1")) as! BinaryEffector
        let r2Effector =
            network.appendEffector(SimpleBinaryEffector(network: network, idString: "r2")) as! BinaryEffector
        
        
        // Setup Node Info
        
        var info = NodeInfo(identifier: xSensor.identifier!)
        info.name = "X"
        info.title = "Discrete exterioceptive cue associated with one trial type."
        info.explanation = "Cue presented on a random 50% of trials. Associated with Sr on 50% of those trials in which it is presented."
        network.setInfoForNode(info)
        
        info = NodeInfo(identifier: ySensor.identifier!)
        info.name = "Y"
        info.title = "Discrete exterioceptive cue associated with one trial type."
        info.explanation = "Cue presented on a random 50% of trials. Associated with Sr on all trials in which it is presented."
        network.setInfoForNode(info)
        
        info = NodeInfo(identifier: srSensor.identifier!)
        info.name = "Sr"
        info.title = "Reinforcing stimulus: A biologically significant reward (e.g.,food)."
        info.explanation = "Feeds directly into the dopaminergic unit via its sensory input neuron."
        network.setInfoForNode(info)
        

        // Interconnect
        
        xSensor.sendTo = sPrime1
        ySensor.sendTo = sPrime2
        srSensor.sendTo = sStar
        
        let pavSr = sStar as! PavlovianInputNeuron
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
        
        // Start with all neurons at the "0.01 for all the rest"
        try! network.setConnectionWeights(priv_baseWeight)
        
        // Set connection weight to 0.2 for S_Prime_-S": first layer in first area of sensory association region.
        try! network.sensoryAssociationRegion[0][0].setConnectionWeights(priv_sensoryWeight)
        
        // and for the S"-H: all connections to the hippocampus are from S"
        try! network.hippocampus.setConnectionWeights(priv_sensoryWeight)
        
        // Use the updater that implements the BurgosGarciaLeal2015 randomized 
        // update with immediate propogation of new activation levels.
        //
        // Note that this overrides the built-in updater which computes all
        // activation levels BEFORE propogating the activation levels, done
        // in "natural" order, versus randomized order.
        //
        network.updater = RandomizedContinuousPropogationUpdater()
        
        return network
        
    } // end class func BurgosGarciaLeal2015.create()
    
    
    
    
} // end class BurgosGarciaLeal2015


