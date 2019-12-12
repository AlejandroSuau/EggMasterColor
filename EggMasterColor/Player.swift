import SpriteKit

class Player: GameEntity, CustomStringConvertible
{
    var colorChanger: ColorChanger!
    var positionX: Float
    var positionY: Float
    
    var maxErrorColorsAllowed = 0
    var errorColors = 0
    
    var description: String {
        return "Color: \(itemColor)"
    }
    
    var spriteName: String {
        return "Player-\(itemColor.spriteName)"
    }
    
    var frequencyToChangeColor: Double {
        return colorChanger.timeFrequencyToChange
    }
    
    init(frequencyChangeColor: Double, colorsQuantity: Int) {
        self.positionX = 0
        self.positionY = 0
        
        let lives = 1
        let itemColor = ItemColor.random(colorsQuantity: colorsQuantity)
        
        super.init(lives: lives, itemColor: itemColor)
        self.colorChanger = ColorChanger(
            gameEntity: self, timeFrequencyToChange: frequencyChangeColor, colorsQuantity: colorsQuantity
        )
    }
    
    func hasChangedColor() -> Bool {
        return previousItemColor != itemColor
    }
    
    // Random between [2,3]
    func calculateMaxErrorColorsAllowed() {
        errorColors = 0
        maxErrorColorsAllowed = Int(arc4random_uniform(UInt32(2))) + 2
    }
    
    func hasMaxErrorColorsAllowed() -> Bool {
        return errorColors == maxErrorColorsAllowed
    }
    
    func update(_ currentTime: Double) {
        colorChanger.update(currentTime)
    }
}
