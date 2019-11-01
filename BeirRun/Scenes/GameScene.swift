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
    var drinkShadow: SKSpriteNode?
    var drinkTracker: SKSpriteNode?
    
    var squareTable: SKSpriteNode?
    var poolTableTop: SKSpriteNode?
    var poolTableBot: SKSpriteNode?
    var roundTableL: SKSpriteNode?
    var roundTableR: SKSpriteNode?
    var pillarBaseL: SKSpriteNode?
    var pillarBaseR: SKSpriteNode?
    var background: SKSpriteNode?
    
    var tracker: SKSpriteNode?

    var timerFill: SKSpriteNode?
    var timerSubstrate: SKSpriteNode?
    var labelBox: CGRect?
    var countLabel: UILabel?
    var timeLabel: UILabel?
    var timer = 100.0
    var sTime = Timer()
    var isFirst = true
    
    var pos = CGPoint(x: 0, y: 0)
    
    var playerFrames:[SKTexture]?
    
    let substrateImage = UIImage(named: "timerSubstrate")
    let fillImage = UIImage(named: "timerFill")
    
    let standingBack = UIImage(named: "backstanding")
    let standingP = UIImage(named: "standingFront")
    
    let sideStandingR = UIImage(named: "sideStillR")
    let sideStandingL = UIImage(named: "sideStillL")
    
    let beerHitbox = UIImage(named: "beer1")
    
    var frontFrames:[SKTexture] = []
    var sideLFrames:[SKTexture] = []
    var sideRFrames:[SKTexture] = []
    var backFrames:[SKTexture] = []
    var prevFrames:[SKTexture] = []
    var shadowFrames:[SKTexture] = []
    var trackerFrames:[SKTexture] = []
    var beerAction:[SKAction] = []

    let moveJoystick = 🕹(withDiameter: 100)
    let rotateJoystick = TLAnalogJoystick(withDiameter: 100)
    
    //let background = SKSpriteNode(imageNamed: "newbg" )

    var isContact = 0
    var fillWidth = CGFloat(0)
    //var highScore = UserDefaults.init(suiteName: "HIGH SCORE")
    var prevBeerX = CGFloat(0)
    var prevBeerY = CGFloat(0)
    
    var aVelocity = CGFloat(0)
   
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
 
        self.camera = cam
        self.addChild(cam)
      // background.size = CGSize(width: (background.size.width) / 2, height: (background.size.height / 2))
       // background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
       // self.addChild(background)
       // background.zPosition = -10000
        
        //physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        prevBeerX = frame.width / 2
        prevBeerY = frame.height / 2
        //physicsBody?.usesPreciseCollisionDetection = true
        //Set UP
        setUpTables()
        placeTracker()

        setupJoystick()
        setUpTimer()
        setUpCount()
        placeDrink()

        //MARK: Handlers begin
        moveJoystick.on(.move) { [unowned self] joystick in
            guard let player = self.player else {
                return
            }
            player.physicsBody?.isDynamic = true
            self.aVelocity = joystick.angular
            var speed = CGFloat(0.1)
            
            let left = CGFloat( (1 / 4) * Double.pi )
            var drunkX = CGFloat(0.0)
            var drunkY = CGFloat(0.0)
            
            if (self.aVelocity < left && self.aVelocity > -left) {
                self.playerFrames = self.backFrames
                let lowerBound = CGFloat((-1 / 20) * pow(Double(self.app.drinkCount), 2.0))
                let upperBound = CGFloat((1 / 20) * pow(Double(self.app.drinkCount), 2.0))
                drunkX = CGFloat.random(in: lowerBound...upperBound)
                player.physicsBody?.applyForce(CGVector(dx: drunkX, dy: 0))
            }
                
            else if (self.aVelocity > left && self.aVelocity < 3 * left) {
                self.playerFrames = self.sideLFrames
                let lowerBound = CGFloat((-1 / 50) * pow(Double(self.app.drinkCount), 2.0))
                let upperBound = CGFloat((1 / 50) * pow(Double(self.app.drinkCount), 2.0))
                drunkY = CGFloat.random(in: lowerBound...upperBound)
                player.physicsBody?.applyForce(CGVector(dx: 0, dy: drunkY))
            }
                
            else if (self.aVelocity < -left && self.aVelocity > -3 * left) {
                self.playerFrames = self.sideRFrames
                let lowerBound = CGFloat((-1 / 50) * pow(Double(self.app.drinkCount), 2.0))
                let upperBound = CGFloat((1 / 50) * pow(Double(self.app.drinkCount), 2.0))
                drunkY = CGFloat.random(in: lowerBound...upperBound)
                player.physicsBody?.applyForce(CGVector(dx: 0, dy: drunkY))
            }
                
            else {
                self.playerFrames = self.frontFrames
                let lowerBound = CGFloat((-1 / 20) * pow(Double(self.app.drinkCount), 2.0))
                let upperBound = CGFloat((1 / 20) * pow(Double(self.app.drinkCount), 2.0))
                drunkX = CGFloat.random(in: lowerBound...upperBound)
                player.physicsBody?.applyForce(CGVector(dx: drunkX, dy: 0))
            }
            
            
            if (self.playerFrames != self.prevFrames) {
                if (self.playerFrames == self.sideRFrames || self.playerFrames == self.sideLFrames) {
                    player.run(SKAction.repeatForever(SKAction.animate(with: self.playerFrames!, timePerFrame: 0.2)))
                }
                else {
                    player.run(SKAction.repeatForever(SKAction.animate(with: self.playerFrames!, timePerFrame: 0.3)))
                }
                self.prevFrames = self.playerFrames!
            }
            
            /*
            if (player.texture == self.playerFrames![0]) {
                player.run(SKAction.setTexture(self.playerFrames![1]), completion: )
            }
            else {
                player.run(SKAction.setTexture(self.playerFrames![0]))
            }
            */
            let pVelocity = joystick.velocity;

            //Stops player after game is over
            if self.sTime.isValid == false {
                speed = 0.0
                //aVelocity = 0.0
            }
            
            player.position = CGPoint(x: player.position.x + (pVelocity.x * speed), y: player.position.y + (pVelocity.y * speed))
            //player.run(SKAction.rotate(toAngle: (aVelocity + .pi / 2 ), duration: 0.01, shortestUnitArc: true))
        }
        
        moveJoystick.on(.end) { [unowned self] joystick in
            guard let player = self.player else {
                return
            }
            player.removeAllActions()
            player.physicsBody?.isDynamic = false
            self.aVelocity = joystick.angular

            let left = CGFloat( (1 / 4) * Double.pi )
            
            if (self.aVelocity < left && self.aVelocity > -left) {
                player.texture = SKTexture(image: self.standingBack!)
            }
            
            else if (self.aVelocity > left && self.aVelocity < 3 * left) {
                player.texture = SKTexture(image: self.sideStandingL!)
            }
                
            else if (self.aVelocity < -left && self.aVelocity > -3 * left) {
                player.texture = SKTexture(image: self.sideStandingR!)
            }
                
            else {
                player.texture = SKTexture(image: self.standingP!)
            }

        }

        view.isMultipleTouchEnabled = true
 
        setupPlayer(CGPoint(x: frame.midX, y: frame.midY))
    }
    
    func setupJoystick() {
        joystickStickImageEnabled = true
        joystickSubstrateImageEnabled = true
        //only allows user to control joystick from left side of screen
        let moveJoystickHiddenArea = TLAnalogJoystickHiddenArea(rect: CGRect(x: 0, y: 500, width: -1000, height: -1000))
        
        moveJoystickHiddenArea.joystick = moveJoystick
        moveJoystick.isMoveable = true
        moveJoystickHiddenArea.strokeColor = SKColor.clear
        cam.addChild(moveJoystickHiddenArea)
        //cam.addChild(moveJoystick)
    }
    
    func setupPlayer(_ position: CGPoint) {
        //let pImage = UIImage(named: "frontwalkright")
        let hitBox = UIImage(named: "hitBox1")
        let texture = SKTexture(image: standingP!)
        let hitboxTexture = SKTexture(image: hitBox!)
        let p = SKSpriteNode(texture: texture)
        let hitboxP = SKSpriteNode(texture: hitboxTexture)
        
        p.size = CGSize(width: texture.size().width / 2.5, height: texture.size().height / 2.5)
        hitboxP.size = CGSize(width: hitboxTexture.size().width / 2.5, height: hitboxTexture.size().height / 2.5)

        p.position = CGPoint(x: frame.width / 2, y: frame.height / 2)

        p.physicsBody = SKPhysicsBody(texture: hitboxTexture, size: hitboxP.size)

        p.physicsBody!.affectedByGravity = false
        p.physicsBody?.contactTestBitMask = drink!.physicsBody!.collisionBitMask

        p.physicsBody?.allowsRotation = false
        p.name = "player"
        
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



        cam.addChild(sub)
        cam.addChild(fil)

        timerSubstrate = sub
        timerFill = fil
        
        timerFill?.run(SKAction.resize(toWidth: 0, duration: timer))
        timerFill?.run(SKAction.moveTo(x: timerSubstrate!.position.x - (fillWidth / 4), duration: timer))
        sTime = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(displayTimer), userInfo: nil, repeats: true)
    }
    
    func placeTracker() {
        let trackerAtlas = SKTextureAtlas(named: "tracker")
        
        for index in 1 ... 2 {
            let textureName = "arrow_\(index)"
            let texture = trackerAtlas.textureNamed(textureName)
            trackerFrames.append(texture)
        }
        let texture = trackerFrames[0]
        tracker = SKSpriteNode(texture: texture)
        
        tracker!.size = CGSize(width: texture.size().width * 1.3, height: texture.size().height * 1.3)
        
        tracker!.position = CGPoint(x: 0, y: 0)
        
        
        
        tracker!.name = "tracker"
        
        tracker!.zPosition = 4
        tracker!.run(SKAction.repeatForever(SKAction.animate(with: trackerFrames, timePerFrame: 0.2)))

        cam.addChild(tracker!)
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
        guard let BGImage = UIImage(named: "newbg") else {
            return
        }
        
        guard let sqtableImage = UIImage(named: "squareTable") else {
            return
        }
        
        guard let rdtableImage = UIImage(named: "roundTable") else {
            return
        }
        
        guard let pooltableImage = UIImage(named: "poolTable") else {
            return
        }
        
        guard let plrBaseImage = UIImage(named: "pillarFlowers") else {
            return
        }
        
        let BGtexture = SKTexture(image: BGImage)
        let sqtableTexture = SKTexture(image: sqtableImage)
        let rdtableTexture = SKTexture(image: rdtableImage)
        let plrBaseTexture = SKTexture(image: plrBaseImage)
        let pooltableTexture = SKTexture(image: pooltableImage)

        
        let bg = SKSpriteNode(texture: BGtexture)
        let sqtable = SKSpriteNode(texture: sqtableTexture)
        let rdtableL = SKSpriteNode(texture: rdtableTexture)
        let rdtableR = SKSpriteNode(texture: rdtableTexture)
        let plrBaseL = SKSpriteNode(texture: plrBaseTexture)
        let plrBaseR = SKSpriteNode(texture: plrBaseTexture)
        let poolTableT = SKSpriteNode(texture: pooltableTexture)
        let poolTableB = SKSpriteNode(texture: pooltableTexture)

        //SIZE
        bg.size = CGSize(width: BGImage.size.width / 2, height: BGImage.size.height / 2)
        sqtable.size = CGSize(width: sqtableImage.size.width / 2, height: sqtableImage.size.height / 2)
        rdtableL.size = CGSize(width: rdtableImage.size.width / 2, height: rdtableImage.size.height / 2)
        rdtableR.size = CGSize(width: rdtableImage.size.width / 2, height: rdtableImage.size.height / 2)
        plrBaseL.size = CGSize(width: plrBaseImage.size.width / 2, height: plrBaseImage.size.height / 2)
        plrBaseR.size = CGSize(width: plrBaseImage.size.width / 2, height: plrBaseImage.size.height / 2)
        poolTableT.size = CGSize(width: pooltableImage.size.width / 2, height: pooltableImage.size.height / 2)
        poolTableB.size = CGSize(width: pooltableImage.size.width / 2, height: pooltableImage.size.height / 2)

        //POSITION
        bg.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        sqtable.position = CGPoint(x: bg.position.x - 50, y: bg.position.y - 120)
        rdtableL.position = CGPoint(x: bg.position.x - 340, y: bg.position.y - 120)
        rdtableR.position = CGPoint(x: bg.position.x + 275, y: bg.position.y - 120)
        plrBaseL.position = CGPoint(x: bg.position.x - 228, y: bg.position.y + 40)
        plrBaseR.position = CGPoint(x: bg.position.x + 130, y: bg.position.y + 42)
        poolTableT.position = CGPoint(x: bg.position.x + 614, y: bg.position.y + 9)
        poolTableB.position = CGPoint(x: bg.position.x + 614, y: bg.position.y - 155)

        //PHYSICS BODY
        sqtable.physicsBody = SKPhysicsBody(texture: sqtableTexture, size: sqtable.size)
        rdtableL.physicsBody = SKPhysicsBody(texture: rdtableTexture, size: rdtableL.size)
        rdtableR.physicsBody = SKPhysicsBody(texture: rdtableTexture, size: rdtableR.size)
        plrBaseL.physicsBody = SKPhysicsBody(texture: plrBaseTexture, size: plrBaseL.size)
        plrBaseR.physicsBody = SKPhysicsBody(texture: plrBaseTexture, size: plrBaseR.size)
        poolTableT.physicsBody = SKPhysicsBody(texture: pooltableTexture, size: poolTableT.size)
        poolTableB.physicsBody = SKPhysicsBody(texture: pooltableTexture, size: poolTableB.size)
        
        //tr.physicsBody?.collisionBitMask = drink!.physicsBody!.collisionBitMask
        //tl.physicsBody?.collisionBitMask = drink!.physicsBody!.collisionBitMask

        sqtable.physicsBody!.affectedByGravity = false
        rdtableL.physicsBody!.affectedByGravity = false
        rdtableR.physicsBody!.affectedByGravity = false
        plrBaseL.physicsBody!.affectedByGravity = false
        plrBaseR.physicsBody!.affectedByGravity = false
        poolTableT.physicsBody!.affectedByGravity = false
        poolTableB.physicsBody!.affectedByGravity = false

        sqtable.physicsBody!.isDynamic = false
        rdtableL.physicsBody!.isDynamic = false
        rdtableR.physicsBody!.isDynamic = false
        plrBaseL.physicsBody!.isDynamic = false
        plrBaseR.physicsBody!.isDynamic = false
        poolTableT.physicsBody!.isDynamic = false
        poolTableB.physicsBody!.isDynamic = false

        bg.zPosition = -99999
        sqtable.zPosition = -3
        rdtableL.zPosition = -3
        rdtableR.zPosition = -3
        plrBaseL.zPosition = -3
        plrBaseR.zPosition = -3
        poolTableT.zPosition = -3
        poolTableB.zPosition = -3

        addChild(bg)
        addChild(sqtable)
        addChild(rdtableL)
        addChild(rdtableR)
        addChild(plrBaseL)
        addChild(plrBaseR)
        addChild(poolTableT)
        addChild(poolTableB)

        background = bg
        squareTable = sqtable
        roundTableL = rdtableL
        roundTableR = rdtableR
        pillarBaseL = plrBaseL
        pillarBaseR = plrBaseR
        poolTableTop = poolTableT
        poolTableBot = poolTableB

        //player!.physicsBody?.contactTestBitMask = tableL!.physicsBody!.collisionBitMask
       // player!.physicsBody?.contactTestBitMask = tableR!.physicsBody!.collisionBitMask
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
                drinkShadow!.removeFromParent()
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
            let customFont = UIFont(name: "GrungeTank", size: 36)

            countLabel?.font = customFont
           // countLabel?.frame.size.width = 0
            countLabel?.lineBreakMode = .byClipping
            countLabel?.sizeToFit()
            countLabel?.center = CGPoint(x: frame.width / 2 - frame.width / 8, y: frame.height * 0.078)
            
            view.addSubview(countLabel!)
        }
    }
    /*
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
    */
    
    func placeDrink() {
        if (!isFirst) {
            drink?.removeFromParent()
        }
        
        let beer = SKTexture(image: beerHitbox!)
        let shadowAtlas = SKTextureAtlas(named: "shadow")
        
        
        for index in 1 ... 3 {
            let textureName = "shadow_\(index)"
            let texture = shadowAtlas.textureNamed(textureName)
            shadowFrames.append(texture)
        }
 
        
        let d = SKSpriteNode(texture: beer)
        let shadow = SKSpriteNode()
        //d.size = CGSize(width: beerFrames[0].size().width, height: beerFrames[0].size().height)
        beerAction.append(SKAction.moveBy(x: 0.0, y: 5.0, duration: 0.15))
        beerAction.append(SKAction.moveBy(x: 0.0, y: -5.0, duration: 0.15))
            
        d.run(SKAction.repeatForever(SKAction.sequence(beerAction)))
        
        var xLower = frame.width / 2 - 50
        var xUpper = frame.width / 2 + 50
        var yLower = frame.height / 2 - 50
        var yUpper = frame.height / 2 + 50
        
        if (!isFirst) {
            xLower = player!.position.x - 50
            xUpper = player!.position.x + 50
            yLower = player!.position.y - 50
            yUpper = player!.position.y + 50
        }
        
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
        
        repeat {
            let posX = CGFloat.random(in: 100...(frame.width - 100))
            let posY = CGFloat.random(in: 100...(frame.height - 100))
            pos = CGPoint(x: posX, y: posY)
        }
        while (rect.contains(pos))
        
        d.size = CGSize(width: d.size.width / 2, height: d.size.width / 2)
        d.position = pos
        
        shadow.position = CGPoint(x: d.position.x, y: d.position.y - 5.0)
        shadow.size = d.size
        shadow.run(SKAction.repeatForever(SKAction.animate(with: shadowFrames, timePerFrame: 0.1)))
        d.physicsBody = SKPhysicsBody(texture: beer, size: d.size)
        d.physicsBody!.affectedByGravity = false
        d.name = "drink"
        
        d.zPosition = -2
        shadow.zPosition = -2
        //d.physicsBody = SKPhysicsBody(texture: texture, size: texture.size())
        self.addChild(d)
        self.addChild(shadow)
        
        drinkShadow = shadow
        drink = d
        isFirst = false


    }
    
    func endGame() {
        //let newScene = GGScene(fileNamed: "GGScene.swift")!

        moveJoystick.stop()
        player?.removeFromParent()
        timeLabel?.removeFromSuperview()
        countLabel?.removeFromSuperview()
        background?.removeFromParent()
        squareTable?.removeFromParent()
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
            drinkShadow!.removeFromParent()
            placeDrink()
            if timer > 0 {
                timer = 20 - Double(app.drinkCount)*(0.1)
                timerFill?.removeAllActions()
                timerFill?.run(SKAction.resize(toWidth: fillWidth / 2, duration: 0.0))
                timerFill?.run(SKAction.moveTo(x: timerSubstrate!.position.x, duration: 0.0))
                
                timerFill?.run(SKAction.resize(toWidth: 0, duration: timer))
                timerFill?.run(SKAction.moveTo(x: timerSubstrate!.position.x - (fillWidth / 4), duration: timer))
            }
        }
            /*
        else if contact.bodyB.node?.name == "table" {
            app.drinkCount = 99
        }
 */
    }
    
    func getDrinkCount() -> Int {
        return (app.drinkCount)
    }
    
    override func update(_ currentTime: TimeInterval) {
        //////////////////////////////////////////////
        ///           TRACKER HANDLING
        //////////////////////////////////////////////

        if (abs(drink!.position.x - player!.position.x) < frame.width / 2 && abs(drink!.position.y - player!.position.y) < frame.height / 2) {
            tracker!.isHidden = true
        }
        else {
            tracker!.isHidden = false
        }
  
        tracker!.position = CGPoint(x: (pos.x - player!.position.x) / 4, y: (pos.y - player!.position.y) / 4)
        let angle = atan((pos.y - player!.position.y) / (pos.x - player!.position.x))
        if (player!.position.x >= drink!.position.x) {
            tracker!.zRotation = angle + CGFloat(Double.pi / 2)
        }
        else {
            tracker!.zRotation = angle - CGFloat(Double.pi / 2)
        }
        
        
        
        if isContact == 1 {
            app.drinkCount += 1
            if self.view != nil {
                let num = String(app.drinkCount)
                countLabel?.text = "     " + num + "     "
            }
            isContact = 0
        }
        if (app.drinkCount > 3) {
            /*
            var variance = CGFloat(100 / app.drinkCount)
            let squared = CGFloat(app.drinkCount*app.drinkCount)
            variance = squared / variance
            if (variance > 50) {
                variance = 50
            }
            let random = CGFloat.random(in: 0...variance)
            let constraint = SKConstraint.distance(SKRange(constantValue: random), to: player!)
            cam.constraints = [ constraint ]
 */
        }
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }
}
