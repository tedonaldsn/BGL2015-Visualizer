//
//  ActivatableNodeSymbol.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 11/7/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork



open class ActivatableNodeSymbol: BaseSymbol, UpdatableNodeLayoutProtocol {
    
    
    open class ActivatableNodeSymbolAppearance: BaseSymbol.BaseSymbolAppearance {
        
    }
    
    open override class func defaultAppearance() -> BaseLayout.BaseAppearance {
        return ActivatableNodeSymbolAppearance(
            fillColor: StrengthColor(colorAtWeakest: NSColor.lightGray.cgColor,
                                     colorAtStrongest: NSColor.white.cgColor),
            lineStyle: StrengthLineStyle(colorAtWeakest: NSColor.darkGray.cgColor,
                                         colorAtStrongest: NSColor.black.cgColor,
                                         widthAtWeakest: 1.0,
                                         widthAtStrongest: 5.0,
                                         dashPattern: nil,
                                         dashPatternPhase: 0.0),
            padding: ActivatableNodeSymbol.defaultPadding,
            label: nil
        )
    }

    
    // MARK: Data
    
    public unowned let rootLayout: NeuralNetworkLayout
    
    open var updatableNodeLayouts: UpdatableNodeLayoutRegistry {
        return rootLayout.updatableNodeLayouts
    }
    
    open var node: BASelectionistNeuralNetwork.Node {
        return priv_node
    }
    
    open var activatableNode: BASelectionistNeuralNetwork.ActivatableNode {
        return priv_node
    }
    
    
    open var activationLevel: Scaled0to1Value {
        let level = activatableNode.activationLevel
        return level
    }
    open var activationLevelString: String {
        return BaseSymbol.format(scaledValue: activationLevel)
    }
    
    
    open override var presentationStrength: Scaled0to1Value {
        return activationLevel
    }
    
    
    
    open override var statusSummary: NSAttributedString? {
        let info = NSMutableAttributedString()
        
        if let label = label {
            info.append(label.text)
            info.append(NSAttributedString(string: "\n"))
        }
        
        info.append(NSAttributedString(string: "Activation level: \(activationLevelString)"))
        
        return info
    }
    
    
    // MARK: Initialization
    
    public required init(rootLayout: NeuralNetworkLayout,
                         node: Node,
                         appearance: BaseLayout.BaseAppearance? = nil) {
        
        assert(node is ActivatableNode)
        priv_node = node as! ActivatableNode
        
        self.rootLayout = rootLayout
        
        
        let myAppearance = appearance != nil
            ? appearance!
            : ActivatableNodeSymbol.defaultAppearance()
        
        super.init(appearance: myAppearance)
    }
    
    
    // MARK: Updates
    
    open func isValidNodeForTimestepUpdate(_ nodeState: Node) -> Bool {
        return basicIsValidNodeForTimestepUpdate(nodeState)
    }
    
    open func updateForTimestep(_ nodeState: Node) -> Void {
        assert(isValidNodeForTimestepUpdate(nodeState))
        priv_node = nodeState as! ActivatableNode
    }
    
    
    
    // MARK: *Private* Data

    fileprivate var priv_node: ActivatableNode
    
    
} // end class ActivatableNodeSymbol

