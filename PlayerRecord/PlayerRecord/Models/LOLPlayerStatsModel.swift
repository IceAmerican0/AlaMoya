//
//  LOLPlayerStatsModel.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/19.
//

import Foundation

public enum LOLPlayerStatsModel {
    public struct Request: Encodable {
        let summonerName: String
        
        public init(
            summonerName: String
        ) {
            self.summonerName = summonerName
        }
    }
    
    public struct Response: Decodable {
        public let id: String?
        public let accountId: String?
        public let puuid: String?
        public let name: String?
        public let profileIconId: Int?
        public let revisionDate: Int?
        public let summonerLevel: Int?
        
        public init(
            id: String,
            accountId: String,
            puuid: String,
            name: String,
            profileIconId: Int,
            revisionDate: Int,
            summonerLevel: Int
        ) {
            self.id = id
            self.accountId = accountId
            self.puuid = puuid
            self.name = name
            self.profileIconId = profileIconId
            self.revisionDate = revisionDate
            self.summonerLevel = summonerLevel
        }
    }
}
