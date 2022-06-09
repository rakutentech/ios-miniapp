import Foundation

enum MiniAppSecureStorageError: MiniAppErrorProtocol, Equatable {

    case storageFullError
    case storageIOError
    case storageUnavailable

    var name: String {
        switch self {
        case .storageFullError:
            return "SecureStorageFullError"
        case .storageIOError:
            return "SecureStorageIOError"
        case .storageUnavailable:
            return "SecureStorageUnavailableError"
        }
    }

    var description: String {
        switch self {
        case .storageFullError:
            return "Storage size exceeded"
        case .storageIOError:
            return "IO Error"
        case .storageUnavailable:
            return "Storage not available"
        }
    }
}
