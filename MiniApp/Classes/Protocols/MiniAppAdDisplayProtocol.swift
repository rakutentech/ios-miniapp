import Foundation

public protocol MiniAppAdDisplayProtocol {
	func showInterstitial(onClosed: @escaping (() -> Void), onFailed: @escaping ((Error) -> Void))
	func showRewarded(onClosed: @escaping ((MiniAppReward?) -> Void), onFailed: @escaping ((Error) -> Void))
}
