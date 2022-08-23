import Foundation
import XCTest
@testable import MiniApp


class MiniAppViewTests: XCTestCase {

    enum TestError: Error {
        case storageShouldNotExist
    }

    // MARK: - Setup
    func test_miniappview_load_async_should_fail() async throws {
        let view = await MiniAppView(
            config: MiniAppNewConfig(
                config: nil,
                messageInterface: makeMockMessageDelegate(miniAppId: "miniapp-1234", miniAppVersion: nil)
            ),
            type: .miniapp,
            appId: "miniapp-1234"
        )
        do {
            _ = try await view.loadAsync()
            XCTFail("should not load with invalid miniapp id")
        } catch {
            XCTAssertTrue(error.localizedDescription.contains("400"))
        }
    }

    func test_miniappview_load_should_fail() {
        let expectation = XCTestExpectation(description: #function)
        
        let view = MiniAppView(
            config: MiniAppNewConfig(
                config: nil,
                messageInterface: makeMockMessageDelegate(miniAppId: "miniapp-1234", miniAppVersion: nil)
            ),
            type: .miniapp,
            appId: "miniapp-1234"
        )
        view.load { result in
            switch result {
            case .success:
                XCTFail("should not succeed")
            case let .failure(error):
                XCTAssertTrue(error.localizedDescription.contains("400"))
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }

    func test_miniappview_load_from_cache_should_fail() {
        let expectation = XCTestExpectation(description: #function)
        
        let view = MiniAppView(
            config: MiniAppNewConfig(
                config: nil,
                messageInterface: makeMockMessageDelegate(miniAppId: "miniapp-1234", miniAppVersion: nil)
            ),
            type: .miniapp,
            appId: "miniapp-1234"
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
        
        let view = MiniAppView(
            config: MiniAppNewConfig(
                config: nil,
                messageInterface: makeMockMessageDelegate(miniAppId: "miniapp-1234", miniAppVersion: nil)
            ),
            type: .miniapp,
            url: URL(string: "http://localhost:1337")!
        )
        view.load { result in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10.0)
    }
}

extension MiniAppViewTests {

    func makeMockMessageDelegate(miniAppId: String, miniAppVersion: String? = nil) -> MiniAppMessageDelegate {
        return MockDelegate(miniAppId: miniAppId, miniAppVersion: miniAppVersion)
    }
    class MockDelegate: MiniAppMessageDelegate {
        var miniAppId: String
        var miniAppVersion: String?

        var onSendMessage: (() -> Void)?

        init(miniAppId: String = "", miniAppVersion: String? = nil) {
            self.miniAppId = miniAppId
            self.miniAppVersion = miniAppVersion
        }

        func getUniqueId(completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
            completionHandler(.success("MAUID-\(miniAppId.prefix(8))-\((miniAppVersion ?? "").prefix(8))"))
        }

        func downloadFile(fileName: String, url: String, headers: DownloadHeaders, completionHandler: @escaping (Result<String, MASDKDownloadFileError>) -> Void) {
            //
        }

        func sendMessageToContact(_ message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
            onSendMessage?()
        }

        func sendMessageToContactId(_ contactId: String, message: MessageToContact, completionHandler: @escaping (Result<String?, MASDKError>) -> Void) {
            //
        }

        func sendMessageToMultipleContacts(_ message: MessageToContact, completionHandler: @escaping (Result<[String]?, MASDKError>) -> Void) {
            onSendMessage?()
        }

        func getContacts(completionHandler: @escaping (Result<[MAContact]?, MASDKError>) -> Void) {
            if miniAppId.starts(with: "404") {
                completionHandler(.success([
                    MAContact(id: "1", name: "John Doe", email: "joh@doe.com")
                ]))
                return
            } else if miniAppId.starts(with: "21f") {
                completionHandler(.success([
                    MAContact(id: "1", name: "Steve Jops", email: "steve@appl.com")
                ]))
                return
            }
            completionHandler(.failure(.unknownError(domain: "", code: 0, description: "no contacts")))
            return
        }

        func getPoints(completionHandler: @escaping (Result<MAPoints, MASDKPointError>) -> Void) {
            completionHandler(.success(MAPoints(standard: 0, term: 0, cash: 0)))
        }

        func requestCustomPermissions(permissions: [MASDKCustomPermissionModel], miniAppTitle: String, completionHandler: @escaping (Result<[MASDKCustomPermissionModel], MASDKCustomPermissionError>) -> Void) {
            completionHandler(.failure(.userDenied))
        }
    }
}
