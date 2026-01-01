import Foundation

struct FiatCurrencyDTO: CurrencyDTO, Sendable {
    let id: String
    let name: String
    let value: Double
    let iconData: Data?
    let favourite: Bool
    let popularity: Int
    let sortOrder: Int?

}
