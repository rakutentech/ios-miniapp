import Foundation
import XCTest
@testable import MiniApp

class MiniAppViewTests: XCTestCase {

    override class func setUp() {
        updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .userName, status: .allowed)
        updateCustomPermissionStatus(miniAppId: mockMiniAppInfo.id, permissionType: .profilePhoto, status: .allowed)
    }

    override class func tearDown() {
        deleteMockMiniApp(appId: mockMiniAppInfo.id, versionId: mockMiniAppInfo.version.versionId)
    }

    // MARK: - Async
    func test_miniappview_load_async_should_fail() async throws {
        let messageDelegate = MockMessageInterface()

        let params = MiniAppViewParameters.default(
            .init(
                config: MiniAppConfig(
                    config: nil,
                    messageDelegate: messageDelegate
                ),
                type: .miniapp,
                appId: mockMiniAppInfo.id
            )
        )
        let view = await MiniAppView(params: params)
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

        let params = MiniAppViewParameters.default(
            .init(
                config: MiniAppConfig(
                    config: nil,
                    messageDelegate: delegate
                ),
                type: .miniapp,
                appId: mockMiniAppInfo.id,
                version: mockMiniAppInfo.version.versionId
            )
        )
        let view = MiniAppView(params: params)
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

    func test_miniappview_info_load() {
        let expectation = XCTestExpectation(description: #function)

        let delegate = MockMessageInterface()
        let mockHandler = makeMockViewHandler(messageDelegate: delegate)

        let params = MiniAppViewParameters.info(
            .init(
                config: MiniAppConfig(
                    config: nil,
                    messageDelegate: delegate
                ),
                type: .miniapp,
                info: MiniAppInfo(
                    id: mockMiniAppInfo.id,
                    icon: URL(string: "https://www.rakuten.co.jp")!,
                    version: mockMiniAppInfo.version
                )
            )
        )
        let view = MiniAppView(params: params)
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

        let params = MiniAppViewParameters.default(
            .init(
                config: MiniAppConfig(
                    config: nil,
                    messageDelegate: messageDelegate
                ),
                type: .miniapp,
                appId: mockMiniAppInfo.id
            )
        )
        let view = MiniAppView(params: params)
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

    func test_miniappview_load_from_cache() {
        let downloadedExpectation = XCTestExpectation(description: "download")

        let delegate = MockMessageInterface()
        let mockHandler = makeMockViewHandler(messageDelegate: delegate)

        mockHandler.miniAppDownloader.verifyAndDownload(
            appId: mockMiniAppInfo.id,
            versionId: mockMiniAppInfo.version.versionId
        ) { (result) in
            switch result {
            case .success(let url):
                MiniAppLogger.d(url.absoluteString)
                downloadedExpectation.fulfill()
            case .failure(let error):
                MiniAppLogger.e("error", error)
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [downloadedExpectation], timeout: 10.0)

        let miniAppDirectory = FileManager.getMiniAppVersionDirectory(with: mockMiniAppInfo.id, and: mockMiniAppInfo.version.versionId)
        XCTAssertEqual(miniAppDirectory.pathComponents.last, mockMiniAppInfo.version.versionId)

        let expectation = XCTestExpectation(description: #function)

        let params = MiniAppViewParameters.default(
            .init(
                config: MiniAppConfig(
                    config: nil,
                    messageDelegate: delegate
                ),
                type: .miniapp,
                appId: mockMiniAppInfo.id,
                version: mockMiniAppInfo.version.versionId
            )
        )
        let view = MiniAppView(params: params)
        view.miniAppHandler = mockHandler

        view.load(fromCache: true) { result in
            switch result {
            case .success:
                XCTAssertTrue(true)
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func test_miniappview_load_from_cache_should_fail() {
        let expectation = XCTestExpectation(description: #function)
        let messageDelegate = MockMessageInterface()

        let params = MiniAppViewParameters.default(
            .init(
                config: MiniAppConfig(
                    config: nil,
                    messageDelegate: messageDelegate
                ),
                type: .miniapp,
                appId: mockMiniAppInfo.id
            )
        )
        let view = MiniAppView(params: params)
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

        let params = MiniAppViewParameters.url(
            .init(
                config: MiniAppConfig(
                    config: nil,
                    messageDelegate: messageDelegate
                ),
                type: .miniapp,
                url: URL(string: "http://localhost:1337")!
            )
        )
        let view = MiniAppView(params: params)
        view.load { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func test_miniappview_get_title() {
        let messageDelegate = MockMessageInterface()
        let params = MiniAppViewParameters.url(
            .init(
                config: MiniAppConfig(
                    config: nil,
                    messageDelegate: messageDelegate
                ),
                type: .miniapp,
                url: URL(string: "http://localhost:1337")!
            )
        )
        let view = MiniAppView(params: params)
        XCTAssertEqual(view.miniAppTitle, MiniAppSDKConstants.miniAppRootFolderName)

        view.miniAppHandler.title = "MiniApp (Test)"
        XCTAssertEqual(view.miniAppTitle, "MiniApp (Test)")
    }

    func test_miniappview_should_close_empty() {
        let messageDelegate = MockMessageInterface()
        let params = MiniAppViewParameters.url(
            .init(
                config: MiniAppConfig(
                    config: nil,
                    messageDelegate: messageDelegate
                ),
                type: .miniapp,
                url: URL(string: "http://localhost:1337")!
            )
        )
        let view = MiniAppView(params: params)
        XCTAssertTrue(view.alertInfo == nil)
    }

    func test_miniappviewable_load() {

        let messageDelegate = MockMessageInterface()
        let params = MiniAppViewParameters.url(
            .init(
                config: MiniAppConfig(
                    config: nil,
                    messageDelegate: messageDelegate
                ),
                type: .miniapp,
                url: URL(string: "http://localhost:1337")!
            )
        )
        let view: MiniAppViewable = MiniAppView(params: params)

        let expectation = XCTestExpectation(description: #function)
        view.load { result in
            switch result {
            case .success:
                expectation.fulfill()
            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func test_miniappviewable_load_async() {
        let messageDelegate = MockMessageInterface()
        let params = MiniAppViewParameters.url(
            .init(
                config: MiniAppConfig(
                    config: nil,
                    messageDelegate: messageDelegate
                ),
                type: .miniapp,
                url: URL(string: "http://localhost:1337")!
            )
        )
        let view: MiniAppViewable = MiniAppView(params: params)

        let expectation = XCTestExpectation(description: #function)
        Task {
            do {
                try await view.loadAsync()
                expectation.fulfill()
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
        wait(for: [expectation], timeout: 10.0)
    }
    
    func test_sendJsonToMiniApp(){
        let messageDelegate = MockMessageInterface()
        let mockHandler = makeMockViewHandler(messageDelegate: messageDelegate)
        let params = MiniAppViewParameters.default(
            .init(
                config: MiniAppConfig(
                    config: nil,
                    messageDelegate: messageDelegate
                ),
                type: .miniapp,
                appId: mockMiniAppInfo.id
            )
        )
        let view = MiniAppView(params: params)
        view.miniAppHandler = mockHandler
        view.sendJsonToMiniApp(string: "Test send json to miniapp")
        XCTAssertEqual(mockHandler.messageBodies.count, 1)
    }
}

extension MiniAppViewTests {
    func makeMockViewHandler(messageDelegate: MiniAppMessageDelegate) -> MiniAppViewHandler {
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

        return viewHandler
    }
}
