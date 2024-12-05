//
//  Game.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-28.
//

struct Game: Encodable, Decodable{
    var id : Int = -1
    var username: String
    var word: Word?
    var time: Double
    var isFound: Bool
}
