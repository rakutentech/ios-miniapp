import Foundation
import GoogleMobileAds

/// This subclass of [MiniAppAdDisplayer](x-source-tag://MiniAppAdDisplayer) is internally used by Mini App SDK to display Google Ads
public class AdMobDisplayer: MiniAppAdDisplayer {
    internal var interstitialAds: [String: GADInterstitial] = [:]
    internal var rewardedAds: [String: GADRewardedAd] = [:]
    internal var onInterstitialLoaded: [String: (Result<Void, Error>) -> Void] = [:]

    public override init() {
        super.init()
        delegate = self
    }

    override func cleanReward(_ adId: String) {
        rewardedAds.removeValue(forKey: adId)
        super.cleanReward(adId)
    }

    override func cleanInterstitial(_ adId: String) {
        onInterstitialLoaded.removeValue(forKey: adId)
        interstitialAds.removeValue(forKey: adId)
        super.cleanInterstitial(adId)
    }

    private func onReadyFailCheck(ready: Bool, adId: String, adType: MiniAppAdType) -> Error {
        if ready {
            return NSError.miniAppAdNotLoaded(message: createLoadTwiceError(adUnitId: adId))
        } else {
            switch adType {
            case .interstitial:
                if interstitialAds[adId] != nil {
                    return NSError.miniAppAdNotLoaded(message: createLoadReqError(adUnitId: adId))
                }
            case .rewarded:
                if rewardedAds[adId] != nil {
                    return NSError.miniAppAdNotLoaded(message: createLoadReqError(adUnitId: adId))
                }
            }
            return NSError.miniAppAdNotLoaded(message: createNotLoadingReqError(adUnitId: adId))
        }
    }

    func createNotLoadingReqError(adUnitId: String) -> String {
        String(format: MASDKLocale.localize(.adNotLoadedError), adUnitId)
    }

    func createLoadReqError(adUnitId: String) -> String {
        String(format: MASDKLocale.localize(.adLoadingError), adUnitId)
    }

    func createLoadTwiceError(adUnitId: String) -> String {
        String(format: MASDKLocale.localize(.adLoadedError), adUnitId)
    }

    public override func loadInterstitial(for adId: String, onLoaded: @escaping (Result<Void, Error>) -> Void) {
        if let gad = interstitialAds[adId] {
            onLoaded(.failure(onReadyFailCheck(ready: gad.isReady, adId: adId, adType: .interstitial)))
        } else {
            onInterstitialLoaded[adId] = onLoaded
            interstitialAds[adId] = GADInterstitial(adUnitID: adId)
            interstitialAds[adId]?.delegate = self
            interstitialAds[adId]?.load(GADRequest())
        }
    }

    public override func loadRewarded(for adId: String, onLoaded: @escaping (Result<(), Error>) -> Void) {
        if let gad = rewardedAds[adId] {
            onLoaded(.failure(onReadyFailCheck(ready: gad.isReady, adId: adId, adType: .rewarded)))
        } else {
            rewardedAds[adId] = GADRewardedAd(adUnitID: adId)
            rewardedAds[adId]?.load(GADRequest()) { error in
                if let err = error {
                    onLoaded(.failure(err))
                } else {
                    onLoaded(.success(()))
                }
            }
        }
    }

    public override func showInterstitial(for adId: String, onClosed: @escaping (Result<Void, Error>) -> Void) {
        if interstitialAds[adId]?.isReady ?? false {
            if let viewController = UIApplication.topViewController() {
                onInterstitialClosed[adId] = onClosed
                interstitialAds[adId]?.present(fromRootViewController: viewController)
            } else {
                onClosed(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.hostUIError.localizedDescription)))
            }
        } else {
            onClosed(.failure(onReadyFailCheck(ready: false, adId: adId, adType: .interstitial)))
        }
    }

    public override func showRewarded(for adId: String, onClosed: @escaping (Result<MiniAppReward, Error>) -> Void) {
        if rewardedAds[adId]?.isReady ?? false {
            if let viewController = UIApplication.topViewController() {
                onRewardedClosed[adId] = onClosed
                rewardedAds[adId]?.present(fromRootViewController: viewController, delegate: self)
            } else {
                onClosed(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.hostUIError.localizedDescription)))
            }
        } else {
            onClosed(.failure(onReadyFailCheck(ready: false, adId: adId, adType: .rewarded)))
        }
    }
}

extension AdMobDisplayer: GADInterstitialDelegate {
    // function predicate comes from Google's SDK, had to disable swiftlint rule
    public func interstitialDidDismissScreen(_ ad: GADInterstitial) { // swiftlint:disable:this identifier_name
        if let id = ad.adUnitID {
            onInterstitialClosed[id]?(.success(()))
            cleanInterstitial(id)
        }
    }

    /// Called when an interstitial ad request succeeded. Show it at the next transition point in your
    /// application such as when transitioning between view controllers.
    public func interstitialDidReceiveAd(_ ad: GADInterstitial) { // swiftlint:disable:this identifier_name
        if let id = ad.adUnitID {
            onInterstitialLoaded[id]?(.success(()))
        }
    }

    /// Called when an interstitial ad request completed without an interstitial to
    /// show. This is common since interstitials are shown sparingly to users.
    public func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) { // swiftlint:disable:this identifier_name
        if let id = ad.adUnitID {
            onInterstitialLoaded[id]?(.failure(error))
            cleanInterstitial(id)
        }
    }
}

extension AdMobDisplayer: GADRewardedAdDelegate {
    public func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        rewards[rewardedAd.adUnitID] = MiniAppReward(type: reward.type, amount: Int(truncating: reward.amount))
    }

    public func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        if let reward = rewards[rewardedAd.adUnitID] {
            onRewardedClosed[rewardedAd.adUnitID]?(.success(reward))
        } else {
            onRewardedClosed[rewardedAd.adUnitID]?(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.rewardFailure.localizedDescription)))
        }
        cleanReward(rewardedAd.adUnitID)
    }
}
