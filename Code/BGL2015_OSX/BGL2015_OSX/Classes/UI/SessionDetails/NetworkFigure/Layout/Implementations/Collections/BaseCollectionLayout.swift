//
//  BaseCollectionLayout.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 11/15/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Cocoa
import BASimulationFoundation
import BASelectionistNeuralNetwork


open class BaseCollectionLayout: BaseNodeLayout {
    
    open class BaseCollectionAppearance: BaseNodeLayout.BaseNodeAppearance {
        public override init(padding: CGFloat) {
            super.init(padding: padding)
        }
    }
    open override class func defaultAppearance() -> BaseLayout.BaseAppearance {
        return BaseCollectionAppearance(padding: 0.0)
    }
    
    
    // MARK: Data
    
    open var collectionAxis: CollectionAxis = .Undefined {
        willSet { precondition(collectionAxis == .Undefined) }
    }
    var isVerticalAxis: Bool {
        return collectionAxis == .XMajor
    }
    var isHorizontalAxis: Bool {
        return collectionAxis == .YMajor
    }

    
    open var layoutCount: Int {
        return priv_layouts.count
    }
    open var layouts: [BaseLayout] {
        return priv_layouts
    }
    
    open var contentRect: CGRect {
        var minRect = CGRect(x: frame.origin.x + padding,
                             y: frame.origin.y + padding,
                             width: 0.0,
                             height: 0.0)
        for layout in priv_layouts {
            minRect = minRect.union(layout.frame)
        }
        return minRect
    }
    
    
    
    
    // MARK: Initialization
    
    public init(node: Node,
                collectionAxis: CollectionAxis,
                appearance: BaseLayout.BaseAppearance? = nil) {
        
        assert(node is NeuralLayer || node is NeuralArea || node is NeuralRegion || node is Network)
        
        let myAppearance = appearance != nil
            ? appearance
            : BaseCollectionLayout.defaultAppearance()
        
        self.collectionAxis = collectionAxis
        super.init(node: node, appearance: myAppearance)
    }
    
    
    
    
    // Adds the layout to the end of the collection, and translates it into the
    // appropriately padded position within the contentRect. Size of the layout
    // is unchanged.
    //
    // IMPORTANT: This assumes that the NSView on which the layout will be
    //      drawn isFlipped to give us a top-down-left-to-right coordinate
    //      system instead of NSView's usual Cartesian Quadrant I coordinates.
    //
    open func append(layout: BaseLayout) -> Void {
        assert(collectionAxis != .Undefined)
        
        let nextOrigin = priv_nextAppendOrigin(layoutSize: layout.frame.size)
        
        let deltaX = nextOrigin.x - layout.frame.origin.x
        let deltaY = nextOrigin.y - layout.frame.origin.y
        layout.translate(xBy: deltaX, yBy: deltaY)
        
        priv_layouts.append(layout)
        
        let newContentRect = contentRect
        
        let newFrame =
            CGRect(origin: frame.origin,
                   size: CGSize(width: newContentRect.size.width + (padding * 2.0),
                                height: newContentRect.size.height + (padding * 2.0)))
        
        extendFrameToInclude(rect: newFrame)
        
    } // end append
    

    
    
    
    open func prepend(layout: BaseLayout) {
        assert(collectionAxis != .Undefined)
        
        let nextOrigin = priv_nextPrependOrigin(layoutSize: layout.frame.size)
        
        layout.translateOrigin(to: nextOrigin)
        
        let shiftDelta: CGPoint =
            isVerticalAxis
                ? CGPoint(x: 0.0,
                          y: layout.frame.size.height)
                : CGPoint(x: layout.frame.size.width,
                          y: 0.0)
        
        for layout in priv_layouts {
            layout.translate(xBy: shiftDelta.x, yBy: shiftDelta.y)
        }
        
        priv_layouts.insert(layout, at: 0)
        
        let newContentRect = contentRect
        
        let newFrame =
            CGRect(origin: frame.origin,
                   size: CGSize(width: newContentRect.size.width + (padding * 2.0),
                                height: newContentRect.size.height + (padding * 2.0)))
        
        extendFrameToInclude(rect: newFrame)
        
    } // end prepend
    
    
    
    open func append(layout: BaseLayout,
                     toCollectionAt atPath: DataKeyPathSearchIterator) -> Bool {
        
        return priv_addLayout(layout: layout,
                              toCollectionAt: atPath,
                              isAppend: true)
    }
    
    
    
    open func prepend(layout: BaseLayout,
                     toCollectionAt atPath: DataKeyPathSearchIterator) -> Bool {
        
        return priv_addLayout(layout: layout,
                              toCollectionAt: atPath,
                              isAppend: false)
    }
    
    
    
    // MARK: Connect
    
    
    open func connectNeuralUnits() -> Void {
        assert(!priv_isConnected)
        priv_isConnected = true
        
        for candidate in priv_layouts {
            
            if let collection = candidate as? BaseCollectionLayout {
                collection.connectNeuralUnits()

            } else if let neuralUnit = candidate as? PostsynapticSymbolProtocol {
                neuralUnit.requestConnectionsFromPresynapticSymbols()
            }
        }
        
    } // end connectNeuralUnits
    
    
    
    
    // MARK: Update
    
    
    open override func isValidNodeForTimestepUpdate(_ nodeState: Node) -> Bool {
        
        return super.isValidNodeForTimestepUpdate(nodeState)
    }
    

    
    /*
    open override func updateForTimestep(_ nodeState: Node) -> Void {
        super.updateForTimestep(nodeState)
    }
    */
    
    
    
    
    
    // MARK: Search
    
    open func deepestLayoutContainerContaining(point: CGPoint) -> BaseCollectionLayout? {

        for layout in priv_layouts {
            if let subcontainer = layout as? BaseCollectionLayout {
                if let target = subcontainer.deepestLayoutContainerContaining(point: point) {
                    return target
                }
            }
        }
        return nil
    }
    
    open func deepestSymbolLayoutContaining(point: CGPoint) -> BaseSymbol? {
        
        for layout in priv_layouts {
            
            if let symbol = layout as? BaseSymbol {
                if let target = symbol.deepestSymbolLayoutContaining(point: point) {
                    return target
                }
                
            } else if let subcontainer = layout as? BaseCollectionLayout {
                
                if let target = subcontainer.deepestSymbolLayoutContaining(point: point) {
                    return target
                }
            }
        }
        return nil
    }
    
    
    
    
    
    // On exit, if found, the search iterator isTerminal. If not found,
    // the search iterator current is the identifier at which it failed.
    //
    open func contains(collectionAt: DataKeyPathSearchIterator) -> Bool {
        if let _ = find(atPath: collectionAt) {
            return true
        }
        return false
    }
    
    
    open func find(idString: String) -> BaseLayout? {
        return find(identifier: Identifier(idString: idString))
    }
    open func find(identifier: Identifier) -> BaseLayout? {
        for layout in priv_layouts {
            if let nodeLayout = layout as? NodeLayoutProtocol {
                if nodeLayout.nodeIdentifier != nil && nodeLayout.nodeIdentifier! == identifier {
                    return layout
                }
            }
        }
        return nil
    }
    
    open func find(atPath: DataKeyPathSearchIterator) -> BaseLayout? {
        
        if atPath.isTerminal {
            return find(identifier: atPath.terminal)
            
        } else {
            for layout in priv_layouts {
                if let collection = layout as? BaseCollectionLayout,
                    let identifier = collection.nodeIdentifier {
                    if identifier == atPath.current {
                        let _ = atPath.advanceToNext()
                        return collection.find(atPath: atPath)
                    }
                    
                }
            }
        }
        return nil
    }
    
    
    // MARK: Scaling
    
    open override func scale(_ scalingFactor: CGFloat) {
        super.scale(scalingFactor)

        if scalingFactor != 1.0 {
            
            for layout in priv_layouts {
                layout.scale(scalingFactor)
            }

        } // end if scaling factor not unity

    } // end scale
    
    
    
    // MARK: Repositioning
    
    open override func translate(xBy deltaX: CGFloat, yBy deltaY: CGFloat) -> Void {
        super.translate(xBy: deltaX, yBy: deltaY)
        for layout in priv_layouts {
            layout.translate(xBy: deltaX, yBy: deltaY)
        }
    }
    
    
    
    // MARK: Drawing
    
    open override func draw() -> Void {
        super.draw()
        
        for layout in priv_layouts {
            layout.draw()
        }
        
    } // end draw
    
    
    // MARK: *Private* Data
    
    fileprivate var priv_layouts = [BaseLayout]()
    
    fileprivate var priv_isConnected = false
    
    
    // MARK: *Private* Methods
    
    
    
    fileprivate func priv_centeringAdjustment(contentRectSize: CGSize,
                                              layoutSize: CGSize) -> CGFloat {
        guard contentRectSize.width > 0.0 && contentRectSize.height > 0.0 else {
            return 0.0
        }
        
        let centeringAdjustment =
            isVerticalAxis
                ? (contentRect.size.width - layoutSize.width) / 2.0
                : (contentRect.size.height - layoutSize.height) / 2.0
        
        return centeringAdjustment
        
    } // end priv_centeringAdjustment
    
    
    fileprivate func priv_nextAppendOrigin(layoutSize: CGSize) -> CGPoint {
        
        let currentContentRect = contentRect
        
        let centeringAdjustment: CGFloat = 0.0 /*
            = priv_centeringAdjustment(contentRectSize: currentContentRect.size,
                                       layoutSize: layoutSize) */
        
        let nextOrigin =
            isVerticalAxis
                ? CGPoint(
                    x: currentContentRect.origin.x + centeringAdjustment,
                    y: currentContentRect.origin.y
                        + currentContentRect.size.height
                        + padding)
                    
                : CGPoint(
                    x: currentContentRect.origin.x
                        + currentContentRect.size.width
                        + padding,
                    y: currentContentRect.origin.y + centeringAdjustment)
        
        return nextOrigin
        
    } // end priv_nextAppendOrigin
    
    
    
    fileprivate func priv_nextPrependOrigin(layoutSize: CGSize) -> CGPoint {
        
        let currentContentRect = contentRect
        
        let centeringAdjustment
            = priv_centeringAdjustment(contentRectSize: currentContentRect.size,
                                       layoutSize: layoutSize)
        
        let nextOrigin =
            isVerticalAxis
                ? CGPoint(x: frame.origin.x + padding + centeringAdjustment,
                          y: frame.origin.y + padding)
                : CGPoint(x: frame.origin.x + padding,
                          y: frame.origin.y + padding + centeringAdjustment)
        
        return nextOrigin
        
    } // end priv_nextPrependOrigin
    
    
    
    
    
    
    
    fileprivate func priv_addLayout(layout: BaseLayout,
                                    toCollectionAt atPath: DataKeyPathSearchIterator,
                                    isAppend: Bool) -> Bool {
        
        precondition(!atPath.isAtEnd)
        
        if atPath.isTerminal {
            for ix in 0..<priv_layouts.count {
                if let collection = priv_layouts[ix] as? BaseCollectionLayout,
                    let identifier = collection.nodeIdentifier {
                    
                    if identifier == atPath.terminal {
                        
                        let oldSize = collection.frame.size
                        
                        if isAppend {
                            collection.append(layout: layout)
                        } else {
                            collection.prepend(layout: layout)
                        }
                        extendFrameToInclude(rect: collection.frame)
                        
                        let newSize = collection.frame.size
                        
                        let delta = CGSize(width: newSize.width - oldSize.width,
                                           height: newSize.height - oldSize.height)
                        
                        priv_shift(startingIx: ix+1, delta: delta)
                        
                        return true
                    }
                }
            }
            
        } else {
            for candidate in priv_layouts {
                if let collection = candidate as? BaseCollectionLayout,
                    let identifier = collection.nodeIdentifier {
                    
                    if identifier == atPath.current {
                        let _ = atPath.advanceToNext()
                        
                        if isAppend {
                            return collection.append(layout: layout,
                                                     toCollectionAt: atPath)
                        } else {
                            return collection.prepend(layout: layout,
                                                      toCollectionAt: atPath)
                        }
                    }
                }
            }
        }
        
        return false
        
    } // end priv_addLayout
    
    
    fileprivate func priv_shift(startingIx: Int, delta: CGSize) -> Void {
        
        for ix in startingIx..<priv_layouts.count {
            
            let layout = priv_layouts[ix]
            
            if isVerticalAxis {
                layout.translate(xBy: 0.0, yBy: delta.height)
            } else {
                layout.translate(xBy: delta.width, yBy: 0.0)
            }
            extendFrameToInclude(rect: layout.frame)
        }
    }
    
    

} // end class BaseCollectionLayout

