//
//  URLRequest+Encoding.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/27.
//

import Foundation

internal extension URLRequest {
    mutating func encoded(encodable: Encodable, encoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        do {
            let encodable = AnyEncodable(encodable)
            httpBody = try encoder.encode(encodable)
            
            let contentTypeHeaderName = "Content-Type"
            if value(forHTTPHeaderField: contentTypeHeaderName) == nil {
                setValue("application/json", forHTTPHeaderField: contentTypeHeaderName)
            }
            
            return self
        } catch {
            throw NetworkError.encodableMapping(error)
        }
    }
}

extension URLRequest {
    public var method: HTTPMethod? {
        get { httpMethod.flatMap(HTTPMethod.init) }
        set { httpMethod = newValue?.rawValue }
    }
    
    public func validate() throws {
        if method == .get, let bodyData = httpBody {
            throw NetworkError.urlRequestValidationFailed(reason: .bodyDataInGETRequest(bodyData))
        }
    }
}
