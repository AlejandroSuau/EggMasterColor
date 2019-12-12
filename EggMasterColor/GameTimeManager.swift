class GameTimeManager
{
    let initTime: Double

    var isPaused: Bool
    var elapsedTime: Double // Elapsed time since the beginning of the game
    var firstTimeRegistered: Double! // Auxiliar time to calculate elapsed time
    var timeSinceBeginning: Double {
        return initTime - elapsedTime
    }
    
    init(initTime: Double) {
        self.initTime = initTime
        self.elapsedTime = 0
        self.isPaused = false
    }
    
    func update(_ currentTime: Double) {
        if firstTimeRegistered == nil {
            firstTimeRegistered = currentTime
        }
        
        elapsedTime = currentTime - firstTimeRegistered!
    }
    
    func isTimeOver() -> Bool {
        return timeSinceBeginning <= 0
    }
}
