/**
 * Protocol for the client that talks to 'GET /app:/version:/manifest' endpoint.
 */
protocol MiniAppClientProtocol {

    /// Fetches the manifest from the MiniApp backend.
    /// - Parameters:
    ///   - appId: String - AppID of the MiniApp.
    ///   - versionId: String - VersionID of the MiniApp.
    /// - Returns:Response of from the endpoint.
    func fetchManifest(with appId: String, and versionId: String) -> ManifestResponse?
}

struct MiniAppClient: MiniAppClientProtocol {
    var serviceCommunicator: ServiceCommunicatorProtocol = ServiceCommunicator()

    func fetchManifest(with appId: String, and versionId: String) -> ManifestResponse? {
        guard let manifestUrl = formRequestUrl(with: appId, and: versionId) else {
            #if DEBUG
                print("MiniAppSDK: Failed to create manifest URL.")
            #endif
            return nil
        }

        let (responseBody, metadata) = serviceCommunicator.requestFromServer(withUrl: manifestUrl,
                                                                             withHttpMethod: .get,
                                                                             withSemaphoreWait: true)

        guard let manifestResponse = decodeManifestResponse(with: responseBody) else {
            return nil
        }

        return manifestResponse
    }

    private func formRequestUrl(with appId: String, and versionId: String) -> URL? {
        return URL(string: Constants.URLs.miniAppBaseUrl + appId + "/version/" + versionId + "/manifest")
    }

    private func decodeManifestResponse(with dataResponse: Data?) -> ManifestResponse? {
        do {
            return try JSONDecoder().decode(ManifestResponse.self, from: dataResponse!)
        } catch let error {
            #if DEBUG
                print("MiniAppSDK: Failed to decode ManifestResponse: ", error)
            #endif
            return nil
        }
    }
}
