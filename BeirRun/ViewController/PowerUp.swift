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
    let redbullAtlas = SKTextureAtlas(named: "Redbull")
    var redbullFrames:[SKTexture] = []

    init(_ powerupType: String) {
        isRunning = true
        pos = CGPoint(x: Int.random(in: -150..<1000), y: Int.random(in: -200..<250)) //change to random later
        //if (powerupType == "redbull") {
        let objTexture = SKTexture(imageNamed: "beer1")
        for index in 1 ... 3 {
            let textureName = "redbull_\(index)"
            let sTexture = redbullAtlas.textureNamed(textureName)
            redbullFrames.append(sTexture)
        }
        object = SKSpriteNode(texture: objTexture)
        object.run(SKAction.repeatForever(
            SKAction.animate(with: redbullFrames,
                             timePerFrame: 0.2,
                             resize: false,
                             restore: true)),
            withKey:"redbullAnimation")
        object.size = CGSize(width: object.size.width  / 3, height: object.size.height / 2)
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
