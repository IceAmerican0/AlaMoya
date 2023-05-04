//
//  HTTPMethod.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/27.
//

public struct HTTPMethod: RawRepresentable, Equatable, Hashable {
    public static let get = HTTPMethod(rawValue: "GET")
    public static let post = HTTPMethod(rawValue: "POST")
    public static let head = HTTPMethod(rawValue: "HEAD")
    public static let delete = HTTPMethod(rawValue: "DELETE")
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
