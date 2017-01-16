//
//  Shapes.swift
//  BGL2015_OSX
//
//  Created by Tom Donaldson on 10/13/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//



import Foundation
import BASimulationFoundation




final public class Shapes {
    
    public typealias Creator = (_ shapeType: Identifier, _ centeredInRect: CGRect) -> RegularShapeProtocol
    
    
    
    public static let sharedInstance = Shapes()
    
    
    
    // MARK: Initialization
    
    public init() {
        priv_installDefaultCreators()
    }
    
    public func append(_ shapeType: Identifier, creator: @escaping Creator) -> Void {
        assert(!contains(shapeType))
        priv_creators[shapeType] = creator
    }
    

    // MARK: Create Shapes
    
    public func contains(_ shapeType: Identifier) -> Bool {
        return priv_creators[shapeType] != nil
    }
    
    public func create(_ shapeType: Identifier, centeredInRect: CGRect) -> RegularShapeProtocol? {
        if let creator = priv_creators[shapeType] {
            return creator(shapeType, centeredInRect)
        }
        return nil
    }

    
    // MARK: *Private* Data
    
    
    
    
    fileprivate var priv_creators = [Identifier : Creator]()
    

    
    // MARK: *Private* Methods
    
    fileprivate func priv_installDefaultCreators() -> Void {
        
        priv_creators[Identifier(idString: "circle")] = {
            (shapeType: Identifier, centeredInRect: CGRect) -> RegularShapeProtocol in
            return CircleShape(shapeType: shapeType, centeredInRect: centeredInRect)
        }
        
        priv_creators[Identifier(idString: "triangle")] = {
            (shapeType: Identifier, centeredInRect: CGRect) -> RegularShapeProtocol in
            return RegularPolygonShape(shapeType: shapeType,
                                       numberOfSides: 3,
                                       centeredInRect: centeredInRect,
                                       firstVertexRadians: Trig.pi)
        }
        
        priv_creators[Identifier(idString: "square")] = {
            (shapeType: Identifier, centeredInRect: CGRect) -> RegularShapeProtocol in
            return RegularPolygonShape(shapeType: shapeType,
                                       numberOfSides: 4,
                                       centeredInRect: centeredInRect,
                                       firstVertexRadians: Trig.pi/4.0)
        }
        
        priv_creators[Identifier(idString: "pentagon")] = {
            (shapeType: Identifier, centeredInRect: CGRect) -> RegularShapeProtocol in
            return RegularPolygonShape(shapeType: shapeType,
                                       numberOfSides: 5,
                                       centeredInRect: centeredInRect)
        }
        
        priv_creators[Identifier(idString: "hexagon")] = {
            (shapeType: Identifier, centeredInRect: CGRect) -> RegularShapeProtocol in
            return RegularPolygonShape(shapeType: shapeType,
                                       numberOfSides: 6,
                                       centeredInRect: centeredInRect)
        }
        
        priv_creators[Identifier(idString: "heptagon")] = {
            (shapeType: Identifier, centeredInRect: CGRect) -> RegularShapeProtocol in
            return RegularPolygonShape(shapeType: shapeType,
                                       numberOfSides: 7,
                                       centeredInRect: centeredInRect)
        }
        
        priv_creators[Identifier(idString: "octagon")] = {
            (shapeType: Identifier, centeredInRect: CGRect) -> RegularShapeProtocol in
            return RegularPolygonShape(shapeType: shapeType,
                                       numberOfSides: 8,
                                       centeredInRect: centeredInRect)
        }
        
        priv_creators[Identifier(idString: "nonagon")] = {
            (shapeType: Identifier, centeredInRect: CGRect) -> RegularShapeProtocol in
            return RegularPolygonShape(shapeType: shapeType,
                                       numberOfSides: 9,
                                       centeredInRect: centeredInRect)
        }
        
        priv_creators[Identifier(idString: "decagon")] = {
            (shapeType: Identifier, centeredInRect: CGRect) -> RegularShapeProtocol in
            return RegularPolygonShape(shapeType: shapeType,
                                       numberOfSides: 10,
                                       centeredInRect: centeredInRect)
        }
        
    } // end priv_installDefaultCreators
    
    
} // end class Shapes



