//
//  GGScene.swift
//  BeirRun
//
//  Created by Nicholas Lennox on 9/27/19.
//  Copyright © 2019 BeirRunRCOS. All rights reserved.
//
import SpriteKit

class MenuScene: SKScene {
    
    var menu: UILabel?
    var playAgain = UIButton.init(type: .roundedRect)
    
    override func didMove(to view: SKView) {
        if view == self.view {
            let background = SKSpriteNode()
            background.color = .yellow
            background.size = CGSize(width: (frame.width), height: (frame.height))
            background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
            addChild(background)
            background.zPosition = -10000
            
            playAgain.frame = CGRect(x: frame.width / 2 - 50, y: frame.height / 4, width: 100, height: 100)
            playAgain.setImage(UIImage(named: "beer")?.withRenderingMode(.alwaysOriginal), for: .normal)
            playAgain.setImage(UIImage(named: "jSubstrate")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
            
            playAgain.addTarget(self, action: #selector(MenuScene.buttonAction(_:)), for: .touchUpInside)
            
            view.addSubview(playAgain)
            
            menu = UILabel()
            menu?.text = " MENU "
            menu?.font = UIFont.boldSystemFont(ofSize:100)
            //gameOver?.frame.size.width = 0
            menu?.lineBreakMode = .byClipping
            menu?.sizeToFit()
            menu?.center = CGPoint(x: frame.width/2, y: frame.height/2)
            
            view.addSubview(menu!)
        }
    }
    
    @objc func buttonAction(_ sender:UIButton!)
    {
        let newGame = GameScene(size: self.size)
        
        menu?.removeFromSuperview()
        playAgain.removeFromSuperview()
        let gameTrans = SKTransition.moveIn(with: .right, duration: 0.5)
        playAgain.removeFromSuperview()
        self.view?.presentScene(newGame, transition: gameTrans)
    }
}
