//
//  BGL2015ExperimentStates.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 11/26/15.
//  Copyright © 2015 Tom Donaldson. All rights reserved.
//



import BASimulationFoundation
import GameplayKit




public class BGL2015ExperimentStateBase: GKState {
    
    public unowned var experiment: BGL2015Experiment
    
    public init(experiment: BGL2015Experiment) {
        self.experiment = experiment
    }

} // end class BGL2015ExperimentStateBase




final public class BGL2015ExperimentStart: BGL2015ExperimentStateBase {
    
    public override init(experiment: BGL2015Experiment) {
        super.init(experiment: experiment)
    }
    
    public override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass == BLG2015ExperimentSubjectSession.self
    }
    
    public override func didEnterWithPreviousState(previousState: GKState?) -> Void {
        experiment.initializeSummaryStats()
        stateMachine!.enterState(BLG2015ExperimentSubjectSession)
    }
    
} // end class BGL2015ExperimentStart




final public class BLG2015ExperimentSubjectSession: BGL2015ExperimentStateBase {
    
    var session: BGL2015Session? = nil
    
    public override init(experiment: BGL2015Experiment) {
        super.init(experiment: experiment)
    }
    
    public override func isValidNextState(stateClass: AnyClass) -> Bool {
        return
            stateClass == BLG2015ExperimentSubjectSession.self
                || stateClass == BLG2015ExperimentStop.self
    }
    
    public override func didEnterWithPreviousState(previousState: GKState?) -> Void {
        session = experiment.newSession()
        session!.start()
    }
    
    public override func updateWithDeltaTime(seconds: NSTimeInterval) {
        if session!.isRunning {
            session!.timeStep()
        }
        
        if !session!.isRunning {
            if experiment.numberOfSubjects > experiment.currentSubjectNumber {
                stateMachine!.enterState(BLG2015ExperimentSubjectSession)
            } else {
                stateMachine!.enterState(BLG2015ExperimentStop)
            }
        }
    } // end updateWithDeltaTime
    
    public override func willExitWithNextState(nextState: GKState) {
        experiment.updateSummaryStats()
        session = nil
    }
    
    
} // end class BLG2015ExperimentSubjectSession




final public class BLG2015ExperimentStop: BGL2015ExperimentStateBase {
    
    public override init(experiment: BGL2015Experiment) {
        super.init(experiment: experiment)
    }
    
    public override func isValidNextState(stateClass: AnyClass) -> Bool {
        return stateClass == BGL2015ExperimentStart.self
    }
    
    public override func didEnterWithPreviousState(previousState: GKState?) -> Void {
        experiment.debugPrintSummary()
    }
}






