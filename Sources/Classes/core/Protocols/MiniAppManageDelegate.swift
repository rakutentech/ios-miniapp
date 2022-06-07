import Foundation

/**
 * Protocol for the Managing Mini Apps
 */
internal protocol MiniAppManageDelegate: AnyObject {

    func setMiniAppCloseAlertInfo(alertInfo: CloseAlertInfo?)
}
