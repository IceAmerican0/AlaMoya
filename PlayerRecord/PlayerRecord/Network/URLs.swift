//
//  URLs.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/18.
//

import Foundation

public class Hosts {
    public static let shared = Hosts()
    
    public let riotAPI : String
    
    public init(riotAPI: String = "")
    {
        self.riotAPI = riotAPI
    }
}

public enum HostType {
    case riotAPI
    
    public var host: String {
        switch self {
        case .riotAPI:
            return "https://"
        }
    }
}

public class Paths {
    public static let riot = "/example/example"
}


public class Urls {
    public static func compose(_ hostType: HostType = .riotAPI, path: String) -> String {
        return "\(hostType.host)\(path)"
    }
}
