//
//  GGViewController.swift
//  BeirRun
//
//  Created by Nicholas Lennox on 9/27/19.
//  Copyright © 2019 BeirRunRCOS. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GGViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene = GGScene(size: view.bounds.size)
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
            
                // Present the scene
                view.presentScene(scene)
            
                
                view.ignoresSiblingOrder = true
                
                view.showsFPS = true
                view.showsNodeCount = true
        }
    }
}
