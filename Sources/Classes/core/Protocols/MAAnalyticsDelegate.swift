import Foundation

/**
 Public Protocol that will be used by the Mini App to send Aalytics info to host app.
 With the Native implementation host can receive MAAnalytics object through this interface.
 */
public protocol MAAnalyticsDelegate: AnyObject {
    /// This interface must be implemented int he host app to get the MAAnalytics object from the MiniApps.
    func didReceiveMAAnalytics(analyticsInfo: MAAnalytics, completionHandler: @escaping (Result<MASDKProtocolResponse, MAAnalyticsError>) -> Void)
}
