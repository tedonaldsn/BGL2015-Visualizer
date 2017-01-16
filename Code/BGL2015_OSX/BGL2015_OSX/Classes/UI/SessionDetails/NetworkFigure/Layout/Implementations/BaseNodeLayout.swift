//
//  BaseNodeLayout.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 12/3/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//


import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



open class BaseNodeLayout: BaseLayout, UpdatableNodeLayoutProtocol {
    
    open class BaseNodeAppearance: BaseLayout.BaseAppearance {
        public override init(padding: CGFloat) {
            super.init(padding: padding)
        }
    }
    open override class func defaultAppearance() -> BaseLayout.BaseAppearance {
        return BaseNodeAppearance(padding: 0.0)
    }
    
    
    open var node: BASelectionistNeuralNetwork.Node {
        return priv_node
    }
    
    
    // Initialization
    
    public init(node: Node, appearance: BaseLayout.BaseAppearance?) {
        
        let myAppearance = appearance != nil
            ? appearance
            : BaseNodeLayout.defaultAppearance()
        
        priv_node = node
        
        super.init(appearance: myAppearance)
    }
    
    
    // MARK: Update
    
    open func isValidNodeForTimestepUpdate(_ nodeState: Node) -> Bool {
        return basicIsValidNodeForTimestepUpdate(nodeState)
    }
    
    
    open func updateForTimestep(_ nodeState: Node) -> Void {
        assert(isValidNodeForTimestepUpdate(nodeState))
        priv_node = nodeState
    }
    
    
    // MARK: *Private*
    
    fileprivate var priv_node: Node
    
} // end class BaseNodeLayout

