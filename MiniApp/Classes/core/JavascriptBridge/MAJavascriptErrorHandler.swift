func prepareJSONString<T: Codable>(_ value: T) -> String {
    let encoder = JSONEncoder()
    do {
        let jsonData = try encoder.encode(value)
        return String(data: jsonData, encoding: .utf8) ?? prepareMAJavascriptError(MiniAppErrorType.unknownError)
    } catch {
        MiniAppLogger.e("JSON Parsing Error: \(error.localizedDescription)")
        return error.localizedDescription
    }
}

func getMiniAppErrorMessage<T: MiniAppErrorProtocol>(_ error: T) -> String {
    "\(error.name): \(error.description)"
}

/// Method to send in error in proper format i.e {type: "SomeError", message: "message"}
func prepareMAJavascriptError<T: MiniAppErrorProtocol>(_ error: T) -> String {
    guard !error.name.isEmpty else {
        return prepareJSONString(MAJavascriptErrorModel(type: nil, message: error.description))
    }
    guard !error.description.isEmpty else {
        return prepareJSONString(MAJavascriptErrorModel(type: error.name, message: nil))
    }
    return prepareJSONString(MAJavascriptErrorModel(type: error.name, message: error.description))
}
