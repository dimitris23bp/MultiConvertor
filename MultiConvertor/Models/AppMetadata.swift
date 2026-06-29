import Foundation
import SwiftData

@Model
final class AppMetadata {
	var cryptoLastUpdate: String?
	var fiatLastUpdate: String?

	init(
		cryptoLastUpdate: String? = nil,
		fiatLastUpdate: String? = nil
	) {
		self.cryptoLastUpdate = cryptoLastUpdate
		self.fiatLastUpdate = fiatLastUpdate
	}
}
