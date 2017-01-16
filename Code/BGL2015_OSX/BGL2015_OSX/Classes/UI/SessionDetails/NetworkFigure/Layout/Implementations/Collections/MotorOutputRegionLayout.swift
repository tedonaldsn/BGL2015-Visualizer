//
//  MotorOutputRegionLayout.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 1/2/17.
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
import BASimulationFoundation
import BASelectionistNeuralNetwork



open class MotorOutputRegionLayout: BaseCollectionLayout {
    
    // MARK: Data
    
    public unowned let rootLayout: NeuralNetworkLayout
    
    public var region: MotorOutputRegion {
        return node as! MotorOutputRegion
    }
    
    
    // MARK: Initialization
    
    public init(rootLayout: NeuralNetworkLayout, regionNode: Node) {
        
        assert(regionNode is MotorOutputRegion)
        
        self.rootLayout = rootLayout
        
        super.init(node: regionNode, collectionAxis: CollectionAxis.XMajor)
        
        priv_populate()
        
    } // end init
    
    
    
    // Called by NeuralNetworkLayout after all neural units, including their
    // dendrites and axons, have been created.
    //
    open func createFeedbackPath() -> FeedbackConsumerPath? {
        
        var regionPath: FeedbackConsumerPath? = nil
        
        for layout in layouts {
            if let area = layout as? MotorOutputAreaLayout {
                
                let areaPath = FeedbackConsumerPath(motorOutputLayer: area)
                
                if let regionPath = regionPath {
                    regionPath.appendVertically(pathBelow: areaPath)
                } else {
                    regionPath = areaPath
                }
            }
        }
        
        return regionPath
        
    } // end createFeedbackPath
    
    
    
    
    
    
    
    // MARK: Search
    
    open override func find(identifier: Identifier) -> BaseLayout? {
        //
        // Find area with the specified identifier
        //
        if let layout = super.find(identifier: identifier) {
            return layout
        }
        //
        // Find symbol with the specified identifier
        //
        for layout in layouts {
            if let collection = layout as? BaseCollectionLayout,
                let targetLayout = collection.find(identifier: identifier) {
                return targetLayout
            }
        }
        
        return nil
    }
    
    
    
    // MARK: Update
    
    open override func isValidNodeForTimestepUpdate(_ nodeState: Node) -> Bool {
        if let newRegion = nodeState as? MotorOutputRegion {
            return newRegion.areaCount == region.areaCount
                && super.isValidNodeForTimestepUpdate(nodeState)
        }
        return false
    }
    
    open override func updateForTimestep(_ nodeState: Node) -> Void {
        super.updateForTimestep(nodeState)
        
        let areas: [NeuralArea] = region.areas
        var areaIx: Int = 0
        
        for layout in layouts {
            if let nodeLayout = layout as? BaseNodeLayout {
                let area = areas[areaIx]
                nodeLayout.updateForTimestep(area)
                areaIx = areaIx + 1
            }
        }
        
        assert(areaIx == areas.count)
        
    } // end updateForTimestep
    
    
    // MARK: Scaling
    
    open override func scale(_ scalingFactor: CGFloat) -> Void{
        super.scale(scalingFactor)
    }
    
    
    
    // MARK: Repositioning
    
    open override func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) -> Void {
        super.translate(xBy: deltaX, yBy: deltaY)
    }
    
    
    // MARK: Drawing
    
    open override func draw() -> Void {
        super.draw()
    }
    
    
    
    // MARK: *Private* Data
    
    
    
    // MARK: *Private* Methods
    
    
    fileprivate func priv_populate() {
        
        let areas: [NeuralArea] = region.areas
        
        for area in areas {
            
            let layout = MotorOutputAreaLayout(rootLayout: rootLayout, areaNode: area)
            append(layout: layout)
        }
        
    } // end priv_populate
    
    
    
    
    
} // end class MotorOutputRegionLayout

