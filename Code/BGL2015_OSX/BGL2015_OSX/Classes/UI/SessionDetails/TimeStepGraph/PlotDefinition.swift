//
//  PlotDefinition.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 7/16/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation
import CorePlot


open class PlotDefinition {
    open let label: String
    open let dataKey: String
    
    open let lineWidth: CGFloat
    open let lineColor: CPTColor
    
    public init(label: String,
                dataKey: String,
                lineWidth: CGFloat,
                lineColor: CPTColor) {
        self.label = label
        self.dataKey = dataKey
        self.lineWidth = lineWidth
        self.lineColor = lineColor
    }
    
    open func createPlot() -> CPTPlot {
        preconditionFailure("Derived class responsibility")
    }
    
} // end class PlotDefinition

