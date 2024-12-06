//
//  Score.swift
//  Charivari
//
//  Created by William Leroux on 2024-12-04.
//

struct PostScore: Encodable, Decodable {
    var Success: Bool
    var Error: String
}

struct Score: Encodable, Decodable {
    var List: [ScoreList]?
    var Error: String
}

struct ScoreList: Encodable, Decodable {
    var Player: String
    var Score: Int
}
