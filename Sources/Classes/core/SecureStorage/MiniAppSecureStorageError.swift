import Foundation

public enum MiniAppSecureStorageError: MiniAppErrorProtocol, Equatable {

    case storageFullError
    case storageIOError
    case storageUnvailable

    var name: String {
        switch self {
        case .storageFullError:
            return "SecureStorageFullError"
        case .storageIOError:
            return "SecureStorageIOError"
        case .storageUnvailable:
            return "SecureStorageUnavailableError"
        }
    }

    var description: String {
        switch self {
        case .storageFullError:
            return "Storage size exceeded"
        case .storageIOError:
            return "IO Error"
        case .storageUnvailable:
            return "Storage not available"
        }
    }
}
