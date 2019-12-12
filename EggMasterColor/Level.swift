import Foundation

let NumColumns = 6
let NumRows = 6

class Level {
    fileprivate var enemies = Array2D<Enemy>(columns: NumColumns, rows: NumRows)
    
    private var tiles = Array2D<Tile>(columns: NumColumns, rows: NumRows)
    private var comboMultiplier = 0
    
    var aliveEnemiesQuantity = 0
    var targetScore = 0
    var startingTime: Double = 0
    var frequencyToChangeColor: Double = 0
    var colorsQuantity = 0
    
    init(filename: String) {
        guard let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename: filename) else { return }
        guard let tilesArray = dictionary["tiles"] as? [[Int]] else { return }
        
        for (row, rowArray) in tilesArray.enumerated() {
            let tileRow = NumRows - row - 1
            
            for (column, value) in rowArray.enumerated() {
                if value == 1 {
                    tiles[column, tileRow] = Tile()
                }
            }
        }
        
        targetScore = dictionary["targetScore"] as! Int
        startingTime = dictionary["startingTime"] as! Double
        frequencyToChangeColor = dictionary["frequencyToChangeColor"] as! Double
        colorsQuantity = dictionary["colorsQuantity"] as! Int
    }
    
    func enemyAt(column: Int, row: Int) -> Enemy? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return enemies[column, row]
    }
    
    func tileAt(column: Int, row: Int) -> Tile? {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        return tiles[column, row]
    }
    
    func shuffle() ->Set<Enemy> {
        var set: Set<Enemy>
        
        set = createEnemies()
        
        return set
    }
    
    func createEnemies() -> Set<Enemy> {
        var set = Set<Enemy>()
        
        aliveEnemiesQuantity = 0
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if tiles[column, row] != nil {
                    aliveEnemiesQuantity += 1
                    
                    let enemy = BasicEnemy(
                        column: column, row: row, availableColorsQuantity: self.colorsQuantity
                    )
                    enemies[column, row] = enemy
                    set.insert(enemy)
                }
            }
        }

        return set
    }
    
    func remove(enemy: Enemy) {
        enemies[enemy.column, enemy.row] = nil
    }
    
    func searchEnemyWithThis(itemColor: ItemColor) -> (column: Int, row: Int)? {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if itemColor == enemies[column, row]?.itemColor {
                    return (column, row)
                }
            }
        }
        return nil
    }
    
    func randomEnemyColor() -> ItemColor {
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let enemy = enemies[column, row] {
                    return enemy.itemColor
                }
            }
        }
        
        return ItemColor.random()
    }
    
    func filteredEnemies(itemColor: ItemColor) -> (corrects: Set<Enemy>, incorrects: Set<Enemy>) {
        var corrects = Set<Enemy>()
        var incorrects = Set<Enemy>()
        
        for row in 0..<NumRows {
            for column in 0..<NumColumns {
                if let enemy = enemies[column, row] {
                    if (enemy.itemColor == itemColor) {
                        corrects.insert(enemy)
                    } else {
                        incorrects.insert(enemy)
                    }
                }
            }
        }
        
        return (corrects, incorrects)
    }
    
    func decreaseAliveEnemiesQuantity() {
        aliveEnemiesQuantity -= 1
    }
}
