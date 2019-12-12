import SpriteKit

enum ItemColor: Int, CustomStringConvertible {
    static let availableColorsQuantity: Int = 5
    static let minimunColorsQuantity: Int = 2
    
    case unknown = 0, blue, red, yellow, green, purple
    
    var spriteName: String {
        let spriteNames = [
            "Blue",
            "Red",
            "Yellow",
            "Green",
            "Purple"
        ]
        
        return spriteNames[rawValue - 1]
    }
    
    var description: String {
        return spriteName
    }
    
    static func random() -> ItemColor {
        return self.random(colorsQuantity: self.availableColorsQuantity)
    }
    
    static func random(colorsQuantity: Int) -> ItemColor {
        if colorsQuantity < self.minimunColorsQuantity || colorsQuantity > self.availableColorsQuantity {
            return self.random()
        }
        
        return ItemColor(rawValue: Int(arc4random_uniform(UInt32(colorsQuantity))) + 1)!
    }
}
