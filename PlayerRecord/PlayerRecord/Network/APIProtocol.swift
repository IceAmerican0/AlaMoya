//
//  APIProtocol.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/19.
//

import Foundation

public protocol APIProtocol {
    associatedtype Request: APIRequest
    associatedtype Response: APIResponse
}

public protocol APIRequest: Encodable {
    associatedtype Body: Encodable
    var dataBody: Body { get }
}

public protocol APIResponse: Decodable {
    associatedtype Body: Decodable
    var dataBody: Body { get }
}
