//
//  Response.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/25.
//

import Foundation

public final class Response: CustomStringConvertible, Equatable {
    public let statusCode: Int
    public let data: Data
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    
    public init(statusCode: Int, data: Data, request: URLRequest?, response: HTTPURLResponse?) {
        self.statusCode = statusCode
        self.data = data
        self.request = request
        self.response = response
    }
    
    public var description: String {
        "Status Code: \(statusCode), Data Length: \(data.count)"
    }
    
    public var debugDescription: String { description }
    
    public static func == (lhs: Response, rhs: Response) -> Bool {
        lhs.statusCode == rhs.statusCode
            && lhs.data == rhs.data
            && lhs.response == rhs.response
    }
}
