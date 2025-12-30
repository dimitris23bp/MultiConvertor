extension [Currency] {
    /// Get the new highest order based on the currencies that are favourited.
    func getHighestOrder() -> Int {
        var highest = 0

        self.filter(\.favourite).forEach { currency in
            guard let sortOrder = currency.sortOrder else {
                print("SortOrder is nil for \(currency.id) while is it favourite: \(currency.favourite).")
                return
            }
            if sortOrder > highest {
                highest = sortOrder
            }
        }
        return highest
    }

}
