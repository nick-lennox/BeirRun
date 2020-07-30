//
//  ProfileScene.swift
//  BeirRun
//
//  Created by Jared O'Connor on 7/7/20.
//  Copyright © 2020 BeirRunRCOS. All rights reserved.
//

import SpriteKit

class ProfileScene: SKScene {
    
    var totalDrinksLabel: UILabel?
    var totalGamesLabel: UILabel?
    var highScoreLabel: UILabel?
    var avgScoreLabel: UILabel?
    var title: UILabel?

    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    /*
     Nick Lennox
     Displays the menu scene
     */
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
            
            let scoreFont = UIFont(name: "GrungeTank", size: 44)
            
            //Title
            title = UILabel()
            title?.text = "PROFILE"
            title?.font = scoreFont
            title?.font = title?.font.withSize(70)
            title?.textColor = .white
            title?.lineBreakMode = .byClipping
            title?.sizeToFit()
            title?.center = CGPoint(x: frame.width / 2, y: frame.height / 2 - 140)
            
            view.addSubview(title!)
            
            //Total drinks
            totalDrinksLabel = UILabel()
            totalDrinksLabel?.adjustsFontForContentSizeCategory = true
            let drinks = app.totalDrinks
            totalDrinksLabel?.font = scoreFont
            totalDrinksLabel?.text = "Total Drinks - \(drinks)"
            totalDrinksLabel?.textColor = .white
            totalDrinksLabel?.lineBreakMode = .byClipping
            totalDrinksLabel?.sizeToFit()
            totalDrinksLabel?.center = CGPoint(x: frame.width / 2, y: frame.height / 2 - 20)
            
            view.addSubview(totalDrinksLabel!)
            
            //Total games played
            totalGamesLabel = UILabel()
            totalGamesLabel?.adjustsFontForContentSizeCategory = true
            let games = app.gamesPlayed
            totalGamesLabel?.font = scoreFont
            totalGamesLabel?.text = "Total Games - \(games)"
            totalGamesLabel?.textColor = .white
            totalGamesLabel?.lineBreakMode = .byClipping
            totalGamesLabel?.sizeToFit()
            totalGamesLabel?.center = CGPoint(x: frame.width / 2, y: frame.height / 2 + 20)
            
            view.addSubview(totalGamesLabel!)

            
            //High score
            highScoreLabel = UILabel()
            highScoreLabel?.adjustsFontForContentSizeCategory = true
            let highscore = app.highScore
            highScoreLabel?.font = scoreFont
            highScoreLabel?.text = "High Score - \(highscore)"
            highScoreLabel?.textColor = .white
            highScoreLabel?.lineBreakMode = .byClipping
            highScoreLabel?.sizeToFit()
            highScoreLabel?.center = CGPoint(x: frame.width / 2, y: frame.height / 2 + 60)
            
            view.addSubview(highScoreLabel!)
            
            //AVG score
            avgScoreLabel = UILabel()
            avgScoreLabel?.adjustsFontForContentSizeCategory = true
            var avg = 0
            if (games != 0) {
                avg = drinks / games
            }
            avgScoreLabel?.font = scoreFont
            avgScoreLabel?.text = "Average Score - \(avg)"
            avgScoreLabel?.textColor = .white
            avgScoreLabel?.lineBreakMode = .byClipping
            avgScoreLabel?.sizeToFit()
            avgScoreLabel?.center = CGPoint(x: frame.width / 2, y: frame.height / 2 + 100)
            
            view.addSubview(avgScoreLabel!)
            
        }
    }
    
   override func touchesEnded(_: Set<UITouch>, with: UIEvent?)    {
      let newGame = MenuScene(size: self.size)
       totalDrinksLabel?.removeFromSuperview()
       totalGamesLabel?.removeFromSuperview()
       highScoreLabel?.removeFromSuperview()
       avgScoreLabel?.removeFromSuperview()
       title?.removeFromSuperview()

       let gameTrans = SKTransition.moveIn(with: .right, duration: 0.5)
       self.view?.presentScene(newGame, transition: gameTrans)

   }
}
