//
//  Word.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-27.
//

/// Structure représentant un mot
struct Word: Decodable, Encodable{
    var Word: String /// Mot
    var Secret: String /// Secret du mot
    var Error: String /// Erreur
}
