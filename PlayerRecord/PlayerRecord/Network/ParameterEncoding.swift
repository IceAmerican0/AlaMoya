//
//  ParameterEncoding.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/24.
//

import Foundation

public protocol ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest
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
