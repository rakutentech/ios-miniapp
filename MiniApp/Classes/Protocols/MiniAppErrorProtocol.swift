protocol MiniAppErrorProtocol: Error {
  var name: String { get }
  var description: String { get }
}
