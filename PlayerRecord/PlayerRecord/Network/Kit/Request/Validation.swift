//
//  Validation.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/05/02.
//

import Foundation

extension Request {
    fileprivate typealias ErrorReason = NetworkError
    
    public typealias ValidationResult = Result<Void, Error>
    
    // MARK: Properties
    
    fileprivate var acceptableStatusCodes: Range<Int> { 200..<300 }
    
    fileprivate var acceptableContentTypes: [String] {
        if let accept = request?.value(forHTTPHeaderField: "Accept") {
            return accept.components(separatedBy: ",")
        }
        
        return ["*/*"]
    }
    
}
