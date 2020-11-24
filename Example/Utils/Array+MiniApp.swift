extension Array {
    public func dictionaryFilteredBy<Key: Hashable> (index selectKey: (Element) -> Key) -> [Key: [Element]] {
        var dict = [Key: [Element]]()
        for element in self {
            if dict[selectKey(element)] != nil {
                dict[selectKey(element)]?.append(element)
            } else {
                dict[selectKey(element)] = [Element]()
                dict[selectKey(element)]!.append(element)
            }
        }
        return dict
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}
