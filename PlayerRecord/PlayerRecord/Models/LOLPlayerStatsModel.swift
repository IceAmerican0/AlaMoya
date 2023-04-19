//
//  LOLPlayerStatsModel.swift
//  PlayerRecord
//
//  Created by 60156056 on 2023/04/19.
//

import Foundation

public enum LOLPlayerStatsModel: APIProtocol {
    public struct Request: APIRequest {
        public var dataBody: Body
        
        public struct Body: Encodable {
            let playerID: String
            
            public init(
                playerID: String
            ) {
                self.playerID = playerID
            }
        }
        
        public init(
            dataBody: Body
        ) {
            self.dataBody = dataBody
        }
    }
    
    public struct Response: APIResponse {
        public var dataBody: Body
        
        public struct Body: Decodable {
            public let playerID: String?
            public let player: String?
            
            public init(
                playerID: String,
                player: String
            ) {
                self.playerID = playerID
                self.player = player
            }
        }
    }
}
