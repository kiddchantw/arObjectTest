//
//  ViewController.swift
//  arObjectTest
//
//  Created by kiddchantw on 2018/8/10.
//  Copyright © 2018年 kiddchantw. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    
    @IBOutlet var arView: ARSCNView!
    
    let drone = Drone()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.addDrone()
        
        addTapGestureToSceneView()
        //        addBox(x: 50, y: 0, z: 50)
        //        addSphere(x: -50, y: 0, z: -50)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //arView setting
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
        
    }
    
    
    //add ar Object
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.arView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }

    func getUserVectorM1() -> SCNVector3 {
        if let frame = self.arView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let pos = SCNVector3( 1*mat.m41, 1*mat.m42,-2 * mat.m43) // location of camera in world space
            print("get pos \(pos)")
            return pos
        }
        return (SCNVector3(0, 0, -0.2))
        
    }
    
    
    func getUserVectorM2() -> SCNVector3 { // (direction, position)
            if let frame = self.arView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            print("get dir \(dir)")
            return dir
        }
        return (SCNVector3(0, 0, -0.2))
    }
    
    
    
    
    var objectIndex = 1
    @IBAction func btnClick(_ sender: Any) {
        print("btnClick add sphere")

        
         let sphere = SCNSphere(radius: 0.1)
        let node = SCNNode(geometry: sphere)
        node.position = getUserVectorM1()
            //SCNVector3(0, 0, 0)
        node.geometry = node.geometry!.copy() as? SCNGeometry
        node.geometry?.firstMaterial = node.geometry?.firstMaterial!.copy() as? SCNMaterial
        node.geometry?.firstMaterial?.diffuse.contents = randomColor()
        arView.scene.rootNode.addChildNode(node)
        arView.autoenablesDefaultLighting = false

        
        
        
//        let sphere2 = SCNSphere(radius: 0.1)
//        let node2 = SCNNode(geometry: sphere2)
//        node2.position = getUserVector2()
//        //getCameraPosition(in: arView)!
//        //SCNVector3(0, 0, 0)
//        node2.geometry = node.geometry!.copy() as? SCNGeometry
//        node2.geometry?.firstMaterial = node.geometry?.firstMaterial!.copy() as? SCNMaterial
//        node2.geometry?.firstMaterial?.diffuse.contents = UIColor.green //randomColor()
//        arView.scene.rootNode.addChildNode(node)
//        arView.autoenablesDefaultLighting = false
        

    }
    
    
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
        arView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    
    
    
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: arView)
        let hitTestResults = arView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else {
            let hitTestResultsWithFeaturePoints = arView.hitTest(tapLocation, types: .featurePoint)
            if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
                let translation = hitTestResultWithFeaturePoints.worldTransform.translation
                print("didTap  x: \(translation.x), y: \(translation.y), z: \(translation.z)")
                self.addBox(x: translation.x, y: translation.y, z: translation.z)
//              self.addSphere(x: translation.x, y: translation.y, z: translation.z)
            }
            return
        }
        node.removeFromParentNode()
    }
    
    
    
    //ar Object  box
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(x, y, z)
        let colors = [randomColor(),randomColor(),randomColor(),randomColor(),randomColor(),randomColor()]
        let sideMaterials = colors.map { color -> SCNMaterial in
            let material = SCNMaterial()
            material.diffuse.contents = color
            material.locksAmbientWithDiffuse = true
            return material
        }
        box.materials = sideMaterials
        arView.scene.rootNode.addChildNode(boxNode)
    }
    
    
    func addSphere(x: Float = 0, y: Float = 0, z: Float = -0.2){
        let sphere = SCNSphere(radius: 0.1)
        let node = SCNNode(geometry: sphere)
        node.position = SCNVector3(x, y, z)
        node.geometry = node.geometry!.copy() as? SCNGeometry
        node.geometry?.firstMaterial = node.geometry?.firstMaterial!.copy() as? SCNMaterial
        node.geometry?.firstMaterial?.diffuse.contents = randomColor()
        arView.scene.rootNode.addChildNode(node)
        arView.autoenablesDefaultLighting = false
    }
    
    
    //無法設定點擊位置出現
    func addDrone() {
        drone.loadModel()
        arView.scene.rootNode.addChildNode(drone)
    }
    
    
    //失敗
    func addTextObject(x: Float = 0, y: Float = 0, z: Float = -0.2){
        let geoText = SCNText(string: "Hello", extrusionDepth: 1.0)
        geoText.font = UIFont (name: "Arial", size: 12)
        geoText.firstMaterial!.diffuse.contents = randomColor()
        let textNode = SCNNode(geometry: geoText)
        let (minVec, maxVec) = textNode.boundingBox
        //textNode.position = SCNVector3(x, y, z) //
       textNode.position =  SCNVector3(x: (minVec.x - maxVec.x) / 2, y: minVec.y - maxVec.y, z: 0)
        textNode.pivot = SCNMatrix4MakeTranslation((maxVec.x - minVec.x) / 2, 0, 0)
        arView.scene.rootNode.addChildNode(textNode)
        
        let w = CGFloat(maxVec.x - minVec.x)
        let h = CGFloat(maxVec.y - minVec.y)
        let d = CGFloat(maxVec.z - minVec.z)
        
        let geoBox = SCNBox(width: w, height: h, length: d, chamferRadius: 0)
        geoBox.firstMaterial!.diffuse.contents =   UIColor.green.withAlphaComponent(0.5)
        let boxNode = SCNNode(geometry: geoBox)
        boxNode.position = SCNVector3Make((maxVec.x - minVec.x) / 2 + minVec.x, (maxVec.y - minVec.y) / 2 + minVec.y, 0);
        textNode.addChildNode(boxNode)
    }
    
    
    func randomColor() -> UIColor{
        let redC   : CGFloat = CGFloat(arc4random_uniform(255))/CGFloat(255)
        let greenC : CGFloat = CGFloat(arc4random_uniform(255))/CGFloat(255)
        let blueC  : CGFloat = CGFloat(arc4random_uniform(255))/CGFloat(255)
        return  UIColor(red: redC, green: greenC, blue: blueC, alpha: 1)
    }
    
}

//Adding Multiple Objects to ARSCNView
extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}
