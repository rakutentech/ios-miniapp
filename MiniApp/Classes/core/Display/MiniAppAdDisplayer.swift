import Foundation

/// This class is the parent class meant to be overriden when implementing ads SDK
/// - Tag: MiniAppAdDisplayer
internal class MiniAppAdDisplayer: NSObject, MiniAppAdDisplayDelegate {
    #if RMA_SDK_ADMOB
    static let shared = AdMobDisplayer()
    #else
    static let shared = MiniAppAdDisplayer()
    #endif

    weak var delegate: MiniAppAdDisplayDelegate?
    var onInterstitialClosed: [String: (Result<Void, Error>) -> Void] = [:]
    var onRewardedClosed: [String: (Result<MiniAppReward, Error>) -> Void] = [:]
    var rewards: [String: MiniAppReward] = [:]

    override init() {
        super.init()
        initFramework()
    }

    func initFramework() {
    }

    func loadRequestedAd(forParams params: RequestParameters?, onLoaded: @escaping (Result<Void, Error>) -> Void) {
        guard let delegate = delegate, let params = params, let adTypeRaw = params.adType, let adType = MiniAppAdType(rawValue: adTypeRaw), let adId = params.adUnitId else {
            return onLoaded(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.failedToConformToProtocol.localizedDescription)))
        }
        switch adType {
        case .interstitial:
            delegate.loadInterstitial(for: adId, onLoaded: onLoaded)
        case .rewarded:
            delegate.loadRewarded(for: adId, onLoaded: onLoaded)
        }
    }

    func cleanReward(_ adId: String) {
        rewards.removeValue(forKey: adId)
        onRewardedClosed.removeValue(forKey: adId)
    }

    func cleanInterstitial(_ adId: String) {
        onInterstitialClosed.removeValue(forKey: adId)
    }

    func loadInterstitial(for adId: String, onLoaded: @escaping (Result<Void, Error>) -> Void) {
        return onLoaded(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.failedToConformToProtocol.localizedDescription)))
    }

    func showInterstitial(for adId: String, onClosed: @escaping (Result<Void, Error>) -> Void) {
        return onClosed(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.failedToConformToProtocol.localizedDescription)))
    }

    func loadRewarded(for adId: String, onLoaded: @escaping (Result<Void, Error>) -> Void) {
        return onLoaded(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.failedToConformToProtocol.localizedDescription)))
    }

    func showRewarded(for adId: String, onClosed: @escaping (Result<MiniAppReward, Error>) -> Void) {
        return onClosed(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.failedToConformToProtocol.localizedDescription)))
    }
}
