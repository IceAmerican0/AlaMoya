//
//  API.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/18.
//

import Foundation
import Combine

private let LOLToken = ""
private let VALToken = ""

public typealias Parameters = [String:Any]
public typealias RequestModifier = (inout URLRequest) throws -> Void
public typealias ValidationResult = Result<Void, Error>

public class API {
    
    struct RequestConvertible: URLRequestConvertible {
        let url: URLConvertible
        let parameters: Parameters?
        let headers: HTTPHeaders?
        let encoding: ParameterEncoding
        let requestModifier: RequestModifier?
        
        func asURLRequest() throws -> URLRequest {
            var request = try URLRequest(url: url, headers: headers)
            try requestModifier?(&request)

            return try encoding.encode(request, with: parameters)
        }
    }
    
    public func request(url: URL) {
        var urlRequest: URLRequest
        do {
            urlRequest = try URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            urlRequest.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
            urlRequest.setValue(LOLToken, forHTTPHeaderField: "X-Riot-Token")
        } catch {
            return
        }
    }
    
    public func requestWithCombine(url: String) -> AnyPublisher<String, NetworkError> {
        let url = URL(string: url)
        Just(url)
            .setFailureType(to: NetworkError)
            .flatMap { url -> AnyPublisher<Data, NetworkError> in
                let (data, _, error) = URLSession.shared.synchronousDataTask(with: url)
                if let error = error {
                    return Fail(error: error)
                        .eraseToAnyPublisher()
                } else if let data = data {
                    return Just(data)
                        .setFailureType(to: error)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: error.description)
                        .eraseToAnyPublisher()
                }
            }
            .flatMap { data -> AnyPublisher<Data, NetworkError> in
                guard let response = try? JSONDecoder().decode(LOLPlayerStatsModel, from: data) else {
                    return Fail(error: Error.eraseToAnyPublisher())
                }
            }
            
    }
    
}

public protocol URLConvertible {
    func asURL() throws -> URL
}

extension String: URLConvertible {
    public func asURL() throws -> URL {
        let error: Error
        guard let url = URL(string: self) else { throw error }

        return url
    }
}

public protocol URLRequestConvertible {
    func asURLRequest() throws -> URLRequest
}

extension URLRequestConvertible {
    public var urlRequest: URLRequest? { try? asURLRequest() }
}

extension URLRequest: URLRequestConvertible {
    public func asURLRequest() throws -> URLRequest { self }
}

extension URLRequest {
    public init(url: URLConvertible, headers: HTTPHeaders? = nil) throws {
        let url = try url.asURL()
        
        self.init(url: url)
        
        httpMethod = "GET"
        allHTTPHeaderFields = headers?.dictionary
    }
}
