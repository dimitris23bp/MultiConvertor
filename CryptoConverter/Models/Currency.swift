import Foundation
import SwiftUI
import CloudKit

@MainActor
protocol Currency: AnyObject {
    var id: String { get }
    var name: String { get }
    var value: Double { get set }
    var favourite: Bool { get set }
    var sortOrder: Int? { get set }
    var iconData: Data? { get }
    var icon: UIImage? { get }
}
