import Foundation

public enum MiniAppSecureStorageError: MiniAppErrorProtocol, Equatable {

    case storageFullError
    case storageIOError
    case storageUnvailable
    case storageBusy

    var name: String {
        switch self {
        case .storageFullError:
            return "SecureStorageFullError"
        case .storageIOError:
            return "SecureStorageIOError"
        case .storageUnvailable:
            return "SecureStorageUnavailableError"
        case .storageBusy:
            return "SecureStorageBusyError"
        }
    }

    var description: String {
        switch self {
        case .storageFullError:
            return "Storage size exceeded"
        case .storageIOError:
            return "IO or unknown error occured"
        case .storageUnvailable:
            return "StorageUnavailable"
        case .storageBusy:
            return "UnavailableItem"
        }
    }
}
