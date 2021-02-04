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

    private func onReadyFailCheck(ready: Bool, adId: String) -> Error {
        if ready {
            return NSError.miniAppAdNotLoaded(message: createLoadTwiceError(adUnitId: adId))
        } else {
            return NSError.miniAppAdNotLoaded(message: createLoadReqError(adUnitId: adId))
        }
    }

    func createNotLoadingReqError(adUnitId: String) -> String {
        "Ad \(adUnitId) is not loaded yet"
    }

    func createLoadReqError(adUnitId: String) -> String {
        "Previous \(adUnitId) is still in progress"
    }

    func createLoadTwiceError(adUnitId: String) -> String {
        "Ad \(adUnitId) is already loaded"
    }

    public override func loadInterstitial(for adId: String, onLoaded: @escaping (Result<Void, Error>) -> Void) {
        if interstitialAds[adId] != nil {
           onLoaded(.failure(onReadyFailCheck(ready: true, adId: adId)))
        } else {
            onInterstitialLoaded[adId] = onLoaded
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: adId, request: request) { [weak self]  (interstitialAd, error) in
                if let error = error {
                    self?.onInterstitialLoaded[adId]?(.failure(error))
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
            onLoaded(.failure(onReadyFailCheck(ready: true, adId: adId)))
        } else {
            let request = GADRequest()
            GADRewardedAd.load(withAdUnitID: adId,
                    request: request, completionHandler: { [weak self] (rewardedAd, error) in
                if let err = error {
                    onLoaded(.failure(err))
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
            onClosed(.failure(onReadyFailCheck(ready: false, adId: adId)))
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
            onClosed(.failure(onReadyFailCheck(ready: false, adId: adId)))
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
