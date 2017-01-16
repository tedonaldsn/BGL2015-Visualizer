//
//  SessionStepData.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 5/27/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//


import Foundation
import CoreData
import BASimulationFoundation




// Data for one step. To be collected during experimental session, then
// saved to Core Data at the end. The Core Data managed object context will
// run in its own queue.
//
// Why? Do not want to run either the experimental session or the data collection
// on the user interface queue. But to run Core Data otherwise, it has to be
// run in its own private queue which the experimental session cannot share.
//
open class SessionStepData: NSObject, NSCoding {
    
    // MARK: Data
    
    open var trialNumber: Int = 0
    open var trialStepNumber: Int = 0
    
    open var isLearning: Bool = false
    
    open var isXOn: Bool = false
    open var isYOn: Bool = false
    open var isSrOn: Bool = false
    
    open var s1m1Weight: Double = 0.0
    open var s2m2Weight: Double = 0.0
    
    open var m1outActivation: Double = 0.0
    open var m2outActivation: Double = 0.0
    
    // MARK: Predicates
    
    open var isTrainingTrial: Bool { return TrialsLooper.isTrainingTrial(trialNumber) }
    open var isChoiceTrial: Bool { return TrialsLooper.isChoiceTrial(trialNumber) }
    
    open var isXTrainingTrial: Bool { return isTrainingTrial && isXOn && !isYOn }
    open var isYTrainingTrail: Bool { return isTrainingTrial && isYOn && !isXOn }
    
    open var isIntertrialIntervalStep: Bool { return TrialsLooper.isIntertrialIntervalStep(trialStepNumber) }
    
    open var isFirstStepOfTrialProper: Bool { return TrialsLooper.isFirstStepOfTrialProper(trialStepNumber) }
    open var isNonSrStep: Bool { return TrialsLooper.isNonSrStep(trialStepNumber) }
    open var isSrStep: Bool { return TrialsLooper.isSrStep(trialStepNumber) }
    open var isFinalStepOfTrialProoper: Bool { return TrialsLooper.isFinalStepOfTrialProoper(trialStepNumber) }
    open var isFinalSrStepOfTrial: Bool { return TrialsLooper.isFinalSrStepOfTrial(trialStepNumber) }
    
    // MARK: Initialization
    
    public override init() {
        super.init()
    }
    
    // MARK: NSCoding
    
    public struct ArchiveKey {
        public static let trialNumber = "trialNumber"
        public static let trialStepNumber = "trialStepNumber"
        
        public static let isLearning = "isLearning"
        
        public static let isXOn = "isXOn"
        public static let isYOn = "isYOn"
        public static let isSrOn = "isSrOn"
        
        public static let s1m1Weight = "s1m1Weight"
        public static let s2m2Weight = "s2m2Weight"
        
        public static let m1outActivation = "m1outActivation"
        public static let m2outActivation = "m2outActivation"
    }

    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init()
        
        trialNumber = aDecoder.decodeInteger(forKey: ArchiveKey.trialNumber)
        trialStepNumber = aDecoder.decodeInteger(forKey: ArchiveKey.trialStepNumber)
        
        isLearning = aDecoder.decodeBool(forKey: ArchiveKey.isLearning)
        
        isXOn = aDecoder.decodeBool(forKey: ArchiveKey.isXOn)
        isYOn = aDecoder.decodeBool(forKey: ArchiveKey.isYOn)
        isSrOn = aDecoder.decodeBool(forKey: ArchiveKey.isSrOn)
        
        s1m1Weight = aDecoder.decodeDouble(forKey: ArchiveKey.s1m1Weight)
        s2m2Weight = aDecoder.decodeDouble(forKey: ArchiveKey.s2m2Weight)
        
        m1outActivation = aDecoder.decodeDouble(forKey: ArchiveKey.m1outActivation)
        m2outActivation = aDecoder.decodeDouble(forKey: ArchiveKey.m2outActivation)
    }
    
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(trialNumber, forKey: ArchiveKey.trialNumber)
        aCoder.encode(trialStepNumber, forKey: ArchiveKey.trialStepNumber)
        
        aCoder.encode(isLearning, forKey: ArchiveKey.isLearning)

        aCoder.encode(isXOn, forKey: ArchiveKey.isXOn)
        aCoder.encode(isYOn, forKey: ArchiveKey.isYOn)
        aCoder.encode(isSrOn, forKey: ArchiveKey.isSrOn)
        
        aCoder.encode(s1m1Weight, forKey: ArchiveKey.s1m1Weight)
        aCoder.encode(s2m2Weight, forKey: ArchiveKey.s2m2Weight)
        
        aCoder.encode(m1outActivation, forKey: ArchiveKey.m1outActivation)
        aCoder.encode(m2outActivation, forKey: ArchiveKey.m2outActivation)
    }

    
    
} // end class SessionStepData


