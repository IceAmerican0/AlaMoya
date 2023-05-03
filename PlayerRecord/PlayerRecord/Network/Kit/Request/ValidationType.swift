//
//  ValidationType.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/26.
//

import Foundation

public enum ValidationType {
    case none
    case successCodes
    case customCodes([Int])
    
    var statusCodes: [Int] {
        switch self {
        case .successCodes:
            return Array(200..<300)
        case .customCodes(let codes):
            return codes
        case .none:
            return []
        }
    }
}

extension ValidationType: Equatable {
    public static func == (lhs: ValidationType, rhs: ValidationType) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none),
             (.successCodes, .successCodes):
            return true
        case (.customCodes(let code1), .customCodes(let code2)):
            return code1 == code2
        default:
            return false
        }
    }
}
