//
//  Game.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-28.
//


/// Structure représentant une partie
struct Game: Encodable, Decodable{
    var id : Int = -1 /// Id du mot dans la base de données, -1 si le mot n'est pas dans la base de données
    var username: String /// Nom du joueur
    var word: Word? /// Mot
    var time: Double /// Temps écoulé
    var isFound: Bool /// Booléan indiquant si le mot a été trouvé
}
