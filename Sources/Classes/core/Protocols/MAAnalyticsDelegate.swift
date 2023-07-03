import Foundation

/**
 Public Protocol that will be used by the Mini App to send Analytics info to host app.
 With the Native implementation host can receive MAAnalyticsInfo object through this interface.
 */
public protocol MAAnalyticsDelegate: AnyObject {
    /// This interface must be implemented int he host app to get the MAAnalyticsInfo object from the MiniApps.
    func didReceiveMAAnalytics(analyticsInfo: MAAnalyticsInfo, completionHandler: @escaping (Result<MASDKProtocolResponse, MAAnalyticsError>) -> Void)
}
