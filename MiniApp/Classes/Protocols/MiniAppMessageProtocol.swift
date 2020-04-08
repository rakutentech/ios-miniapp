/**
Public Protocol that will be used by the Mini App to communicate
 with the Native implementation
*/
public protocol MiniAppMessageProtocol {

    /// Interface that should be implemented to return alphanumeric string that uniquely identifies a device.
    func getUniqueId() -> String
}
