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
    public let r6API : String
    
    public init(
        riotAPI: String = "kr.api.riotgames.com",
        r6API: String = "")
    {
        self.riotAPI = riotAPI
        self.r6API = r6API
    }
}

public enum HostType {
    case LOLPlayerStatsAPI
    
    public var host: String {
        switch self {
        case .LOLPlayerStatsAPI:
            return "https://\(Hosts.shared.riotAPI)"
        }
    }
}

public class Paths {
    public static let playerStats = "/lol/summoner/v4/summoners/by-name/"
}

public class Urls {
    public static func compose(_ hostType: HostType, path: String) -> String {
        return "\(hostType.host)\(path)"
    }
}
