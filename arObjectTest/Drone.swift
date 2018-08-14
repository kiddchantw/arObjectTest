//
//  Drone.swift
//  SimpleARKitDemo
//
//  Created by kiddchantw on 2018/7/12.
//  Copyright © 2018年 AppCoda. All rights reserved.
//

import UIKit
import ARKit

class Drone: SCNNode {
    func loadModel() {
        guard let virtualObjectScene = SCNScene(named: "Drone_dae.scn") else { return }
        let wrapperNode = SCNNode()
        for child in virtualObjectScene.rootNode.childNodes {
            wrapperNode.addChildNode(child)
        }
        addChildNode(wrapperNode)
    }
}
