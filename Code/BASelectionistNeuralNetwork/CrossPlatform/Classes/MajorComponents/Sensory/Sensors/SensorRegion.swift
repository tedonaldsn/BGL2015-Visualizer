//
//  SensorRegion.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 3/3/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//

import Foundation
import BASimulationFoundation



// SensorRegion
//
// Transducer region that converts inputs of various types into uniform
// activation level inputs to the sensory input region. The sensor inputs are
// entirely the domain of the particular type of sensor. 
//
// The sensor region consists of parallel areas of sensors that conceptually
// serve as one layer, though each region may serve a different type of sensor
// and each region may output to different sensory input regions.
//
final public class SensorRegion: NSObject, NeuralRegion {
    
    public var isStructureLocked: Bool { return network.isStructureLocked }
    
    // MARK: Node Protocol
    
    public var hasIdentifier: Bool { return priv_node.hasIdentifier }
    public var identifier: Identifier? { return priv_node.identifier }
    public var network: Network { return priv_node.network }
    public var logger: Logger { return priv_node.logger }
    
    
    // MARK: NeuralRegion Protocol
    
    public var maxLayerDepth: Int { return 1 }
    public var maxNodeWidth: Int {
        return priv_areas.reduce(0) {
            (count: Int, area: NeuralArea) -> Int in count + area.maxNodeWidth
        }
    }
    
    public var areaCount: Int { return priv_areas.count }
    public var areas: [NeuralArea] {
        return priv_areas.map() { (area: NeuralArea) -> NeuralArea in return area }
    }
    
    
    
    // MARK: Data
    
    public var sensors: [SensorArea] {
        return priv_areas
    }
    
    
    // MARK: Initialization
    
    public init(network: Network, identifier: Identifier? = nil) {
        priv_node = NodeBody(network: network, identifier: identifier)
    }
    public convenience init(environment: ComputationalNode, identifier: Identifier? = nil) {
        self.init(network: environment.network, identifier: identifier)
    }
    
    
    
    // MARK: Sensing
    
    public func prepareActivation() -> Void {
        for area in priv_areas {
            area.prepareActivation()
        }
    }
    
    public func commitActivation() -> Void {
        for area in priv_areas {
            area.commitActivation()
        }
    }
    
    public func resetActivation() -> Void {
        for area in priv_areas {
            area.resetActivation()
        }
    }
    
    
    // MARK: Append
    
    public func append(_ sensor: Sensor, areaIndex: Int = 0) -> Sensor {
        precondition(!isStructureLocked)
        createArea(areaIndex)
        return priv_areas[areaIndex].append(sensor)
    }
    
    public func createArea(_ index: Int = 0) -> Void {
        while index >= priv_areas.count {
            precondition(!isStructureLocked)
            
            let id = Identifier(idString: "SensorArea_\(index)")
            priv_areas.append(SensorArea(network: network, identifier: id))
        }
    }
    
    // MARK: Access
    
    
    public subscript(index: Int) -> SensorArea {
        return priv_areas[index]
    }
    
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_sensors = "sensors"
    
    @objc public required init?(coder aDecoder: NSCoder) {
        priv_node = NodeBody(coder: aDecoder)!
        priv_areas = aDecoder.decodeObject(forKey: SensorRegion.key_sensors) as! [SensorArea]
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        aCoder.encode(priv_areas, forKey: SensorRegion.key_sensors)
    }
    
    

    
    
    // MARK: *Private*
    
    fileprivate var priv_node: NodeBody
    
    fileprivate var priv_areas = [SensorArea]()
    
    
    
} // end class SensorRegion


