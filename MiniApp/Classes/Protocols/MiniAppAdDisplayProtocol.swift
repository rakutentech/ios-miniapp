import Foundation

public protocol MiniAppAdDisplayProtocol {
	func showInterstitial(onClosed: (() -> Void), onFailed: (() -> Void))
	func showRewarded(onClosed: ((MiniAppReward?) -> Void), onFailed: ((Error) -> Void))
}
