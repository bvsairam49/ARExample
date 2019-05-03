//
//  ViewController.swift
//  ARPortal
//
//  Created by sairam on 12/25/18.
//  Copyright © 2017 sairampersonal.com. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var configuration = ARWorldTrackingConfiguration()
    var isModelAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.backgroundColor = UIColor.clear
    }
    
    @objc func tapped(recognizer: UIGestureRecognizer){
        
        let sceneViewTappedOn = recognizer.view as! SCNView
        let touchCoordinates = recognizer.location(in: sceneViewTappedOn)
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        if hitTest.isEmpty {
            print("didn't touch anything")
        } else {
            
            let results = hitTest.first!
            let node = results.node
            if node.name == "stepPlane"
            {
                sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                    if node.name == "slideDoor1"
                    {
                            let waitDuration = SCNAction.wait(duration: 0.3)
                            let moveLeft = SCNAction.move(to: SCNVector3.init(-0.501, 0, -0.126), duration: 0.3)
                            node.runAction(SCNAction.sequence([waitDuration,moveLeft]))
                    }
                    else if node.name == "slideDoor2"
                    {
                        let waitDuration = SCNAction.wait(duration: 0.3)
                        let moveLeft = SCNAction.move(to: SCNVector3.init(-0.501, 0, 0.189), duration: 0.3)
                        node.runAction(SCNAction.sequence([waitDuration,moveLeft]))
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        
        // setting plane detection to horizontal so that we are able to detect horizontal planes.
        configuration.planeDetection = .horizontal
        
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // called when touches are detected on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            // gives us the location of where we touched on the 2D screen.
            let touchLocation = touch.location(in: sceneView)
            
            // hitTest is performed to get the 3D coordinates corresponding to the 2D coordinates that we got from touching the screen.
            // That 3d coordinate will only be considered when it is on the existing plane that we detected.
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            // if we have got some results using the hitTest then do this
            if let hitResult = results.first {
                
                let boxScene = SCNScene(named: "art.scnassets/ignite.scn")!
                
                if let boxNode = boxScene.rootNode.childNode(withName: "ignite", recursively: true) {
                    
                    print("Box Size is : ")
                    print(boxNode.scale)
                    boxNode.movabilityHint = .fixed
                    boxNode.position = SCNVector3(x: 0 , y: 0.5, z:  4.0)
                    boxNode.eulerAngles.y = Float(-90.degreesToRadians)

                    sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
                        node.removeFromParentNode()
                    }
                    // finally the box is added to the scene.
                    sceneView.scene.rootNode.addChildNode(boxNode)
                    isModelAdded = true
                }
            }
        }
    }
    
    @IBAction func resetAction(_ sender: Any) {
        isModelAdded = false
        resetSession()
    }
    
    func resetSession()
    {
        sceneView.session.pause()
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        sceneView.session.run(sceneView.session.configuration!, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // this is a delegate method which comes from ARSCNViewDelegate, and this method is called when a horizontal plane is detected.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !isModelAdded
        {
            if anchor is ARPlaneAnchor {
                
                // anchors can be of many types, as we are just dealing with horizontal plane detection we need to downcast anchor to ARPlaneAnchor
                let planeAnchor = anchor as! ARPlaneAnchor
                
                // creating a plane geometry with the help of dimentions we got using plane anchor.
                let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
                
                // a node is basically a position.
                let planeNode = SCNNode()
                
                // setting the position of the plane geometry to the position we got using plane anchor.
                planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
                
                // when a plane is created its created in xy plane instead of xz plane, so we need to rotate it along x axis.
                planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
                
                //create a material object
                let gridMaterial = SCNMaterial()
                
                //setting the material as an image. A material can also be set to a color.
                gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
                
                // assigning the material to the plane
                plane.materials = [gridMaterial]
                
                
                // assigning the position to the plane
                planeNode.geometry = plane
                
                //adding the plane node in our scene
                node.addChildNode(planeNode)
                
                
                
            }
                
            else {
                
                return
            }
        }
        
    }
    
}


extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}
