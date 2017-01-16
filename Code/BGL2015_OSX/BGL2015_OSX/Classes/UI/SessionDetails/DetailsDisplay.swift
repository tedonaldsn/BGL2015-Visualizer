//
//  DetailsDisplay.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 6/28/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//



import Cocoa
import BASimulationFoundation




// DetailsDisplay
//
// A time step display controlled by a DetailsCoordinator. Will normally be
// the view controller.
//
public protocol DetailsDisplay: AnyObject {
    
    var coordinator: DetailsCoordinator { get }

    
    // The time step data has changed, usually as a result of changes in filtering
    // criteria. Or display appearance settings have changed. In either case,
    // fetch coordinator.timeStep data for tables, graphs, figures, etc., and
    // coordinator current coordinator.labeledSymbols
    //
    func reloadData() -> Void
    
    // Scroll the current set of filtered time steps such that the specified
    // range of time steps are display, to the degree possible/practial for the
    // particular type of display.
    //
    // If the display shows more or less than the requested range, the middle
    // time step in the range should be in the center of the display. If the
    // display only shows one step at a time, it should be the central item
    // in the range.
    //
    // Note that this is simply a scroll operations. The display should not
    // change the number of steps displayed in order to satisfy this request.
    //
    func synchronizeScroll(_ scrollInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void
    
    // If the display supports zoom, zoom to the specified percentage of possible
    // zoom centered on the current display.
    //
    // percentOfRangeToDisplay: 1.0 is zoomed all the way out (i.e., no zoom). Zoomed in as
    // far as possible is 0.0.
    //
    func synchronizeZoom(_ zoomInitiator: DetailsDisplay, percentOfRangeToDisplay: Double) -> Void
    func synchronizeZoom(_ zoomInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void
    
    // Select the specified time step. This might mean scrolling to the item
    // and highlighting it in some way, or placing a cursor over the item.
    //
    func synchronizeSelect(_ selectionInitiator: DetailsDisplay, selectedTimeStepIndex: Int) -> Void
    
    
    
    // Called just before the displays are closed. The coordinator and all
    // coordinated displays MUST not respond to any display requests (e.g.,
    // refresh, scrolling, zooming) after this call.
    //
    func willClose() -> Void
    
} // end protocol DetailsDisplay



public extension DetailsDisplay {
    
    var logger: Logger {
        return coordinator.logger
    }
    //
    // The array controller is required by some views for bindings.
    //
    var timeSteps: NSArrayController {
        return coordinator.timeSteps
    }
    //
    // Access the Core Data steps as an array.
    //
    var timeStepsArray: [Step] {
        return coordinator.timeStepsArray
    }
    
} // end extension DetailsDisplay

