//
//  RouteNode.swift
//  AR_Navigation
//
//  Created by Gleb Radchenko on 12/1/17.
//  Copyright © 2017 Gleb Radchenko. All rights reserved.
//

import Foundation
import SceneKit
import MapKit

class RouteNode: GlobalNode<Container<MKRoute>> {
    
    var stepNodes: [StepNode] = []
    var lineNodes: [LineNode] = []
    
    override init(element: Container<MKRoute>) {
        super.init(element: element)
        sourceId = element.id
        initialNodesPrepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialNodesPrepare() {
        stepNodes = element.element.steps.map { StepNode(element: $0) }
        stepNodes.forEach { addChildNode($0) }
    }
    
    override func updateWith(currentCameraTransform: matrix_float4x4, currentCoordinates: CLLocationCoordinate2D, thresholdDistance: Double) {
        stepNodes.forEach { $0.updateWith(currentCameraTransform: currentCameraTransform,
                                          currentCoordinates: currentCoordinates,
                                          thresholdDistance: thresholdDistance) }
        clearLineNodes()
        addLineNodes()
    }
    
    func addLineNodes() {
        let stepsCount = stepNodes.count
        guard stepsCount >= 2 else { return }
        
        let indexPairs: [(firstIndex: Int, secondIndex: Int)] = (0..<stepsCount - 1).map { ($0, $0 + 1) }
        let stepPairs: [(firstStep: StepNode, secondStep: StepNode)] = indexPairs.map { (stepNodes[$0.firstIndex], stepNodes[$0.secondIndex]) }
        
        let lineNodes = stepPairs.map { LineNode(from: $0.firstStep, to: $0.secondStep, radius: 0.2) }
        lineNodes.forEach { addChildNode($0) }
        self.lineNodes = lineNodes
    }
    
    func clearLineNodes() {
        lineNodes.forEach { $0.removeFromParentNode() }
        lineNodes.removeAll()
    }
    
    func applyColor(_ color: UIColor) {
        stepNodes.forEach { $0.applyColor(color) }
        lineNodes.forEach { $0.applyColor(color) }
    }
}
