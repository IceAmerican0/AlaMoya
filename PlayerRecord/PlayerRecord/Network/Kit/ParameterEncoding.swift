//
//  ParameterEncoding.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/24.
//

import Foundation

public typealias Parameters = [String: Any]

public protocol ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest
}

public struct URLEncoding: ParameterEncoding {
    public enum Destination {
        case methodDependent
        case queryString
        case httpBody
        
        func encodesParametersInURL(for method: HTTPMethod) -> Bool {
            switch self {
            case .methodDependent: return [.get, .head, .delete].contains(method)
            case .queryString: return true
            case .httpBody: return false
            }
        }
    }
    
    public enum ArrayEncoding {
        case brackets
        case noBrackets
        case indexInBarckets
        
        func encode(key: String, atIndex index: Int) -> String {
            switch self {
            case .brackets:
                return "\(key)[]"
            case .noBrackets:
                return key
            case .indexInBarckets:
                return "\(key)[\(index)]"
            }
        }
    }
    
    public enum BoolEncoding {
        case numeric
        case literal
        
        func encode(value: Bool) -> String {
            switch self {
            case .numeric:
                return value ? "1" : "0"
            case .literal:
                return value ? "true" : "false"
            }
        }
    }
    
    public static var `default`: URLEncoding { URLEncoding() }
    public static var queryString: URLEncoding { URLEncoding(destination: .queryString) }
    public static var httpBody: URLEncoding { URLEncoding(destination: .httpBody) }
    public let destination: Destination
    public let arrayEncoding: ArrayEncoding
    public let boolEncoding: BoolEncoding
    
    public init(destination: Destination = .methodDependent,
                arrayEncoding: ArrayEncoding = .brackets,
                boolEncoding: BoolEncoding = .numeric) {
        self.destination = destination
        self.arrayEncoding = arrayEncoding
        self.boolEncoding = boolEncoding
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        guard let parameters else { return urlRequest }
        
        if let method = urlRequest.method, destination.encodesParametersInURL(for: method) {
            guard let url = urlRequest.url else {
                throw NetworkError.parameterEncodingFailed(reason: .missingURL)
            }
            
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                urlRequest.url = urlComponents.url
            }
        } else {
            if urlRequest.headers["Content-Type"] == nil {
                urlRequest.httpBody = Data(query(parameters).utf8)
            }
        }
        
        return urlRequest
    }
}

public struct JSONEncoding: ParameterEncoding {
    public enum Error: Swift.Error {
        case invalidJSONObject
    }
    
    public static var `default`: JSONEncoding { JSONEncoding() }
    
    public let options: JSONSerialization.WritingOptions
    
    public static var prettyPrinted: JSONEncoding { JSONEncoding(options: .prettyPrinted) }
    
    public init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        guard let parameters = parameters else { return urlRequest }
        
        guard JSONSerialization.isValidJSONObject(parameters) else {
            throw NetworkError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: Error.invalidJSONObject))
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: options)
        }
        
        return urlRequest
    }
}
