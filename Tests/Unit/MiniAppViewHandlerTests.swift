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
}
