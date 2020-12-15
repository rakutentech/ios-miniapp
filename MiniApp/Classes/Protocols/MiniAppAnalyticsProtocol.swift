/**
 Public Protocol that will be used by any hosting application
 to communicate with the Mini App analytics module
 */
public protocol MiniAppAnalyticsDelegate: class {
    /// send analytic data for specific event
    func miniAppAnalytics(triggered event: String, with parameters: [String: Any]?, completionHandler: @escaping (Result<MASDKProtocolResponse, Error>) -> Void)
}
