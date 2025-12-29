import Foundation

struct FiatCurrencyDTO: Sendable {
    let id: String
    let name: String
    let value: Double
    let renderedFlagData: Data?
    let favourite: Bool
    let popularity: Int
    let sortOrder: Int?

}
