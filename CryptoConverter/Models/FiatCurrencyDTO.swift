import Foundation

struct FiatCurrencyDTO: Sendable {
    let id: String
    let name: String
    let value: Double
    let renderedFlagData: Data?
    let favourite: Bool
    let sortOrder: Int?
}
