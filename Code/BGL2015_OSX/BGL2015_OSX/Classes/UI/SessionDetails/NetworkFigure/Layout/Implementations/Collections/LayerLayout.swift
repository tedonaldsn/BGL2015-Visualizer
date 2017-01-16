//
//  LayerLayout.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 11/13/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork


// LayerLayout
//
// A layer is a vertical stack of neural units, or rather, symbols representing
// neural units. Neural units are displayed in square CGRect areas. Thus, the
// dimensions of a node symbol area are the frame size width.
//
// The rectangle passed to init() is the space that the layer is permitted to 
// use. It is precomputed based on the desired node dimension and the number
// of nodes currently within the layer.
//
open class LayerLayout: BaseCollectionLayout {
    
    // MARK: Data
    
    public unowned let rootLayout: NeuralNetworkLayout

    public var layerNode: NeuralLayer {
        return node as! NeuralLayer
    }

    
    // MARK: Initialization
    
    public init(rootLayout: NeuralNetworkLayout, node: Node) {
        
        assert(node is NeuralLayer)
        
        self.rootLayout = rootLayout
        super.init(node: node, collectionAxis: CollectionAxis.XMajor)
        
        priv_populate()
    }
    
    
    
    // MARK: Scaling
    
    open override func scale(_ scalingFactor: CGFloat) {
        super.scale(scalingFactor)
    }
    
    
    // MARK: Drawing
    
    open override func draw() {
        super.draw()
    }
    
    
    // MARK: Updating
    
    // Supply new node state to each contained layout that displays a node.
    //
    // Important: Not all layouts are ActivatableNodeLayout's. There may be
    // other types of layouts in the list, such as those used to label regions.
    //
    open override func updateForTimestep(_ nodeState: Node) {
        assert(nodeState is NeuralLayer)
        super.updateForTimestep(nodeState)
        
        let activatableNodes: [ActivatableNode] = layerNode.nodes
        let displayLayouts: [BaseLayout] = layouts
        
        var nodeIx: Int = 0
        
        for displayLayout in displayLayouts {
            if let nodeLayout = displayLayout as? UpdatableNodeLayoutProtocol {
                let activatableNode = activatableNodes[nodeIx]
                nodeLayout.updateForTimestep(activatableNode)
                nodeIx = nodeIx + 1
            }
        }
        
        assert(nodeIx == activatableNodes.count)

    } // end updateForTimestep
    
    
    
    
    // MARK: *Private* Data
    
    
    // MARK: *Private* Methods
    
    // Symbols are arranged from top to bottom, with symbol for the zeroeth
    // neural node at the top, and the nth one at the bottom. Thus, the nth
    // node is at y==0 and the zeroth one is at y==height-itemHeight.
    //
    fileprivate func priv_populate() -> Void {
        
        let layer = layerNode
        let activatableNodes: [ActivatableNode] = layer.nodes
        
        let factory = ActivatableNodeSymbolFactory.sharedInstance
        let registry = rootLayout.updatableNodeLayouts
        
        for activatableNode in activatableNodes {
            assert(!registry.contains(activatableNode))
            
            let symbol = factory.create(rootLayout: rootLayout,
                                        forNode: activatableNode)
            
            registry.append(symbol)
            append(layout: symbol)
        }
        
    } // end priv_populate
    
    
} // end class LayerLayout

