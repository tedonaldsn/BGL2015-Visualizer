//
//  PreferencesViewController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 5/31/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    
    // MARK: Outlets and Actions
    

    @IBOutlet weak var loggerView: NSView!
    
    @IBOutlet weak var stepDisplayFilterView: NSView!
    
    
    
    var loggerViewController: LoggerViewController!
    var stepDisplayFilterViewController: StepDisplayFilterViewController!
    
    
    // MARK: Data
    
    var logger = AppDelegate.sharedInstance().logger
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the functioning logger controller view, size it to fit in the
        // placeholder's spot, and replace the placeholder with the functioning
        // view.
        //
        loggerViewController =
            LoggerViewController(nibName: nil, bundle: nil)
        loggerViewController.logger = self.logger
        let newLoggerView: NSView = loggerViewController.view
        newLoggerView.frame = loggerView.frame
        self.view.replaceSubview(loggerView, with: newLoggerView)
        
        // Same for session details step filter
        //
        stepDisplayFilterViewController =
            StepDisplayFilterViewController(nibName: nil, bundle: nil)
        let newStepFilterView: NSView = stepDisplayFilterViewController.view
        newStepFilterView.frame = stepDisplayFilterView.frame
        self.view.replaceSubview(stepDisplayFilterView, with: newStepFilterView)
        
        AppDelegate.sharedInstance().preferencesWindow = self.view.window
    }

} // end class PreferencesViewController


