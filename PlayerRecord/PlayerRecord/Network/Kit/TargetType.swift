//
//  TargetType.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/26.
//

import Foundation

public protocol TargetType {
    var baseURL: URL { get }
    var path: String { get }
    var task: Task { get }
    var validationType: ValidationType { get }
    var headers: [String: String]? { get }
}

public extension TargetType {
    var validationType: ValidationType { .none }
}
