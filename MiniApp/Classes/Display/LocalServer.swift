import Telegraph

class LocalServer: NSObject {
    var identity: CertificateIdentity?
    var caCertificate: Certificate?
    var tlsPolicy: TLSPolicy?
    var localServerPreferences: MiniAppLocalServerPreferences?
    var server: Server?
    var appId: String?

    override init() {
        localServerPreferences = MiniAppLocalServerPreferences()
    }

    func startServer(appId: String, versionId: String, isSecure: Bool) {
        self.appId = appId

        if isSecure {
            loadCertificates(p12CertificateName: "Certificates", caCertificateName: "miniapp-server")
        }
        if isSecure, let identity = identity, let caCertificate = caCertificate {
            server = Server(identity: identity, caCertificates: [caCertificate])
        } else {
            server = Server()
        }
        server?.serveDirectory(serveMiniAppDirectory(appId: appId, versionId: versionId), "/\(versionId)")
        server?.concurrency = 4
        do {
            try server?.start(port: (localServerPreferences?.getPortNumberForMiniApp(key: appId))!, interface: nil)
        } catch let serverError {
            print("Error: ", serverError)
        }
    }

    func stopServer() {
        server?.stop(immediately: true)
    }

    private func loadCertificates(p12CertificateName: String, caCertificateName: String) {
        // Load the P12 identity package from the bundle
        let bundle = Bundle(for: MiniApp.self)
        guard let identityURL = bundle.url(forResource: p12CertificateName, withExtension: "p12") else {
            return
        }
        identity = CertificateIdentity(p12URL: identityURL, passphrase: "miniapp@13july")
        guard let caCertificateURL = bundle.url(forResource: caCertificateName, withExtension: "der") else {
            return
        }
        caCertificate = Certificate(derURL: caCertificateURL)
        if let caCertificate = caCertificate {
            tlsPolicy = TLSPolicy(commonName: "Rakuten Inc", certificates: [caCertificate])
        }
    }

    func serveMiniAppDirectory(appId: String, versionId: String) -> URL {
        return FileManager.getMiniAppVersionDirectory(with: appId, and: versionId)
    }
}

extension LocalServer {
    func serverURL(path: String = "") -> URL {
        savePortInPreferences(portNumber: Int(server!.port))
        var components = URLComponents()
        components.scheme = server?.isSecure ?? false ? "https" : "http"
        components.host = "localhost"
        components.port = Int(server!.port)
        components.path = path
        return components.url!
    }

    func savePortInPreferences(portNumber: Int) {
        guard let appId = self.appId else {
            return
        }
        localServerPreferences?.savePortNumberForMiniApp(appId: appId, portNumber: portNumber)
    }
}
