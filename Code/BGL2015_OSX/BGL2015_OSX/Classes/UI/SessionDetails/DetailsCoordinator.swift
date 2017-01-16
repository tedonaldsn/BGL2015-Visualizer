//
//  DetailsCoordinator.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 6/28/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//



import Cocoa
import BASimulationFoundation



// DetailsCoordinator
//
// Controls one or more time step detail displays and coordinates their 
// contents and focal points. The detail coordinator will normally be
// the main controller for a window's content view with detail displays
// as subviews.
//
public protocol DetailsCoordinator: AnyObject {
    
    var logger: Logger { get }
    
    // Session time steps loaded from Core Data. Content filtering is
    // controlled by the time step display filter settings, which are the
    // basis of the fetch predicate(s).
    //
    // The timeStepsController.arrangedObjects attribute contains the filtered time
    // steps to be displayed.
    //
    var timeSteps: NSArrayController { get }
    
    // Called just before the displays are closed. The coordinator and all
    // coordinated displays MUST not respond to any display requests (e.g.,
    // scrolling, zooming) after this call.
    //
    func willClose() -> Void
    
    
    // Called by any display to request a particular playback range and starting
    // cursor/selection position. This sets up the playback controller as if
    // the playback range were setup by the controller itself. In particular,
    // if playback is currently running, it continues to do so, but with the
    // new settings. If not currently running, the autozoom feature will obey
    // the requested range, as will the playback itself.
    //
    func setPlaybackRange(beginIndex: UInt,
                          cursorIndex: UInt,
                          endIndex: UInt) -> Void
    
    // Called by the displays being coordinated when the display is scrolled.
    // The coordinator will call the synchronizeScroll() method of each of the
    // other displays to give them the opportunity to synchronize the data
    // being displayed. 
    //
    // If scrolling has no meaning in a particular display implementation, this
    // method should simply return.
    //
    func didScroll(_ scrollInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void
    
    
    // Called by a display being coordinated when it is zoomed in or out.
    // The coordinator will call the synchronizeZoom() method of each of the
    // other displays to give them the opportunity to zoom level of each display.
    //
    // percentOfRangeToDisplay: 1.0 is zoomed all the way out (i.e., no zoom). Zoomed in as
    // far as possible is 0.0.
    //
    // If zooming has no meaning in a particular display implementation, this
    // method should simply return.
    //
    func didZoom(_ zoomInitiator: DetailsDisplay, percentOfRangeToDisplay: Double) -> Void
    func didZoom(_ zoomInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void
    
    // Called by display when an individual time step is selected, whatever
    // that means to the display.
    //
    // The coordinator will call the synchronizeSelect() of each subdisplay.
    //
    func didSelect(_ selectionInitiator: DetailsDisplay, selectedTimeStepIndex: Int) -> Void
    
} // end protocol DetailsCoordinator



public extension DetailsCoordinator {
    
    var timeStepsArray: [Step] {
        return (timeSteps.arrangedObjects as? [Step])!
    }
    
    func closestStep(_ trialNumber: Int, stepIndex: Int) -> Step {
        let index = indexOfClosestStep(trialNumber, stepIndex: stepIndex)
        return timeStepsArray[index]
    }
    
    func indexOfClosestStep(_ trialNumber: Int, stepIndex: Int) -> Int {
        
        let steps = timeStepsArray
        let stepCount = steps.count
        
        guard trialNumber >= 1 else { return 0 }
        guard trialNumber < TrialsLooper.totalTrials else { return stepCount - 1 }

        var closestIx = 0
        
        for ix in 0..<stepCount {
            if trialNumber == Int(steps[ix].trialNumber) {
                closestIx = ix
                break
            }
        }
        for ix in closestIx+1..<stepCount {
            let step = steps[ix]
            let stepTrialNumber = Int(step.trialNumber)
            if stepTrialNumber != trialNumber {
                break
            }
            let trialStepIndex = Int(step.trialStepNumber)
            if trialStepIndex == stepIndex {
                closestIx = ix
                break
            }
            if trialStepIndex > stepIndex {
                break
            }
        }

        return closestIx

    } // end indexOfClosestStep
    
    

} // end extension DetailsCoordinator






