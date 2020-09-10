protocol MiniAppErrorProtocol: Error {
  var name: String { get }
  var message: String { get }
}
