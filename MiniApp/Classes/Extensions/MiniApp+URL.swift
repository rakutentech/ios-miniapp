extension URL {
    func fileExtension() -> String {
        (self.absoluteString as NSString).pathExtension.lowercased()
    }
}
