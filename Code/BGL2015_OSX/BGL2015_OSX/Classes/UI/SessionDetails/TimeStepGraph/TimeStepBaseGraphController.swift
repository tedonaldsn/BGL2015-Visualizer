//
//  TimeStepBaseGraphController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 7/16/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//


import Cocoa
import CorePlot



class TimeStepBaseGraphController: NSViewController, DetailsDisplay,
    CPTScatterPlotDataSource, CPTPlotSpaceDelegate, CPTAxisDelegate
{
    
    
    
    static let minZoomPercent: Double = 0.001
    static let minZoomTimeSteps: Double = 100.0
    
    
    
    // MARK: Outlets
    
    
    weak var corePlotHostingView: CPTGraphHostingView!
    
    
    
    // MARK: Actions
    
    
    
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
    
    
    var cursorIndex: Int {
        return priv_cursorPosition
    }
    var range: NSRange {
        let plotRange: CPTPlotRange = plotSpace.xRange
        return NSRange(location: Int(plotRange.locationDouble),
                       length: Int(plotRange.lengthDouble))
    }
    
    
    let cursorPlotIdentifier = "cursor"
    
    var cursorPlot: CPTBarPlot {
        return graph.plot(withIdentifier: cursorPlotIdentifier as NSCopying?)! as! CPTBarPlot
    }
    
    var isLegendEnabled = false
    
    var plotDefinitions: [PlotDefinition] {
        return priv_plotDefinitions.definitions
    }
    
    let doubleClickZoomPercentDelta: Double = 0.125
    
    // In various places while adjusting the display we report changes back
    // to the coordinator to allow it to synch up other displays. BUT: this
    // can/does result in recursive displays to self that have some really
    // bad effects. So, in places where we might trigger recursive calls,
    // we us a flag to simply exit recursive calls.
    //
    var priv_isBlockingRecursiveUpdate = false
    
    var hasGraph: Bool {
        let hosted: CPTXYGraph? = corePlotHostingView.hostedGraph as? CPTXYGraph
        return hosted != nil
    }
    var graph: CPTXYGraph {
        let graph = corePlotHostingView.hostedGraph
        let xyGraph = graph as? CPTXYGraph
        return xyGraph!
    }
    
    // Entire area of the graph, including plotting area, axes, titles, etc.
    //
    var plotSpace: CPTXYPlotSpace {
        return (graph.defaultPlotSpace as? CPTXYPlotSpace)!
    }
    
    // Area within which data is plotted.
    //
    var plotArea: CPTPlotArea {
        return graph.plotAreaFrame!.plotArea!
    }
    
    var timeStepAxis: CPTXYAxis {
        let axisSet: CPTXYAxisSet = (graph.axisSet as? CPTXYAxisSet)!
        let x: CPTXYAxis = axisSet.xAxis!
        return x
    }
    
    
    
    var majorGridLineStyle: CPTLineStyle {
        let lineStyle: CPTMutableLineStyle = CPTMutableLineStyle()
        lineStyle.lineWidth = 0.75;
        lineStyle.lineColor = CPTColor(genericGray: 0.2).withAlphaComponent(0.75)
        return lineStyle
    }
    
    var minorGridLineStyle: CPTLineStyle {
        let lineStyle: CPTMutableLineStyle = CPTMutableLineStyle()
        lineStyle.lineWidth = 0.25;
        lineStyle.lineColor = CPTColor(genericGray: 0.2).withAlphaComponent(0.1)
        return lineStyle
    }
    
    
    
    var areDelegatesSet = false
    
    var isClosed: Bool { return priv_isClosed }
    
    
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func appendPlotDefinition(_ definition: PlotDefinition) {
        priv_plotDefinitions.append(definition)
    }
    func appendPlotDefinitions(_ definitions: [PlotDefinition]) {
        for definition in definitions {
            appendPlotDefinition(definition)
        }
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
        
        priv_isBlockingRecursiveUpdate = true
        if !hasGraph {
            createGraph()
            setGraphDelegates()
            zoom(1)
        }
        priv_isBlockingRecursiveUpdate = false
        
    } // end viewWillAppear
    
    
    override func viewDidAppear() {
        super.viewDidAppear()
        reloadData()
    }
    
    
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        let notifier = NotificationCenter.default
        notifier.removeObserver(self)
        
        clearGraphDelegates()
        corePlotHostingView.hostedGraph = nil
    }

    
    
    // MARK: DetailsDisplay Functions
    
    func willClose() {
        guard !priv_isClosed else { return }
        
        priv_isClosed = true
        clearGraphDelegates()
    }
    
    func reloadData() -> Void {
        assert(priv_coordinator != nil)
        
        guard !priv_isClosed else { return }
        
        if !priv_isBlockingRecursiveUpdate {
            
            // Defer creation of graph as long as possible. It is slow, and it
            // can appear that nothing is happening. Allow window to display
            // first.
            //
            if !areDelegatesSet {
                priv_isBlockingRecursiveUpdate = true
                
                let delay = DispatchTime.now() + Double(1) / Double(NSEC_PER_SEC)
                
                DispatchQueue.main.asyncAfter(deadline: delay) {
                    self.setGraphDelegates()
                    
                    DispatchQueue.main.asyncAfter(deadline: delay) {
                        self.priv_reloadTimeSteps()
                        self.priv_isBlockingRecursiveUpdate = false
                    }
                }
                
            } else {
                priv_isBlockingRecursiveUpdate = true
                priv_reloadTimeSteps()
                priv_isBlockingRecursiveUpdate = false
            }
        }
        
    } // end displayTimeSteps
    
    
    func synchronizeScroll(_ scrollInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
        assert(toTimeStepRange.location >= 0)
        assert(toTimeStepRange.length >= 0)
        
        guard !priv_isClosed else { return }
        
        if !priv_isBlockingRecursiveUpdate {
            priv_isBlockingRecursiveUpdate = true
            
            let focalIndex = toTimeStepRange.location + (toTimeStepRange.length/2)
            
            scroll(toTimeStepIndex: focalIndex)
            
            priv_isBlockingRecursiveUpdate = false
        }
        
    } // end synchronizeScroll
    
    
    
    func scroll(toTimeStepIndex focalIndex: Int) {
        
        guard !priv_isClosed else { return }
        
        let plotRange = plotSpace.xRange
        
        var newLocation = focalIndex - (plotRange.length.intValue/2)
        if newLocation < 0 {
            newLocation = 0
        }
        
        plotSpace.xRange = CPTPlotRange(location: NSNumber(value: newLocation),
                                        length: plotRange.length)
        
    } // end scroll
    
    
    func isTimeStepInPlotRange(_ timeStepIndex: Int) -> Bool {
        let plotRange = plotSpace.xRange
        let minX = plotRange.location.intValue
        let maxX = plotRange.length.intValue + minX
        return timeStepIndex >= minX && timeStepIndex <= maxX
    }
    
    
    func synchronizeSelect(_ selectionInitiator: DetailsDisplay, selectedTimeStepIndex: Int) -> Void {
        
        guard !priv_isClosed else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
        guard selectedTimeStepIndex != priv_cursorPosition else { return }
        
        priv_isBlockingRecursiveUpdate = true
        
        let oldCursorPosition = priv_cursorPosition
        priv_cursorPosition = selectedTimeStepIndex
        
        let plotRange = plotSpace.xRange
        let rangeLength = plotRange.length.intValue
        let currentStartLocation = plotRange.location.intValue
        let currentEndLocation = currentStartLocation + rangeLength
        var newStartLocation = currentStartLocation
        
        if priv_cursorPosition < plotRange.location.intValue {
            newStartLocation = priv_cursorPosition
            
        } else if priv_cursorPosition > currentEndLocation {
            newStartLocation = priv_cursorPosition - rangeLength
        }
        
        if newStartLocation != currentStartLocation {
            plotSpace.xRange = CPTPlotRange(location: NSNumber(value: newStartLocation),
                                            length: plotRange.length)
        }
        
        if oldCursorPosition < timeStepsArray.count {
            cursorPlot.reloadData(inIndexRange: NSMakeRange(oldCursorPosition, 1))
        }
        cursorPlot.reloadData(inIndexRange: NSMakeRange(priv_cursorPosition, 1))
        
        if !isTimeStepInPlotRange(priv_cursorPosition) {
            scroll(toTimeStepIndex: priv_cursorPosition)
        }
        
        priv_isBlockingRecursiveUpdate = false
        
    } // end synchronizeSelect
    
    
    
    // MARK: Setup
    
    func createGraph() {
        precondition(!hasGraph)
        
        setupGraph()
        setupVerticalPaddingAroundGraph()
        setupAxes()
        setupTimeStepAxisLabels()
        setupWeightActivationLevelAxisLabels()
        
        for definition in plotDefinitions {
            let plot = definition.createPlot()
            graph.add(plot)
        }
        
        if isLegendEnabled {
            setupLegend()
        }
        
        setupCursorPlot()
        
        // NO: scaleToFitPlots() makes plot as small as possible to accommodate
        // the values on the plots. This ends up trimming the top off of the
        // weights and activations plot because no value can ever hit 1.0. But,
        // the graph looks a whole lot better with the full scale of 0.0-1.0 shown.
        // Plus: it makes all graph spaces the same height and more visually
        // comparable.
        //
        // let allPlots = graph.allPlots()
        // graph.defaultPlotSpace!.scaleToFitPlots(allPlots)
        
    } // end createGraph
    
    
    func setupGraph() {
        
        let newGraph = CPTXYGraph(frame: CGRect.zero)
        
        // let theme = CPTTheme(named: kCPTPlainWhiteTheme)
        let theme = CPTTheme(named: CPTThemeName.slateTheme)
        newGraph.apply(theme)
        
        newGraph.plotAreaFrame!.masksToBorder = false
        
        newGraph.paddingLeft  = 80.0
        newGraph.paddingRight  = 20.0
        
        let globalMinTimeStep = NSNumber(value: 0.0 as Double)
        let globalMaxTimeStep = NSNumber(value: Double(TrialsLooper.totalSteps) as Double)
        // let globalTimeStepRange = CPTPlotRange(location: globalMinTimeStep, length: globalMaxTimeStep)
        
        let plotSpace = (newGraph.defaultPlotSpace as? CPTXYPlotSpace)!
        plotSpace.globalXRange = CPTPlotRange(location: globalMinTimeStep, length: globalMaxTimeStep)
        plotSpace.xRange = CPTPlotRange(location: globalMinTimeStep, length: globalMaxTimeStep)
        
        let minWeightActivation = NSNumber(value: 0.0 as Double)
        let maxWeightActivation = NSNumber(value: 1.0 as Double)
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
        corePlotHostingView.hostedGraph = newGraph
        
    } // end setupGraph
    
    
    
    func setupVerticalPaddingAroundGraph() {
        
        graph.paddingBottom = 60.0
        graph.paddingTop    = 10.0
        
    } // end setupPaddingAroundGraph
    
    
    
    func setupLegend() {
        let legend = CPTLegend(graph: graph)
        
        // legend.textStyle = x.titleTextStyle;
        // legend.borderLineStyle = x.axisLineStyle;
        
        // Alpha channel: 0.0 is fully transparent, 1.0 is fully opaque
        //
        let legendFillColor = CPTColor.white().withAlphaComponent(0.95)
        legend.fill = CPTFill(color: legendFillColor)
        legend.cornerRadius = 5.0;
        legend.swatchSize = CGSize(width: 20.0, height: 20.0);
        
        legend.numberOfColumns = 1;
        
        graph.legendAnchor = CPTRectAnchor.topLeft
        graph.legendDisplacement = CGPoint(x: 100.0, y: -18.0);
        
        priv_legend = legend
        graph.legend = priv_legend;
    }
    
    func toggleLegend() -> Void {
        if isLegendEnabled {
            if graph.legend == nil {
                graph.legend = priv_legend
            } else {
                graph.legend = nil
            }
        }
    }
    
    func setupAxes() {
        
        let axisSet: CPTXYAxisSet = (graph.axisSet as? CPTXYAxisSet)!
        let x: CPTXYAxis = axisSet.xAxis!
        
        x.orthogonalPosition = NSNumber(value: 0.0)
        x.axisConstraints = CPTConstraints.constraint(withLowerOffset: 0.0)
        
        // Contrary to documentation for Core Plot (Mac OS) at
        //
        // http://core-plot.github.io/MacOS/protocol_c_p_t_axis_delegate-p.html#a859270e9a0fb2a7174ffe760e9663ac7
        //
        // if the labeling policy is "none", the axis delegate method
        // axis:shouldUpdateAxisLabelsAtLocations: will NOT be called.
        //
        x.labelingPolicy = CPTAxisLabelingPolicy.fixedInterval
        //
        // preferredNumberOfMajorTicks only applies when labeling policy is
        // Automatic or EqualDivisions. But when FixedInterval, we use it to
        // compute the majorIntervalLength.
        //
        x.preferredNumberOfMajorTicks = 20
        //
        // majorIntervalLength does not apply when labeling policy is Automatic.
        // Used when policy is FixedInterval.
        //
        let stepsPerTick = UInt(TrialsLooper.totalSteps) / x.preferredNumberOfMajorTicks
        x.majorIntervalLength = stepsPerTick as NSNumber?
        x.minorTicksPerInterval = 0
        x.majorGridLineStyle = majorGridLineStyle
        x.minorGridLineStyle = minorGridLineStyle
        
        
        let y: CPTXYAxis = axisSet.yAxis!
        
        y.orthogonalPosition = NSNumber(value: 0.0)
        y.axisConstraints = CPTConstraints.constraint(withLowerOffset: 0.0)
        
        y.minorTicksPerInterval = 0
        y.preferredNumberOfMajorTicks = 10
        
    } // end setupAxes
    
    
    
    func setupTimeStepAxisLabels() {
        //
        // Default: No labels.
        //
        let x = timeStepAxis
        x.labelingPolicy = CPTAxisLabelingPolicy.none
        
    } // end setupTimeStepAxis
    
    
    
    func setupWeightActivationLevelAxisLabels() {
        //
        // Default: No labels.
        //
        let axisSet: CPTXYAxisSet = (graph.axisSet as? CPTXYAxisSet)!
        let y: CPTXYAxis = axisSet.yAxis!
        y.labelingPolicy = CPTAxisLabelingPolicy.none
    }
    
    func setupCursorPlot() -> Void {
        let plot = CPTBarPlot()
        
        plot.identifier = cursorPlotIdentifier as (NSCoding & NSCopying & NSObjectProtocol)?
        plot.cachePrecision = CPTPlotCachePrecision.double
        
        let mutableLineStyle = CPTMutableLineStyle()
        mutableLineStyle.lineWidth = 1.0
        mutableLineStyle.lineColor = CPTColor.black()//.withAlphaComponent(0.65)
        plot.lineStyle = mutableLineStyle
        
        //plot.fill = CPTFill(color: CPTColor.black().withAlphaComponent(0.2))
        
        
        plot.barWidth = 1.0
        plot.barCornerRadius = 10.0
        
        plot.barBaseCornerRadius = plot.barCornerRadius
        plot.barsAreHorizontal = false
        graph.add(plot)
    }
    
    
    // The cursor width is the proportion of the space used to display one
    // time step. When only a few time steps are displayed, a cursor that
    // is size 1.0 will be very large. When many are displayed, a cursor
    // that is size 1.0 will be difficult to see.
    //
    // Adjust the size of the cursor to be be more consistent and readily
    // visible at all times.
    //
    let cursorWidthMaximumSteps = 2.5
    
    func scaleCursor() -> Void {
        
        let totalTimeSteps = timeStepsArray.count
        let timeStepsDisplayed = range.length
        
        let proportion = Double(timeStepsDisplayed) / Double(totalTimeSteps)
        
        let width: Double = cursorWidthMaximumSteps * proportion
        
        let plot = cursorPlot
        
        plot.barWidth = NSNumber(value: width)
        
    } // end scaleCursor
    
    

    
    func setGraphDelegates() {
        guard !areDelegatesSet else { return }
        
        let allPlots = graph.allPlots()
        for plot in allPlots {
            plot.dataSource = self
            plot.delegate = self
        }
        
        plotArea.delegate = self
        
        plotSpace.delegate = self
        plotSpace.allowsUserInteraction = true;
        
        areDelegatesSet = true
        
    } // end setGraphDelegates
    
    
    func clearGraphDelegates() {
        guard areDelegatesSet else { return }
        
        plotSpace.allowsUserInteraction = false;
        plotSpace.delegate = nil
        
        plotArea.delegate = nil
        
        let allPlots = graph.allPlots()
        for plot in allPlots {
            plot.dataSource = nil
            plot.delegate = nil
        }
        
        // graph.plotAreaFrame!.plotArea!.delegate = nil
        
        areDelegatesSet = false
        
    } // end clearGraphDelegates
    
    
    // MARK: X Axis Length
    
    var maximumGraphPlotRangeLength: Int {
        let pad = TrialsLooper.maxStepsPerTrial
        return timeStepsArray.count + pad
    }
    
    
    
    // MARK: Zoom
    
    // Zoom to the requested level out of a possible 100. Adjust the zoom level
    // if the zoom would show fewer steps than there currently are available
    // per trial.
    //
    // percentOfRangeToDisplay is the proportion of time steps to show. Thus, 1.0 is all
    // steps, and 0.0 is no steps. But set a minimum number of time steps to
    // show at 0.1% (0.001), and an absolute 10.0 steps.
    //
    // Records the zoom level so that it can be used to reestablish the same
    // zoom if other actions reload data.
    //
    func zoom(_ percentOfRangeToDisplay: Double) -> Void {
        assert(percentOfRangeToDisplay >= 0.0)
        assert(percentOfRangeToDisplay <= 1.0)

        let effectiveZoom = percentOfRangeToDisplay < TimeStepBaseGraphController.minZoomPercent
            ? TimeStepBaseGraphController.minZoomPercent
            : percentOfRangeToDisplay

        let prevFlagValue = priv_isBlockingRecursiveUpdate
        priv_isBlockingRecursiveUpdate = true
        
        var newLength = Double(maximumGraphPlotRangeLength) * effectiveZoom
        if newLength < TimeStepBaseGraphController.minZoomTimeSteps {
            newLength = TimeStepBaseGraphController.minZoomTimeSteps
        }

        var newLocation = priv_cursorPosition - Int(newLength / 2)
        if newLocation < 0 {
            newLocation = 0
        }
        
        zoomTo(NSMakeRange(Int(newLocation), Int(newLength)))
        
        coordinator.didZoom(self, percentOfRangeToDisplay: percentOfRangeToDisplay)
        
        priv_isBlockingRecursiveUpdate = prevFlagValue
        
    } // end zoom
    
    
    func zoomTo(_ range: NSRange) -> Void {
        
        let totalLength: Double = Double(coordinator.timeStepsArray.count)
        
        var newLocation: Double = Double(range.location)
        var newLength: Double = Double(range.length)
        
        if newLength < TimeStepBaseGraphController.minZoomTimeSteps {
            newLength = TimeStepBaseGraphController.minZoomTimeSteps
        }
        
        if newLocation + newLength > totalLength {
            newLocation = totalLength - newLength
        }
        
        if newLocation < 0.0 {
            newLocation = 0.0
        }
        
        if newLocation + newLength > totalLength {
            newLength = totalLength - newLocation
        }
        
        assert(newLocation >= 0.0)
        assert(newLocation < totalLength)
        assert(newLength > 0)

        
        priv_lastZoomPercent = newLength / totalLength
        if priv_lastZoomPercent > 1.0 {
            priv_lastZoomPercent = 1.0
        }
        if priv_lastZoomPercent < TimeStepBaseGraphController.minZoomPercent {
            priv_lastZoomPercent = TimeStepBaseGraphController.minZoomPercent
        }
        
        let newRange =  CPTPlotRange(location: NSNumber(value: newLocation),
                                     length: NSNumber(value: newLength))
        
        let x = timeStepAxis
        var stepsPerTick = UInt(range.length) / x.preferredNumberOfMajorTicks
        if stepsPerTick == 0 {
            stepsPerTick = 1
        }
        x.majorIntervalLength = stepsPerTick as NSNumber?
        x.relabel()
        
        plotSpace.xRange = newRange
        
        // Size the cursor bar to the size of the range.
        //
        scaleCursor()

    } // end zoomTo
    
    
    func synchronizeZoom(_ zoomInitiator: DetailsDisplay, percentOfRangeToDisplay: Double) -> Void {
        guard !priv_isClosed else { return }
        guard zoomInitiator !== self else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        priv_isBlockingRecursiveUpdate = true
        zoom(percentOfRangeToDisplay)
        priv_isBlockingRecursiveUpdate = false
        
    } // end synchronizeZoom
    
    
    func synchronizeZoom(_ zoomInitiator: DetailsDisplay, toTimeStepRange: NSRange) -> Void {
        guard !priv_isClosed else { return }
        guard zoomInitiator !== self else { return }
        guard !priv_isBlockingRecursiveUpdate else { return }
        
        priv_isBlockingRecursiveUpdate = true
        
        zoomTo(toTimeStepRange)
        
        priv_isBlockingRecursiveUpdate = false
        
    }
    
    

    

    
    
    
    // MARK: Event Handlers
    
    func timeStepClickHandler(timeStepIndex: Int, event: NSEvent) {
        
        guard !priv_isClosed else { return }
        
        let clickNumber = event.clickCount
        
        if clickNumber == 1 {
            
            scroll(toTimeStepIndex: timeStepIndex)
            synchronizeSelect(self, selectedTimeStepIndex: timeStepIndex)
            coordinator.didSelect(self, selectedTimeStepIndex: timeStepIndex)
            
        } else if clickNumber == 2 {
            
            let modifierFlags: NSEventModifierFlags = event.modifierFlags
            let isZoomOut = modifierFlags.contains(NSEventModifierFlags.shift)
            let delta: Double = isZoomOut
                ? -doubleClickZoomPercentDelta
                : doubleClickZoomPercentDelta
            var newZoom: Double = priv_lastZoomPercent - delta
            
            if newZoom < TimeStepBaseGraphController.minZoomPercent {
                newZoom = TimeStepBaseGraphController.minZoomPercent
            } else if newZoom > 1.0 {
                newZoom = 1.0
            }
            
            if newZoom >= TimeStepBaseGraphController.minZoomPercent && newZoom <= 1.0 {
                zoom(newZoom)
                scroll(toTimeStepIndex: timeStepIndex)
                priv_lastZoomPercent = newZoom
            }
        }
        
    } // end timeStepClickHandler
    
    
    
    // MARK: Plot datasource methods
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        
        return UInt(timeStepsArray.count)
        
    } // end numberOfRecordsForPlot
    
    
    
    func dataKeyForPlot(_ plotId: String) -> String? {
        return priv_plotDefinitions.dataKey(plotId)
    }
    
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        
        guard idx > 0 else { return nil }
        
        let dataItemIndex = Int(idx)
        
        let fieldId: Int = Int(fieldEnum)
        
        
        if fieldId == CPTScatterPlotField.X.rawValue {
            return NSNumber(value: dataItemIndex)
            
        } else if fieldId == CPTScatterPlotField.Y.rawValue {
            
            let plotId = (plot.identifier as? String)!
            
            if plotId == cursorPlotIdentifier {
                if dataItemIndex == priv_cursorPosition {
                    return priv_cursorOnValue
                }
                return priv_cursorOffValue
                
            } else if let dataKey = dataKeyForPlot(plotId) {
                let step: Step = timeStepsArray[dataItemIndex]
                let value = step.value(forKey: dataKey) as? NSNumber
                return value
            }
        }
        
        return nil
        
    } // end numberForPlot
    
    
    
    
    // MARK: CPTPlotSpaceDelegate Protocol
    
    func plotSpace(_ space: CPTPlotSpace,
                   didChangePlotRangeFor coordinate: CPTCoordinate) {
        
        if !priv_isBlockingRecursiveUpdate && coordinate == CPTCoordinate.X {
            priv_isBlockingRecursiveUpdate = true
            
            if let plotSpace = space as? CPTXYPlotSpace {
                let range: NSRange = NSMakeRange(plotSpace.xRange.location.intValue,
                                                 plotSpace.xRange.length.intValue)
                coordinator.didScroll(self, toTimeStepRange: range)
            }
            
            priv_isBlockingRecursiveUpdate = false
        }
    } // end plotSpace didChangePlotRangeForCoordinate
    
    
    
    // Click anywhere in the graph, including title areas, plotting areas, 
    // legend. Convert it to a plot area point.
    //
    // If the plot area point x or y are negative, the click was below or left
    // of the plot area.
    //
    // The calculation of which time step was clicked seems to be close, but
    // it is off by a little compared to the plot delegate methods that 
    // specify which object was clicked. So here we are just handling clicks
    // that missed a plot, but we still want to do SOMETHING reasonable
    // rather than do nothing until the user clicks EXACTLY on a plot.
    //
    func plotSpace(_ space: CPTPlotSpace,
                   shouldHandlePointingDeviceUp event: NSEvent,
                   at point: CGPoint) -> Bool {
        
        let areaPoint = space.plotAreaViewPoint(for: event)
        let area = plotArea
        let areaBounds = area.bounds

        if areaBounds.contains(areaPoint) {
            let proportionOfWidth: CGFloat = areaPoint.x / areaBounds.width
            
            let totalTimeSteps: Int = timeStepsArray.count
            let clickedTimeStepIndex = Int(CGFloat(totalTimeSteps) * proportionOfWidth)
            
            timeStepClickHandler(timeStepIndex: clickedTimeStepIndex, event: event)
            
            return true
        }
        
        return false
        
    } // end plotSpace:shouldHandlePointingDeviceUpEvent:atPoint
    
    
    
    // MARK: CPTPlotAreaDelegate Protocol
    
    
    
    
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_isClosed = false
    
    fileprivate var priv_coordinator: DetailsCoordinator? = nil
    
    fileprivate var priv_lastZoomPercent: Double = 0.0
    
    fileprivate var priv_plotDefinitions = PlotDefinitions()
    
    fileprivate var priv_legend: CPTLegend? = nil
    
    fileprivate var priv_cursorPosition: Int = -1
    fileprivate var priv_cursorOnValue = NSNumber(value: 1.0 as Double)
    fileprivate var priv_cursorOffValue: NSNumber? = nil
    
    
    // MARK: *Private* Methods
    
    
    fileprivate func priv_reloadTimeSteps() {
        guard !priv_isClosed else { return }
        
        let globalLength = timeStepsArray.count
        plotSpace.globalXRange = CPTPlotRange(location: NSNumber(value: 0), length: NSNumber(value: globalLength))
        
        graph.reloadData()
        timeStepAxis.relabel()
    }
    
    
} // end class TimeStepBaseGraphController


