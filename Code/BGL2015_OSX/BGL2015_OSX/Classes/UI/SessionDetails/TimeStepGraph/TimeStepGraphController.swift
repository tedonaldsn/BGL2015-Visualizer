//
//  TimeStepGraphController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 6/30/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import CorePlot
import BASimulationFoundation



class TimeStepGraphController: NSViewController, DetailsCoordinator, DetailsDisplay {
    

    
    // MARK: Outlets
    
    @IBOutlet weak var xStimulusBarPlotHostingView: CPTGraphHostingView!
    @IBOutlet weak var yStimulusBarPlotHostingView: CPTGraphHostingView!
    @IBOutlet weak var srBarPlotHostingView: CPTGraphHostingView!
    
    @IBOutlet weak var weightsActivationsLinePlotHostingView: CPTGraphHostingView!
    
    
    
    @IBAction func toggleLegendAction(_ sender: AnyObject) {
        toggleLegend()
    }
    @IBOutlet weak var zoomSlider: NSSlider!
    
    
    
    
    @IBAction func setPlaybackRangeAction(_ sender: Any) {
        
        let cursorIndex = weightsActivationsGraphController.cursorIndex
        let range = weightsActivationsGraphController.range
        let beginIndex = range.location
        let endIndex = beginIndex + range.length
        
        assert(beginIndex >= 0)
        assert(cursorIndex >= 0)
        assert(endIndex >= 0)
        
        coordinator.setPlaybackRange(beginIndex: UInt(beginIndex),
                                     cursorIndex: UInt(cursorIndex),
                                     endIndex: UInt(endIndex))
    }
    
    
    // MARK: Actions
    
    @IBAction func zoomAction(_ sender: AnyObject) {
        assert(sender === zoomSlider)
        assert(zoomSlider.minValue == 0)
        assert(zoomSlider.maxValue == 100)
        
        // Slider range is 0-100 (set in Interface Builder). Lowest level of
        // zoom is 0, maximum zoom is 100.
        //
        // But our zoom routines expect to be told what percentage of items
        // are to be shown, now the position of the zoom slider. So we must
        // invert the meaning of the slider output.
        //
        let percentOfRangeToDisplay: Double = 1.0 - (zoomSlider.doubleValue / zoomSlider.maxValue)
        synchronizeZoom(self, percentOfRangeToDisplay: percentOfRangeToDisplay)
    }
    
    
    
    // MARK: DetailsCoordinator
    
    var logger: Logger { return coordinator.logger }
    
    var timeSteps: NSArrayController { return coordinator.timeSteps }
    
    var displays: [DetailsDisplay] { return priv_displays }
    
    
    
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
    
    // MARK: Data
    
    var weightsActivationsGraphController: TimeStepLineGraphController!
    
    var priv_isBlockingRecursiveUpdate = false
    
    let scatterPlotDefinitions = PlotDefinitions(definitions: [
        ScatterPlotDefinition(label: "M'1 Activation",
            dataKey: "m1outActivation",
            lineWidth: 3.0,
            lineColor: CPTColor.orange()),
        ScatterPlotDefinition(label: "M'2 Activation",
            dataKey: "m2outActivation",
            lineWidth: 3.0,
            lineColor: CPTColor.green()),
        ScatterPlotDefinition(label: "S\"1–M\"1 Weight",
            dataKey: "s1m1Weight",
            lineWidth: 3.0,
            lineColor: CPTColor.purple()),
        ScatterPlotDefinition(label: "S\"2–M\"2 Weight",
            dataKey: "s2m2Weight",
            lineWidth: 3.0,
            lineColor: CPTColor.blue())
    ])
    
    
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    

    
    
    
    // MARK: NSViewController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.autoresizingMask = [
            NSAutoresizingMaskOptions.viewWidthSizable,
            NSAutoresizingMaskOptions.viewMinYMargin
        ]
    }
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
    
        // Start out unzoomed.
        //
        setSliderPosition(percentOfRangeToDisplay: 1.0)

        
    } // end viewWillAppear
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        

        let xStimGraphController = TimeStepBarGraphController()
        xStimGraphController.coordinator = self
        xStimGraphController.appendPlotDefinition(BarPlotDefinition(label: "X",
            dataKey: "isXOn",
            lineWidth: 1.0,
            lineColor: CPTColor.red(),
            barFill: CPTFill(color: CPTColor.red()),
            barWidth: 0.5,
            barCornerRadius: 4.0))
        priv_displays.append(xStimGraphController)
        xStimGraphController.view.frame = xStimulusBarPlotHostingView.frame
        view.replaceSubview(xStimulusBarPlotHostingView, with: xStimGraphController.view)
        
        let yStimGraphController = TimeStepBarGraphController()
        yStimGraphController.coordinator = self
        yStimGraphController.appendPlotDefinition(BarPlotDefinition(label: "Y",
            dataKey: "isYOn",
            lineWidth: 1.0,
            lineColor: CPTColor.yellow(),
            barFill: CPTFill(color: CPTColor.yellow()),
            barWidth: 0.5,
            barCornerRadius: 4.0))
        priv_displays.append(yStimGraphController)
        yStimGraphController.view.frame = yStimulusBarPlotHostingView.frame
        view.replaceSubview(yStimulusBarPlotHostingView, with: yStimGraphController.view)
        
        let srGraphController = TimeStepBarGraphController()
        srGraphController.coordinator = self
        srGraphController.appendPlotDefinition(BarPlotDefinition(label: "Sr",
            dataKey: "isSrOn",
            lineWidth: 1.0,
            lineColor: CPTColor.purple(),
            barFill: CPTFill(color: CPTColor.purple()),
            barWidth: 0.75,
            barCornerRadius: 4.0))
        priv_displays.append(srGraphController)
        srGraphController.view.frame = srBarPlotHostingView.frame
        view.replaceSubview(srBarPlotHostingView, with: srGraphController.view)
        
        weightsActivationsGraphController = TimeStepLineGraphController()
        weightsActivationsGraphController.coordinator = self
        weightsActivationsGraphController.appendPlotDefinitions(scatterPlotDefinitions.definitions)
        weightsActivationsGraphController.isLegendEnabled = true
        priv_displays.append(weightsActivationsGraphController)
        weightsActivationsGraphController.view.frame = weightsActivationsLinePlotHostingView.frame
        view.replaceSubview(weightsActivationsLinePlotHostingView, with: weightsActivationsGraphController.view)

    } // end viewDidAppear
    
    
    
    // MARK: Graph Specific
    
    func toggleLegend() {
        for display in priv_displays {
            if let mapDisplayController = display as? TimeStepBaseGraphController {
                mapDisplayController.toggleLegend()
            }
        }
    }
    
    
    
    // MARK: DetailsCoordinator Functions
    
    
    // Remove all subdisplays after shutting them down.
    //
    func willClose() {
        for display in priv_displays {
            display.willClose()
        }
        priv_displays.removeAll()
    }
    
    func setPlaybackRange(beginIndex: UInt, cursorIndex: UInt, endIndex: UInt) {
        
        coordinator.setPlaybackRange(beginIndex: beginIndex,
                                     cursorIndex: cursorIndex,
                                     endIndex: endIndex)
    }

    
    
    func didScroll(_ scrollInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
        assert(toTimeStepRange.location >= 0)
        assert(toTimeStepRange.length >= 0)
        
        if !priv_isBlockingRecursiveUpdate {
            priv_isBlockingRecursiveUpdate = true
            
            for display in priv_displays {
                if display !== scrollInitiator {
                    display.synchronizeScroll(scrollInitiator, toTimeStepRange: toTimeStepRange)
                }
            }
            
            coordinator.didScroll(scrollInitiator, toTimeStepRange: toTimeStepRange)
            
            priv_isBlockingRecursiveUpdate = false
        }
    }
    
    func didZoom(_ zoomInitiator: DetailsDisplay, percentOfRangeToDisplay: Double) -> Void {
        assert(percentOfRangeToDisplay >= 0.0)
        assert(percentOfRangeToDisplay <= 1.0)
        
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        priv_isBlockingRecursiveUpdate = true
        
        setSliderPosition(percentOfRangeToDisplay: percentOfRangeToDisplay)
        
        for display in priv_displays {
            if display !== zoomInitiator {
                display.synchronizeZoom(zoomInitiator, percentOfRangeToDisplay: percentOfRangeToDisplay)
            }
        }
        
        coordinator.didZoom(zoomInitiator, percentOfRangeToDisplay: percentOfRangeToDisplay)
        
        priv_isBlockingRecursiveUpdate = false
    }
    
    
    func didZoom(_ zoomInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
        let totalLength = coordinator.timeStepsArray.count
        let requestedLength = toTimeStepRange.length
        let percentOfRangeToDisplay: Double = Double(requestedLength) / Double(totalLength)
        
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        priv_isBlockingRecursiveUpdate = true
        
        assert(percentOfRangeToDisplay >= 0.0)
        assert(percentOfRangeToDisplay <= 1.0)
        
        setSliderPosition(percentOfRangeToDisplay: percentOfRangeToDisplay)
        
        for display in priv_displays {
            if display !== zoomInitiator {
                display.synchronizeZoom(zoomInitiator, toTimeStepRange: toTimeStepRange)
            }
        }
        
        coordinator.didZoom(zoomInitiator, toTimeStepRange: toTimeStepRange)
        
        priv_isBlockingRecursiveUpdate = false
    }
    
    
    func didSelect(_ selectionInitiator: DetailsDisplay, selectedTimeStepIndex: Int) -> Void {
        assert(selectedTimeStepIndex >= 0)
        
        if !priv_isBlockingRecursiveUpdate {
            priv_isBlockingRecursiveUpdate = true
            
            for display in priv_displays {
                if display !== selectionInitiator {
                    display.synchronizeSelect(selectionInitiator, selectedTimeStepIndex: selectedTimeStepIndex)
                }
            }
            
            coordinator.didSelect(selectionInitiator, selectedTimeStepIndex: selectedTimeStepIndex)
            
            priv_isBlockingRecursiveUpdate = false
        }
    } // end didSelect
    
    
    
    // MARK: DetailsDisplay Functions
    
    
    func reloadData() -> Void {
        assert(priv_coordinator != nil)
        
        if !priv_isBlockingRecursiveUpdate {
            priv_isBlockingRecursiveUpdate = true
            for display in priv_displays {
                display.reloadData()
            }
            priv_isBlockingRecursiveUpdate = false
        }
        
    } // end displayTimeSteps
    
    
    func synchronizeScroll(_ scrollInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
        assert(toTimeStepRange.location >= 0)
        assert(toTimeStepRange.length >= 0)
        
        if !priv_isBlockingRecursiveUpdate {
            priv_isBlockingRecursiveUpdate = true
            
            for display in priv_displays {
                if display !== scrollInitiator {
                    display.synchronizeScroll(scrollInitiator, toTimeStepRange: toTimeStepRange)
                }
            }
            
            priv_isBlockingRecursiveUpdate = false
        }
        
    } // end synchronizeScroll
    
    
    
    func synchronizeZoom(_ zoomInitiator: DetailsDisplay, percentOfRangeToDisplay: Double) -> Void {
        assert(percentOfRangeToDisplay >= 0.0)
        assert(percentOfRangeToDisplay <= 1.0)
        
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        priv_isBlockingRecursiveUpdate = true
        
        setSliderPosition(percentOfRangeToDisplay: percentOfRangeToDisplay)
        
        for display in priv_displays {
            if display !== zoomInitiator {
                display.synchronizeZoom(zoomInitiator, percentOfRangeToDisplay: percentOfRangeToDisplay)
            }
        }
        
        priv_isBlockingRecursiveUpdate = false
        
    } // end synchronizeZoom
    
    
    func setSliderPosition(percentOfRangeToDisplay: Double) -> Void {
        let sliderPosition: Double = (1.0 - percentOfRangeToDisplay) * zoomSlider.maxValue
        zoomSlider.doubleValue = sliderPosition
    }
    
    
    
    func synchronizeZoom(_ zoomInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
        
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        priv_isBlockingRecursiveUpdate = true
        
        let percentOfRangeToDisplay: Double =
            Double(toTimeStepRange.length) / Double(coordinator.timeStepsArray.count)
        
        setSliderPosition(percentOfRangeToDisplay: percentOfRangeToDisplay)
        
        for display in priv_displays {
            if display !== zoomInitiator {
                display.synchronizeZoom(zoomInitiator, toTimeStepRange: toTimeStepRange)
            }
        }
        
        priv_isBlockingRecursiveUpdate = false
        
    } // end synchronizeZoom
    
    
    
    func synchronizeSelect(_ selectionInitiator: DetailsDisplay, selectedTimeStepIndex: Int) -> Void {
        assert(selectedTimeStepIndex >= 0)
        
        if !priv_isBlockingRecursiveUpdate {
            priv_isBlockingRecursiveUpdate = true
            
            for display in priv_displays {
                if display !== selectionInitiator {
                    display.synchronizeSelect(selectionInitiator, selectedTimeStepIndex: selectedTimeStepIndex)
                }
            }
            
            priv_isBlockingRecursiveUpdate = false
        }
    } // end didSelect
    

    
    // MARK: *Private*
    
    fileprivate var priv_coordinator: DetailsCoordinator? = nil
    
    fileprivate var priv_displays = [DetailsDisplay]()
    
    
} // end class TimeStepGraphController


