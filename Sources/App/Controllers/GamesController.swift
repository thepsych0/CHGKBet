final class GamesController {
    func getGameInfo(id: String) -> GameInfo? {
        let game = Game(rawValue: id)
        return game?.gameInfo
    }
    
    func getGamesInfo(ids: [String]) -> [String: GameInfo] {
        var gamesInfo = [String: GameInfo]()
        ids.forEach { id in
            let game = Game(rawValue: id)
            gamesInfo[id] = game?.gameInfo
        }
        return gamesInfo
    }
}
