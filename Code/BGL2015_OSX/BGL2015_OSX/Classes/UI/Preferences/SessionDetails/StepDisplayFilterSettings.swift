//
//  StepDisplayFilterSettings.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 6/22/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation


// Class StepDisplayFilterSettings
//
// Trials from which phases to display in details: training, choice.
//
// Which time steps within trials to display.
//
open class StepDisplayFilterSettings: NSObject, NSCoding {
    
    public typealias onCompletionBlock = ()->Void
    
    open class func defaultSettings() -> StepDisplayFilterSettings {
        return StepDisplayFilterSettings()
    }
    
    // MARK: Change Control
    
    open var timeStamp: TimeInterval {
        return priv_timeStamp
    }
    
    
    
    // MARK: Selected Phases and Steps
    
    open var isTrainingPhase = true { didSet { setTimeStamp() } }
    open var isChoicePhase = true { didSet { setTimeStamp() } }
    
    open var isNonSrTimeSteps = true { didSet { setTimeStamp() } }
    open var isSrTimeStep = true { didSet { setTimeStamp() } }
    open var isIntertrialTimeStep = true { didSet { setTimeStamp() } }
    
    open var isDefault: Bool {
        return isPhasesDefault && isStepsDefault
    }
    open var isPhasesDefault: Bool {
        return isPhasesEqual(StepDisplayFilterSettings.priv_defaults)
    }
    open var isStepsDefault: Bool {
        return isStepsEqual(StepDisplayFilterSettings.priv_defaults)
    }
    
    
    // MARK: Debug
    
    open override var debugDescription: String {
        return "\(super.debugDescription): isTrainingPhase: \(isTrainingPhase), isChoicePhase: \(isChoicePhase), isNonSrTimeSteps: \(isNonSrTimeSteps), isSrTimeStep: \(isSrTimeStep), isIntertrialTimeStep: \(isIntertrialTimeStep)"
    }
    
    
    // MARK: Initialization
    
    public override init() {
    }
    
    public convenience init(from: StepDisplayFilterSettings) {
        self.init()
        isTrainingPhase = from.isTrainingPhase
        isChoicePhase = from.isChoicePhase
        
        isNonSrTimeSteps = from.isNonSrTimeSteps
        isSrTimeStep = from.isSrTimeStep
        isIntertrialTimeStep = from.isIntertrialTimeStep
        
        priv_timeStamp = from.timeStamp
    }
    
    open func clone() -> StepDisplayFilterSettings {
        return StepDisplayFilterSettings(from: self)
    }
    
    
    
    // MARK: Filtering
    //
    // Pass: use the time step or trial. If not passed, don't use/display
    // data for that item.
    //
    open func passTimeStep(_ trialNumber: Int, stepIndex: Int) -> Bool {
        return passTrial(trialNumber) && passStep(stepIndex)
    }
    open func passTrial(_ trialNumber: Int) -> Bool {
        if !isTrainingPhase && TrialsLooper.isTrainingTrial(trialNumber) {
            return false
        }
        if !isChoicePhase && TrialsLooper.isChoiceTrial(trialNumber) {
            return false
        }
        return true
    }
    open func passStep(_ stepIndex: Int) -> Bool {
        if !isIntertrialTimeStep && TrialsLooper.isIntertrialIntervalStep(stepIndex) {
            return false
        }
        if !isNonSrTimeSteps && TrialsLooper.isNonSrStep(stepIndex) {
            return false
        }
        if !isSrTimeStep && TrialsLooper.isSrStep(stepIndex) {
            return false
        }
        return true
    }
    
    
    // MARK: Important Positions
    
    open func isFirstStepInTrial(_ trialNumber: Int, trialStepNumber: Int) -> Bool {
        let firstStepIndex = firstStepInTrial(trialNumber)
        return firstStepIndex == trialStepNumber
    }
    
    
    open func firstStepInTrial(_ trialNumber: Int) -> Int {
        if isIntertrialTimeStep && trialNumber > 1 {
            return 0
        }
        if isNonSrTimeSteps {
            return TrialsLooper.intertrialStepsPerTrial
        }
        if isSrTimeStep {
            return TrialsLooper.intertrialStepsPerTrial + TrialsLooper.nonSrTimeStepsPerTrial
        }
        return -1
    }
    
    // MARK: Change Control
    
    open func setTimeStamp() -> Void {
        priv_timeStamp = Date.timeIntervalSinceReferenceDate
    }
    
    // MARK: Equality
    //
    // Note that equality does not include timeStamp. Only the "content".
    
    open override func isEqual(_ object: Any?) -> Bool {

        if let other = object as? StepDisplayFilterSettings {
            return isPhasesEqual(other) && isStepsEqual(other)
        }
        return false
    }
    
    open func isPhasesEqual(_ other: StepDisplayFilterSettings) -> Bool {
        return isTrainingPhase == other.isTrainingPhase
            && isChoicePhase == other.isChoicePhase
    }
    open func isStepsEqual(_ other: StepDisplayFilterSettings) -> Bool {
        return isNonSrTimeSteps == other.isNonSrTimeSteps
            && isSrTimeStep == other.isSrTimeStep
            && isIntertrialTimeStep == other.isIntertrialTimeStep
    }
    
    // MARK: Defaults
    
    open func setDefault() {
        setDefaultPhases()
        setDefaultSteps()
    }
    open func setDefaultPhases() -> Void {
        isTrainingPhase = StepDisplayFilterSettings.priv_defaults.isTrainingPhase
        isChoicePhase = StepDisplayFilterSettings.priv_defaults.isChoicePhase
    }
    open func setDefaultSteps() -> Void {
        isNonSrTimeSteps = StepDisplayFilterSettings.priv_defaults.isNonSrTimeSteps
        isSrTimeStep = StepDisplayFilterSettings.priv_defaults.isSrTimeStep
        isIntertrialTimeStep = StepDisplayFilterSettings.priv_defaults.isIntertrialTimeStep
    }
    
    
    // MARK: NSCoding
    
    public struct Settings {
        public static let isTrainingPhase = "isTrainingPhase"
        public static let isChoicePhase = "isChoicePhase"
        
        public static let isNonSrTimeSteps = "isNonSrTimeSteps"
        public static let isSrTimeStep = "isSrTimeStep"
        public static let isIntertrialTimeStep = "isIntertrialTimeStep"
        
        public static let timeStamp = "timeStamp"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        isTrainingPhase = aDecoder.decodeBool(forKey: Settings.isTrainingPhase)
        isChoicePhase = aDecoder.decodeBool(forKey: Settings.isChoicePhase)
        
        isNonSrTimeSteps = aDecoder.decodeBool(forKey: Settings.isNonSrTimeSteps)
        isSrTimeStep = aDecoder.decodeBool(forKey: Settings.isSrTimeStep)
        isIntertrialTimeStep = aDecoder.decodeBool(forKey: Settings.isIntertrialTimeStep)
        
        priv_timeStamp = aDecoder.decodeDouble(forKey: Settings.timeStamp)
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(isTrainingPhase, forKey: Settings.isTrainingPhase)
        aCoder.encode(isChoicePhase, forKey: Settings.isChoicePhase)
        
        aCoder.encode(isNonSrTimeSteps, forKey: Settings.isNonSrTimeSteps)
        aCoder.encode(isSrTimeStep, forKey: Settings.isSrTimeStep)
        aCoder.encode(isIntertrialTimeStep, forKey: Settings.isIntertrialTimeStep)
        
        aCoder.encode(priv_timeStamp, forKey: Settings.timeStamp)
    }
    
    
    // MARK: *Private*
    
    
    fileprivate static let priv_defaults = StepDisplayFilterSettings.defaultSettings()
    
    fileprivate var priv_timeStamp: TimeInterval = 0.0

    
} // end class StepDisplayFilterSettings


public func ==(lhs: StepDisplayFilterSettings, rhs: StepDisplayFilterSettings) -> Bool {
    return lhs.isEqual(rhs)
}



