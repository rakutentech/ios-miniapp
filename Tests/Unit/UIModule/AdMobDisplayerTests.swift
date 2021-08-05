import Quick
import Nimble
import GoogleMobileAds

@testable import MiniApp

// swiftlint:disable function_body_length
class AdMobDisplayerTests: QuickSpec {
#if RMA_SDK_ADMOB
    override func spec() {
        let adId = "AdUnitId"
        let key1 = "AdKey1"
        let key2 = "AdKey2"
        describe("AdMobDisplayerTests") {
            context("when cleanInterstitial method is called") {
                it("will clear all the keys from the AdMobDisplayer") {
                    let adMobDisplayer = AdMobDisplayer()
                    #if RMA_SDK_ADMOB7
                        adMobDisplayer.interstitialAds = [key1: GADInterstitial(adUnitID: adId), key2: GADInterstitial(adUnitID: adId)]
                    #elseif RMA_SDK_ADMOB8
                        adMobDisplayer.interstitialAds = [key1: GADInterstitialAd(), key2: GADInterstitialAd()]
                    #endif
                    expect(adMobDisplayer.interstitialAds.count).to(equal(2))
                    adMobDisplayer.cleanInterstitial(key1)
                    adMobDisplayer.cleanInterstitial(key2)
                    expect(adMobDisplayer.interstitialAds.count).to(equal(0))
                }
            }
            context("when cleanReward method is called") {
                it("will clear all the keys from the AdMobDisplayer") {
                    let adMobDisplayer = AdMobDisplayer()
                    #if RMA_SDK_ADMOB7
                        adMobDisplayer.rewardedAds = [key1: GADRewardedAd(adUnitID: adId), key2: GADRewardedAd(adUnitID: adId)]
                    #elseif RMA_SDK_ADMOB8
                        adMobDisplayer.rewardedAds = [key1: GADRewardedAd(), key2: GADRewardedAd()]
                    #endif
                    expect(adMobDisplayer.rewardedAds.count).to(equal(2))
                    adMobDisplayer.cleanReward(key1)
                    adMobDisplayer.cleanReward(key2)
                    expect(adMobDisplayer.rewardedAds.count).to(equal(0))
                }
            }
            context("when createNotLoadingReqError method is called") {
                it("will return error string with adUnitId") {
                    let adMobDisplayer = AdMobDisplayer()
                    let error = adMobDisplayer.createNotLoadingReqError(adUnitId: adId)
                    expect(error).to(equal(String(format: MASDKLocale.localize(.adNotLoadedError), adId)))
                }
            }
            context("when createNotLoadingReqError method is called") {
                it("will return error string with adUnitId") {
                    let adMobDisplayer = AdMobDisplayer()
                    let error = adMobDisplayer.createLoadReqError(adUnitId: adId)
                    expect(error).to(equal(String(format: MASDKLocale.localize(.adLoadingError), adId)))
                }
            }
            context("when createLoadTwiceError method is called") {
                it("will return error string with adUnitId") {
                    let adMobDisplayer = AdMobDisplayer()
                    let error = adMobDisplayer.createLoadTwiceError(adUnitId: adId)
                    expect(error).to(equal(String(format: MASDKLocale.localize(.adLoadedError), adId)))
                }
            }
        }
    }
#endif
}
