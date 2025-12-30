protocol CurrencyDTO: Sendable {
    var id: String { get }
    var name: String { get }
    var value: Double { get }
    var favourite: Bool { get }
    var sortOrder: Int? { get }

}
