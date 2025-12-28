protocol Currency {
    var id: String { get }
    var name: String { get }
    var value: Double { get set }
    var favourite: Bool { get set }
    var sortOrder: Int? { get set }
}
