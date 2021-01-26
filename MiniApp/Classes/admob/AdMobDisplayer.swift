import Foundation
import GoogleMobileAds

/// This subclass of [MiniAppAdDisplayer](x-source-tag://MiniAppAdDisplayer) is internally used by Mini App SDK to display Google Ads
internal class AdMobDisplayer: MiniAppAdDisplayer {
    var interstitialAds: [String: GADInterstitial] = [:]
    var rewardedAds: [String: GADRewardedAd] = [:]
    var onInterstitialLoaded: [String: (Result<Void, Error>) -> Void] = [:]
    var admobStartResult: [String : GADAdapterStatus]?

    override init() {
        super.init()
        delegate = self
    }

    override func initFramework() {
        GADMobileAds.sharedInstance().start {[weak self] status in
            self?.admobStartResult = status.adapterStatusesByClassName
        }
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

    private func onReadyFailCheck(ready: Bool, adId: String, gad: NSObject?) -> Error {
        if gad == nil {
            return NSError.miniAppAdNotLoaded(message: createNotLoadingReqError(adUnitId: adId))
        } else if ready {
            return NSError.miniAppAdNotLoaded(message: createLoadTwiceError(adUnitId: adId))
        } else {
            return NSError.miniAppAdNotLoaded(message: createLoadReqError(adUnitId: adId))
        }
    }

    func createNotLoadingReqError(adUnitId: String) -> String {
        "Ad \(adUnitId) is not loading"
    }

    func createLoadReqError(adUnitId: String) -> String {
        "Previous \(adUnitId) is still in progress"
    }

    func createLoadTwiceError(adUnitId: String) -> String {
        "Ad \(adUnitId) is already loaded"
    }

    override func loadInterstitial(for adId: String, onLoaded: @escaping (Result<Void, Error>) -> Void) {
        if admobStartResult == nil {
            onLoaded(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.sdkError.localizedDescription)))
        } else if let gad = interstitialAds[adId] {
            let ready = gad.isReady
            onLoaded(.failure(onReadyFailCheck(ready: ready, adId: adId, gad: gad)))
        } else {
            onInterstitialLoaded[adId] = onLoaded
            interstitialAds[adId] = GADInterstitial(adUnitID: adId)
            interstitialAds[adId]?.delegate = self
            interstitialAds[adId]?.load(GADRequest())
        }
    }

    override func loadRewarded(for adId: String, onLoaded: @escaping (Result<(), Error>) -> Void) {
        if admobStartResult == nil {
            onLoaded(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.sdkError.localizedDescription)))
        } else if let gad = rewardedAds[adId] {
            let ready = gad.isReady
            onLoaded(.failure(onReadyFailCheck(ready: ready, adId: adId, gad: gad)))
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

    override func showInterstitial(for adId: String, onClosed: @escaping (Result<Void, Error>) -> Void) {
        if interstitialAds[adId]?.isReady ?? false {
            if let viewController = UIApplication.topViewController() {
                onInterstitialClosed[adId] = onClosed
                interstitialAds[adId]?.present(fromRootViewController: viewController)
            } else {
                onClosed(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.hostUIError.localizedDescription)))
            }
        } else {
            onClosed(.failure(onReadyFailCheck(ready: false, adId: adId, gad: interstitialAds[adId])))
        }
    }

    override func showRewarded(for adId: String, onClosed: @escaping (Result<MiniAppReward, Error>) -> Void) {
        if rewardedAds[adId]?.isReady ?? false {
            if let viewController = UIApplication.topViewController() {
                onRewardedClosed[adId] = onClosed
                rewardedAds[adId]?.present(fromRootViewController: viewController, delegate: self)
            } else {
                onClosed(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.hostUIError.localizedDescription)))
            }
        } else {
            onClosed(.failure(onReadyFailCheck(ready: false, adId: adId, gad: interstitialAds[adId])))
        }
    }
}

extension AdMobDisplayer: GADInterstitialDelegate {
    // function predicate comes from Google's SDK, had to disable swiftlint rule
    func interstitialDidDismissScreen(_ ad: GADInterstitial) { // swiftlint:disable:this identifier_name
        if let id = ad.adUnitID {
            onInterstitialClosed[id]?(.success(()))
            cleanInterstitial(id)
        }
    }

    /// Called when an interstitial ad request succeeded. Show it at the next transition point in your
    /// application such as when transitioning between view controllers.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) { // swiftlint:disable:this identifier_name
        if let id = ad.adUnitID {
            onInterstitialLoaded[id]?(.success(()))
        }
    }

    /// Called when an interstitial ad request completed without an interstitial to
    /// show. This is common since interstitials are shown sparingly to users.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) { // swiftlint:disable:this identifier_name
        if let id = ad.adUnitID {
            onInterstitialLoaded[id]?(.failure(error))
        }
    }
}

extension AdMobDisplayer: GADRewardedAdDelegate {
    func rewardedAd(_ rewardedAd: GADRewardedAd, userDidEarn reward: GADAdReward) {
        rewards[rewardedAd.adUnitID] = MiniAppReward(type: reward.type, amount: Int(truncating: reward.amount))
    }

    func rewardedAdDidDismiss(_ rewardedAd: GADRewardedAd) {
        if let reward = rewards[rewardedAd.adUnitID] {
            onRewardedClosed[rewardedAd.adUnitID]?(.success(reward))
        } else {
            onRewardedClosed[rewardedAd.adUnitID]?(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.rewardFailure.localizedDescription)))
        }
        cleanReward(rewardedAd.adUnitID)
    }
}
