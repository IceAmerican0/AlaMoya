//
//  NetworkError.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/24.
//

import Foundation

public enum NetworkError: Error {
    public enum ParameterEncodingFailureReason {
        case missingURL
        case jsonEncodingFailed(error: Error)
        case customEncodingFailed(error: Error)
    }
    
    case parameterEncodingFailed(reason: ParameterEncodingFailureReason)
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

extension Error {
    public var asNetworkError: NetworkError? {
        self as? NetworkError
    }
}

extension NetworkError {
    public var parameterEncodingError: Bool {
        if case .parameterEncodingFailed = self { return true }
        return false
    }
}

extension NetworkError {
    public var underlyingError: Error? {
        switch self {
        case let .parameterEncodingFailed(reason):
            return reason.underlyingError
        }
    }
}
