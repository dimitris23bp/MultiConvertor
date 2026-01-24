import Foundation

struct FiatCurrencyDTO: CurrencyDTO, Sendable {
    let id: String
    let name: String
    let value: Double
    let iconData: Data?
    let popularity: Int
}
