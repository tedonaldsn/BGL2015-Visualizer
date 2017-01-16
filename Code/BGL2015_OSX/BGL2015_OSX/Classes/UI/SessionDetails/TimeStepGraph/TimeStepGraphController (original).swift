//
//  TimeStepGraphController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 6/30/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import CorePlot

class TimeStepGraphController: NSViewController,
    CPTScatterPlotDataSource, CPTPlotSpaceDelegate, CPTScatterPlotDelegate, CPTAxisDelegate,
DetailsDisplay {
    
    struct ScatterPlotParameters {
        var label: String
        var dataKey: String
        
        var lineWidth: CGFloat
        var lineColor: CPTColor
        var lineStyle: CPTLineStyle? // If nil, uses default
        
    } // end ScatterPlotParameters
    
    
    struct BarPlotParameters {
        var label: String
        var dataKey: String
        
        var lineWidth: CGFloat
        var lineColor: CPTColor
        var lineStyle: CPTLineStyle? // If nil, uses default
        
        var barFill: CPTFill
        var barWidth: CGFloat // percent of available width
        var barCornerRadius: CGFloat // pixels
        
    } // end BarPlotParameters
    
    
    
    // MARK: Outlets
    
    @IBOutlet weak var graphHostingView: CPTGraphHostingView!
    
    @IBOutlet weak var zoomSlider: NSSlider!
    
    
    
    // MARK: Actions
    
    @IBAction func zoomAction(sender: AnyObject) {
        assert(sender === zoomSlider)
        
        zoom(zoomSlider.integerValue)
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
    
    // MARK: Data
    
    let doubleClickZoomDelta = 20
    
    let scatterPlotDefinitions = [
        ScatterPlotParameters(label: "M'1 Activation",
            dataKey: "m1outActivation",
            lineWidth: 2.0,
            lineColor: CPTColor.orangeColor(),
            lineStyle: nil),
        ScatterPlotParameters(label: "M'2 Activation",
            dataKey: "m2outActivation",
            lineWidth: 2.0,
            lineColor: CPTColor.greenColor(),
            lineStyle: nil),
        ScatterPlotParameters(label: "S\"1–M\"1 Weight",
            dataKey: "s1m1Weight",
            lineWidth: 3.0,
            lineColor: CPTColor.purpleColor(),
            lineStyle: nil),
        ScatterPlotParameters(label: "S\"2–M\"2 Weight",
            dataKey: "s2m2Weight",
            lineWidth: 3.0,
            lineColor: CPTColor.blueColor(),
            lineStyle: nil)
    ]
    
    // Dictionary is initialized by addScatterPlot()
    //
    var scatterPlotParameters = [ String: ScatterPlotParameters ]()
    
    let barPlotDefinitions = [
        BarPlotParameters(label: "X",
            dataKey: "isXOn",
            lineWidth: 1.0,
            lineColor: CPTColor.redColor(),
            lineStyle: nil,
            barFill: CPTFill(color: CPTColor.redColor()),
            barWidth: 0.57,
            barCornerRadius: 4.0),
        BarPlotParameters(label: "Y",
            dataKey: "isYOn",
            lineWidth: 1.0,
            lineColor: CPTColor.yellowColor(),
            lineStyle: nil,
            barFill: CPTFill(color: CPTColor.yellowColor()),
            barWidth: 0.57,
            barCornerRadius: 4.0),
        BarPlotParameters(label: "Sr",
            dataKey: "isSrOn",
            lineWidth: 1.0,
            lineColor: CPTColor.whiteColor(),
            lineStyle: nil,
            barFill: CPTFill(color: CPTColor.whiteColor()),
            barWidth: 0.57,
            barCornerRadius: 4.0)
    ]
    
    var barPlotParameters = [ String: BarPlotParameters ]()
    
    
    // In various places while adjusting the display we report changes back
    // to the coordinator to allow it to synch up other displays. BUT: this
    // can/does result in recursive displays to self that have some really
    // bad effects. So, in places where we might trigger recursive calls,
    // we us a flag to simply exit recursive calls.
    //
    var isBlockingRecursiveScroll = false
    
    var hasGraph: Bool {
        let hosted: CPTXYGraph? = graphHostingView.hostedGraph as? CPTXYGraph
        return hosted != nil
    }
    var graph: CPTXYGraph {
        return (graphHostingView.hostedGraph as? CPTXYGraph)!
    }
    
    var trialTimeStepAxis: CPTXYAxis {
        let axisSet: CPTXYAxisSet = (graph.axisSet as? CPTXYAxisSet)!
        let x: CPTXYAxis = axisSet.xAxis!
        return x
    }
    
    var areDelegatesSet = false
    

    
    
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    

    
    
    
    // MARK: NSViewController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.autoresizingMask = [
            NSAutoresizingMaskOptions.ViewWidthSizable,
            NSAutoresizingMaskOptions.ViewMinYMargin
        ]
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        let notifier = NSNotificationCenter.defaultCenter()
        notifier.removeObserver(self)
        
        clearGraphDelegates()
        graphHostingView.hostedGraph = nil
    }
    
    
    
    // MARK: Manual Control
    
    
    
    
    func reloadData() {
        logger.logTrace("-->Enter reloadData()")
        graph.reloadData()
        zoom(priv_lastZoomLevel)
        trialTimeStepAxis.relabel()
        let plotSpace: CPTXYPlotSpace = (graph.defaultPlotSpace as? CPTXYPlotSpace)!
        let plotRange = plotSpace.xRange
        let scrollRange = NSMakeRange(plotRange.location.integerValue, plotRange.length.integerValue)
        coordinator.didScroll(self, toTimeStepRange: scrollRange)
        logger.logTrace("Exit reloadData() -->")
    }
    
    
    // MARK: DetailsDisplay Functions
    
    
    
    func prepareTimeStepDisplay() -> Void {
        assert(priv_coordinator != nil)
        
        isBlockingRecursiveScroll = true
        zoomSlider.integerValue = 0
        isBlockingRecursiveScroll = false
        
        createGraph()
        
    } // end prepareTimeStepDisplay
    
    
    
    func display(timeStepFilter: StepDisplayFilterSettings) -> Void {
        assert(priv_coordinator != nil)
        
        if !isBlockingRecursiveScroll {
            
            // Defer creation of graph as long as possible. It is slow, and it
            // can appear that nothing is happening. Allow window to display
            // first.
            //
            if !areDelegatesSet {
                isBlockingRecursiveScroll = true
                
                let delay = dispatch_time(DISPATCH_TIME_NOW, 1)
                
                dispatch_after(delay, dispatch_get_main_queue()) {
                    self.setGraphDelegates()
                    
                    dispatch_after(delay, dispatch_get_main_queue()) {
                        self.reloadData()
                        self.isBlockingRecursiveScroll = false
                    }
                }
                
            } else {
                isBlockingRecursiveScroll = true
                reloadData()
                isBlockingRecursiveScroll = false
            }
        }
        
    } // end displayTimeSteps
    
    
    func synchronizeScroll(scrollInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
        assert(toTimeStepRange.location >= 0)
        assert(toTimeStepRange.length >= 0)
        // assert(toTimeStepRange.location + toTimeStepRange.length <= timeStepsInGraph)
        
        if !isBlockingRecursiveScroll {
            isBlockingRecursiveScroll = true
            
            // logger.logDebug("Initiator: \(scrollInitiator), to range: \(toTimeStepRange)")
            
            let focalIndex = toTimeStepRange.location + (toTimeStepRange.length/2)
            
            scroll(toTimeStepIndex: focalIndex)
            
            isBlockingRecursiveScroll = false
        }
        
    } // end synchronizeScroll
    
    
    
    func scroll(toTimeStepIndex focalIndex: Int) {
        
        let plotSpace: CPTXYPlotSpace = (graph.defaultPlotSpace as? CPTXYPlotSpace)!
        let plotRange = plotSpace.xRange
        
        var newLocation = focalIndex - (plotRange.length.integerValue/2)
        if newLocation < 0 {
            newLocation = 0
        }
        
        plotSpace.xRange = CPTPlotRange(location: NSNumber(integer: newLocation),
                                        length: plotRange.length)
        
    } // end scroll
    
    
    
    // MARK: Setup
    
    func setGraphDelegates() {
        guard !areDelegatesSet else { return }
        
        logger.logTrace("--> Enter setGraphDelegates()")
        
        // graph.defaultPlotSpace!.delegate = self
        /*
        let axisSet: CPTXYAxisSet = (graph.axisSet as? CPTXYAxisSet)!
        axisSet.xAxis!.delegate = self
        axisSet.yAxis!.delegate = self
        */
        let allPlots = graph.allPlots()
        for plot in allPlots {
            plot.dataSource = self
            plot.delegate = self
        }
        
        let plotSpace: CPTXYPlotSpace = (graph.defaultPlotSpace as? CPTXYPlotSpace)!
        plotSpace.delegate = self
        plotSpace.allowsUserInteraction = true;
        
        areDelegatesSet = true
        
        logger.logTrace("Exit setGraphDelegates() -->")

    } // end setGraphDelegates
    
    
    func clearGraphDelegates() {
        guard areDelegatesSet else { return }
        
        logger.logTrace("--> Enter clearGraphDelegates()")
        
        let plotSpace: CPTXYPlotSpace = (graph.defaultPlotSpace as? CPTXYPlotSpace)!
        plotSpace.allowsUserInteraction = false;
        plotSpace.delegate = nil
        
        let allPlots = graph.allPlots()
        for plot in allPlots {
            plot.dataSource = nil
            plot.delegate = nil
        }
        areDelegatesSet = false
        
        logger.logTrace("Exit clearGraphDelegates() -->")
        
    } // end clearGraphDelegates
    
    
    func createGraph() {
        logger.logTrace("--> Enter createGraph()")
        precondition(!hasGraph)
        
        setupGraph()
        setupAxes()
        setupBarPlots()
        
        for parameters in scatterPlotDefinitions {
            addScatterPlot(parameters)
        }
        
        setupLegend()
        
        // NO: scaleToFitPlots() makes plot as small as possible to accommodate
        // the values on the plots. This ends up trimming the top off of the
        // weights and activations plot because no value can ever hit 1.0. But,
        // the graph looks a whole lot better with the full scale of 0.0-1.0 shown.
        // Plus: it makes all graph spaces the same height and more visually
        // comparable.
        //
        // let allPlots = graph.allPlots()
        // graph.defaultPlotSpace!.scaleToFitPlots(allPlots)

        logger.logTrace("Exit createGraph() -->")
        
    } // end createGraph
    
    
    func setupGraph() {
        
        let newGraph = CPTXYGraph(frame: CGRectZero)
        
        let theme = CPTTheme(named: kCPTSlateTheme)
        newGraph.applyTheme(theme)
        
        newGraph.plotAreaFrame!.masksToBorder = false
        
        newGraph.paddingBottom = 60.0
        newGraph.paddingLeft  = 80.0
        newGraph.paddingTop    = 20.0
        newGraph.paddingRight  = 20.0
        
        let plotSpace: CPTXYPlotSpace = (newGraph.defaultPlotSpace as? CPTXYPlotSpace)!
        
        let globalMinTimeStep = NSNumber(double: 0.0)
        let globalMaxTimeStep = NSNumber(double: Double(TrialsLooper.totalSteps))
        // let globalTimeStepRange = CPTPlotRange(location: globalMinTimeStep, length: globalMaxTimeStep)
        
        plotSpace.globalXRange = CPTPlotRange(location: globalMinTimeStep, length: globalMaxTimeStep)
        plotSpace.xRange = CPTPlotRange(location: globalMinTimeStep, length: globalMaxTimeStep)
        
        let minWeightActivation = NSNumber(double: 0.0)
        let maxWeightActivation = NSNumber(double: 1.0)
        let weightActivationRange = CPTPlotRange(location: minWeightActivation, length: maxWeightActivation)
        
        plotSpace.globalYRange = weightActivationRange
        plotSpace.yRange = weightActivationRange
        
        /*
         let titleStyle = CPTMutableTextStyle()
         titleStyle.color = CPTColor.whiteColor()
         titleStyle.fontName = "Helvetica-Bold";
         titleStyle.fontSize = 16.0
         
         let title = "Weights & Activations By Time Step";
         newGraph.title = title;
         newGraph.titleTextStyle = titleStyle;
         newGraph.titlePlotAreaFrameAnchor = CPTRectAnchor.Top;
         newGraph.titleDisplacement = CGPointMake(0.0, -16.0)
         */
        graphHostingView.hostedGraph = newGraph
        
    } // end setupGraph
    
    
    
    func setupLegend() {
        let legend = CPTLegend(graph: graph)
        
        // legend.textStyle = x.titleTextStyle;
        // legend.borderLineStyle = x.axisLineStyle;
        
        // Alpha channel: 0.0 is fully transparent, 1.0 is fully opaque
        //
        let legendFillColor = CPTColor.whiteColor().colorWithAlphaComponent(0.50)
        legend.fill = CPTFill(color: legendFillColor)
        legend.cornerRadius = 5.0;
        legend.swatchSize = CGSizeMake(25.0, 25.0);
        
        legend.numberOfColumns = 1;
        
        graph.legendAnchor = CPTRectAnchor.TopLeft
        graph.legendDisplacement = CGPointMake(100.0, -35.0);
        
        graph.legend = legend;
    }
    
    
    
    func setupAxes() {

        setupTrialTimeStepAxis()
        setupWeightActivationLevelAxis()
    
    } // end setupAxes
    
    
    func setupTrialTimeStepAxis() {
        
        // Grid line styles
        let majorGridLineStyle: CPTMutableLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.75;
        majorGridLineStyle.lineColor = CPTColor(genericGray: 0.2).colorWithAlphaComponent(0.75)
        
        let minorGridLineStyle: CPTMutableLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25;
        minorGridLineStyle.lineColor = CPTColor(genericGray: 0.2).colorWithAlphaComponent(0.1)
        
        // Label x axis with a fixed interval policy
        
        let x = trialTimeStepAxis
        
        // Set delegate so we can provide customized labels.
        //
        x.delegate = self
        
        x.orthogonalPosition = NSNumber(double: 0.0)
        x.axisConstraints = CPTConstraints.constraintWithLowerOffset(0.0)
        
        // Contrary to documentation for Core Plot (Mac OS) at
        //
        // http://core-plot.github.io/MacOS/protocol_c_p_t_axis_delegate-p.html#a859270e9a0fb2a7174ffe760e9663ac7
        //
        // if the labeling policy is "none", the axis delegate method
        // axis:shouldUpdateAxisLabelsAtLocations: will NOT be called.
        //
        x.labelingPolicy = CPTAxisLabelingPolicy.FixedInterval
        
        // preferredNumberOfMajorTicks only applies when labeling policy is
        // Automatic or EqualDivisions. But when FixedInterval, we use it to
        // compute the majorIntervalLength.
        //
        x.preferredNumberOfMajorTicks = 15
        
        // majorIntervalLength does not apply when labeling policy is Automatic.
        // Used when policy is FixedInterval.
        //
        let stepsPerTick = UInt(TrialsLooper.totalSteps) / x.preferredNumberOfMajorTicks
        x.majorIntervalLength = stepsPerTick
        
        x.minorTicksPerInterval = 0
        
        x.majorGridLineStyle = majorGridLineStyle
        x.minorGridLineStyle = minorGridLineStyle
        x.title = "Trial-TimeStep"
        x.titleOffset = 30.0
        
    } // end setupTrialTimeStepAxis
    
    
    func setupWeightActivationLevelAxis() {
        
        // Grid line styles
        let majorGridLineStyle: CPTMutableLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.75;
        majorGridLineStyle.lineColor = CPTColor(genericGray: 0.2).colorWithAlphaComponent(0.75)
        
        let minorGridLineStyle: CPTMutableLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25;
        minorGridLineStyle.lineColor = CPTColor(genericGray: 0.2).colorWithAlphaComponent(0.1)

        // Label y with an automatic label policy.
        
        let axisSet: CPTXYAxisSet = (graph.axisSet as? CPTXYAxisSet)!
        let y: CPTXYAxis = axisSet.yAxis!
        
        y.orthogonalPosition = NSNumber(double: 0.0)
        y.axisConstraints = CPTConstraints.constraintWithLowerOffset(0.0)
        
        y.labelingPolicy = CPTAxisLabelingPolicy.Automatic
        y.minorTicksPerInterval = 0
        y.preferredNumberOfMajorTicks = 10
        y.majorGridLineStyle = majorGridLineStyle
        y.minorGridLineStyle = minorGridLineStyle
        y.labelOffset = 10.0
        y.title = "Weight & Activation"
        y.titleOffset = 50.0
        
    } // end setupWeightActivationLevelAxis
    
    
    

    
    
    func addScatterPlot(parameters: ScatterPlotParameters) {
        scatterPlotParameters[parameters.label] = parameters
        
        let plot = CPTScatterPlot()
        
        plot.identifier = parameters.label
        plot.cachePrecision = CPTPlotCachePrecision.Double
        
        // Give a little latitude for detecting clicks on plot
        //
        plot.plotSymbolMarginForHitDetection = 30.0
        
        let sampleLineStyle = parameters.lineStyle ?? plot.dataLineStyle!
        let mutableLineStyle = (sampleLineStyle.mutableCopy() as? CPTMutableLineStyle)!
        
        mutableLineStyle.lineWidth = parameters.lineWidth
        mutableLineStyle.lineColor = parameters.lineColor
        plot.dataLineStyle = mutableLineStyle
        
        // plot.dataSource = self
        // plot.delegate = self
        
        graph.addPlot(plot)
        
    } // end addScatterPlot
    
    
    func setupBarPlots() {
        for parameters in barPlotDefinitions {
            barPlotParameters[parameters.label] = parameters
            
            let plot = CPTBarPlot()
            
            plot.identifier = parameters.label
            plot.cachePrecision = CPTPlotCachePrecision.Double
            
            let mutableLineStyle = CPTMutableLineStyle()
            
            mutableLineStyle.lineWidth = parameters.lineWidth
            mutableLineStyle.lineColor = parameters.lineColor
            plot.lineStyle = mutableLineStyle
            
            plot.fill = parameters.barFill
            plot.barWidth = parameters.barWidth
            plot.barBaseCornerRadius = parameters.barCornerRadius
            plot.barsAreHorizontal = false

            // plot.dataSource = self
            // plot.delegate = self
            
            graph.addPlot(plot)
        }
    }
    

    
    var maximumGraphPlotRangeLength: Int {
        let pad = TrialsLooper.maxStepsPerTrial
        if let count = timeSteps.arrangedObjects.count {
            return count + pad
        }
        return pad
    }
    
    
    
    // MARK: Displayed Items
    
    // Zoom to the requested level out of a possible 100. Adjust the zoom level
    // if the zoom would show fewer steps than there currently are available
    // per trial.
    //
    // Records the zoom level so that it can be used to reestablish the same
    // zoom if other actions reload data.
    //
    func zoom(requestedZoom: Int) -> Void {
        assert(requestedZoom >= 0)
        assert(requestedZoom <= 100)
        
        // guard requestedZoom != priv_lastZoomLevel else { return }
        priv_lastZoomLevel = requestedZoom
        
        let plotSpace: CPTXYPlotSpace = (graph.defaultPlotSpace as? CPTXYPlotSpace)!
        let plotRange = plotSpace.xRange
        let oldLocation = plotRange.location.doubleValue
        let oldLength = plotRange.length.doubleValue
        
        let zoomProportion = (100.0 - Double(requestedZoom)) / 100.0
        
        var newLength = Double(maximumGraphPlotRangeLength) * zoomProportion
        if newLength < Double(1) {
            newLength = Double(1)
        }
        let deltaLength = oldLength - newLength
        var newLocation = oldLocation - (deltaLength/2.0)
        if newLocation < 0.0 {
            newLocation = 0.0
        }
        
        let newRange =  CPTPlotRange(location: NSNumber(double: Double(newLocation)),
                                     length: NSNumber(double: newLength))
        
        let x = trialTimeStepAxis
        var stepsPerTick = UInt(newLength) / x.preferredNumberOfMajorTicks
        if stepsPerTick == 0 {
            stepsPerTick = 1
        }
        x.majorIntervalLength = stepsPerTick
        x.relabel()
        
        plotSpace.xRange = newRange
        
    } // end zoom

    
    
    


    
    // MARK: Plot datasource methods
    
    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        
        // If time steps have been supplied via Core Data, then the count
        // must be the expected, fixed, number.
        //
        let timeStepsInData = timeSteps.arrangedObjects.count ?? 0
        let graphPositions = timeStepsInData + 1
        
        return UInt(graphPositions)
        
    } // end numberOfRecordsForPlot
    
    
    
    
    // There is no zeroth item on the display: return nil for the zeroth 
    // display position.
    //
    // However, data items use zero based indexing, so we will then need to 
    // subtract one from the display index to get the data index.
    //
    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject? {
        
        guard idx > 0 else { return nil }
        
        let xGraphPosition: Int = Int(idx)
        let dataItemIndex = xGraphPosition - 1
        
        let fieldId: Int = Int(fieldEnum)
        
        
        if fieldId == CPTScatterPlotField.X.rawValue {
            return NSNumber(integer: xGraphPosition)
            
        } else if fieldId == CPTScatterPlotField.Y.rawValue {
            
            let plotId = (plot.identifier as? String)!
            
            if let descriptor = scatterPlotParameters[plotId] {
                
                let steps: [Step] = (timeSteps.arrangedObjects as? [Step])!
                let step: Step = steps[dataItemIndex]
                
                let dataKey = descriptor.dataKey
                let value = step.valueForKey(dataKey) as? NSNumber
                
                return value
                
            } else if let descriptor = barPlotParameters[plotId] {
                
                let steps: [Step] = (timeSteps.arrangedObjects as? [Step])!
                let step: Step = steps[dataItemIndex]
                
                let dataKey = descriptor.dataKey
                let value = step.valueForKey(dataKey) as? NSNumber
                
                return value
            }
        }
        
        return nil
        
    } // end numberForPlot
    
    
    
    
    // MARK: CPTPlotSpaceDelegate Protocol
    
    func plotSpace(space: CPTPlotSpace,
                   didChangePlotRangeForCoordinate coordinate: CPTCoordinate) {
        
        if !isBlockingRecursiveScroll && coordinate == CPTCoordinate.X {
            isBlockingRecursiveScroll = true
            
            if let plotSpace = space as? CPTXYPlotSpace {
                let range: NSRange = NSMakeRange(plotSpace.xRange.location.integerValue,
                                                 plotSpace.xRange.length.integerValue)
                coordinator.didScroll(self, toTimeStepRange: range)
            }
            
            isBlockingRecursiveScroll = false
        }
    } // end plotSpace didChangePlotRangeForCoordinate
    
    
    func plotSpace(space: CPTPlotSpace, shouldHandlePointingDeviceUpEvent event: NSEvent, atPoint point: CGPoint) -> Bool {
        
        logger.logDebug("space: \(space), event: \(event), point: \(point)")
        return true
        
    } // end plotSpace shouldHandlePointingDeviceUpEvent
    
    
    
    func plotSpace(space: CPTPlotSpace, shouldHandlePointingDeviceDownEvent event: NSEvent, atPoint point: CGPoint) -> Bool {
        
        logger.logDebug("space: \(space), event: \(event), point: \(point)")
        return true
        
    } // end plotSpace shouldHandlePointingDeviceDownEvent
    
    
    
    // MARK: CPTScatterPlotDelegate Protocol
    
    func scatterPlot(plot: CPTScatterPlot, plotSymbolWasSelectedAtRecordIndex idx: UInt, withEvent event: NSEvent) {
        
        // logger.logDebug("plot: \(plot.identifier), record index: \(idx), event: \(event)")
        
        let clickNumber = event.clickCount
        if clickNumber == 2 {
            let currentZoom = zoomSlider.integerValue
            
            let modifierFlags: NSEventModifierFlags = event.modifierFlags
            if modifierFlags.contains(NSEventModifierFlags.ShiftKeyMask) {
                if currentZoom >= Int(zoomSlider.minValue) + doubleClickZoomDelta {
                    let newZoom = currentZoom - doubleClickZoomDelta
                    zoom(newZoom)
                    scroll(toTimeStepIndex: Int(idx))
                    zoomSlider.integerValue = newZoom
                }
            } else {
                if currentZoom <= Int(zoomSlider.maxValue) - doubleClickZoomDelta {
                    let newZoom = currentZoom + doubleClickZoomDelta
                    zoom(newZoom)
                    scroll(toTimeStepIndex: Int(idx))
                    zoomSlider.integerValue = newZoom
                }
            }

        }
        
    } // end scatterPlot plotSymbolWasSelectedAtRecordIndex
    
    
    // MARK: CPTAxisDelegate Labeling
    
    
    func axisShouldRelabel(axis: CPTAxis) -> Bool {
        
        // Swift.print("axis: \(axis), delegate: \(axis.delegate)")
        
        return true //  axis.coordinate == CPTCoordinate.X
    }
    
    
    // Updates labels on the trials/timesteps axis (i.e., X axis)
    //
    // Text of label is the trial number.
    //
    // All other axis (currently just the Y-activation/weight level) automatically.
    //
    
    func axis(axis: CPTAxis, shouldUpdateAxisLabelsAtLocations locations: Set<NSNumber>) -> Bool {
        
        // If any axis other than the trials/timesteps axis (i.e., X), tell
        // Core Plot to do automatic labeling.
        //
        guard axis.coordinate == CPTCoordinate.X else { return true }
        
        logger.logDebug("Location count: \(locations.count)")
        
        let labelRotation = axis.labelRotation
        let labelAlignment = axis.labelAlignment
        let labelOffset = axis.labelOffset
        
        let textStyle = CPTMutableTextStyle(style: axis.labelTextStyle)
        textStyle.color = CPTColor.blackColor()
        
        // let tickDirection = axis.tickDirection
        // let orthogonalCoordinate = CPTOrthogonalCoordinate(axis.coordinate)
        
        // Not sure exactly what this call does. The Core Plot documentation
        // simply reiterates the name of the function. And below we explicitly
        // assign content layers to the axis label group.
        //
        // WILL TRY COMMENTING IT OUT AT SOME POINT
        //
        let plotArea: CPTPlotArea = axis.plotArea!
        plotArea.setAxisSetLayersForType(CPTGraphLayerType.AxisLabels)
        
        var currentLabels = Set<CPTAxisLabel>()
        
        // Core Data items being plotted. Labels will be based on contents
        // of specified items. For now: just the trial number.
        //
        let steps: [Step] = (timeSteps.arrangedObjects as? [Step])!
        
        for location in locations {
            
            let xGraphPosition: Int = Int(location.doubleValue)
            let dataItemIndex = xGraphPosition - 1
            
            if dataItemIndex >= 0 && dataItemIndex < steps.count {
                
                let timeStep: Step = steps[dataItemIndex]
                let trialNumber = Int(timeStep.trialNumber)
                let stepIndex = Int(timeStep.trialStepNumber)
                
                let labelText = "\(trialNumber)-\(stepIndex)"
                
                let contentLayer = CPTTextLayer(text: labelText, style: textStyle)
                let label = CPTAxisLabel(contentLayer: contentLayer)
                
                label.tickLocation = location
                label.rotation = labelRotation
                label.offset = labelOffset
                label.alignment = labelAlignment
                
                currentLabels.insert(label)
            }
        }
        
        axis.axisLabels = currentLabels
        axis.needsLayout()
        
        return false // No, don't go ahead and do any kind of default labelling.
        
    } // end axis shouldUpdateAxisLabelsAtLocations
    
    
    
    
    // MARK: *Private*
    
    
    private var priv_coordinator: DetailsCoordinator? = nil
    
    private var priv_lastZoomLevel = 0
    
    
} // end class TimeStepGraphController


