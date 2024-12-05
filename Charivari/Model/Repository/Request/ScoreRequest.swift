//
//  ScoreRequest.swift
//  Charivari
//
//  Created by William Leroux on 2024-12-05.
//

struct ScoreRequest {
    static let CREATE_TABLE = "CREATE TABLE IF NOT EXISTS scores (id INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT NOT NULL, secret TEXT NOT NULL, score INTEGER NOT NULL, username TEXT NOT NULL);"
    static let INSERT_SCORE = "INSERT INTO scores (word, secret, score, username) VALUES (?, ?, ?, ?);"
    static let SELECT_SCORE = "SELECT * FROM scores;"
    static let DELETE_SCORE = "DELETE FROM scores WHERE id = ?;"
}
