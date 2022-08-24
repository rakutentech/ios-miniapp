import Foundation
import XCTest
@testable import MiniApp

class MiniAppViewTests: XCTestCase {

    override class func setUp() {
        updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .userName, status: .allowed)
        updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .profilePhoto, status: .allowed)
    }

    // MARK: - Async
    func test_miniappview_load_async_should_fail() async throws {
        let messageDelegate = MockMessageInterface()

        let view = await MiniAppView(
            config: MiniAppConfig(
                config: nil,
                messageInterface: messageDelegate
            ),
            type: .miniapp,
            appId: mockMiniAppInfo.id
        )
        do {
            _ = try await view.loadAsync()
            XCTFail("should not load with invalid miniapp id")
        } catch {
            XCTAssertTrue(!error.localizedDescription.isEmpty)
        }
    }

    // MARK: - Closure
    func test_miniappview_load() {
        let expectation = XCTestExpectation(description: #function)

        let delegate = MockMessageInterface()
        let mockHandler = makeMockViewHandler(messageDelegate: delegate)

        let view = MiniAppView(
            config: MiniAppConfig(
                config: nil,
                messageInterface: delegate
            ),
            type: .miniapp,
            appId: mockMiniAppInfo.id,
            version: mockMiniAppInfo.version.versionId
        )
        view.miniAppHandler = mockHandler
        view.load { result in
            switch result {
            case let .success(success):
                XCTAssertTrue(success)
                expectation.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func test_miniappview_load_should_fail() {
        let expectation = XCTestExpectation(description: #function)
        let messageDelegate = MockMessageInterface()

        let view = MiniAppView(
            config: MiniAppConfig(
                config: nil,
                messageInterface: messageDelegate
            ),
            type: .miniapp,
            appId: mockMiniAppInfo.id
        )
        view.load { result in
            switch result {
            case .success:
                XCTFail("should not succeed")
            case let .failure(error):
                XCTAssertTrue(!error.localizedDescription.isEmpty)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func test_miniappview_load_from_cache_should_fail() {
        let expectation = XCTestExpectation(description: #function)
        let messageDelegate = MockMessageInterface()

        let view = MiniAppView(
            config: MiniAppConfig(
                config: nil,
                messageInterface: messageDelegate
            ),
            type: .miniapp,
            appId: mockMiniAppInfo.id
        )
        view.load(fromCache: true) { result in
            switch result {
            case .success:
                XCTFail("should not succeed")
            case let .failure(error):
                XCTAssertTrue(error.localizedDescription.contains("MiniApp is not in preview mode"))
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func test_miniappview_load_from_url() {
        let expectation = XCTestExpectation(description: #function)
        let messageDelegate = MockMessageInterface()

        let view = MiniAppView(
            config: MiniAppConfig(
                config: nil,
                messageInterface: messageDelegate
            ),
            type: .miniapp,
            url: URL(string: "http://localhost:1337")!
        )
        view.load { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}

extension MiniAppViewTests {
    func makeMockViewHandler(messageDelegate: MiniAppMessageDelegate) -> MiniAppViewHandler {
        let viewHandler = MiniAppViewHandler(
            config: MiniAppConfig(
                config: nil,
                messageInterface: messageDelegate
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

        return viewHandler
    }
}
