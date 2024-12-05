//
//  ScoreDatabaseManager.swift
//  Charivari
//
//  Created by William Leroux on 2024-12-04.
//

import SQLite3
import Foundation

class ScoreDatabaseManager {
    private var db: OpaquePointer?
    static let shared = WordDatabaseManager()
    var count = 0
    
    init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        let dbUrl = FileManager.default.temporaryDirectory.appendingPathComponent("score.sqlite")
        
        if (sqlite3_open(dbUrl.path(), &db) == SQLITE_OK) {
            if (sqlite3_exec(db, ScoreRequest.CREATE_TABLE.description, nil, nil, nil) == SQLITE_OK) {
                print("Database setup successful")
            } else {
                print("Error setting up database: \(String(describing: (sqlite3_errmsg(db))))")
            }
        }
    }
    
    func insert(game: Game) {
        var insertStatement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, ScoreRequest.INSERT_SCORE, -1, &insertStatement, nil) == SQLITE_OK) {
            let nsWord : NSString = game.word!.Word as NSString
            let nsSectet : NSString = game.word!.Secret as NSString
            let nsUsername : NSString = game.username as NSString
            sqlite3_bind_text(insertStatement, 1, nsWord.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, nsSectet.utf8String, -1, nil)
            sqlite3_bind_int64(insertStatement, 3, Int64(game.time))
            sqlite3_bind_text(insertStatement, 4, nsUsername.utf8String, -1, nil)
            if (sqlite3_step(insertStatement) != SQLITE_DONE) {
                print("Error inserting word: \(String(describing: (sqlite3_errmsg(db))))")
                return
            }
        }
        count += 1
        sqlite3_finalize(insertStatement)
    }
    
    func getAll() -> [Game] {
        var statement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, ScoreRequest.SELECT_SCORE, -1, &statement, nil) == SQLITE_OK) {
            var games: [Game] = []
            while (sqlite3_step(statement) == SQLITE_ROW) {
                let word = Word(Word: String(cString: sqlite3_column_text(statement, 0)!), Secret: String(cString: sqlite3_column_text(statement, 1)), Error: "")
                let time = Double(sqlite3_column_int64(statement, 2))
                let username = String(cString: sqlite3_column_text(statement, 3))
                let game = Game(username: username, word: word, time: time, isFound: false)
                games.append(game)
            }
            sqlite3_finalize(statement)
            return games
        }
        sqlite3_finalize(statement)
        return []
    }
    
    func deleteScore(word: Word) {
        var deleteStatement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, ScoreRequest.DELETE_SCORE, -1, &deleteStatement, nil) == SQLITE_OK) {
            let nsWord : NSString = word.Word as NSString
            let nsSectet : NSString = word.Secret as NSString
            sqlite3_step(deleteStatement)
            sqlite3_finalize(deleteStatement)
            count -= 1
        }
    }
}
