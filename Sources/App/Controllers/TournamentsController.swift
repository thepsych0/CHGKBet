import Vapor
import FluentPostgreSQL

final class TournamentsController {
    func index(_ req: Request) throws -> [Tournament] {
        return ServerModels.tournaments
    }
}

final class ServerModels {
    static let tournaments = [
        Tournament(id: 1, title: "MGIMO-International", date: 1573285500, games: ["chgk","brainNoF","ek","si","other"])
    ]

    static let events = [
        Event(
            id: 2,
            title: "Регион команды-победителя",
            options: [
                Option(title: "Москва и МО", coef: 1.96),
                Option(title: "Санкт-Петербург", coef: 3.45),
                Option(title: "Минск", coef: 6.25),
                Option(title: "Другой", coef: 25)
            ],
            gameID: "chgk",
            tournamentID: 1
        ),
        Event(
            id: 16,
            title: "Тотал победителя в финале",
            options: [
                Option(title: "100 и меньше", coef: 3.45),
                Option(title: "От 110 до 200", coef: 2.33),
                Option(title: "От 210 до 300", coef: 5.56),
                Option(title: "От 310 и больше", coef: 16.67)
            ],
            gameID: "ek",
            tournamentID: 1
        ),
        Event(
            id: 19,
            title: "Победитель Эрудит-квартета",
            options: [
                Option(title: "Чмоки", coef: 4),
                Option(title: "Флуд", coef: 5.26),
                Option(title: "Во вторник сможем", coef: 5.56),
                Option(title: "Деффект бабочки", coef: 5.88),
                Option(title: "Другой", coef: 5)
            ],
            gameID: "ek",
            tournamentID: 1
        ),
        Event(
            id: 4,
            title: "Команда-победитель выиграет минимум четыре тура из шести",
            options: [
                Option(title: "Да", coef: 4.76),
                Option(title: "Нет", coef: 1.27)
            ],
            gameID: "chgk",
            tournamentID: 1
        ),
        Event(
            id: 3,
            title: "Будет перестрелка хотя бы за одно из призовых мест",
            options: [
                Option(title: "Да", coef: 2.63),
                Option(title: "Нет", coef: 1.61)
            ],
            gameID: "chgk",
            tournamentID: 1
        ),
        Event(
            id: 5,
            title: "В финал выйдет хотя бы одна девушка",
            options: [
                Option(title: "Да", coef: 5.26),
                Option(title: "Нет", coef: 1.23)
            ],
            gameID: "si",
            tournamentID: 1
        ),
        Event(
            id: 23,
            title: "Хотя бы одна команда возьмёт медали во всех командных дисциплинах",
            options: [
                Option(title: "Да", coef: 3.7),
                Option(title: "Нет", coef: 1.37)
            ],
            gameID: "other",
            tournamentID: 1
        ),
        Event(
            id: 12,
            title: "Максимальное количество вопросов, взятых одним игроком в финале",
            options: [
                Option(title: "1", coef: 3.45),
                Option(title: "2", coef: 2.33),
                Option(title: "3", coef: 5.56),
                Option(title: "4", coef: 16.67),
                Option(title: "5", coef: 25)
            ],
            gameID: "brainNoF",
            tournamentID: 1
        ),
        Event(
            id: 20,
            title: "Все игры начнутся вовремя",
            options: [
                Option(title: "Да", coef: 100),
                Option(title: "Нет", coef: 1.01)
            ],
            gameID: "other",
            tournamentID: 1
        ),
        Event(
            id: 21,
            title: "Хотя бы один игрок или хотя бы одна команда будут дисквалифицированы с турнира",
            options: [
                Option(title: "Да", coef: 60),
                Option(title: "Нет", coef: 1.02)
            ],
            gameID: "other",
            tournamentID: 1
        ),
        Event(
            id: 13,
            title: "Хотя бы в одном из полуфиналов список финалистов поменяется на последнем вопросе",
            options: [
                Option(title: "Да", coef: 4.76),
                Option(title: "Нет", coef: 1.27)
            ],
            gameID: "ek",
            tournamentID: 1
        ),
        Event(
            id: 8,
            title: "Хотя бы один из боёв закончится со счётом 5:0",
            options: [
                Option(title: "Да", coef: 1.69),
                Option(title: "Нет", coef: 2.43)
            ],
            gameID: "brainNoF",
            tournamentID: 1
        ),
        Event(
            id: 1,
            title: "Победитель ЧГК",
            options: [
                Option(title: "Флуд", coef: 5.56),
                Option(title: "Искусство ухода", coef: 6.67),
                Option(title: "Чмоки", coef: 6.67),
                Option(title: "Игугундер", coef: 7.69),
                Option(title: "Ханаанский бальзам", coef: 7.69),
                Option(title: "Во вторник сможем", coef: 10),
                Option(title: "Пикник", coef: 10),
                Option(title: "Другой", coef: 16.67)
            ],
            gameID: "chgk",
            tournamentID: 1
        ),
        Event(
            id: 14,
            title: "Обладатель хотя бы одной из медалей поменяется на последнем вопросе",
            options: [
                Option(title: "Да", coef: 3.34),
                Option(title: "Нет", coef: 1.43)
            ],
            gameID: "ek",
            tournamentID: 1
        ),
        Event(
            id: 9,
            title: "Победитель не проиграет ни одного боя",
            options: [
                Option(title: "Да", coef: 1.49),
                Option(title: "Нет", coef: 3.03)
            ],
            gameID: "brainNoF",
            tournamentID: 1
        ),
        Event(
            id: 15,
            title: "Хотя бы один игрок наберёт 150 очков в одной из тем",
            options: [
                Option(title: "Да", coef: 6.67),
                Option(title: "Нет", coef: 1.18)
            ],
            gameID: "ek",
            tournamentID: 1
        ),
        Event(
            id: 10,
            title: "Победитель выиграет все бои",
            options: [
                Option(title: "Да", coef: 2.63),
                Option(title: "Нет", coef: 1.61)
            ],
            gameID: "brainNoF",
            tournamentID: 1
        ),
        Event(
            id: 11,
            title: "Хотя бы в одном из боёв плей-офф понадобится перестрелка",
            options: [
                Option(title: "Да", coef: 1.22),
                Option(title: "Нет", coef: 5.56)
            ],
            gameID: "brainNoF",
            tournamentID: 1
        ),
        Event(
            id: 17,
            title: "Хотя бы одна из команд завершит финал с минусом",
            options: [
                Option(title: "Да", coef: 2.86),
                Option(title: "Нет", coef: 1.54)
            ],
            gameID: "ek",
            tournamentID: 1
        ),
        Event(
            id: 18,
            title: "Победитель займёт первое место во всех боях",
            options: [
                Option(title: "Да", coef: 7.14),
                Option(title: "Нет", coef: 1.16)
            ],
            gameID: "ek",
            tournamentID: 1
        ),
        Event(
            id: 22,
            title: "Одна команда выиграет во всех командных дисциплинах",
            options: [
                Option(title: "Да", coef: 25),
                Option(title: "Нет", coef: 1.04)
            ],
            gameID: "other",
            tournamentID: 1
        ),
        Event(
            id: 24,
            title: "Количество команд, которые получат хотя бы одну медаль в командных дисциплинах",
            options: [
                Option(title: "3", coef: 100),
                Option(title: "4", coef: 33.33),
                Option(title: "5", coef: 3.7),
                Option(title: "6", coef: 2.63),
                Option(title: "7", coef: 4.55),
                Option(title: "8", coef: 16.67),
                Option(title: "9", coef: 33.33)
            ],
            gameID: "other",
            tournamentID: 1
        ),
        Event(
            id: 25,
            title: "Количество гробов 3 или больше",
            options: [
                Option(title: "Да", coef: 1.67),
                Option(title: "Нет", coef: 2.5)
            ],
            gameID: "chgk",
            tournamentID: 1
        ),
        Event(
            id: 7,
            title: "Победитель Брейн-ринга",
            options: [
                Option(title: "Флуд", coef: 5),
                Option(title: "Эстонский экспресс", coef: 5.56),
                Option(title: "Чмоки", coef: 6.67),
                Option(title: "Пикник", coef: 8.34),
                Option(title: "Здесь был этот русский", coef: 10),
                Option(title: "Другой", coef: 4)
            ],
            gameID: "brainNoF",
            tournamentID: 1
        ),
        Event(
            id: 6,
            title: "Победитель Своей игры",
            options: [
                Option(title: "Никита Шевела", coef: 5.5),
                Option(title: "Никита Воробьёв", coef: 6.67),
                Option(title: "Иван Петренко", coef: 8.33),
                Option(title: "Руслан Алиев", coef: 10),
                Option(title: "Дмитрий Хмыров", coef: 10),
                Option(title: "Григорий Зырянов", coef: 10),
                Option(title: "Ирина Абдрашитова", coef: 12.5),
                Option(title: "Пётр Игнатенко", coef: 12.5),
                Option(title: "Максим Дьяконов", coef: 420),
                Option(title: "Другой", coef: 11)
            ],
            gameID: "si",
            tournamentID: 1
        ),
        Event(
            id: 26,
            title: "Победитель займёт первое место во всех боях",
            options: [
                Option(title: "Да", coef: 9.09),
                Option(title: "Нет", coef: 1.12)
            ],
            gameID: "si",
            tournamentID: 1
        ),
        Event(
            id: 27,
            title: "Хотя бы один игрок наберёт 150 очков в одной из тем",
            options: [
                Option(title: "Да", coef: 4.17),
                Option(title: "Нет", coef: 1.31)
            ],
            gameID: "si",
            tournamentID: 1
        )
    ]
}
