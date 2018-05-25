//
//  ViewController.swift
//  ARDrawing
//
//  Created by Will Hess on 5/24/18.
//  Copyright © 2018 Will Hess. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var draw: UIButton!
    @IBOutlet weak var colorPickerView: ColorPickerView!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    var pickerColor = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        self.colorPickerView.isHidden = true
        self.colorPickerView.didChangeColor = { color in
            self.pickerColor = color!
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        guard let pointOfView = sceneView.pointOfView else {return}
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let currentPositionOfCamera = orientation + location
        
        DispatchQueue.main.async {
            if self.draw.isHighlighted {
                let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.02))
                sphereNode.position = currentPositionOfCamera
                self.sceneView.scene.rootNode.addChildNode(sphereNode)
                sphereNode.geometry?.firstMaterial?.diffuse.contents = self.pickerColor
            }
            else {
                let pointer = SCNNode(geometry: SCNSphere(radius: 0.008))
                pointer.name = "pointer"
                pointer.position = currentPositionOfCamera
                self.sceneView.scene.rootNode.enumerateChildNodes({ (node, _) in
                    if node.name == "pointer" {
                        node.removeFromParentNode()
                    }
                })
                self.sceneView.scene.rootNode.addChildNode(pointer)
                pointer.geometry?.firstMaterial?.diffuse.contents = self.pickerColor
            }
        }
    }
    
    @IBAction func colors(_ sender: Any) {
        displayColorPicker()
    }
    
    func displayColorPicker() {
        if colorPickerView.isHidden == false {
            self.colorPickerView.isHidden = true
        } else {
            self.colorPickerView.isHidden = false
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        restartSession()
    }
    
    func restartSession() {
        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
    }
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

