//
//  BarPlotDefinition.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 7/15/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//



import Foundation
import CorePlot




final public class BarPlotDefinition: PlotDefinition {
    
    var barFill: CPTFill
    var barWidth: CGFloat // percent of available width
    var barCornerRadius: CGFloat // pixels
    
    public init(label: String,
                dataKey: String,
                lineWidth: CGFloat,
                lineColor: CPTColor,
                barFill: CPTFill,
                barWidth: CGFloat,
                barCornerRadius: CGFloat) {
        self.barFill = barFill
        self.barWidth = barWidth
        self.barCornerRadius = barCornerRadius
        super.init(label: label, dataKey: dataKey, lineWidth: lineWidth, lineColor: lineColor)
    }
    
    // Does not set dataSource or delegate
    //
    public override func createPlot() -> CPTPlot {
        return createBarPlot()
    }
    public func createBarPlot() -> CPTBarPlot {
        let plot = CPTBarPlot()
        
        plot.identifier = label as (NSCoding & NSCopying & NSObjectProtocol)?
        plot.cachePrecision = CPTPlotCachePrecision.double
        
        let mutableLineStyle = CPTMutableLineStyle()
        mutableLineStyle.lineWidth = lineWidth
        mutableLineStyle.lineColor = lineColor
        plot.lineStyle = mutableLineStyle
        
        plot.fill = barFill
        plot.barWidth = NSNumber(value: Double(barWidth))
        plot.barBaseCornerRadius = barCornerRadius
        plot.barsAreHorizontal = false
        
        return plot
        
    } // end createPlot
    
} // end class BarPlotDefinition

