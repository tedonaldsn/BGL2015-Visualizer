//
//  BGL2015Subject.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 10/19/15.
//  Copyright © 2015 Tom Donaldson. All rights reserved.
//
//  One subject network for Burgos & García-Leal 2015. The article calls for
//  nine of these (p 66).
//
//  All neurons are named as in Figure 1, p 65. 
//
//  Neurons are saved as public data members for ease of manipulation and for testing.





import BASimulationFoundation



public final class BGL2015Subject {
    
    public var subjectIdentifier: String { return network.identifier!.asString }
    public var network: Network
    
    // MARK: Boolean Inputs
    
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
    

    
    // MARK: Initialization
    
    public init(subjectIdentifier: Identifier) {
        
        // Create
        
        let network = BurgosGarciaLeal2015.create(subjectIdentifier)
        
        xSensor = network.findBinarySensor(Identifier(idString: "X"))!
        ySensor = network.findBinarySensor(Identifier(idString: "Y"))!
        srSensor = network.findBinarySensor(Identifier(idString: "Sr"))!
        
        sPrime1 = network.findSensoryInputNeuron(Identifier(idString: "S_Prime_1"))!
        sPrime2 = network.findSensoryInputNeuron(Identifier(idString: "S_Prime_2"))!
        sStar = network.findPavlovianSensoryInputNeuron(Identifier(idString: "S_Star"))!
        
        sPrimePrime1 = network.findSensoryInterneuron(Identifier(idString: "S_Prime_Prime_1"))!
        sPrimePrime2 = network.findSensoryInterneuron(Identifier(idString: "S_Prime_Prime_2"))!
        
        mPrimePrime1 = network.findMotorInterneuron(Identifier(idString: "M_Prime_Prime_1"))!
        mPrimePrime2 = network.findMotorInterneuron(Identifier(idString: "M_Prime_Prime_2"))!
        
        mPrime1 = network.findMotorOutputNeuron(Identifier(idString: "M_Prime_1"))!
        mPrime2 = network.findMotorOutputNeuron(Identifier(idString: "M_Prime_2"))!
        
        h1 = network.findHippocampalNeuron(Identifier(idString: "h1"))!
        h2 = network.findHippocampalNeuron(Identifier(idString: "h2"))!
        
        d = network.findDopaminergicNeuron(Identifier(idString: "d"))!
        
        r1Effector = network.findBinaryEffector(Identifier(idString: "r1"))!
        r2Effector = network.findBinaryEffector(Identifier(idString: "r2"))!
        
        self.network = network
        
    } // end init
    
    
    
} // end class BGL2015Subject







