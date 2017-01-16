//
//  ScatterPlotDefinition.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 7/14/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation
import CorePlot




final public class ScatterPlotDefinition: PlotDefinition {
    
    public override init(label: String,
                dataKey: String,
                lineWidth: CGFloat,
                lineColor: CPTColor) {
        super.init(label: label, dataKey: dataKey, lineWidth: lineWidth, lineColor: lineColor)
    }
    
    // Does not set dataSource or delegate
    //
    public override func createPlot() -> CPTPlot {
        return createScatterPlot()
    }
    public func createScatterPlot() -> CPTScatterPlot {
        let plot = CPTScatterPlot()
        
        plot.identifier = label as (NSCoding & NSCopying & NSObjectProtocol)?
        plot.cachePrecision = CPTPlotCachePrecision.double
        
        // Give a little latitude for detecting clicks on plot
        //
        plot.plotSymbolMarginForHitDetection = 30.0

        let mutableLineStyle = CPTMutableLineStyle()
        mutableLineStyle.lineWidth = lineWidth
        mutableLineStyle.lineColor = lineColor
        plot.dataLineStyle = mutableLineStyle
        
        return plot

    } // end createPlot
    
} // end class ScatterPlotDefinition

