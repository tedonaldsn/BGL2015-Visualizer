//
//  TimeStepTableViewController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 6/29/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa

class TimeStepTableViewController: NSViewController, NSTableViewDelegate, DetailsDisplay {
    
    // MARK: Outlets

    @IBOutlet weak var timeStepTableScrollView: NSScrollView!
    @IBOutlet weak var timeStepTableView: NSTableView!
    
    // MARK: Actions
    
    
    // MARK: DetailsDisplay Data
    
    var coordinator: DetailsCoordinator {
        get {
            assert(priv_coordinator != nil)
            return priv_coordinator!
        }
        set {
            // This seems to get set by a "materializer" each time an attribute
            // of the coordinator is accessed, so cannot assert(priv_coordinator == nil)
            priv_coordinator = newValue
        }
    }
    
    // MARK: Data
    
    // In various places while adjusting the display we report changes back
    // to the coordinator to allow it to synch up other displays. BUT: this
    // can/does result in recursive displays to self that have some really
    // bad effects. So, in places where we might trigger recursive calls,
    // we us a flag to simply exit recursive calls.
    //
    var priv_isBlockingRecursiveUpdate = false
    
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    
    // MARK: Finalization
    
    
    override func finalize() {
        let notifier = NotificationCenter.default
        notifier.removeObserver(self)
    }
    
    
    
    // MARK: NSViewController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.autoresizingMask = [
            NSAutoresizingMaskOptions.viewHeightSizable
        ]
    }
    
    
    override func viewWillAppear() {
        assert(priv_coordinator != nil)
        
        super.viewWillAppear()
        
        let notifier = NotificationCenter.default
        
        notifier.addObserver(self,
                             selector: #selector(visibleStepsChanged),
                             name: NSNotification.Name.NSViewBoundsDidChange,
                             object: timeStepTableScrollView.contentView)
        
        timeStepTableView.bind(NSContentBinding,
                               to: timeSteps,
                               withKeyPath: "arrangedObjects",
                               options: nil)
        
        timeStepTableView.bind(NSSelectionIndexesBinding,
                               to: timeSteps,
                               withKeyPath: "selectionIndexes",
                               options: nil)
        
        timeStepTableView.delegate = self

    } // end viewWillAppear
    
    

    // Move left and move right do nothing in the table view as used to display
    // read-only summary data per time step. "Remap" them to do something
    // reasonable instead of annoyingly ignoring left and right arrow key
    // presses.
    //
    override func moveLeft(_ sender: Any?) {
        guard !priv_isClosed else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        let selectedIndex = timeStepTableView.selectedRow - 1
        if selectedIndex >= 0 {
            synchronizeSelect(self, selectedTimeStepIndex: selectedIndex)
            coordinator.didSelect(self, selectedTimeStepIndex: selectedIndex)
        }
    } // end moveLeft
    
    override func moveRight(_ sender: Any?) {
        guard !priv_isClosed else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        let selectedIndex = timeStepTableView.selectedRow + 1
        if selectedIndex < timeStepsArray.count {
            synchronizeSelect(self, selectedTimeStepIndex: selectedIndex)
            coordinator.didSelect(self, selectedTimeStepIndex: selectedIndex)
        }
    } // end moveRight
    
    
    
    
    // MARK: DetailsDisplay Functions
    
    func willClose() {
        guard !priv_isClosed else { return }
        priv_isClosed = true
    }
    
    func reloadData() -> Void {
        assert(priv_coordinator != nil)
        
        guard !priv_isClosed else { return }
        
        if !priv_isBlockingRecursiveUpdate {
            priv_isBlockingRecursiveUpdate = true
            
            priv_isBlockingRecursiveUpdate = false
        }
        
    } // end displayTimeSteps
    
    
    // MARK: Scroll Management
    
    

    
    
    func visibleStepsTableIndexRange() -> NSRange {
        let visibleRect: CGRect = timeStepTableScrollView.contentView.visibleRect;
        let range: NSRange = timeStepTableView.rows(in: visibleRect)
        return range
    }
    
    func visibleStepsChanged(_ tableScrollNotification: Notification) -> Void {
        
        guard !priv_isClosed else { return }
        
        if !priv_isBlockingRecursiveUpdate {
            priv_isBlockingRecursiveUpdate = true
            
            let visibleRows = visibleStepsTableIndexRange()
            coordinator.didScroll(self, toTimeStepRange: visibleRows)
            
            priv_isBlockingRecursiveUpdate = false
        }
    }
    
    func synchronizeScroll(_ scrollInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
        
        guard !priv_isClosed else { return }
        
        if !priv_isBlockingRecursiveUpdate {
            priv_isBlockingRecursiveUpdate = true
            
            let startingRange = visibleStepsTableIndexRange()
            let halfVisibleRange: Double = Double(startingRange.length) / 2.0
            let startingMidRangeLocation: Double = Double(startingRange.location) + halfVisibleRange
            
            let requestedMidRangeLocation: Double =
                Double(toTimeStepRange.location) + (Double(toTimeStepRange.length) / 2.0)
            let delta: Double = startingMidRangeLocation - requestedMidRangeLocation
            var adjustedMidRangeLocation: Double = requestedMidRangeLocation

            // The adjustedMidRangeLocation compensates for oddities in how 
            // NSTableView scrolls to a requested location. The adjustments 
            // result in an average error of about 0.5 rows per scroll in the
            // final display, based on the midpoint of the visible range.
            //
            if delta > 0.0 {
                adjustedMidRangeLocation = round(adjustedMidRangeLocation + 2.0) - Double(Int(halfVisibleRange))
                
            } else if delta < 0.0 {
                adjustedMidRangeLocation = Double(Int(adjustedMidRangeLocation) + Int(halfVisibleRange))
            }
            
            timeStepTableView.scrollRowToVisible(Int(adjustedMidRangeLocation))
            
            priv_isBlockingRecursiveUpdate = false
        }
    }

    // No zooming defined for table.
    //
    func synchronizeZoom(_ zoomInitiator: DetailsDisplay, percentOfRangeToDisplay: Double) -> Void {
    }
    func synchronizeZoom(_ zoomInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
    }
    
    
    
    
    func synchronizeSelect(_ selectionInitiator: DetailsDisplay, selectedTimeStepIndex: Int) -> Void {
        assert(selectedTimeStepIndex >= 0)
        
        guard !priv_isClosed else { return }
        
        if !priv_isBlockingRecursiveUpdate {
            priv_isBlockingRecursiveUpdate = true
            
            let indexSet = IndexSet(integer: selectedTimeStepIndex)
            timeStepTableView.selectRowIndexes(indexSet, byExtendingSelection: false)
            timeStepTableView.scrollRowToVisible(selectedTimeStepIndex)
            
            priv_isBlockingRecursiveUpdate = false
        }
    } // end didSelect
    

    
    // MARK: NSTableViewDelegate
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        guard !priv_isClosed else { return }
        
        if !priv_isBlockingRecursiveUpdate {
            priv_isBlockingRecursiveUpdate = true
            
            let selectedIndex = timeStepTableView.selectedRow
            
            if selectedIndex >= 0 {
                coordinator.didSelect(self, selectedTimeStepIndex: selectedIndex)
            }
            
            priv_isBlockingRecursiveUpdate = false
        }
        
    } // end tableViewSelectionDidChange

    

    
    // MARK: *Private*
    
    
    fileprivate var priv_isClosed = false
    
    fileprivate var priv_coordinator: DetailsCoordinator? = nil
    
    
} // end TimeStepTableViewController


