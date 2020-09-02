protocol MiniAppErrorProtocol: Error {
  var title: String { get }
  var description: String { get }
}
