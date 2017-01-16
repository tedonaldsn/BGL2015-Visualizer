//
//  SessionsWindowController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 5/31/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa

class SessionsWindowController: NSWindowController {
    
    @IBOutlet weak var createSessionButton: NSToolbarItem!
    
    @IBAction func createSessionAction(_ sender: Any) {
        sessionsViewController.createSessionAction(sender)
    }
    
    
    @IBOutlet weak var deleteSessionsButton: NSToolbarItem!
    
    @IBAction func deleteSessionsAction(_ sender: AnyObject) {
        sessionsViewController.deleteSessionsAction(sender)
    }
    
    
    
    @IBOutlet weak var sessionDetailsButton: NSToolbarItem!
    
    @IBAction func sessionDetailsAction(_ sender: AnyObject) {
        sessionsViewController.sessionDetailsAction(sender)
    }
    
    
    
    var sessionsViewController: SessionsViewController {
        return (contentViewController as? SessionsViewController)!
    }
    

    override func windowDidLoad() {
        super.windowDidLoad()
    
        sessionsViewController.windowController = self
    }
    

} // end class SessionsWindowController


