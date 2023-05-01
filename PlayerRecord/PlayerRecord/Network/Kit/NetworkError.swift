//
//  NetworkError.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/24.
//

import Foundation

public enum NetworkError: Error {
    public enum MultipartEncodingFailureReason {
        case bodyPartURLInvalid(url: URL)
    }
    
    public enum ParameterEncodingFailureReason {
        case missingURL
        case jsonEncodingFailed(error: Error)
        case customEncodingFailed(error: Error)
    }
    
    case multipartEncodingFailed(reason: MultipartEncodingFailureReason)
    case parameterEncodingFailed(reason: ParameterEncodingFailureReason)
    case explicitlyCancelled
    case invalidURL(url: URLConvertible)
    case requestMapping(String)
    case encodableMapping(Swift.Error)
//    case underlying(Swift.Error, Response?)
}


extension Error {
    public var asNetworkError: NetworkError? {
        self as? NetworkError
    }
    
    public func asNetworkError(orFailWith message: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> NetworkError {
        guard let networkError = self as? NetworkError else {
            fatalError(message(), file: file, line: line)
        }
        return networkError
    }
    
    func asNetworkError(or defaultNetworkError: @autoclosure () -> NetworkError) -> NetworkError {
        self as? NetworkError ?? defaultNetworkError()
    }
}

extension NetworkError {
    public var multipartEncodingError: Bool {
        if case .multipartEncodingFailed = self { return true }
        return false
    }
    
    public var parameterEncodingError: Bool {
        if case .parameterEncodingFailed = self { return true }
        return false
    }
}

// MARK: - Convenience Properties

extension NetworkError {
    public var isInvalidURLError: Bool {
        if case .invalidURL = self { return true }
        return false
    }
    
    public var urlConvertible: URLConvertible? {
        guard case let .invalidURL(url) = self else { return nil }
        return url
    }
    
    public var url: URL? {
        guard case let .multipartEncodingFailed(reason) = self else { return nil }
        return reason.url
    }
    
    public var underlyingError: Error? {
        switch self {
        case let .multipartEncodingFailed(reason):
            return reason.underlyingError
        case let .parameterEncodingFailed(reason):
            return reason.underlyingError
        case .explicitlyCancelled,
             .invalidURL,
             .encodableMapping,
             .requestMapping:
            return nil
        }
    }
}

extension NetworkError.MultipartEncodingFailureReason {
    var url: URL? {
        switch self {
        case let .bodyPartURLInvalid(url):
            return url
        }
    }
    
    var underlyingError: Error? {
        switch self {
        case .bodyPartURLInvalid:
            return nil
        }
    }
}

extension NetworkError.ParameterEncodingFailureReason {
    var underlyingError: Error? {
        switch self {
            case let.jsonEncodingFailed(error),
                 let.customEncodingFailed(error):
                return error
            case .missingURL:
                return nil
        }
    }
}

// MARK: - Error Descriptions

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .multipartEncodingFailed(reason):
            return reason.localizedDescription
        case let .parameterEncodingFailed(reason):
            return reason.localizedDescription
        case .explicitlyCancelled:
            return "Request explicitly cancelled."
        case let .invalidURL(url):
            return "URL is not valid: \(url)"
        case .requestMapping:
            return "Failed to map Endpoint to a URLRequest."
        case .encodableMapping:
            return "Failed to encode Encodable object into data."
        }
    }
}

extension NetworkError.MultipartEncodingFailureReason {
    var localizedDescription: String {
        switch self {
        case let .bodyPartURLInvalid(url):
            return "The URL Provided is not a file URL: \(url)"
        }
    }
}

extension NetworkError.ParameterEncodingFailureReason {
    var localizedDescription: String {
        switch self {
        case .missingURL:
            return "URL request to encode was missing a URL"
        case let .jsonEncodingFailed(error):
            return "JSON could not be encoded because of error:\n\(error.localizedDescription)"
        case let .customEncodingFailed(error):
            return "Custom parameter encoder failed with error: \(error.localizedDescription)"
        }
    }
}
