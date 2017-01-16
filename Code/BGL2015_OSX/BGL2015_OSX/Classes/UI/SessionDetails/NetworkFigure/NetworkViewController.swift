//
//  NetworkViewController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 8/31/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



class NetworkViewController: NSViewController, DetailsDisplay {
    
    // MARK: Outlets & Actions
    
    var neuralNetworkView: NeuralNetworkView {
        return view as! NeuralNetworkView
    }
    
    
    // MARK: DetailsDisplay Data
    
    
    var coordinator: DetailsCoordinator {
        get {
            assert(priv_coordinator != nil)
            return priv_coordinator!
        }
        set {
            priv_coordinator = newValue
        }
    }
    
    
    // MARK: Initialization
    
    
    // MARK: NSViewController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view.translatesAutoresizingMaskIntoConstraints = false
        
        view.autoresizingMask = [
            NSAutoresizingMaskOptions.viewWidthSizable,
            NSAutoresizingMaskOptions.viewHeightSizable
        ]
        
    } //  end viewDidLoad
    
    
    
    
    // MARK: DetailsDisplay Functions
    
    
    func reloadData() -> Void {
        assert(priv_coordinator != nil)
        guard !priv_didClose else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        priv_isBlockingRecursiveUpdate = true
        
        
        priv_isBlockingRecursiveUpdate = false
        
    } // end displayTimeSteps
    
    
    func synchronizeScroll(_ scrollInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
        guard !priv_didClose else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
    } // end synchronizeScroll
    
    
    
    func synchronizeZoom(_ zoomInitiator: DetailsDisplay, percentOfRangeToDisplay: Double) -> Void {
        guard !priv_didClose else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        priv_isBlockingRecursiveUpdate = true
        
        
        priv_isBlockingRecursiveUpdate = false
        
    } // end synchronizeZoom
    
    
    
    func synchronizeZoom(_ zoomInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
        guard !priv_didClose else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        priv_isBlockingRecursiveUpdate = true
        
        
        priv_isBlockingRecursiveUpdate = false
        
    } // end synchronizeZoom
    
    
    
    func synchronizeSelect(_ selectionInitiator: DetailsDisplay, selectedTimeStepIndex: Int) -> Void {
        guard !priv_didClose else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        priv_isBlockingRecursiveUpdate = true
        
        let step = coordinator.timeStepsArray[selectedTimeStepIndex]
        
        if priv_currentStep !== step {
            priv_currentStep = step
            
            if let networkData = step.networkState {
                let network: Network = NSKeyedUnarchiver.unarchiveObject(with: networkData as Data) as! Network
                
                update(network)
            }
        }
        
        priv_isBlockingRecursiveUpdate = false
        
    } // end synchronizeZoom
    
    
    
    func willClose() {
        guard !priv_didClose else { return }
        priv_didClose = true
    }
    
    
    // MARK: Configuration & Update
    
    

    
    func update(_ network: Network) -> Void {
        
        neuralNetworkView.updateForTimestep(network)
        
    } // end update
    
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_isBlockingRecursiveUpdate = false
    fileprivate var priv_coordinator: DetailsCoordinator? = nil
    fileprivate var priv_didClose = false
    
    fileprivate var priv_currentStep: Step? = nil
} // end NetworkViewController

