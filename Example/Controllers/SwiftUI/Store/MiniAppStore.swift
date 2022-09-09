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

    var testString: String = "lul"

    @AppStorage("MiniApp.FirstLaunch") var miniAppFirstLaunch = false
    @AppStorage("MiniApp.SetupCompleted") var miniAppSetupCompleted = false

    @AppStorage(Constants.miniAppIdentifierSingle.rawValue) var miniAppIdentifierSingle = ""
    @AppStorage(Constants.miniAppVersionSingle.rawValue) var miniAppVersionSingle = ""

    @AppStorage(Constants.miniAppIdentifierTrippleFirst.rawValue) var miniAppIdentifierTrippleFirst = ""
    @AppStorage(Constants.miniAppVersionTrippleFirst.rawValue) var miniAppVersionTrippleFirst = ""

    @AppStorage(Constants.miniAppIdentifierTrippleSecond.rawValue) var miniAppIdentifierTrippleSecond = ""
    @AppStorage(Constants.miniAppVersionTrippleSecond.rawValue) var miniAppVersionTrippleSecond = ""

    @AppStorage(Constants.miniAppIdentifierTrippleThird.rawValue) var miniAppIdentifierTrippleThird = ""
    @AppStorage(Constants.miniAppVersionTrippleThird.rawValue) var miniAppVersionTrippleThird = ""

    @AppStorage(wrappedValue: "", Constants.miniAppIdentifierSingle.rawValue, store: UserDefaults(suiteName: ""))
    var miniAppProdProjectId: String

    @AppStorage(wrappedValue: "", Constants.miniAppIdentifierSingle.rawValue, store: UserDefaults(suiteName: ""))
    var miniAppProdSubscriptionKey: String

    @AppStorage(wrappedValue: "", Constants.miniAppIdentifierSingle.rawValue, store: UserDefaults(suiteName: ""))
    var miniAppProdProjectIdList2: String

    @AppStorage(wrappedValue: "", Constants.miniAppIdentifierSingle.rawValue, store: UserDefaults(suiteName: ""))
    var miniAppProdSubscriptionKeyList2: String

    @Published
    var miniAppInfoList: [MiniAppInfo] = []

    @Published
    var indexedMiniAppInfoList: [String: [MiniAppInfo]] = [:]

    @Published
    var indexedMiniAppInfoList2: [String: [MiniAppInfo]] = [:]

    init() {
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

    func load(type: MiniAppListViewType) {
        switch type {
        case .listI:
            MiniApp.shared().list { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(infos):
                        self.miniAppInfoList = infos

                        let ids = Set<String>(infos.map({ $0.id }))
                        for id in ids {
                            self.indexedMiniAppInfoList[id] = infos.filter({ $0.id == id })
                        }
                    case let .failure(error):
                        print(error)
                    }
                }
            }
        case .listII:
            let list2Config = MiniAppSdkConfig(
                rasProjectId: Config.getUserDefaultsString(key: .projectIdList2),
                subscriptionKey: Config.getUserDefaultsString(key: .subscriptionKeyList2)
            )
            MiniApp.shared(with: list2Config).list { result in
                DispatchQueue.main.async {
                    switch result {
                    case let .success(infos):
                        //self.miniAppInfoList = infos

                        let ids = Set<String>(infos.map({ $0.id }))
                        for id in ids {
                            self.indexedMiniAppInfoList2[id] = infos.filter({ $0.id == id })
                        }
                    case let .failure(error):
                        print(error)
                    }
                }
            }
        }
    }

    func update(type: MiniAppListViewType, infos: [MiniAppInfo]) {
        switch type {
        case .listI:
            indexedMiniAppInfoList.removeAll()
            let ids = Set<String>(infos.map({ $0.id }))
            for id in ids {
                self.indexedMiniAppInfoList[id] = infos.filter({ $0.id == id })
            }
        case .listII:
            indexedMiniAppInfoList2.removeAll()
            let ids = Set<String>(infos.map({ $0.id }))
            for id in ids {
                self.indexedMiniAppInfoList2[id] = infos.filter({ $0.id == id })
            }
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
        return UInt64(UserDefaults.standard.integer(forKey: Config.LocalKey.maxSecureStorageFileLimit.rawValue))
    }

    func getSecureStorageLimitString() -> String {
        let maxSecureStorageLimit = UserDefaults.standard.integer(forKey: Config.LocalKey.maxSecureStorageFileLimit.rawValue)
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

        UserDefaults.standard.set(textInt, forKey: Config.LocalKey.maxSecureStorageFileLimit.rawValue)
        UserDefaults.standard.synchronize()

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
