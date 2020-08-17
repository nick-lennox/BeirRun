//
//  AI.swift
//  BeirRun
//
//  Created by nick-lennox on 7/27/20.
//  Copyright © 2020 BeirRunRCOS. All rights reserved.
//

import SpriteKit

class AI {
    var AI: SKSpriteNode
    var southFrames:[SKTexture] = []
    var northFrames:[SKTexture] = []
    var eastFrames:[SKTexture] = []
    var westFrames:[SKTexture] = []


    init(aiTexture: String) {
        var southAtlas : SKTextureAtlas
        var northAtlas : SKTextureAtlas
        var eastAtlas : SKTextureAtlas
        var westAtlas : SKTextureAtlas

        if (aiTexture == "Youngbusinessmanwalking") {
            southAtlas = SKTextureAtlas(named: "ManSouth")
            northAtlas = SKTextureAtlas(named: "ManNorth")
            eastAtlas = SKTextureAtlas(named: "ManEast")
            westAtlas = SKTextureAtlas(named: "ManWest")
        }
        else if (aiTexture == "Maleyouthwalking") {
            southAtlas = SKTextureAtlas(named: "KidSouth")
            northAtlas = SKTextureAtlas(named: "KidNorth")
            eastAtlas = SKTextureAtlas(named: "KidEast")
            westAtlas = SKTextureAtlas(named: "KidWest")
        }
        else if (aiTexture == "Femaletrendywalking") {
            southAtlas = SKTextureAtlas(named: "TrendySouth")
            northAtlas = SKTextureAtlas(named: "TrendyNorth")
            eastAtlas = SKTextureAtlas(named: "TrendyEast")
            westAtlas = SKTextureAtlas(named: "TrendyWest")
        }
        else {
            southAtlas = SKTextureAtlas(named: "KidSouth")
            northAtlas = SKTextureAtlas(named: "KidNorth")
            eastAtlas = SKTextureAtlas(named: "KidEast")
            westAtlas = SKTextureAtlas(named: "KidWest")
        }
        for index in 1 ... 8 {
            let textureName = aiTexture + "south\(index)"
            let pTexture = southAtlas.textureNamed(textureName)
            southFrames.append(pTexture)
        }
        for index in 1 ... 8 {
            let textureName = aiTexture + "north\(index)"
            let pTexture = northAtlas.textureNamed(textureName)
            northFrames.append(pTexture)
        }
        for index in 1 ... 8 {
            let textureName = aiTexture + "east\(index)"
            let pTexture = eastAtlas.textureNamed(textureName)
            eastFrames.append(pTexture)
        }
        for index in 1 ... 8 {
            let textureName = aiTexture + "west\(index)"
            let pTexture = westAtlas.textureNamed(textureName)
            westFrames.append(pTexture)
        }
        let initialTexture = SKTexture(imageNamed: "ManSouth")
        AI = SKSpriteNode(texture: initialTexture)
        AI.name = "ai"
        AI.position = CGPoint(x: Int.random(in: 0 ... 100), y: Int.random(in: 0 ... 100))
        AI.size = CGSize(width: AI.size.width * 3, height: AI.size.height * 3)
        AI.physicsBody = SKPhysicsBody(texture: initialTexture, size: AI.size)
        AI.physicsBody!.affectedByGravity = false
        AI.physicsBody!.isDynamic = false
        var frames:[SKTexture]?
        let directionTimer = Double.random(in: 1 ... 3)
        Timer.scheduledTimer(withTimeInterval: directionTimer, repeats: true) { (Timer) in
            let rngDirection = Double.random(in: 0 ... 2 * Double.pi)
            if (rngDirection < 2.355 && rngDirection > 0.785) {
                frames = self.northFrames
                self.AI.run(SKAction.repeatForever(SKAction.move(to: CGPoint(x: self.AI.position.x, y: self.AI.position.y + 250), duration: directionTimer)))
            }
            else if (rngDirection > 2.355 && rngDirection < 3.925) {
                frames = self.westFrames
                self.AI.run(SKAction.repeatForever(SKAction.move(to: CGPoint(x: self.AI.position.x - 250, y: self.AI.position.y), duration: directionTimer)))
            }
            else if (rngDirection < 5.495 && rngDirection > 3.925) {
                frames = self.southFrames
                self.AI.run(SKAction.repeatForever(SKAction.move(to: CGPoint(x: self.AI.position.x, y: self.AI.position.y - 250), duration: directionTimer)))
            }
            else {
                frames = self.eastFrames
                self.AI.run(SKAction.repeatForever(SKAction.move(to: CGPoint(x: self.AI.position.x + 250, y: self.AI.position.y), duration: directionTimer)))
            }
            self.AI.run(SKAction.repeatForever(SKAction.animate(with: frames!, timePerFrame: 0.1)))
        }
    }
}
