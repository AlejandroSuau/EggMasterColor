import SpriteKit

class GameEntity
{
    var lives: Int
    var itemColor: ItemColor!
    var previousItemColor: ItemColor
    var sprite:SKSpriteNode?
    
    init(lives: Int, itemColor: ItemColor) {
        self.lives = lives
        self.itemColor = itemColor
        self.previousItemColor = itemColor
    }
    
    func isAlive() -> Bool {
        return lives > 0
    }
    
    func receiveDamage() {
        self.lives -= 1
    }
}
