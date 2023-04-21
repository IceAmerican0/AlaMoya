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

public class API {
    
    struct RequestConvertible: URLRequestConvertible {
        func asURLRequest() throws -> URLRequest {
            <#code#>
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


