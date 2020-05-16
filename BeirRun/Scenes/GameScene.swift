//
//  GameScene.swift
//
import SpriteKit

var cam = SKCameraNode()

class GameScene: SKScene, SKPhysicsContactDelegate {
    let setJoystickStickImageBtn = SKLabelNode()
    let setJoystickSubstrateImageBtn = SKLabelNode()
    let app: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    //var drinkCount: Int = 0
    var player: Player?
    var drink: SKSpriteNode?
    var drinkShadow: SKSpriteNode?
    var drinkTracker: SKSpriteNode?
    
    var background:SKSpriteNode?
    //var pillarBaseL: SKSpriteNode?
    //var pillarBaseR: SKSpriteNode?
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

    var shadowFrames:[SKTexture] = []
    var trackerFrames:[SKTexture] = []
    var beerAction:[SKAction] = []

    let moveJoystick = 🕹(withDiameter: 100)
    let rotateJoystick = TLAnalogJoystick(withDiameter: 100)

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
        return player!.p.position
    }
    
    /*
     Nick Lennox - Jared O'Connor
     Handles the animation and distorted movement.
     */
    override func didMove(to view: SKView) {
        self.camera = cam
        self.addChild(cam)

        physicsWorld.contactDelegate = self
        
        prevBeerX = frame.width / 2
        prevBeerY = frame.height / 2
        
        setUpTables()
        placeTracker()

        setupJoystick()
        setUpTimer()
        setUpCount()
        placeDrink()
        setupPlayer()

        //MARK: Handlers begin
        moveJoystick.on(.move) { [unowned self] joystick in
            guard let player = self.player else {
                return
            }
            self.aVelocity = joystick.angular
            var speed = CGFloat(0.1)
            player.move(self.aVelocity)
            let pVelocity = joystick.velocity

            //Stops player after game is over
            if self.sTime.isValid == false {
                speed = 0.0
            }
            
            player.p.position = CGPoint(x: player.p.position.x + (pVelocity.x * speed), y: player.p.position.y + (pVelocity.y * speed))
        }
        
        moveJoystick.on(.end) { [unowned self] joystick in
            guard let player = self.player else {
                return
            }
            player.p.removeAllActions()

            self.aVelocity = joystick.angular

            let left = CGFloat( (1 / 4) * Double.pi )
            
            if (self.aVelocity < left && self.aVelocity > -left) {
                player.p.texture = SKTexture(image: self.standingBack!)
            }
            
            else if (self.aVelocity > left && self.aVelocity < 3 * left) {
                player.p.texture = SKTexture(image: self.sideStandingL!)
            }
                
            else if (self.aVelocity < -left && self.aVelocity > -3 * left) {
                player.p.texture = SKTexture(image: self.sideStandingR!)
            }
                
            else {
                player.p.texture = SKTexture(image: self.standingP!)
            }

        }

        view.isMultipleTouchEnabled = true
     }
    
    /*
     Nick Lennox
     Adds the joystick image to the screen
     */
    func setupJoystick() {
        joystickStickImageEnabled = true
        joystickSubstrateImageEnabled = true
        //only allows user to control joystick from left side of screen
        let moveJoystickHiddenArea = TLAnalogJoystickHiddenArea(rect: CGRect(x: 0, y: 500, width: -1000, height: -1000))
        
        moveJoystickHiddenArea.joystick = moveJoystick
        moveJoystick.isMoveable = true
        moveJoystickHiddenArea.strokeColor = SKColor.clear
        cam.addChild(moveJoystickHiddenArea)
    }
    
    /*
     Jared O'Connor
     Creates the player and the player hitbox
     */
    func setupPlayer() {
        let p = Player()
    
        self.addChild(p.p)
        player = p
        player!.p.physicsBody!.contactTestBitMask = drink!.physicsBody!.collisionBitMask
        let constraint = SKConstraint.distance(SKRange(constantValue: 0), to: player!.p)
        cam.constraints = [ constraint ]
    }
    
    /*
     Nick Lennox
     Places the timer and the timer substrate on the screen and starts the animation to reduce the time
     */
    func setUpTimer() {
        let subTexture = SKTexture(image: substrateImage!)
        let fillTexture = SKTexture(image: fillImage!)
            
        let sub = SKSpriteNode(texture: subTexture)
        let fil = SKSpriteNode(texture: fillTexture)
        
        fil.size = CGSize(width: fillImage!.size.width / 4, height: fillImage!.size.height / 4)
        sub.size = CGSize(width: substrateImage!.size.width / 4, height: substrateImage!.size.height / 4)
        
        fil.name = "fill"
        sub.name = "subs"
        
        fil.zPosition = 2
        sub.zPosition = 1
    
        sub.position = CGPoint(x: 175, y: 175)
        fil.position = CGPoint(x: 175, y: 175)
        fillWidth = fillImage!.size.width

        cam.addChild(sub)
        cam.addChild(fil)

        timerSubstrate = sub
        timerFill = fil
        
        timerFill?.run(SKAction.resize(toWidth: 0, duration: timer))
        timerFill?.run(SKAction.moveTo(x: timerSubstrate!.position.x - (fillWidth / 16), duration: timer))
        sTime = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(displayTimer), userInfo: nil, repeats: true)
    }
    
    /*
     Nick Lennox
     Adds a tracker when the drink is off the screen that points in the direction of the drink
     */
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
     Jared O'Connor
     Function to add collidable objects
    */
    func setUpTables() {
        
        guard let BGImage = UIImage(named: "noncollidable") else {
            return
        }
        
        guard let benchImage = UIImage(named: "bench") else {
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
        
        guard let leftBoundaryImage = UIImage(named: "leftBoundary") else {
            return
        }
        
        guard let rightBoundaryImage = UIImage(named: "rightBoundary") else {
            return
        }

        let BGtexture = SKTexture(image: BGImage)

        
        let bg = SKSpriteNode(texture: BGtexture)
        let benchT = CollidableObject(benchImage, CGSize(width: benchImage.size.width / 2.5, height: benchImage.size.height / 2.5), CGPoint(x: -250, y: 180), -3)
        let benchM = CollidableObject(benchImage, CGSize(width: benchImage.size.width / 2.5, height: benchImage.size.height / 2.5), CGPoint(x: -250, y: 110), -3)
        let benchB = CollidableObject(benchImage, CGSize(width: benchImage.size.width / 2.5, height: benchImage.size.height / 2.5), CGPoint(x: -250, y: 40), -3)
        
        let sqTable = CollidableObject(sqtableImage, CGSize(width: sqtableImage.size.width / 2, height: sqtableImage.size.height / 2), CGPoint(x: 350, y: 35), -3)
        let rdTableL = CollidableObject(rdtableImage, CGSize(width: rdtableImage.size.width / 2, height: rdtableImage.size.height / 2), CGPoint(x: 75, y: 35), -3)
        let rdTableR = CollidableObject(rdtableImage, CGSize(width: rdtableImage.size.width / 2, height: rdtableImage.size.height / 2), CGPoint(x: 625, y: 35), -3)
        let poolTableT = CollidableObject(pooltableImage, CGSize(width: pooltableImage.size.width / 2, height: pooltableImage.size.height / 2), CGPoint(x: 1025, y: 125), -3)
        let poolTableB = CollidableObject(pooltableImage, CGSize(width: pooltableImage.size.width / 2, height: pooltableImage.size.height / 2), CGPoint(x: 1025, y: -30), -3)
        
        let leftBoundary = CollidableObject(leftBoundaryImage, CGSize(width: leftBoundaryImage.size.width / 2, height: leftBoundaryImage.size.height / 2), CGPoint(x: 448, y: 158), -3)
        
        let rightBoundary = CollidableObject(rightBoundaryImage, CGSize(width: leftBoundaryImage.size.width / 2, height: leftBoundaryImage.size.height / 2), CGPoint(x: 448, y: 158), -3)
        //SIZE
        bg.size = CGSize(width: BGImage.size.width / 2, height: BGImage.size.height / 2)
        //bound.size = CGSize(width: BGImage.size.width / 2, height: BGImage.size.height / 2)

       // plrBaseL.size = CGSize(width: plrBaseImage.size.width / 2, height: plrBaseImage.size.height / 2)
       // plrBaseR.size = CGSize(width: plrBaseImage.size.width / 2, height: plrBaseImage.size.height / 2)

        
        //POSITION
        bg.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        bg.zPosition = -99

        addChild(bg)
        addChild(sqTable.object)
        addChild(rdTableL.object)
        addChild(rdTableR.object)
        //addChild(plrBaseL)
        //addChild(plrBaseR)
        addChild(poolTableT.object)
        addChild(poolTableB.object)
        addChild(benchT.object)
        addChild(benchM.object)
        addChild(benchB.object)
        addChild(leftBoundary.object)
        addChild(rightBoundary.object)

        background = bg
    }


    /*
     Nick Lennox
     */
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
                player!.p.physicsBody?.isDynamic = false
                drink!.removeFromParent()
                drinkShadow!.removeFromParent()
                endGame()
            }
        }
    }
    
    /*
     Nick Lennox
     Displays and increments the total drinks collected
     */
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
     Jared O'Connor
     Places drink every time the player makes contact with the previous drink
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
            xLower = player!.p.position.x - 50
            xUpper = player!.p.position.x + 50
            yLower = player!.p.position.y - 50
            yUpper = player!.p.position.y + 50
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
        while d.physicsBody == nil {
            d.physicsBody = SKPhysicsBody(texture: beer, size: d.size)
        }
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
    
    /*
     Jared O'Connor
     Remove all nodes involved in gameplay
     */
    func endGame() {
        //let newScene = GGScene(fileNamed: "GGScene.swift")!
        moveJoystick.stop()
        player?.p.removeFromParent()
        timeLabel?.removeFromSuperview()
        countLabel?.removeFromSuperview()
        background?.removeFromParent()
        timerSubstrate?.removeFromParent()
        timerFill?.removeFromParent()
        self.removeAllChildren()
        cam.removeAllChildren()
        let ggScene = GGScene(size: self.size)

        let GGTrans = SKTransition.moveIn(with: .right, duration: 0.5)
        self.view?.presentScene(ggScene, transition: GGTrans)
       // self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    /*
     Nick Lennox - Jared O'Connor
     When the player makes contact with a drink, that drink is removed, a new one is placed, and the timer is reset
     */
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "drink" {
            isContact = 1
            drink!.removeFromParent()
            drinkShadow!.removeFromParent()
            placeDrink()
            if timer > 0 {
                timer = 5 - Double(app.drinkCount)*(0.1)
                timerFill?.removeAllActions()
                timerFill?.run(SKAction.resize(toWidth: fillWidth / 4, duration: 0.0))
                timerFill?.run(SKAction.moveTo(x: timerSubstrate!.position.x, duration: 0.0))
                
                timerFill?.run(SKAction.resize(toWidth: 0, duration: timer))
                timerFill?.run(SKAction.moveTo(x: timerSubstrate!.position.x - (fillWidth / 8), duration: timer))
            }
        }
    }
    
    /*
     Nick Lennox
     */
    func getDrinkCount() -> Int {
        return (app.drinkCount)
    }
    
    /*
     Nick Lennox
     Updates the tracker angle and the drinkcount
     */
    override func update(_ currentTime: TimeInterval) {
        if (abs(drink!.position.x - player!.p.position.x) < frame.width / 2 && abs(drink!.position.y - player!.p.position.y) < frame.height / 2) {
            tracker!.isHidden = true
        }
        else {
            tracker!.isHidden = false
        }
  
        tracker!.position = CGPoint(x: (pos.x - player!.p.position.x) / 4, y: (pos.y - player!.p.position.y) / 4)
        let angle = atan((pos.y - player!.p.position.y) / (pos.x - player!.p.position.x))
        if (player!.p.position.x >= drink!.position.x) {
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
    }
}
