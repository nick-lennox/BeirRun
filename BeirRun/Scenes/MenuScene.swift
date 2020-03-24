//
//  GGScene.swift
//  BeirRun
//
//  Created by Nicholas Lennox on 9/27/19.
//
import SpriteKit

class MenuScene: SKScene {
    
    var menu: UILabel?
    var playAgain = UIButton.init(type: .roundedRect)
    var background = SKSpriteNode()
    var playText = SKSpriteNode()
    /*
     Nick Lennox
     Displays the menu scene
     */
    override func didMove(to view: SKView) {
        if view == self.view {
            let menuBG = SKTexture(imageNamed: "menu")
            background = SKSpriteNode(texture: menuBG)
            background.size = CGSize(width: frame.width, height: frame.height)
            background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
            addChild(background)
            background.zPosition = -10000
       
            let ttp = SKTexture(imageNamed: "touchtoplay")
            playText = SKSpriteNode(texture: ttp)
            playText.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
            playText.size = background.size
            
            addChild(playText)
            playText.zPosition = background.zPosition + 1
            let tSeq = SKAction.sequence([
                SKAction.fadeOut(withDuration: 1),
                SKAction.fadeIn(withDuration: 1),
            ])
        playText.run(SKAction.repeatForever(tSeq))  //...the repeat forever
        }
    }
    
    override func touchesEnded(_: Set<UITouch>, with: UIEvent?)    {
       let newGame = GameScene(size: self.size)
        playText.removeAllActions()
        
        background.removeFromParent()
        playText.removeFromParent()
        let gameTrans = SKTransition.moveIn(with: .right, duration: 0.5)
        self.view?.presentScene(newGame, transition: gameTrans)
 
    }
}
