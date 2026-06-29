import Foundation

protocol CurrencyDTO: Sendable {
	var id: String { get }
	var name: String { get }
	var value: Double { get }
	var iconData: Data? { get }
}
