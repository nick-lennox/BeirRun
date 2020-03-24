//
//  Player.swift
//  BeirRun
//
//  Created by Nicholas Lennox on 2/25/20.
//  Copyright © 2020 BeirRunRCOS. All rights reserved.
//

import SpriteKit

class Player {
    var p:SKSpriteNode
    var frontFrames:[SKTexture] = []
    var sideLFrames:[SKTexture] = []
    var sideRFrames:[SKTexture] = []
    var backFrames:[SKTexture] = []
    var prevFrames:[SKTexture] = []
    var frames:[SKTexture]?
    
    init() {
        let hitBox = UIImage(named: "hitBox1")
        let pImage = UIImage(named: "standingFront")
        let ptexture = SKTexture(image: pImage!)
        let hitboxTexture = SKTexture(image: hitBox!)
        p = SKSpriteNode(texture: ptexture)
        let hitboxP = SKSpriteNode(texture: hitboxTexture)
        
        p.size = CGSize(width: ptexture.size().width / 2.5, height: ptexture.size().height / 2.5)
        hitboxP.size = CGSize(width: hitboxTexture.size().width / 2.5, height: hitboxTexture.size().height / 2.5)
        

        p.name = "player"
        p.zPosition = -1
        p.position = CGPoint(x: 350, y: -50)

        
        while (p.physicsBody == nil) {
            p.physicsBody = SKPhysicsBody(texture: hitboxTexture, size: hitboxP.size)
        }
        
        p.physicsBody!.affectedByGravity = false
        p.physicsBody!.allowsRotation = false
        p.physicsBody!.isDynamic = true
        
        self.setUpFrames()
    }
    
    func setUpFrames() {
        let frontWalkAtlas = SKTextureAtlas(named: "frontWalk")
        let sideWalkLAtlas = SKTextureAtlas(named: "sideWalkLeft")
        let sideWalkRAtlas = SKTextureAtlas(named: "sideWalkRight")
        let backWalkAtlas = SKTextureAtlas(named: "backWalk")
        for index in 1 ... 2 {
            let textureName = "walk_\(index)"
            let texture = frontWalkAtlas.textureNamed(textureName)
            frontFrames.append(texture)
        }
       
        var texture1 = sideWalkLAtlas.textureNamed("sideStillL")
        var texture2 = sideWalkLAtlas.textureNamed("sideWalkingL")
        sideLFrames.append(texture1)
        sideLFrames.append(texture2)

        texture1 = sideWalkRAtlas.textureNamed("sideStillR")
        texture2 = sideWalkRAtlas.textureNamed("sideWalkingR")
        sideRFrames.append(texture1)
        sideRFrames.append(texture2)
       
        texture1 = backWalkAtlas.textureNamed("backwalkl")
        texture2 = backWalkAtlas.textureNamed("backwalkr")
        backFrames.append(texture1)
        backFrames.append(texture2)
       //let texture = playerAtlas.textureNamed("frontstanding")
       //frames.append(texture)
        prevFrames = frontFrames
        
    }
    
    func move(_ aVelocity: CGFloat) {
        let left = CGFloat( (1 / 4) * Double.pi )
        
        if (aVelocity < left && aVelocity > -left) {
            frames = backFrames
            //let lowerBound = CGFloat((-1 / 20) * pow(Double(app.drinkCount), 2.0))
            //let upperBound = CGFloat((1 / 20) * pow(Double(app.drinkCount), 2.0))
            //drunkX = CGFloat.random(in: lowerBound...upperBound)
           // player.physicsBody?.applyForce(CGVector(dx: drunkX, dy: 0))
        }
        else if (aVelocity > left && aVelocity < 3 * left) {
            frames = sideLFrames
            /*let lowerBound = CGFloat((-1 / 50) * pow(Double(self.app.drinkCount), 2.0))
            let upperBound = CGFloat((1 / 50) * pow(Double(self.app.drinkCount), 2.0))
            drunkY = CGFloat.random(in: lowerBound...upperBound)
            player.physicsBody?.applyForce(CGVector(dx: 0, dy: drunkY))
 */
        }
        else if (aVelocity < -left && aVelocity > -3 * left) {
            frames = sideRFrames
            /*
            let lowerBound = CGFloat((-1 / 50) * pow(Double(self.app.drinkCount), 2.0))
            let upperBound = CGFloat((1 / 50) * pow(Double(self.app.drinkCount), 2.0))
            drunkY = CGFloat.random(in: lowerBound...upperBound)
            player.physicsBody?.applyForce(CGVector(dx: 0, dy: drunkY))
 */
        }
        else {
            frames = frontFrames
            /*
            let lowerBound = CGFloat((-1 / 20) * pow(Double(self.app.drinkCount), 2.0))
            let upperBound = CGFloat((1 / 20) * pow(Double(self.app.drinkCount), 2.0))
            drunkX = CGFloat.random(in: lowerBound...upperBound)
            player.physicsBody?.applyForce(CGVector(dx: drunkX, dy: 0))
 */
        }
        
        if (self.frames != self.prevFrames) {
            if (frames == sideRFrames || frames == sideLFrames) {
                p.run(SKAction.repeatForever(SKAction.animate(with: frames!, timePerFrame: 0.2)))
            }
            else {
                p.run(SKAction.repeatForever(SKAction.animate(with: frames!, timePerFrame: 0.3)))
            }
            prevFrames = frames!
        }
    }
}
