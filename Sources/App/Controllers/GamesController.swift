final class GamesController {
    func getGameInfo(id: String) -> GameInfo? {
        let game = Game(rawValue: id)
        return game?.gameInfo
    }
}
