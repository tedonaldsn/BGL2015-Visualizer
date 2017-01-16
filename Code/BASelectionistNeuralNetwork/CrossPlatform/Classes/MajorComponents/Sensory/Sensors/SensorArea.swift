//
//  SensorArea.swift
//  BASelectionistNeuralNetwork
//
//  Created by Tom Donaldson on 3/3/16.
//  Copyright © 2016 Tom Donaldson. All rights reserved.
//



import Foundation
import BASimulationFoundation


final public class SensorArea: NSObject, NeuralSingleLayerArea {
    
    public var isStructureLocked: Bool { return network.isStructureLocked }
    
    // MARK: Node Protocol
    
    public var hasIdentifier: Bool { return priv_node.hasIdentifier }
    public var identifier: Identifier? { return priv_node.identifier }
    public var network: Network { return priv_node.network }
    public var logger: Logger { return priv_node.logger }
    
    
    // MARK: NeuralArea Protocol
    
    public var maxLayerDepth: Int { return 1 }
    public var maxNodeWidth: Int { return nodeCount }
    
    
    // MARK: NeuralLayer Protocol
    
    public var nodeCount: Int { return priv_sensors.count }
    public var nodes: [ActivatableNode] {
        return priv_sensors.map() {
            (sensor: Sensor) -> ActivatableNode in return sensor
        }
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
        for sensor in priv_sensors {
            sensor.prepareActivation()
        }
    }
    
    public func commitActivation() -> Void {
        for sensor in priv_sensors {
            sensor.commitActivation()
        }
    }
    
    public func resetActivation() -> Void {
        for sensor in priv_sensors {
            sensor.resetActivation()
        }
    }
    
    
    // MARK: NSCoding
    //
    // NSCoding requires that the object inherit from NSObject
    
    public static var key_sensors = "sensors"
    
    @objc public required init?(coder aDecoder: NSCoder) {
        priv_node = NodeBody(coder: aDecoder)!
        let objArray: NSArray = aDecoder.decodeObject(forKey: SensorArea.key_sensors) as! NSArray
        for neuron in objArray {
            priv_sensors.append(neuron as! Sensor)
        }
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        priv_node.encodeWithCoder(aCoder)
        let objArray: NSMutableArray = NSMutableArray()
        for sensor in priv_sensors {
            objArray.add(sensor)
        }
        aCoder.encode(objArray, forKey: SensorArea.key_sensors)
    }
    
    
    // MARK: Append
    
    public func append(_ sensor: Sensor) -> Sensor {
        precondition(!isStructureLocked)
        precondition(!network.isRegisteredNode(sensor))
        if sensor.hasIdentifier {
            network.registerNode(sensor)
        }
        priv_sensors.append(sensor)
        return sensor
    }
    
    
    
    // MARK: Access
    
    
    public subscript(index: Int) -> Sensor {
        return priv_sensors[index]
    }
    
    


    
    
    // MARK: *Private*
    
    fileprivate var priv_node: NodeBody
    
    fileprivate var priv_sensors = [Sensor]()
    
} // end class SensorArea

