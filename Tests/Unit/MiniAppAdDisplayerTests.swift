import Quick
import Nimble
import WebKit
@testable import MiniApp

// swiftlint:disable function_body_length
class MiniAppAdDisplayerTests: QuickSpec {
    var success = true
    var interstitialLoaded = false
    var rewardLoaded = false
    var interstitialShown = false
    var rewardShown = false
    var rewardValue = Int.min
    var adsDisplayer: MiniAppAdDisplayer?
    let errorText = "TestError"
    var response: String?
    override func spec() {
        adsDisplayer = MiniAppAdDisplayer(with: self)
        describe("When Ads displayer") {
            let scriptMessageHandler = MiniAppScriptMessageHandler(
                    delegate: self,
                    hostAppMessageDelegate: MockMessageInterface(),
                    adsDisplayer: adsDisplayer,
                    miniAppId: "mockMiniAppID",
                    miniAppTitle: "mockMiniAppTitle"
            )
            context("receives a successful interstitial request") {
                it("it loads it") {
                    self.success = true
                    self.response = nil
                    let mockMessage = MockWKScriptMessage(name: "loadAd", body: "{\"action\": \"loadAd\", \"param\": { \"adType\": 0, \"adUnitId\": \"testAdId\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(self.response).to(contain("ad loaded"))
                }
            }
            context("receives a bad interstitial request") {
                it("it sends an error") {
                    self.success = false
                    self.response = nil
                    let mockMessage = MockWKScriptMessage(name: "loadAd", body: "{\"action\": \"loadAd\", \"param\": { \"adType\": 0, \"adUnitId\": \"testAdId\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(self.response).to(be(self.errorText))
                }
            }
            context("receives a successful reward request") {
                it("it loads it") {
                    self.success = true
                    self.response = nil
                    let mockMessage = MockWKScriptMessage(name: "loadAd", body: "{\"action\": \"loadAd\", \"param\": { \"adType\": 1, \"adUnitId\": \"testAdId\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(self.response).to(contain("ad loaded"))
                }
            }
            context("receives a bad reward request") {
                it("it sends an error") {
                    self.success = false
                    self.response = nil
                    let mockMessage = MockWKScriptMessage(name: "loadAd", body: "{\"action\": \"loadAd\", \"param\": { \"adType\": 1, \"adUnitId\": \"testAdId\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(self.response).to(be(self.errorText))
                }
            }
            context("receives a successful interstitial display request") {
                it("it loads it") {
                    self.success = true
                    self.response = nil
                    let mockMessage = MockWKScriptMessage(name: "loadAd", body: "{\"action\": \"showAd\", \"param\": { \"adType\": 0, \"adUnitId\": \"testAdId\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(self.response).to(contain("ad loaded"))
                }
            }
            context("receives a bad interstitial display request") {
                it("it sends an error") {
                    self.success = false
                    self.response = nil
                    let mockMessage = MockWKScriptMessage(name: "loadAd", body: "{\"action\": \"showAd\", \"param\": { \"adType\": 0, \"adUnitId\": \"testAdId\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(self.response).to(be(self.errorText))
                }
            }
            context("receives a successful reward display request") {
                it("it loads it") {
                    self.success = true
                    self.response = nil
                    let mockMessage = MockWKScriptMessage(name: "loadAd", body: "{\"action\": \"showAd\", \"param\": { \"adType\": 1, \"adUnitId\": \"testAdId\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(self.response).to(contain("{\"type\":\"test\",\"amount\":9223372036854775807}"))
                }
            }
            context("receives a bad reward display request") {
                it("it sends an error") {
                    self.success = false
                    self.response = nil
                    let mockMessage = MockWKScriptMessage(name: "loadAd", body: "{\"action\": \"showAd\", \"param\": { \"adType\": 1, \"adUnitId\": \"testAdId\"}, \"id\":\"12345\"}" as AnyObject)
                    scriptMessageHandler.userContentController(WKUserContentController(), didReceive: mockMessage)
                    expect(self.response).to(be(self.errorText))
                }
            }
        }
    }
}

extension MiniAppAdDisplayerTests: MiniAppAdDisplayDelegate {
    func loadInterstitial(for adId: String, onLoaded: @escaping (Result<Void, Error>) -> Void) {
        if success {
            onLoaded(.success(()))
        } else {
            onLoaded(.failure(NSError.miniAppAdNotLoaded(message: errorText)))
        }
    }

    func showInterstitial(for adId: String, onClosed: @escaping (Result<Void, Error>) -> Void) {
        if success {
            onClosed(.success(()))
        } else {
            onClosed(.failure(NSError.miniAppAdNotDisplayed(message: errorText)))
        }
    }

    func loadRewarded(for adId: String, onLoaded: @escaping (Result<Void, Error>) -> Void) {
        if success {
            onLoaded(.success(()))
        } else {
            onLoaded(.failure(NSError.miniAppAdNotDisplayed(message: errorText)))
        }
    }

    func showRewarded(for adId: String, onClosed: @escaping (Result<MiniAppReward, Error>) -> Void) {
        if success {
            onClosed(.success((MiniAppReward(type: "Test", amount: Int.max))))
        } else {
            onClosed(.failure(NSError.miniAppAdNotDisplayed(message: errorText)))
        }
    }
}

extension MiniAppAdDisplayerTests: MiniAppCallbackDelegate {
    func didReceiveScriptMessageResponse(messageId: String, response: String) {
        self.response = response.lowercased()
    }

    func didReceiveScriptMessageError(messageId: String, errorMessage: String) {
        response = errorMessage
    }
}
