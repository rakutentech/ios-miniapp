internal let defaultMimeType = "text/html"

internal let mimeTypes = [
    "html": "text/html",
    "htm": "text/html",
    "css": "text/css",
    "gif": "image/gif",
    "jpeg": "image/jpeg",
    "jpg": "image/jpeg",
    "png": "image/png",
    "svg": "image/svg+xml",
    "svgz": "image/svg+xml",
    "mp3": "audio/mpeg",
    "mpeg": "video/mpeg",
    "mpg": "video/mpeg",
    "js": "application/javascript",
    "json": "application/json"
]

internal func getMimeType(ext: String?) -> String {
    if ext != nil && mimeTypes.contains(where: { $0.0 == ext!.lowercased() }) {
        return mimeTypes[ext!.lowercased()]!
    }
    return defaultMimeType
}

extension String {
    public func mimeType() -> String {
        return getMimeType(ext: self)
    }
}
