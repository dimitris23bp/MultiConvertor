import Foundation
import SwiftUI

@MainActor
protocol Currency: AnyObject {
    var id: String { get }
    var name: String { get }
    var value: Double { get set }
    var favourite: Bool { get set }
    var sortOrder: Int? { get set }
    var iconString: String? { get }
    var icon: (any View)? { get }
}
