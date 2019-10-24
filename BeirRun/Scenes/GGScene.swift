//
//  GGScene.swift
//  BeirRun
//
//  Created by Nicholas Lennox on 9/27/19.
//  Copyright © 2019 BeirRunRCOS. All rights reserved.
//
import SpriteKit

class GGScene: SKScene {
    var playAgain = UIButton.init(type: .custom)
    var menu = UIButton.init(type: .custom)
    var share = UIButton.init(type: .custom)
    var countLabel: UILabel?
    var hsCountLabel: UILabel?
    var scoreLabel: UILabel?
    var hScoreLabel: UILabel?


    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate


    override func didMove(to view: SKView) {
        if view == self.view {
            guard let GGbackground = UIImage(named: "GGbackground") else {
                return
            }
            let GGtexture = SKTexture(image: GGbackground)
            let background = SKSpriteNode(texture: GGtexture)
            background.size = CGSize(width: (frame.width), height: (frame.height))
            background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
            addChild(background)
            background.zPosition = -10000

            
            playAgain.frame = CGRect(x: frame.width / 2 - 50, y: frame.height -  frame.height / 3, width: 100, height: 100)
            playAgain.setImage(UIImage(named: "restartButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
            playAgain.setImage(UIImage(named: "restartButtonPressed")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
            playAgain.addTarget(self, action: #selector(GGScene.restartAction(_:)), for: .touchUpInside)
            
            menu.frame = CGRect(x: frame.width / 4, y: frame.height -  frame.height / 3, width: 75, height: 75)
            menu.setImage(UIImage(named: "menuButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
            menu.setImage(UIImage(named: "menuButtonPressed")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
            menu.addTarget(self, action: #selector(GGScene.menuAction(_:)), for: .touchUpInside)

            share.frame = CGRect(x: (3 / 4) * frame.width - 75, y: frame.height -  frame.height / 3, width: 75, height: 75)
            share.setImage(UIImage(named: "shareButton")?.withRenderingMode(.alwaysOriginal), for: .normal)
            share.setImage(UIImage(named: "shareButtonPressed")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
            //share.addTarget(self, action: #selector(GGScene.buttonAction(_:)), for: .touchUpInside)

            view.addSubview(menu)
            view.addSubview(share)
            view.addSubview(playAgain)
            
            let scoreFont = UIFont(name: "GrungeTank", size: 44)
            scoreLabel = UILabel()
            scoreLabel?.font = scoreFont
            scoreLabel?.adjustsFontForContentSizeCategory = true
            scoreLabel?.text = "score"
            scoreLabel?.textColor = .white
            scoreLabel?.lineBreakMode = .byClipping
            scoreLabel?.sizeToFit()
            scoreLabel?.center = CGPoint(x: frame.width / 4 + menu.frame.width / 2, y: frame.height / 4)
            
            hScoreLabel = UILabel()
            hScoreLabel?.font = scoreFont
            hScoreLabel?.adjustsFontForContentSizeCategory = true
            hScoreLabel?.text = "high score"
            hScoreLabel?.textColor = .white
            hScoreLabel?.lineBreakMode = .byClipping
            hScoreLabel?.sizeToFit()
            hScoreLabel?.center = CGPoint(x: (3 / 4) * frame.width - share.frame.width / 2, y: frame.height / 4)
            
            let customFont = UIFont(name: "GrungeTank", size: 150)
            countLabel = UILabel()
            countLabel?.font = customFont
            countLabel?.adjustsFontForContentSizeCategory = true
            let num = app.drinkCount
            countLabel?.text = "\(num)"
            countLabel?.textColor = .white
            countLabel?.lineBreakMode = .byClipping
            countLabel?.sizeToFit()
            countLabel?.center = CGPoint(x: frame.width / 4 + menu.frame.width / 2, y: frame.height / 2.1)
            
            hsCountLabel = UILabel()
            hsCountLabel?.font = customFont
            hsCountLabel?.adjustsFontForContentSizeCategory = true
            
            let scoreKey = "highscore"
            let defaults = UserDefaults.standard
            var highestScore = defaults.integer(forKey: scoreKey)
            if (highestScore < app.drinkCount) {
                defaults.set(app.drinkCount, forKey: scoreKey)
                highestScore = app.drinkCount
            }
            hsCountLabel?.text = "\(highestScore)"
            hsCountLabel?.textColor = .white
            hsCountLabel?.lineBreakMode = .byClipping
            hsCountLabel?.sizeToFit()
            hsCountLabel?.center = CGPoint(x: (3 / 4) * frame.width - share.frame.width / 2, y: frame.height / 2.1)
            
            view.addSubview(hsCountLabel!)
            view.addSubview(scoreLabel!)
            view.addSubview(countLabel!)
            view.addSubview(hScoreLabel!)
        }
    }
    
    @objc func restartAction(_ sender:UIButton!)
    {
        let newGame = GameScene(size: self.size)
        
        let gameTrans = SKTransition.moveIn(with: .right, duration: 0.5)
        playAgain.removeFromSuperview()
        scoreLabel?.removeFromSuperview()
        countLabel?.removeFromSuperview()
        hScoreLabel?.removeFromSuperview()
        hsCountLabel?.removeFromSuperview()
        app.drinkCount = 0
        menu.removeFromSuperview()
        share.removeFromSuperview()

        self.view?.presentScene(newGame, transition: gameTrans)
        
    }
    
    @objc func menuAction(_ sender:UIButton!)
    {
        let backToMenu = MenuScene(size: self.size)
        
        let gameTrans = SKTransition.moveIn(with: .left, duration: 0.5)
        playAgain.removeFromSuperview()
        scoreLabel?.removeFromSuperview()
        countLabel?.removeFromSuperview()
        hScoreLabel?.removeFromSuperview()
        hsCountLabel?.removeFromSuperview()
        app.drinkCount = 0
        menu.removeFromSuperview()
        share.removeFromSuperview()
        self.view?.presentScene(backToMenu, transition: gameTrans)
        
    }
    
    @objc func shareAction(_ sender:UIButton!)
    {
        //code
    }
}
