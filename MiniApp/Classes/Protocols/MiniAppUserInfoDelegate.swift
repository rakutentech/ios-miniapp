/**
 Public Protocol that will be used by the Mini App to communicate
 with the Native implementation for User profile related retrieval
*/
public protocol MiniAppUserInfoDelegate: class {
    /// Interface that is used to retrieve the user name from the User Profile
    func getUserName() -> String?

    /// Interface that is used to retrieve the Image URI
    func getProfilePhoto() -> String?
}
