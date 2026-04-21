import Foundation

enum AppExternalURL: String, CaseIterable {
    case privacyPolicy = "https://example.com/privacy-policy"
    case termsOfService = "https://example.com/terms"

    var url: URL? {
        URL(string: rawValue)
    }

    var title: String {
        switch self {
        case .privacyPolicy: return "Privacy Policy"
        case .termsOfService: return "Terms of Service"
        }
    }

    var symbolName: String {
        switch self {
        case .privacyPolicy: return "hand.raised.fill"
        case .termsOfService: return "doc.text.fill"
        }
    }
}
