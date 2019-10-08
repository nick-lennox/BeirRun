//
//  GameScene.swift
//
//  Created by Dmitriy Mitrophanskiy on 28.09.14.
//  Copyright (c) 2014 Dmitriy Mitrophanskiy. All rights reserved.
//
import SpriteKit

var cam = SKCameraNode()

class GameScene: SKScene, SKPhysicsContactDelegate {
    let setJoystickStickImageBtn = SKLabelNode()
    let setJoystickSubstrateImageBtn = SKLabelNode()
    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    //var drinkCount: Int = 0
    var player: SKSpriteNode?
    var drink: SKSpriteNode?
    var tableL: SKSpriteNode?
    var tableR: SKSpriteNode?
    var timerFill: SKSpriteNode?
    var timerSubstrate: SKSpriteNode?
    var drinkHitbox: CGRect?
    var labelBox: CGRect?
    var countLabel: UILabel?
    var timeLabel: UILabel?
    var timer = 100.0
    var sTime = Timer()
    
    let substrateImage = UIImage(named: "timerSubstrate")
    let fillImage = UIImage(named: "timerFill")
    
    let moveJoystick = 🕹(withDiameter: 100)
    let rotateJoystick = TLAnalogJoystick(withDiameter: 100)
    
    var isContact = 0
    var fillWidth = CGFloat(0)
    //var highScore = UserDefaults.init(suiteName: "HIGH SCORE")
    var prevBeerX = CGFloat(0)
    var prevBeerY = CGFloat(0)
   
    var joystickStickImageEnabled = true {
        didSet {
            let image = joystickStickImageEnabled ? UIImage(named: "jStick-1") : nil
            
            moveJoystick.handleImage = image
            rotateJoystick.handleImage = image
        }
    }
    
    var joystickSubstrateImageEnabled = true {
        didSet {
            let image = joystickSubstrateImageEnabled ? UIImage(named: "jSubstrate-1") : nil
            moveJoystick.baseImage = image
            rotateJoystick.baseImage = image
        }
    }
    
    public func getPlayerPos() -> CGPoint {
        return player!.position
    }
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        self.camera = cam
        self.addChild(cam)
        let background = SKSpriteNode(imageNamed: "Artboard 1")
        background.size = CGSize(width: (frame.width), height: (frame.height))
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        self.addChild(background)
        background.zPosition = -10000
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        prevBeerX = frame.width / 2
        prevBeerY = frame.height / 2
//        physicsBody?.usesPreciseCollisionDetection = true
        //Set UP
        setupJoystick()
        setUpTables()
        setUpTimer()
        setUpCount()
        placeFirstDrink()

        //MARK: Handlers begin
        moveJoystick.on(.move) { [unowned self] joystick in
            guard let player = self.player else {
                return
            }
            
            let pVelocity = joystick.velocity;
            var speed = CGFloat(0.1)
            /*
            var min1 : CGFloat = 0.0
            var max1 : CGFloat = 0.0

            if (self.drinkCount != 0) {
                min1 = (.pi/(100.0/CGFloat(self.drinkCount)))
                max1 = (.pi/(100.0/CGFloat(self.drinkCount)))
            }
            
            let newMin = joystick.angular - (min1)
            let newMax = joystick.angular + (max1)
            var aVelocity = CGFloat.random(in: newMin...newMax)
             */
            var aVelocity = joystick.angular
            if self.sTime.isValid == false {
                speed = 0.0
                aVelocity = 0.0
            }
            
            player.position = CGPoint(x: player.position.x + (pVelocity.x * speed), y: player.position.y + (pVelocity.y * speed))
            player.run(SKAction.rotate(toAngle: (aVelocity + .pi / 2 ), duration: 0.01, shortestUnitArc: true))
        }

        view.isMultipleTouchEnabled = true
 
        setupPlayer(CGPoint(x: frame.midX, y: frame.midY))

    }
    
    func placeFirstDrink() {
        guard let drinkImage = UIImage(named: "beer") else {
            return
        }
        let texture = SKTexture(image: drinkImage)
        let d = SKSpriteNode(texture: texture)
        
        /*
         let posX = CGFloat.random(in: 100...(frame.width - 100))
         let posY = CGFloat.random(in: 100...(frame.height - 100))
         d.position = CGPoint(x: posX, y: posY)
         */
        
        let posX = CGFloat.random(in: 100...(frame.width - 100))
        let posY = CGFloat.random(in: 50...(frame.height - 50))
        d.position = CGPoint(x: posX, y: posY)
        d.size = CGSize(width: (43), height: (47))
        d.physicsBody = SKPhysicsBody(texture: texture, size: d.size)
        d.physicsBody!.affectedByGravity = false
        d.name = "drink"
        
        
        d.zPosition = -2
        //d.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        self.addChild(d)
        drink = d
    }
    
    func setupJoystick() {
        joystickStickImageEnabled = true
        joystickSubstrateImageEnabled = true
        //only allows user to control joystick from left side of screen
        let moveJoystickHiddenArea = TLAnalogJoystickHiddenArea(rect: CGRect(x: 0, y: 0, width: 1000, height: 1000))
        
        moveJoystickHiddenArea.joystick = moveJoystick
        moveJoystick.isMoveable = true
        moveJoystickHiddenArea.strokeColor = SKColor.clear
        cam.addChild(moveJoystickHiddenArea)
        //cam.addChild(moveJoystick)
    }
    
    func setupPlayer(_ position: CGPoint) {
        guard let playerImage = UIImage(named: "guy") else {
            return
        }
        let texture = SKTexture(image: playerImage)
        let p = SKSpriteNode(texture: texture)
        p.size = CGSize(width: 48, height: 62)
        
        p.physicsBody = SKPhysicsBody(texture: texture, size: p.size)
        p.physicsBody!.affectedByGravity = false
        p.physicsBody?.contactTestBitMask = drink!.physicsBody!.collisionBitMask
        p.name = "player"
        
        p.position = position
        p.zPosition = -1
        self.addChild(p)
        player = p
        let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: player!)
        cam.constraints = [ constraint ]

    }
    
    func setUpTimer() {
        let subTexture = SKTexture(image: substrateImage!)
        let fillTexture = SKTexture(image: fillImage!)
        
        let sub = SKSpriteNode(texture: subTexture)
        let fil = SKSpriteNode(texture: fillTexture)
        
        fil.size = CGSize(width: fillImage!.size.width / 2, height: fillImage!.size.height / 2)
        sub.size = CGSize(width: substrateImage!.size.width / 2, height: substrateImage!.size.height / 2)
        fillWidth = fillImage!.size.width
        
        fil.name = "fill"
        sub.name = "subs"
        
        fil.zPosition = 2
        sub.zPosition = 1
    
        //player = self.childNode(withName: "player") as? SKSpriteNode
        sub.position = CGPoint(x: 175, y: 175)
        fil.position = CGPoint(x: 175, y: 175)
        
        //fil.physicsBody = SKPhysicsBody(texture: fillTexture, size: fill!.size)
        //sub.physicsBody = SKPhysicsBody(texture: subTexture, size: substrate!.size)
        //fil.physicsBody!.isDynamic = false
        //sub.physicsBody!.isDynamic = false


        //timerFill?.run(SKAction.resize(toWidth: 0.0, duration: 6.0))
        //timerFill?.run(SKAction.moveTo(x: timerFill!.position.x - (timerFill!.size.width / 2), duration: 6))
        cam.addChild(sub)
        cam.addChild(fil)
    
        timerSubstrate = sub
        timerFill = fil
        
        sTime = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(displayTimer), userInfo: nil, repeats: true)
    }
    
    /*
     timeLabel = UILabel()
     timeLabel?.text = "   \(timer)   "
     timeLabel?.textColor = .white
     timeLabel?.font = UIFont.boldSystemFont(ofSize:36)
     timeLabel?.frame.size.width = 0
     timeLabel?.lineBreakMode = .byClipping
     timeLabel?.sizeToFit()
     timeLabel?.center = CGPoint(x: frame.width/4, y: 50)
     view.addSubview(timeLabel!)
     */
    func setUpTables() {
        guard let tableImage = UIImage(named: "jSubstrate") else {
            return
        }
        
        let texture = SKTexture(image: tableImage)
        let tr = SKSpriteNode(texture: texture)
        let tl = SKSpriteNode(texture: texture)
        
        tr.size = tableImage.size
        tl.size = tableImage.size

        tr.physicsBody = SKPhysicsBody(texture: texture, size: tr.size)
        tl.physicsBody = SKPhysicsBody(texture: texture, size: tl.size)
        tr.physicsBody!.affectedByGravity = false
        tl.physicsBody!.affectedByGravity = false
        tr.physicsBody!.isDynamic = false
        tl.physicsBody!.isDynamic = false

        tr.name = "table"
        tl.name = "table"
        
        let Lx = CGFloat.random(in: 100...((frame.width / 2) - 50))
        let Ly = CGFloat.random(in: 100...(frame.height - 100))
        
        let midx = ( frame.width / 2 )
        let Rx = CGFloat.random(in: midx...(frame.width - 100))
        let Ry = CGFloat.random(in: 100...(frame.height - 100))
            
        tr.position = CGPoint(x: Rx, y: Ry)
        tl.position = CGPoint(x: Lx, y: Ly)
        
        tr.zPosition = -1
        tl.zPosition = -1
 
        self.addChild(tr)
        self.addChild(tl)
        tableL = tl
        tableR = tr

    }


    
    @objc func displayTimer() {
        if view == self.view {
            // Load the SKScene from 'GameScene.sks'
            if timer > 0 {
                let y = Double(round(timer*1000)/1000)
                timeLabel?.text = "   \(y)   "
                timer -= 0.1
            }
            else {
                timeLabel?.text = "   0.0   "
                if sTime.isValid == true {
                    sTime.invalidate()
                }
                player!.physicsBody?.isDynamic = false
                drink!.removeFromParent()
                endGame()
            }
        }
    }
    
    func setUpCount() {
        if let view = self.view {
            // Load the SKScene from 'GameScene.sks'
            
            countLabel = UILabel()
            countLabel?.text = "    \(app.drinkCount)    "
            countLabel?.textColor = .green
            countLabel?.font = UIFont.boldSystemFont(ofSize:36)
           // countLabel?.frame.size.width = 0
            countLabel?.lineBreakMode = .byClipping
            countLabel?.sizeToFit()
            countLabel?.center = CGPoint(x: frame.width - timerSubstrate!.position.x - 50, y: frame.height - timerSubstrate!.position.y)
            
            view.addSubview(countLabel!)
        }
    }
    
    
    func placeDrink() {
        drink?.removeFromParent()
        guard let drinkImage = UIImage(named: "beer") else {
            return
        }
        let texture = SKTexture(image: drinkImage)
        let d = SKSpriteNode(texture: texture)

        var xLower = player!.position.x - 50
        var xUpper = player!.position.x + 50
        var yLower = player!.position.y - 50
        var yUpper = player!.position.y + 50
        
        if (xLower < 0) {
            xLower = 50
        }
        if (xUpper > (frame.width - 50)) {
            xUpper = frame.width - 50
        }
        if (yLower < 0) {
            yLower = 50
        }
        if (yUpper > (frame.height - 50)) {
            yUpper = frame.height - 50
        }
        
        let rect = CGRect(x: xLower, y: yLower, width: xUpper, height: yUpper)
        var pos = CGPoint(x: 0, y: 0)
        
        repeat {
            let posX = CGFloat.random(in: 100...(frame.width - 100))
            let posY = CGFloat.random(in: 100...(frame.height - 100))
            pos = CGPoint(x: posX, y: posY)
        }
        while (rect.contains(pos))
        
        d.position = pos
        d.size = CGSize(width: (43), height: (47))
        d.physicsBody = SKPhysicsBody(texture: texture, size: d.size)
        d.physicsBody!.affectedByGravity = false
        d.name = "drink"
        

        d.zPosition = -2
        //d.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        self.addChild(d)
        drink = d
        //prevent = 0
        //drinkHitbox = CGRect(x: posX, y: posY, width: 43, height: 47)

    }
    
    func endGame() {
        //let newScene = GGScene(fileNamed: "GGScene.swift")!
        
        moveJoystick.stop()
        player?.removeFromParent()
        timeLabel?.removeFromSuperview()
        countLabel?.removeFromSuperview()
        tableL?.removeFromParent()
        tableR?.removeFromParent()
        timerSubstrate?.removeFromParent()
        timerFill?.removeFromParent()
        cam.removeAllChildren()
        let ggScene = GGScene(size: self.size)

        let GGTrans = SKTransition.moveIn(with: .right, duration: 0.5)
        self.view?.presentScene(ggScene, transition: GGTrans)
       // self.view?.presentScene(gameOverScene, transition: reveal)
        
        /*
        gameOver = UILabel()
        gameOver?.text = " GAME OVER "
        gameOver?.font = UIFont.boldSystemFont(ofSize:100)
        //gameOver?.frame.size.width = 0
        gameOver?.lineBreakMode = .byClipping
        gameOver?.sizeToFit()
        gameOver?.center = CGPoint(x: frame.width/2, y: frame.height/2)
        
        view?.addSubview(gameOver!)
        */
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "drink" {
            isContact = 1
            drink!.removeFromParent()
            placeDrink()
            if timer > 0 {
                timer = 6 - Double(app.drinkCount)*(0.1)
                timerFill?.removeAllActions()
                timerFill?.run(SKAction.resize(toWidth: fillWidth / 2, duration: 0.0))
                timerFill?.run(SKAction.moveTo(x: timerSubstrate!.position.x, duration: 0.0))
                
                timerFill?.run(SKAction.resize(toWidth: 0, duration: timer))
                timerFill?.run(SKAction.moveTo(x: timerSubstrate!.position.x - (fillWidth / 4), duration: timer))
            }
        }
    }
    
    func getDrinkCount() -> Int {
        return (app.drinkCount)
    }
    
    override func update(_ currentTime: TimeInterval) {
      /* Called before each frame is rendered */

        if self.view != nil {
            //substrate!.position = CGPoint(x: (frame.width - (frame.width / 3)), y: frame.height - 40)
           // fill!.position = CGPoint(x: player!.position.x, y: player!.position.y)

        }
        if isContact == 1 {
            app.drinkCount += 1
            if self.view != nil {
                let num = String(app.drinkCount)
                countLabel?.text = "     " + num + "     "
            }
            isContact = 0
        }
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }
}
