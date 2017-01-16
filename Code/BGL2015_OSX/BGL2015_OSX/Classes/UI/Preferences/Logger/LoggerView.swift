//
//  LoggerView.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 4/17/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation

class LoggerView: NSView {
    
    var logger: Logger!
    
    
    @IBOutlet weak var isLoggingButton: NSButton!
    @IBAction func isLoggingAction(_ sender: AnyObject) {
        updateLoggingState()
    }
    
    @IBOutlet weak var isErrorButton: NSButton!
    @IBAction func isErrorAction(_ sender: AnyObject) {
        updateLoggingState()
    }
    
    @IBOutlet weak var isInfoButton: NSButton!
    @IBAction func isInfoAction(_ sender: AnyObject) {
        updateLoggingState()
    }
    
    
    @IBOutlet weak var isWarnButton: NSButton!
    @IBAction func isWarnAction(_ sender: AnyObject) {
        updateLoggingState()
    }
    
    @IBOutlet weak var isTraceButton: NSButton!
    @IBAction func isTraceAction(_ sender: AnyObject) {
        updateLoggingState()
    }
    
    @IBOutlet weak var isDebugButton: NSButton!
    @IBAction func isDebugAction(_ sender: AnyObject) {
        updateLoggingState()
    }
    
    
    @IBOutlet weak var resetButton: NSButton!
    @IBAction func resetAction(_ sender: AnyObject) {
        logger.reset()
        readLoggingState()
        updateLoggingState()
    }
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    func setup() {
        self.wantsLayer = true
        layer!.borderWidth = 1.0
        layer!.cornerRadius = 5.0
    }
    
    
    // MARK: Logging State
    
    func refreshLoggingState() {
        readLoggingState()
        updateLoggingState()
    }
    
    func readLoggingState() {
        isLoggingButton.state = logger.isLoggingEnabled ? NSOnState : NSOffState
        isErrorButton.state = logger.isErrorEnabled ? NSOnState : NSOffState
        isInfoButton.state = logger.isInfoEnabled ? NSOnState : NSOffState
        isWarnButton.state = logger.isWarnEnabled ? NSOnState : NSOffState
        isTraceButton.state = logger.isTraceEnabled ? NSOnState : NSOffState
        isDebugButton.state = logger.isDebugEnabled ? NSOnState : NSOffState
    }
    
    func updateLoggingState() {
        isLoggingButton.isEnabled = true
        
        let isEnabled = isLoggingButton.state == NSOnState
        logger.isLoggingEnabled = isEnabled
        
        isErrorButton.isEnabled = isEnabled
        isInfoButton.isEnabled = isEnabled
        isWarnButton.isEnabled = isEnabled
        isTraceButton.isEnabled = isEnabled
        isDebugButton.isEnabled = isEnabled
        
        logger.isErrorEnabled = isErrorButton.state == NSOnState
        logger.isInfoEnabled = isInfoButton.state == NSOnState
        logger.isWarnEnabled = isWarnButton.state == NSOnState
        logger.isTraceEnabled = isTraceButton.state == NSOnState
        logger.isDebugEnabled = isDebugButton.state == NSOnState
        
        resetButton.isEnabled = !logger.isDefaultSettings
        
        let archive = NSKeyedArchiver.archivedData(withRootObject: logger.settings)
        let prefs = UserDefaults.standard
        prefs.set(archive, forKey: PreferenceKey.logger)
    }
    

    
    // MARK: NSView

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        refreshLoggingState()
    }
    
    
} // end class LoggerView


