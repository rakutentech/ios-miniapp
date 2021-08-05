import Foundation
import GoogleMobileAds

/// This subclass of [MiniAppAdDisplayer](x-source-tag://MiniAppAdDisplayer) is internally used by Mini App SDK to display Google Ads
public class AdMobDisplayer: MiniAppAdDisplayer {
    internal var interstitialAds: [String: GADInterstitialAd] = [:]
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
        if interstitialAds[adId] != nil {
           onLoaded(.failure(onReadyFailCheck(ready: true, adId: adId, adType: .interstitial)))
        } else {
            onInterstitialLoaded[adId] = onLoaded
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: adId, request: request) { [weak self]  (interstitialAd, error) in
                if let error = error {
                    self?.onInterstitialLoaded[adId]?(.failure(error))
                    self?.cleanInterstitial(adId)
                } else {
                    interstitialAd?.fullScreenContentDelegate = self
                    self?.interstitialAds[adId] = interstitialAd
                    self?.onInterstitialLoaded[adId]?(.success(()))
                }
            }
        }
    }

    public override func loadRewarded(for adId: String, onLoaded: @escaping (Result<(), Error>) -> Void) {
        if rewardedAds[adId] != nil {
            onLoaded(.failure(onReadyFailCheck(ready: true, adId: adId, adType: .rewarded)))
        } else {
            let request = GADRequest()
            GADRewardedAd.load(withAdUnitID: adId,
                    request: request, completionHandler: { [weak self] (rewardedAd, error) in
                if let err = error {
                    onLoaded(.failure(err))
                    self?.cleanReward(adId)
                } else {
                    rewardedAd?.fullScreenContentDelegate = self
                    self?.rewardedAds[adId] = rewardedAd
                    onLoaded(.success(()))
                }
            })
        }
    }

    public override func showInterstitial(for adId: String, onClosed: @escaping (Result<Void, Error>) -> Void) {
        if let interstitialAd = interstitialAds[adId] {
            if let viewController = UIApplication.topViewController() {
                onInterstitialClosed[adId] = onClosed
                interstitialAd.present(fromRootViewController: viewController)
            } else {
                onClosed(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.hostUIError.localizedDescription)))
            }
        } else {
            onClosed(.failure(onReadyFailCheck(ready: false, adId: adId, adType: .interstitial)))
        }
    }

    public override func showRewarded(for adId: String, onClosed: @escaping (Result<MiniAppReward, Error>) -> Void) {
        if let rewardedAd = rewardedAds[adId] {
            if let viewController = UIApplication.topViewController() {
                onRewardedClosed[adId] = onClosed
                rewardedAd.present(fromRootViewController: viewController) { [weak self] in
                    let reward = rewardedAd.adReward
                    self?.rewards[adId] = MiniAppReward(type: reward.type, amount: Int(truncating: reward.amount))
                }
            } else {
                onClosed(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.hostUIError.localizedDescription)))
            }
        } else {
            onClosed(.failure(onReadyFailCheck(ready: false, adId: adId, adType: .rewarded)))
        }
    }
}

extension AdMobDisplayer: GADFullScreenContentDelegate {
    /// Tells the delegate that the ad dismissed full screen content.
    public func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) { // swiftlint:disable:this identifier_name
        if let interstitial = ad as? GADInterstitialAd {
            onInterstitialClosed[interstitial.adUnitID]?(.success(()))
            cleanInterstitial(interstitial.adUnitID)
        } else if let rewardedAd = ad as? GADRewardedAd {
            if let reward = rewards[rewardedAd.adUnitID] {
                onRewardedClosed[rewardedAd.adUnitID]?(.success(reward))
            } else {
                onRewardedClosed[rewardedAd.adUnitID]?(.failure(NSError.miniAppAdNotLoaded(message: MASDKAdsDisplayError.rewardFailure.localizedDescription)))
            }
            cleanReward(rewardedAd.adUnitID)
        }
    }
}
