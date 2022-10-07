import Foundation
import XCTest
@testable import MiniApp
import WebKit

// swiftlint:disable function_body_length

class MiniAppViewHandlerTests: XCTestCase {

    override class func setUp() {
        updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .userName, status: .allowed)
        updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .profilePhoto, status: .allowed)
    }

    func test_miniappviewhandler_load_miniapp() {
        let expectation = XCTestExpectation(description: #function)

        let messageDelegate = MockMessageInterface()

        let viewHandler = MiniAppViewHandler(
            config: MiniAppConfig(
                config: nil,
                messageDelegate: messageDelegate
            ),
            appId: mockMiniAppInfo.id,
            version: mockMiniAppInfo.version.versionId
        )

        let mockBundle = MockBundle()
        mockBundle.mockPreviewMode = false
        let environment = Environment(bundle: mockBundle)

        let mockedClient = MockAPIClient()
        mockedClient.environment = environment

        let mockManifestDownloader = MockManifestDownloader()

        let status = MiniAppStatus()
        let mockDownloader = MiniAppDownloader(apiClient: mockedClient, manifestDownloader: mockManifestDownloader, status: status)

        viewHandler.miniAppClient = mockedClient
        viewHandler.manifestDownloader = mockManifestDownloader
        viewHandler.miniAppDownloader = mockDownloader

        let responseString = """
        [{
            "id": "\(mockMiniAppInfo.id)",
            "displayName": "Test",
            "icon": "https://test.com",
            "version": {
                "versionTag": "1.0.0",
                "versionId": "\(mockMiniAppInfo.version.versionId)",
            }
          }]
        """
        let manifestResponse = """
          {
            "manifest": ["\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
          }
        """

        mockedClient.data = responseString.data(using: .utf8)
        mockedClient.metaData = mockMetaDataString.data(using: .utf8)
        mockedClient.manifestData = manifestResponse.data(using: .utf8)

        viewHandler.load { result in
            switch result {
            case let .success(webView):
                XCTAssertEqual(webView.url?.absoluteString, "mscheme.app-id-test://miniapp/index.html")
                expectation.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func test_miniappviewhandler_get_info() {
        let expectation = XCTestExpectation(description: #function)

        let messageDelegate = MockMessageInterface()

        let mockedClient = MockAPIClient()
        let infoJsonData = try? JSONEncoder().encode([mockMiniAppInfo])
        mockedClient.data = infoJsonData

        let viewHandler = MiniAppViewHandler(
            config: MiniAppConfig(
                config: nil,
                messageDelegate: messageDelegate
            ),
            appId: mockMiniAppInfo.id,
            version: mockMiniAppInfo.version.versionId
        )
        viewHandler.miniAppClient = mockedClient

        viewHandler.getMiniAppInfo(miniAppId: mockMiniAppInfo.id) { result in
            switch result {
            case let .success(info):
                XCTAssertEqual(info.id, mockMiniAppInfo.id)
                expectation.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func test_miniappviewhandler_download_miniapp() {
        let expectation = XCTestExpectation(description: #function)

        let messageDelegate = MockMessageInterface()

        let viewHandler = MiniAppViewHandler(
            config: MiniAppConfig(
                config: nil,
                messageDelegate: messageDelegate
            ),
            appId: mockMiniAppInfo.id,
            version: mockMiniAppInfo.version.versionId
        )

        let mockBundle = MockBundle()
        mockBundle.mockPreviewMode = false
        let environment = Environment(bundle: mockBundle)

        let mockedClient = MockAPIClient()
        mockedClient.environment = environment

        let mockManifestDownloader = MockManifestDownloader()

        let status = MiniAppStatus()
        let mockDownloader = MiniAppDownloader(apiClient: mockedClient, manifestDownloader: mockManifestDownloader, status: status)

        viewHandler.miniAppClient = mockedClient
        viewHandler.manifestDownloader = mockManifestDownloader
        viewHandler.miniAppDownloader = mockDownloader

        let responseString = """
        [{
            "id": "\(mockMiniAppInfo.id)",
            "displayName": "Test",
            "icon": "https://test.com",
            "version": {
                "versionTag": "1.0.0",
                "versionId": "\(mockMiniAppInfo.version.versionId)",
            }
          }]
        """
        let manifestResponse = """
          {
            "manifest": ["\(mockHost)/map-published-v2/min-abc/ver-abc/HelloWorld.txt"]
          }
        """

        mockedClient.data = responseString.data(using: .utf8)
        mockedClient.metaData = mockMetaDataString.data(using: .utf8)
        mockedClient.manifestData = manifestResponse.data(using: .utf8)

        viewHandler.downloadMiniApp(appInfo: mockMiniAppInfo) { result in
            switch result {
            case let .success(didSucceed):
                XCTAssertTrue(didSucceed)
                expectation.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func test_miniappviewhandler_validate_scheme() {
        let messageDelegate = MockMessageInterface()

        let viewHandler = MiniAppViewHandler(
            config: MiniAppConfig(
                config: nil,
                messageDelegate: messageDelegate
            ),
            appId: mockMiniAppInfo.id,
            version: mockMiniAppInfo.version.versionId
        )

        let aboutExpectation = XCTestExpectation(description: #function + "_about")
        var aboutPolicy: WKNavigationActionPolicy?
        let aboutUrl = URL(string: "about://")!
        viewHandler.validateScheme(requestURL: aboutUrl, navigationAction: WKNavigationAction()) { policy in
            aboutPolicy = policy
            aboutExpectation.fulfill()
        }

        wait(for: [aboutExpectation], timeout: 3.0)
        XCTAssertEqual(aboutPolicy, .allow)

        let telExpectation = XCTestExpectation(description: #function + "_tel")
        var telPolicy: WKNavigationActionPolicy?
        let telUrl = URL(string: "tel://")!
        viewHandler.validateScheme(requestURL: telUrl, navigationAction: WKNavigationAction()) { policy in
            telPolicy = policy
            telExpectation.fulfill()
        }
        wait(for: [telExpectation], timeout: 3.0)
        XCTAssertEqual(telPolicy, .cancel)

        let schemeExpectation = XCTestExpectation(description: #function + "_mscheme")
        var schemePolicy: WKNavigationActionPolicy?
        let schemeUrl = URL(string: "mscheme.1234://")!
        viewHandler.validateScheme(requestURL: schemeUrl, navigationAction: WKNavigationAction()) { policy in
            schemePolicy = policy
            schemeExpectation.fulfill()
        }
        wait(for: [schemeExpectation], timeout: 3.0)
        XCTAssertEqual(schemePolicy, .allow)

        let base64Expectation = XCTestExpectation(description: #function + "_base64")
        var base64Policy: WKNavigationActionPolicy?
        let base64Url = URL(string: getExampleBase64String())!
        viewHandler.validateScheme(requestURL: base64Url, navigationAction: WKNavigationAction()) { policy in
            base64Policy = policy
            base64Expectation.fulfill()
        }
        wait(for: [base64Expectation], timeout: 3.0)
        XCTAssertEqual(base64Policy, .cancel)

        viewHandler.onExternalWebviewClose = { _ in }
        viewHandler.onExternalWebviewResponse = { _ in }
        let httpsExpectation = XCTestExpectation(description: #function + "_https")
        var httpsPolicy: WKNavigationActionPolicy?
        let httpsUrl = URL(string: "https://www.rakuten.co.jp")!
        viewHandler.validateScheme(requestURL: httpsUrl, navigationAction: WKNavigationAction()) { policy in
            httpsPolicy = policy
            httpsExpectation.fulfill()
        }
        wait(for: [httpsExpectation], timeout: 3.0)
        XCTAssertEqual(httpsPolicy, .cancel)
    }

    // MARK: - WKUIDelegate
    func test_miniappviewhandler_window_alerts() {

        let messageDelegate = MockMessageInterface()

        let viewHandler = MiniAppViewHandler(
            config: MiniAppConfig(
                config: nil,
                messageDelegate: messageDelegate
            ),
            appId: mockMiniAppInfo.id,
            version: mockMiniAppInfo.version.versionId
        )

        let miniAppWebView = MiniAppWebView()
        do {
            try viewHandler.loadWebView(
                webView: miniAppWebView,
                miniAppId: mockMiniAppInfo.id,
                versionId: mockMiniAppInfo.version.versionId
            )
        } catch {
            XCTFail(error.localizedDescription)
        }

        let expectation = XCTestExpectation(description: #function)
        miniAppWebView.evaluateJavaScript("window.alert('This is window alert!');")

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func test_miniappviewhandler_window_alerts_confirm() {
        let expectation = XCTestExpectation(description: #function)

        let messageDelegate = MockMessageInterface()

        let viewHandler = MiniAppViewHandler(
            config: MiniAppConfig(
                config: nil,
                messageDelegate: messageDelegate
            ),
            appId: mockMiniAppInfo.id,
            version: mockMiniAppInfo.version.versionId
        )

        let miniAppWebView = MiniAppWebView()
        do {
            try viewHandler.loadWebView(
                webView: miniAppWebView,
                miniAppId: mockMiniAppInfo.id,
                versionId: mockMiniAppInfo.version.versionId
            )
        } catch {
            XCTFail(error.localizedDescription)
        }

        miniAppWebView.evaluateJavaScript("window.confirm('This is window confirm!');")

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func test_miniappviewhandler_window_alerts_prompt() {
        let expectation = XCTestExpectation(description: #function)

        let messageDelegate = MockMessageInterface()

        let viewHandler = MiniAppViewHandler(
            config: MiniAppConfig(
                config: nil,
                messageDelegate: messageDelegate
            ),
            appId: mockMiniAppInfo.id,
            version: mockMiniAppInfo.version.versionId
        )

        let miniAppWebView = MiniAppWebView()
        do {
            try viewHandler.loadWebView(
                webView: miniAppWebView,
                miniAppId: mockMiniAppInfo.id,
                versionId: mockMiniAppInfo.version.versionId
            )
        } catch {
            XCTFail(error.localizedDescription)
        }

        miniAppWebView.evaluateJavaScript("window.prompt('This is window prompt!', 'sure!');")

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3.0)
    }
}
