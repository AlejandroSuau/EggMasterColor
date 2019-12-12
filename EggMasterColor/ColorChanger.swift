class ColorChanger
{
    var gameEntity: GameEntity
    var timeFrequencyToChange: Double // Time to change color
    var lastTimeChanged: Double! // Last time changed color
    var isChangingColor: Bool
    var colorsQuantity: Int
    
    init(gameEntity: GameEntity, timeFrequencyToChange: Double, colorsQuantity: Int) {
        self.gameEntity = gameEntity
        self.timeFrequencyToChange = timeFrequencyToChange
        self.colorsQuantity = colorsQuantity
        self.isChangingColor = true
    }
    
    func update(_ currentTime: Double) {
        if lastTimeChanged == nil {
            lastTimeChanged = currentTime
        }
        
        if currentTime - lastTimeChanged > timeFrequencyToChange {
            changeColor()
            lastTimeChanged = currentTime
        }
    }
    
    func changeColor() {
        var newItemColor: ItemColor
        
        repeat {
            newItemColor = ItemColor.random(colorsQuantity: colorsQuantity)
        } while newItemColor == gameEntity.itemColor
        
        gameEntity.itemColor = newItemColor
    }
}
