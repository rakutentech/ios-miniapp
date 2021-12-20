import Foundation

internal class PreviewMiniappAPI {
    let environment: Environment

    init(with environment: Environment) {
        self.environment = environment
    }

    func createURLRequest(previewToken: String) -> URLRequest? {
        guard let url = getMiniAppInfo(using: previewToken) else {
            return nil
        }
        return URLRequest.createURLRequest(url: url, environment: environment)
    }

    private func getMiniAppInfo(using token: String) -> URL? {
        guard let baseURL = environment.baseUrl else {
            return nil
        }
        return baseURL.appendingPathComponent("host/\(environment.projectId)/preview-codes/\(token)")
    }
}
