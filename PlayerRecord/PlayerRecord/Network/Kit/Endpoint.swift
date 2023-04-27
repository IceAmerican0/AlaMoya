//
//  Endpoint.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/27.
//

import Foundation

public enum EndpointSampleResponse {
    case networkResponse(Int, Data)
    case response(HTTPURLResponse, Data)
    case networkError(NSError)
}

open class Endpoint {
    public typealias SampleResponseClosure = () -> EndpointSampleResponse
    public let url: String
    public let sampleResponseClosure: SampleResponseClosure
    public let method: Method
    public let task: Task
    public let httpHeaderFields: [String: String]?
    
    public init(url: String,
                sampleResponseClosure: @escaping SampleResponseClosure,
                method: Method, task: Task,
                httpHeaderFields: [String : String]?) {
        self.url = url
        self.sampleResponseClosure = sampleResponseClosure
        self.method = method
        self.task = task
        self.httpHeaderFields = httpHeaderFields
    }
    
    open func adding(newHTTPHeaderFields: [String: String]) -> Endpoint {
        Endpoint(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: task, httpHeaderFields: httpHeaderFields)
    }
    
    open func replacing(task: Task) -> Endpoint {
        Endpoint(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: task, httpHeaderFields: httpHeaderFields)
    }
    
    fileprivate func add(httpHeaderFields headers: [String: String]?) -> [String: String]? {
        guard let unwrappedHeaders = headers, unwrappedHeaders.isEmpty == false else {
            return self.httpHeaderFields
        }
            
        var newHTTPHeaderFields = self.httpHeaderFields ?? [:]
        unwrappedHeaders.forEach { key, value in
            newHTTPHeaderFields[key] = value
        }
        return newHTTPHeaderFields
    }
}

public extension Endpoint {
    func urlRequest() throws -> URLRequest {
        guard let requestURL = Foundation.URL(string: url) else {
            throw NetworkError.requestMapping(url)
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = httpHeaderFields
        
        switch task {
        case .requestData(let data) :
            request.httpBody = data
            return request
        case let .requestJSONEncodable(encodable):
            return try request.encoded(encodable: encodable)
        }
    }
}

extension Endpoint: Equatable, Hashable {
    public func hash(into hasher: inout Hasher) {
        if let request = try? urlRequest() {
            hasher.combine(request)
        } else {
            hasher.combine(url)
        }
    }
    
    public static func == (lhs: Endpoint, rhs: Endpoint) -> Bool {
        let areEndpointsEqualInAdditionalProperties: Bool = {
            return true
        }()
        let lhsRequest = try? lhs.urlRequest()
        let rhsRequest = try? rhs.urlRequest()
        if lhsRequest != nil, rhsRequest == nil { return false }
        if lhsRequest == nil, rhsRequest != nil { return false }
        if lhsRequest == nil, rhsRequest == nil { return lhs.hashValue == rhs.hashValue && areEndpointsEqualInAdditionalProperties }
        return lhsRequest == rhsRequest && areEndpointsEqualInAdditionalProperties
    }
}
