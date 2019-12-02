import Vapor
import FluentPostgreSQL

final class AppsController {

    func getVersion(_ req: Request) throws -> AppVersions {
        guard let osString = req.http.headers.firstValue(name: HTTPHeaderName("OS")) else { throw Abort(.badRequest, reason: "noOSHeader") }
        guard let os = AppOS(rawValue: osString) else { throw Abort(.badRequest, reason: "unsupportedOS") }

        return AppVersions(appVersionCurrent: os.appVersionCurrent, appVersionMinimum: os.appVersionMinimum)
    }
}

struct AppVersions {
    let appVersionCurrent: String
    let appVersionMinimum: String
}

enum AppOS: String {
    case iOS
    case android

    var appVersionCurrent: String {
        switch self {
        case .iOS:
            return "1.3"
        case .android:
            return ""
        }
    }

    var appVersionMinimum: String {
        switch self {
        case .iOS:
            return "1.3"
        case .android:
            return ""
        }
    }
}
