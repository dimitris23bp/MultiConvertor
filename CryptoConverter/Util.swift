
class Util {
	nonisolated static func batchArray<T>(_ array: [T], batchSize: Int) -> [[T]] {
		return stride(from: 0, to: array.count, by: batchSize).map {
			let endIndex = min($0 + batchSize, array.count)
			return Array(array[$0..<endIndex])
		}
	}
}
