import Foundation
import Combine
import SwiftUI

@MainActor
final class TickerUpdateScheduler: ObservableObject {
    @Published private(set) var lastExecution: Date

    private var timer: Timer?
    private let userDefaultsKey = "lastExecution"
    private let minimumInterval: TimeInterval

    var formattedLastExecutionTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: lastExecution)
    }

    init(minimumInterval: TimeInterval = 3600) {
        self.minimumInterval = minimumInterval
        self.lastExecution = UserDefaults.standard.object(forKey: userDefaultsKey) as? Date ?? .distantPast
    }

    func start(every seconds: TimeInterval = 60, action: @escaping () async -> Void) {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.checkIfNeeded() {
					print("Update in Task")
                    self.updateLastExecution()
                    await action()
                }
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func checkIfNeeded() -> Bool {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastExecution)
        return elapsed >= minimumInterval
    }

    func updateLastExecution() {
        lastExecution = Date()
        UserDefaults.standard.set(lastExecution, forKey: userDefaultsKey)
    }

    deinit {
        timer?.invalidate()
    }
}
