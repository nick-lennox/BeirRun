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
        let southAtlas = SKTextureAtlas(named: "ManSouth")
        let northAtlas = SKTextureAtlas(named: "ManNorth")
        let eastAtlas = SKTextureAtlas(named: "ManEast")
        let westAtlas = SKTextureAtlas(named: "ManWest")
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
        AI.position = CGPoint(x: 200, y: 0)
        AI.size = CGSize(width: AI.size.width * 3, height: AI.size.height * 3)
        AI.physicsBody = SKPhysicsBody(texture: initialTexture, size: AI.size)
        AI.physicsBody!.affectedByGravity = false
        AI.physicsBody!.isDynamic = false
        var frames:[SKTexture]?
        let directionTimer = Double.random(in: 2 ... 7)
        Timer.scheduledTimer(withTimeInterval: directionTimer, repeats: true) { (Timer) in
            let rngDirection = Double.random(in: 0 ... 2 * Double.pi)
            let left = CGFloat( (1 / 4) * Double.pi )
            if (rngDirection < Double(left) && rngDirection > -Double(left)) {
                frames = self.northFrames
                self.AI.run(SKAction.repeatForever(SKAction.move(to: CGPoint(x: self.AI.position.x, y: self.AI.position.y + 250), duration: directionTimer)))
            }
            else if (rngDirection > Double(left) && rngDirection < 3 * Double(left)) {
                frames = self.westFrames
                self.AI.run(SKAction.repeatForever(SKAction.move(to: CGPoint(x: self.AI.position.x - 250, y: self.AI.position.y), duration: directionTimer)))
            }
            else if (rngDirection < -Double(left) && rngDirection > -3 *  Double(left)) {
                frames = self.eastFrames
                self.AI.run(SKAction.repeatForever(SKAction.move(to: CGPoint(x: self.AI.position.x + 250, y: self.AI.position.y), duration: directionTimer)))
            }
            else {
                frames = self.southFrames
                self.AI.run(SKAction.repeatForever(SKAction.move(to: CGPoint(x: self.AI.position.x, y: self.AI.position.y - 250), duration: directionTimer)))
            }
            self.AI.run(SKAction.repeatForever(SKAction.animate(with: frames!, timePerFrame: 0.1)))
        }
    }
}
