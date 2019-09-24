//
//  GameScene.swift
//
//  Created by Dmitriy Mitrophanskiy on 28.09.14.
//  Copyright (c) 2014 Dmitriy Mitrophanskiy. All rights reserved.
//
import SpriteKit


class GameScene: SKScene {
    let setJoystickStickImageBtn = SKLabelNode()
    let setJoystickSubstrateImageBtn = SKLabelNode()
    var player: SKSpriteNode?

    let moveJoystick = 🕹(withDiameter: 100)
    let rotateJoystick = TLAnalogJoystick(withDiameter: 100)
 
    
    var joystickStickImageEnabled = true {
        didSet {
            let image = joystickStickImageEnabled ? UIImage(named: "jStick") : nil
            
            moveJoystick.handleImage = image
            rotateJoystick.handleImage = image
        }
    }
    
    var joystickSubstrateImageEnabled = true {
        didSet {
            let image = joystickSubstrateImageEnabled ? UIImage(named: "jSubstrate") : nil
            moveJoystick.baseImage = image
            rotateJoystick.baseImage = image
        }
    }
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        
        let background = SKSpriteNode(imageNamed: "Artboard 1")
        background.size = CGSize(width: (frame.width), height: (frame.height))
        background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addChild(background)
        background.zPosition = -10000
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        //backgroundColor = .white
        setupJoystick()

        //MARK: Handlers begin
        moveJoystick.on(.move) { [unowned self] joystick in
            guard let player = self.player else {
                return
            }
            
            let pVelocity = joystick.velocity;
            let speed = CGFloat(0.12)
            
            player.position = CGPoint(x: player.position.x + (pVelocity.x * speed), y: player.position.y + (pVelocity.y * speed))
        }

        

        view.isMultipleTouchEnabled = true
 
        setupPlayer(CGPoint(x: frame.midX, y: frame.midY))

    }
    
    func setupNodes() {
        //addChild(hero)
    }
    
    func setupJoystick() {
        joystickStickImageEnabled = true
        joystickSubstrateImageEnabled = true
        //only allows user to control joystick from left side of screen
        let moveJoystickHiddenArea = TLAnalogJoystickHiddenArea(rect: CGRect(x: 0, y: 0, width: frame.midX, height: frame.height))
        
        moveJoystickHiddenArea.joystick = moveJoystick
        moveJoystick.isMoveable = true
        moveJoystickHiddenArea.strokeColor = SKColor.clear
        addChild(moveJoystickHiddenArea)
    }
    
    
    func setupPlayer(_ position: CGPoint) {
        guard let playerImage = UIImage(named: "keenan2") else {
            return
        }
        let texture = SKTexture(image: playerImage)
        let p = SKSpriteNode(texture: texture)
        p.physicsBody = SKPhysicsBody(texture: texture, size: p.size)
        p.physicsBody!.affectedByGravity = false
        p.position = position
        p.zPosition = -999
        addChild(p)
        player = p
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        /* Called before each frame is rendered */
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }
}
