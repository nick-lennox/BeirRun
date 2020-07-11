//
//  PowerUp.swift
//  BeirRun
//
//  Created by nick-lennox on 7/10/20.
//  Copyright © 2020 BeirRunRCOS. All rights reserved.
//

import SpriteKit

class PowerUp {
    var object:SKSpriteNode
    var pos: CGPoint
    var isRunning: Bool
    
    init(_ powerupType: String) {
        var objTexture: SKTexture
        isRunning = true
        pos = CGPoint(x: 0, y: 0)
        //if (powerupType == "redbull") {
        objTexture = SKTexture(imageNamed: "beer1")
        //}
        object = SKSpriteNode(texture: objTexture)
        object.size = objTexture.size()
        object.position = pos
        object.physicsBody = SKPhysicsBody(texture: objTexture, size: object.size)
        object.physicsBody!.affectedByGravity = false
        object.physicsBody!.isDynamic = false
    }
    
    func remove() {
        object.removeFromParent()
        isRunning = false
    }
    
    func addTimer(cam: SKCameraNode) {
        isRunning = true
        let subTexture = SKTexture(imageNamed: "timerSubstrate")
        let fillTexture = SKTexture(imageNamed: "poweruptimerfill")
            
        let sub = SKSpriteNode(texture: subTexture)
        let fil = SKSpriteNode(texture: fillTexture)
        
        fil.size = CGSize(width: fillTexture.size().width / 4, height: fillTexture.size().height / 4)
        sub.size = CGSize(width: subTexture.size().width / 4, height: subTexture.size().height / 4)
        
        fil.name = "fill"
        sub.name = "subs"
        
        fil.zPosition = 2
        sub.zPosition = 1
    
        sub.position = CGPoint(x: 175, y: 140)
        fil.position = CGPoint(x: 175, y: 140)
        var fillWidth = CGFloat(0)
        fillWidth = fillTexture.size().width

        cam.addChild(sub)
        cam.addChild(fil)

        fil.run(SKAction.resize(toWidth: fillWidth / 4, duration: 0.0))
        fil.run(SKAction.moveTo(x: sub.position.x, duration: 0.0))
        
        fil.run(SKAction.resize(toWidth: 0, duration: 5))
        fil.run(SKAction.moveTo(x: sub.position.x - (fillWidth / 8), duration: 5))
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (Timer) in
            fil.removeFromParent()
            sub.removeFromParent()
        }
    }
}
