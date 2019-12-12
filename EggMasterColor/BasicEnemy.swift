class BasicEnemy: Enemy
{
    private let initialLives: Int = 1
    
    init(column: Int, row: Int, availableColorsQuantity: Int) {
        super.init(lives: initialLives, column: column, row: row, enemyType: EnemyType.basic, availableColorsQuantity: availableColorsQuantity)
    }
}
