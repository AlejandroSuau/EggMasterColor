import SpriteKit

enum EnemyType: Int, CustomStringConvertible {
    case unknown = 0, basic, armored
    static let typesQuantity: Int = 5
    
    var spriteName: String {
        let spriteNames = [
            "Basic"
        ]
        
        return spriteNames[rawValue - 1]
    }
    
    var score: Int {
        let scores = [
            10
        ]
        
        return scores[rawValue - 1]
    }
    
    var description: String {
        return spriteName
    }
    
    static func random() -> EnemyType {
        return EnemyType(rawValue: Int(arc4random_uniform(UInt32(EnemyType.typesQuantity))) + 1)!
    }
}

class Enemy: GameEntity, CustomStringConvertible, Hashable
{
    let enemyType: EnemyType

    var column: Int
    var row: Int
    
    var spriteName: String {
        return "\(enemyType.spriteName)-\(itemColor.spriteName)"
    }
    
    var description: String {
        return "Type: \(enemyType), Color: \(itemColor), square: (\(column), \(row)), lives: \(lives)"
    }
    
    var hashValue: Int {
        return row*10 + column
    }
    
    init(lives: Int, column: Int, row: Int, enemyType: EnemyType, availableColorsQuantity: Int) {
        self.column = column
        self.row = row
        self.enemyType = enemyType
        
        let itemColor = ItemColor.random(colorsQuantity: availableColorsQuantity)
        super.init(lives: lives, itemColor: itemColor)
    }
}

func ==(lhs: Enemy, rhs: Enemy) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
}
