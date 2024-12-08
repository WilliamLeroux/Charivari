//
//  Score.swift
//  Charivari
//
//  Created by William Leroux on 2024-12-04.
//


/// Structrure représentant la réponse au post d'un score
struct PostScore: Encodable, Decodable {
    var Success: Bool /// Booléan indiquant si la requête a fonctionné
    var Error: String /// Erreur
}

/// Structure représentant un score
struct Score: Encodable, Decodable {
    var List: [ScoreList]? /// Liste des scores, vide s'il n'y en a pas
    var Error: String /// Erreur
}

/// Structure représentant la liste des scores
struct ScoreList: Encodable, Decodable {
    var Player: String /// Nom du joueur
    var Score: Int /// Score
}
