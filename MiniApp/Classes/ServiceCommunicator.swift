/**
 * Enum for ServiceCommunicator protocol for HTTP methods.
 */
enum HttpMethod: String {
    case post
    case get
    case delete
    case put

    var stringValue: String {
        switch self {
        case .post:
            return "POST"
        case .get:
            return "GET"
        case .delete:
            return "DELETE"
        case .put:
            return "PUT"
        }
    }
}

/**
 * Protocol that is conformed to when a class requires HTTP communication abilities.
 */
protocol ServiceCommunicatorProtocol {
    /**
     *  Method for calling an API.
     * @param { url: String } the URL of the API to call.
     * @param { httpMethod: String } the HTTP method used. E.G "POST" / "GET"
     * @param { shouldWait: Bool } whether or not should the program wait for the response before continuing execution.
     * @returns { data: Data?, response: HTTPURLResponse? } returns optional data and optional HTTPURLResponse.
     */
    func requestFromServer(withUrl url: URL,
                           withHttpMethod httpMethod: HttpMethod,
                           withSemaphoreWait shouldWait: Bool) -> (data: Data?, response: HTTPURLResponse?)
}

struct ServiceCommunicator: ServiceCommunicatorProtocol {
    func requestFromServer(withUrl url: URL,
                           withHttpMethod httpMethod: HttpMethod,
                           withSemaphoreWait shouldWait: Bool) -> (data: Data?, response: HTTPURLResponse?) {

        var responseBody: Data?
        var metadata: HTTPURLResponse?

        // Add in the HTTP headers and body.
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.stringValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Semaphore added for synchronous HTTP calls.
        let semaphore = DispatchSemaphore(value: 0)

        // Start HTTP call.
        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in

            if let err = error {
                #if DEBUG
                    print("MiniAppSDK: \(err)")
                #endif
                return
            }

            guard let data = data,
                let response = response as? HTTPURLResponse
                else {
                    #if DEBUG
                        print("MiniAppSDK: HTTP call failed.")
                    #endif
                    semaphore.signal()
                    return
            }

            responseBody = data
            metadata = response

            // Signal completion of HTTP request.
            semaphore.signal()
        }).resume()

        // Pause execution until signal() is called
        // if the request requires the response to act on.
        if shouldWait {
            semaphore.wait()
        }

        return (responseBody, metadata)
    }
}
