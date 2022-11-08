import Foundation
import SwiftUI
import MiniApp

private struct MiniAppStoreKey: EnvironmentKey {
    static var defaultValue: MiniAppStore { .empty() }
}

extension EnvironmentValues {
    var appStore: MiniAppStore {
        get { self[MiniAppStoreKey.self] }
        set { self[MiniAppStoreKey.self] = newValue }
    }
}

class MiniAppStore: ObservableObject {

    static let shared = MiniAppStore()

    @AppStorage("MiniApp.FirstLaunch") var miniAppFirstLaunch = false
    @AppStorage("MiniApp.SetupCompleted") var miniAppSetupCompleted = false

    @AppStorage("QA_CUSTOM_ACCESS_TOKEN_ERROR_MESSAGE") var accessTokenErrorMessage = ""
    @AppStorage("QA_CUSTOM_ACCESS_TOKEN_ERROR_TYPE") var accessTokenErrorBehavior = ""

    @AppStorage(Config.GlobalKey.signatureVerification.rawValue) var signatureVerification: Bool?

    @Published var miniAppInfoList: [MiniAppInfo] = []
    @Published var miniAppInfoListError: Error?
    @Published var miniAppInfoList2: [MiniAppInfo] = []
    @Published var miniAppInfoList2Error: Error?

    private init() {
        if !miniAppFirstLaunch {
            setupUserDefaults()
            miniAppFirstLaunch = true
        }
    }

    func setupUserDefaults() {
        // points
        _ = saveUserPoints(pointsModel: UserPointsModel(standardPoints: 10, termPoints: 20, cashPoints: 30))

        // contacts
        let randomList: [MAContact] = (0..<10).map({ _ in
            let fakeName = Self.randomFakeName()
            return MAContact(id: UUID().uuidString, name: fakeName, email: Self.fakeMail(with: fakeName))
        })
        updateContactList(list: randomList)

        // profile
        let defaultImage = UIImage(named: "default_profile_picture")?.dataURI()
        _ = setProfileSettings(userDisplayName: "MiniAppUser", profileImageURI: defaultImage)
    }

    func load(type: ListType) {
        let sdkConfig = ListConfiguration.current(type: type)
        MiniApp
            .shared(with: sdkConfig)
            .list { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(infos):
                        switch type {
                        case .listI:
                            self.miniAppInfoList = infos
                        case .listII:
                            self.miniAppInfoList2 = infos
                        }
                    case let .failure(error):
                        print(error)
                    }
                }
            }
    }

    func update(type: ListType, infos: [MiniAppInfo]) {
        switch type {
        case .listI:
            miniAppInfoList = infos
        case .listII:
            miniAppInfoList2 = infos
        }
    }

    func hasError(type: ListType) -> Bool {
        switch type {
        case .listI:
            return miniAppInfoListError != nil
        case .listII:
            return miniAppInfoList2Error != nil
        }
    }

    static func empty() -> MiniAppStore {
        return MiniAppStore()
    }

    func clearSecureStorages() {
        MiniApp.shared().clearAllSecureStorage()
    }

    func clearSecureStorage(appId: String) {
        MiniApp.shared().clearSecureStorage(for: appId)
    }

    func getSecureStorageLimit() -> UInt64 {
        return UInt64(Config.int(.maxSecureStorageFileLimit) ?? 5_000_000)
    }

    func getSecureStorageLimitString() -> String {
        let maxSecureStorageLimit = Config.int(.maxSecureStorageFileLimit) ?? 5_000_000
        if maxSecureStorageLimit > 0 {
            return storageLimitFormatter.string(from: NSNumber(value: maxSecureStorageLimit)) ?? ""
        }
        return ""
    }

    func setSecureStorageLimit(maxSize: String) -> Result<String, StoreError> {
        guard
            let textNumber = storageLimitFormatter.number(from: maxSize),
            let textIntString = storageLimitFormatter.string(from: textNumber)
        else {
            return .failure(StoreError.invalidFormat)
        }
        let textInt = Int(truncating: textNumber)

        Config.setInt(key: .maxSecureStorageFileLimit, value: textInt)

        return .success(textIntString)
    }

    let storageLimitFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.decimalSeparator = "."
        return numberFormatter
    }()

    // random generator
    class func fakeMail(with name: String?) -> String {
        name != nil ? name!.replacingOccurrences(of: " ", with: ".", options: .literal, range: nil).lowercased() + "@example.com" : ""
    }

    class func randomFakeName() -> String {
        randomFakeFirstName() + " " + randomFakeLastName()
    }

    class func randomFakeFirstName() -> String {
        let firstNameList = ["Yvonne", "Jamie", "Leticia", "Priscilla", "Sidney", "Nancy", "Edmund", "Bill", "Megan"]
        return firstNameList.randomElement()!
    }

    class func randomFakeLastName() -> String {
        let lastNameList = ["Andrews", "Casey", "Gross", "Lane", "Thomas", "Patrick", "Strickland", "Nicolas", "Freeman"]
        return lastNameList.randomElement()!
    }

    func createRandomContact() -> MAContact {
        let fakeName = Self.randomFakeName()
        return MAContact(id: UUID().uuidString, name: fakeName, email: Self.fakeMail(with: fakeName))
    }

    func getMiniAppPreviewInfo(previewToken: String) async throws -> MiniAppInfo? {
        try await withCheckedThrowingContinuation { continuation in
            MiniApp.shared().getMiniAppPreviewInfo(using: previewToken) { result in
                switch result {
                case let .success(previewInfo):
                    // may need to add host support through qr code
                    continuation.resume(returning: previewInfo.miniapp)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func getMiniAppInfo(miniAppId: String) async throws -> MiniAppInfo? {
        try await withCheckedThrowingContinuation { continuation in
            MiniApp.shared().info(miniAppId: miniAppId) { result in
                switch result {
                case let .success(info):
                    // may need to add host support through qr code
                    continuation.resume(returning: info)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension MiniAppStore {
    enum Constants: String {
        case miniAppIdentifierSingle = "kMiniAppIdentifierSingle"
        case miniAppVersionSingle = "kMiniAppVersionSingle"
        case miniAppIdentifierTrippleFirst = "kMiniAppIdentifierTrippleFirst"
        case miniAppVersionTrippleFirst = "kMiniAppVersionTrippleFirst"
        case miniAppIdentifierTrippleSecond = "kMiniAppIdentifierTrippleSecond"
        case miniAppVersionTrippleSecond = "kMiniAppVersionTrippleSecond"
        case miniAppIdentifierTrippleThird = "kMiniAppIdentifierTrippleThird"
        case miniAppVersionTrippleThird = "kMiniAppVersionTrippleThird"
    }

    enum StoreError: Error {
        case invalidFormat

        var title: String {
            return "Error"
        }

        var message: String {
            switch self {
            case .invalidFormat:
                return "Invalid format provided."
            }
        }
    }
}
