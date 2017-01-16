//
//  TimeStepBarGraphController.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 7/15/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import CorePlot



class TimeStepBarGraphController: TimeStepBaseGraphController, CPTBarPlotDelegate {
    
    
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
    
    
    
    
    
    
    override func setupVerticalPaddingAroundGraph() {
        
        graph.paddingBottom = 2.0
        graph.paddingTop    = 3.0
        
    } // end setupPaddingAroundGraph
    
    
    
    override func setupWeightActivationLevelAxisLabels() {
        
        let axisSet: CPTXYAxisSet = (graph.axisSet as? CPTXYAxisSet)!
        let y: CPTXYAxis = axisSet.yAxis!
        
        y.labelingPolicy = CPTAxisLabelingPolicy.none
        
        // Title but no labels. The title will be the name of the data items
        // being plotted as binary flags.
        //
        let plotIds = plotDefinitions.map() {
            (def: PlotDefinition) -> String in def.label
        }
        let title = plotIds.joined(separator: ", ")
        y.title = title
        y.titleOffset = 32.0
        //
        // Rotate title into horizontal position
        //
        y.titleRotation = CGFloat(2 * M_PI)
        
    } // end setupWeightActivationLevelAxis
    
    
    

    // MARK: CPTBarPlotDelegate

    // NOTE: this is more precise than the functionality of the CPTPlotSpaceDelegate
    //       for those cases in which the click is directly on a plot.
    //
    func barPlot(_ plot: CPTBarPlot, barTouchUpAtRecord idx: UInt, with event: NSEvent) {
        
        timeStepClickHandler(timeStepIndex: Int(idx), event: event)
        
    } // end barPlot barTouchUpAtRecordIndex

    
    // MARK: *Private*
    
    
    
    
} // end class TimeStepBarGraphController


