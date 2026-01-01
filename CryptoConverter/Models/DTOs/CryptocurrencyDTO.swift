import Foundation

/// A thread-safe intermediate representation of cryptocurrency data.
/// Used to transfer data from the background Service to the MainActor Repository.
struct CryptocurrencyDTO: CurrencyDTO, Sendable {
    let id: String
    let name: String
    let value: Double
    let marketCap: Double
    let iconData: Data?
    let favourite: Bool
    let sortOrder: Int?
}
