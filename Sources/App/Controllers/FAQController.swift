import Vapor

class FAQController {

    let faq = FAQ(
        sections: [
            FAQ.Section(
                title: "Общая информация и правила",
                questions: [
                    FAQ.Question(question: "Что это за приложение?", answer: "Это симулятор тотализатора на тему интеллектуальных игр."),
                    FAQ.Question(question: "Почему симулятор?", answer: "Потому что здесь нельзя ставить реальные деньги. Вся валюта виртуальная, играем на интерес."),
                    FAQ.Question(question: "А виртуальная валюта никак не конвертируется в реальные деньги?", answer: "Конвертируются по курсу 1 чгкоин = 0 рублей."),
                    FAQ.Question(question: "А в чём смысл тогда набирать много?", answer: "Во-первых, после каждого турнира будут появляться рейтинги лучших. Во-вторых, топ-3 участника по результатам сезона получат призы."),
                    FAQ.Question(question: "То есть, ставки можно ставить весь сезон?", answer: "Да. В этом, пожалуй, главное отличие этого приложения от всех остальных конкурсов прогнозов на ЧГК. В конкурсе прогнозов в рамках одного турнира выгодно поставить всю виртуальную валюту на один вариант с высоким коэффициентом, ведь только так можно оказаться в топе. Здесь же можно сыграть более равномерно, не рискуя слишком сильно на одном турнире."),
                    FAQ.Question(question: "А если я проиграю все чгкоины на одном турнире, то я больше не смогу участвовать?", answer: "Сможешь. Я буду добавлять на счёт всех участников по 500 чгкоинов за неделю до очередного турнира. Но это меньше, чем сумма при регистрации, так что у тех, кто играет более осторожно, всё равно будет преимущество."),
                    FAQ.Question(question: "А откуда ты берёшь коэффициенты?", answer: "Смотрю доступную статистику выступлений игроков и команд, считаю вероятности и, ориентируясь на них, выставляю коэффициенты. Надо понимать, что я не эксперт в подсчёте вероятностей спортивных исходов, а по ЧГК вообще существует мало данных, что сильно затрудняет анализ. Поэтому коэффициенты могут не учитывать какие-то важные нюансы."),
                    FAQ.Question(question: "Мою команду оценили сильно ниже/выше, чем надо. Я с этим не согласен!", answer: "Если команду недооценили — есть смысл поставить на себя и выиграть кучу чгкоинов. Если твою команду переоценили, значит недооценили команды противников. Ты знаешь, что делать!"),
                    FAQ.Question(question: "А если моя уверенность в неправильности коэффициента основывается не на общих соображениях, а на каком-то секретном знании?", answer: "Если тебе известно какое-то обстоятельство, которое неизвестно остальным и сильно меняет расклад (например, самый сильный игрок вашей команды не сможет приехать на турнир), то ты можешь мне об этом написать, и я исправлю коэффициенты."),
                    FAQ.Question(question: "На себя лично/на свою команду ставить можно?", answer: "Да, не вижу ни одной причины запрещать это делать."),
                    FAQ.Question(question: "На какие турниры можно будет делать ставки?", answer: "Скорее всего, на студенческие мейджоры. Если у меня будет свободное время, то и на студенческие турниры поменьше."),
                    FAQ.Question(question: "А на взрослые/школьные очники? А на синхроны?", answer: "В школьном ЧГК я не разбираюсь совсем, во взрослом разбираюсь довольно слабо, поэтому сам коэффициенты выставлять не смогу. Но если будут энтузиасты, которые помогут мне с коэффициентами (пиши мне, если это про тебя), то может быть. На синхроны точно нет, там всё слишком непредсказуемо, но скучно.")
                ]
            ),
            FAQ.Section(
                title: "Техническая информация",
                questions: [
                    FAQ.Question(question: "Почему именно мобильное приложение?", answer: "Потому что приложения я писать умею, а сайты — не особо. Если найдутся фронтэндеры-добровольцы, желающие помочь проекту (особенно интересует умение сделать красивую вёрстку), то сайт может появиться."),
                    FAQ.Question(question: "На каком языке это всё написано?", answer: "iOS — на Swift, бекэнд — на Vapor (server-side Swift), Android — на Java."),
                    FAQ.Question(question: "Зачем писать бек на Swift?", answer: "Потому что мне нравится Swift, и основная причина, по которой я взялся за этот проект, это желание научиться писать серверную часть на Swift."),
                    FAQ.Question(question: "Проект опенсоурсный?", answer: "Пока нет, но в ближайшее время сделаю."),
                    FAQ.Question(question: "Сколько человек писало это всё, и сколько времени это заняло?", answer: "Два. Чуть меньше недели."),
                    FAQ.Question(question: "Я нашёл баг. Что делать?", answer: "Найти наши контакты в разделе обратная связь и написать. Постараемся всё оперативно исправить, особенно если баг критичный и мешает играть.")

                ]
            ),
            FAQ.Section(
                title: "Обратная связь",
                questions: [
                    FAQ.Question(question: "Кто авторы этого проекта??", answer: "Меня зовут Эдгар (rating.chgk.info/player/63668). Мне принадлежит идея, я придумывал ставки и высчитывал коэффициенты, а также написал бекэнд и iOS-приложение. Android-приложение написал Ованес (rating.chgk.info/player/63634)."),
                    FAQ.Question(question: "Ты писал, что к тебе можно обратиться в случае возникновения вопросов? Как это сделать?", answer: "В общем случае писать на почту chgkbet@yandex.ru. Если что-то срочное, или если мы знакомы лично, то можно написать в вк — vk.com/thepsych0.")
                ]
            )
        ]
    )

    func getFAQ(_ req: Request) throws -> FAQ {
        return faq
    }
}

