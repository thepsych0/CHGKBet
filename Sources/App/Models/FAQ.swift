import Vapor

struct FAQ: Content {
    var sections: [Section]?

    struct Section: Codable {
        var title: String
        var questions: [Question]
    }

    struct Question: Codable {
        var question: String?
        var answer: String?
    }
}
