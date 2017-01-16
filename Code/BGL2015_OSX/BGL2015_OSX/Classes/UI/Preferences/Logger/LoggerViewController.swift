//
//  LoggerViewController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 4/17/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation



class LoggerViewController: NSViewController {
    
    var logger: Logger!
    
    var loggerView: LoggerView {
        return view as! LoggerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loggerView = self.loggerView
        loggerView.logger = self.logger
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        let loggerView = self.loggerView
        loggerView.refreshLoggingState()
    }
}
