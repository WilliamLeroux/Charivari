//
//  WordDatabaseRequest.swift
//  Charivari
//
//  Created by William Leroux on 2024-12-04.
//


/// Structure comprenant toute les requêtes SQL pour la table des mots
struct WordRequest {
    static let CREATE_TABLE =   "CREATE TABLE IF NOT EXISTS words (id INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT NOT NULL, secret TEXT NOT NULL);"
    static let INSERT_WORD =    "INSERT INTO words (word, secret) VALUES (?, ?);"
    static let SELECT_WORD =    "SELECT * FROM words WHERE id = ?;"
    static let GET_LOWEST_ID =  "SELECT MIN(id) FROM words;"
    static let GET_HIGHEST_ID = "SELECT MAX(id) FROM words;"
    static let DELETE_WORD =    "DELETE FROM words WHERE id = ?;"
    static let COUNT_WORDS =    "SELECT COUNT(*) FROM words;"
    
    // MARK: DEBUG
    static let DEBUG_DELETE_ALL_WORDS = "DELETE FROM words;"
    static let DEBUG_SELECT_ALL_WORDS = "SELECT * FROM words;"
}
