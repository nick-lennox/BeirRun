import SpriteKit

class CollidableObject {
    var object:SKSpriteNode
    
    init(_ image: UIImage,_ size: CGSize,_ pos: CGPoint,_ zPos: CGFloat) {
        let objTexture = SKTexture(image: image)
        object = SKSpriteNode(texture: objTexture)
        object.size = size
        object.position = pos
        object.physicsBody = SKPhysicsBody(texture: objTexture, size: size)
    
        object.physicsBody!.affectedByGravity = false
        object.physicsBody!.isDynamic = false
        object.zPosition = zPos
        object.name = "collidable"
    }
    
    func changePBImage(_ image: UIImage) {
        let newTexture = SKTexture(image: image)
        object.physicsBody = SKPhysicsBody(texture: newTexture, size: object.size)
    }

}
