import Foundation

/// This class is the basic class meant to be overridden when implementing ads SDK
/// - Tag: MiniAppAdDisplayer
public class MiniAppAdDisplayer: NSObject, MiniAppAdDisplayDelegate {
    weak var delegate: MiniAppAdDisplayDelegate?
    var onInterstitialClosed: [String: (Result<Void, Error>) -> Void] = [:]
    var onRewardedClosed: [String: (Result<MiniAppReward, Error>) -> Void] = [:]
    var rewards: [String: MiniAppReward] = [:]

    public init (with delegate: MiniAppAdDisplayDelegate) {
        super.init()
        self.delegate = delegate
    }

    /// overridden to make it unavailable to host app
    internal override init() {
        super.init()
    }
    internal func cleanReward(_ adId: String) {
        rewards.removeValue(forKey: adId)
        onRewardedClosed.removeValue(forKey: adId)
    }

    internal func cleanInterstitial(_ adId: String) {
        onInterstitialClosed.removeValue(forKey: adId)
    }

    public func loadInterstitial(for adId: String, onLoaded: @escaping (Result<Void, Error>) -> Void) {
        if let delegate = delegate {
            delegate.loadInterstitial(for: adId, onLoaded: onLoaded)
        } else {
            return onLoaded(.failure(NSError.miniAppAdProtocoleError()))
        }
    }

    public func showInterstitial(for adId: String, onClosed: @escaping (Result<Void, Error>) -> Void) {
        if let delegate = delegate {
            delegate.showInterstitial(for: adId, onClosed: onClosed)
        } else {
            return onClosed(.failure(NSError.miniAppAdProtocoleError()))
        }
    }

    public func loadRewarded(for adId: String, onLoaded: @escaping (Result<Void, Error>) -> Void) {
        if let delegate = delegate {
            delegate.loadRewarded(for: adId, onLoaded: onLoaded)
        } else {
            return onLoaded(.failure(NSError.miniAppAdProtocoleError()))
        }
    }

    public func showRewarded(for adId: String, onClosed: @escaping (Result<MiniAppReward, Error>) -> Void) {
        if let delegate = delegate {
            delegate.showRewarded(for: adId, onClosed: onClosed)
        } else {
            return onClosed(.failure(NSError.miniAppAdProtocoleError()))
        }
    }
}
