//
//  AboutBoxController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 1/5/17.
//  
//  Copyright © 2017 Tom Donaldson.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

//

import Cocoa

class AboutBoxController: NSViewController {

    @IBOutlet weak var appIconView: NSImageView!

    @IBOutlet weak var versionField: NSTextField!
    
    @IBOutlet weak var licenseAgreementButton: NSButton!
    
    let localAppacheLicenseText = "Apache LICENSE-2.0.rtf"
    
    @IBAction func licenseAgreementAction(_ sender: Any) {
        let url = URL(fileReferenceLiteralResourceName: localAppacheLicenseText)
        NSWorkspace.shared().open(url)
    }
    
    
    
    @IBOutlet weak var acknowledgmentsButton: NSButton!
    
    let acknowledgementsFileName = "Acknowledgements.pdf"
    
    @IBAction func acknowledgementsAction(_ sender: Any) {
        let url = URL(fileReferenceLiteralResourceName: acknowledgementsFileName)
        NSWorkspace.shared().open(url)
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appIconImage = NSImage(named: "AppIcon")
        appIconView.image = appIconImage
        
        let info = Bundle.main.infoDictionary!
        let releaseVersion = info["CFBundleShortVersionString"] as! String
        let buildNumber = info["CFBundleVersion"] as! String
        
        versionField.stringValue = "Version \(releaseVersion) (\(buildNumber))"
        
        /*
        let bundle = Bundle.main
        let url = bundle.url(forResource: "Credits", withExtension: "rtf")!
        
        do {
            let formattedText = try NSAttributedString(url: url,
                                                       options: [:],
                                                       documentAttributes: nil)
            textField.attributedStringValue = formattedText
            
        } catch let error as NSError {
            AppDelegate.sharedInstance().handleError(error)
        }
        */

    } // end viewDidLoad
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        let window = view.window!
        window.titlebarAppearsTransparent = true
        window.backgroundColor = NSColor.white
    }
    
} // end class AboutBoxController


