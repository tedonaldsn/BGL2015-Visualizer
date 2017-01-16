//
//  TimeStepLineGraphController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 7/15/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import CorePlot



class TimeStepLineGraphController: TimeStepBaseGraphController, CPTScatterPlotDelegate {
    
    
    
    // MARK: Outlets
    
    // Ideally would directly set outlet in super, but how to do that in IB?
    //
    @IBOutlet weak var graphHostingView: CPTGraphHostingView! {
        didSet { super.corePlotHostingView = graphHostingView }
    }
    
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    
    
    // MARK: Setup
    
    override func setupTimeStepAxisLabels() {
        
        let x = timeStepAxis
        
        x.title = "Trial-TimeStep"
        x.titleOffset = 30.0
        
        // Set delegate so we can provide customized labels.
        //
        x.delegate = self
        x.labelingPolicy = CPTAxisLabelingPolicy.fixedInterval
        
    } // end setupTimeStepAxisLabels
    
    
    override func setupWeightActivationLevelAxisLabels() {
        
        let axisSet: CPTXYAxisSet = (graph.axisSet as? CPTXYAxisSet)!
        let y: CPTXYAxis = axisSet.yAxis!
        
        y.labelingPolicy = CPTAxisLabelingPolicy.automatic
        y.labelOffset = 10.0
        y.title = "Weight & Activation"
        y.titleOffset = 50.0
        
        y.majorGridLineStyle = majorGridLineStyle
        
        let lightColor: CPTColor = CPTColor.white().withAlphaComponent(0.33)
        let darkColor: CPTColor = CPTColor.lightGray().withAlphaComponent(0.33)
        let lightBand: CPTFill = CPTFill.init(color: lightColor)
        let darkBand: CPTFill = CPTFill.init(color: darkColor)
        y.alternatingBandFills = [lightBand, darkBand]
        
    } // end setupWeightActivationLevelAxis
    


    
    
    // MARK: CPTScatterPlotDelegate Protocol
    
    // NOTE: this is more precise than the functionality of the CPTPlotSpaceDelegate
    //       for those cases in which the click is directly on a plot.
    //
    func scatterPlot(_ plot: CPTScatterPlot,
                     plotSymbolWasSelectedAtRecord idx: UInt,
                                                        with event: NSEvent) {
        
        timeStepClickHandler(timeStepIndex: Int(idx), event: event)
        
    } // end scatterPlot plotSymbolWasSelectedAtRecordIndex

    
    
    
    // MARK: CPTAxisDelegate Labeling
    
    
    func axisShouldRelabel(_ axis: CPTAxis) -> Bool {
        return true //  axis.coordinate == CPTCoordinate.X
    }
    
    
    // Updates labels on the trials/timesteps axis (i.e., X axis)
    //
    // Text of label is the trial number.
    //
    // All other axis (currently just the Y-activation/weight level) automatically.
    //
    
    func axis(_ axis: CPTAxis, shouldUpdateAxisLabelsAtLocations locations: Set<NSNumber>) -> Bool {
        
        // If any axis other than the trials/timesteps axis (i.e., X), tell
        // Core Plot to do automatic labeling.
        //
        guard axis.coordinate == CPTCoordinate.X else { return true }
        
        let labelRotation = axis.labelRotation
        let labelAlignment = axis.labelAlignment
        let labelOffset = axis.labelOffset
        
        let textStyle = CPTMutableTextStyle(style: axis.labelTextStyle)
        textStyle.color = CPTColor.black()
        
        // let tickDirection = axis.tickDirection
        // let orthogonalCoordinate = CPTOrthogonalCoordinate(axis.coordinate)
        
        // Not sure exactly what this call does. The Core Plot documentation
        // simply reiterates the name of the function. And below we explicitly
        // assign content layers to the axis label group.
        //
        // WILL TRY COMMENTING IT OUT AT SOME POINT
        //
        let plotArea: CPTPlotArea = axis.plotArea!
        plotArea.setAxisSetLayersFor(CPTGraphLayerType.axisLabels)
        
        var currentLabels = Set<CPTAxisLabel>()
        
        for location in locations {
            
            let xGraphPosition: Int = Int(location.doubleValue)
            let dataItemIndex = xGraphPosition // - 1
            
            if dataItemIndex >= 0 && dataItemIndex < timeStepsArray.count {
                
                let timeStep: Step = timeStepsArray[dataItemIndex]
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
    
    
    
} // end class TimeStepLineGraphController


