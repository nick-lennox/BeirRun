//
//  Beer.swift
//  BeirRun
//
//  Created by Nicholas Lennox on 3/3/20.
//  Copyright © 2020 BeirRunRCOS. All rights reserved.
//

import SpriteKit

class Beer {
    var b:SKSpriteNode
    let shadow = SKSpriteNode()
    var beerAction:[SKAction] = []
    var shadowFrames:[SKTexture] = []
    let shadowAtlas = SKTextureAtlas(named: "shadow")
    
    init() {
        let hitbox = UIImage(named: "beer1")
        let texture = SKTexture(image: hitbox!)
        b = SKSpriteNode(texture: texture)
        
        beerAction.append(SKAction.moveBy(x: 0.0, y: 5.0, duration: 0.15))
        beerAction.append(SKAction.moveBy(x: 0.0, y: -5.0, duration: 0.15))
        
        //b.run(SKAction.repeatForever(SKAction.sequence(beerAction)))
        
        for index in 1 ... 3 {
            let textureName = "shadow_\(index)"
            let sTexture = shadowAtlas.textureNamed(textureName)
            shadowFrames.append(sTexture)
        }
        b.size = CGSize(width: b.size.width / 2, height: b.size.width / 2)
        shadow.size = b.size
        
        while b.physicsBody == nil {
            b.physicsBody = SKPhysicsBody(texture: texture, size: b.size)
        }
        b.physicsBody!.affectedByGravity = false
        b.name = "drink"
    }
    
    func placeDrink(_ posX:CGFloat,_ posY:CGFloat) {
        
        
    }
}
