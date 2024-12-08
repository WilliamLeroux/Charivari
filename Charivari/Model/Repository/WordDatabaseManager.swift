//
//  WordDatabaseManager.swift
//  Charivari
//
//  Created by William Leroux on 2024-12-04.
//

import SQLite3
import Foundation


/// Gestionnaire de la base de données
class WordDatabaseManager {
    private var db: OpaquePointer? /// Pointeur de la bd
    static let shared = WordDatabaseManager() /// Singleton
    var count: Int = 0 /// Compteur du nombre d'entré dans la base de données
    
    init() {
        setupDatabase()
    }
    
    /// Initialise la base de données
    private func setupDatabase() {
        let dbUrl = FileManager.default.temporaryDirectory.appendingPathComponent("word.sqlite")
        
        if (sqlite3_open(dbUrl.path(), &db) == SQLITE_OK) {
            if (sqlite3_exec(db, WordRequest.CREATE_TABLE.description, nil, nil, nil) == SQLITE_OK) {
            } else {
                print("Error setting up database: \(String(describing: (sqlite3_errmsg(db))))")
            }
        }
        
        if (sqlite3_open(dbUrl.path(), &db) == SQLITE_OK) {
            if (sqlite3_exec(db, ScoreRequest.CREATE_TABLE.description, nil, nil, nil) == SQLITE_OK) {
            } else {
                print("Error setting up database: \(String(describing: (sqlite3_errmsg(db))))")
            }
        }
    }
    
    /// Ajoute un mot à la base de données
    /// - Parameter word: Le mot à rajouter
    func insertWord(word: Word) {
        var insertStatement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, WordRequest.INSERT_WORD, -1, &insertStatement, nil) == SQLITE_OK) {
            let actualWord : NSString = word.Word as NSString
            let nsSectet : NSString = word.Secret as NSString
            sqlite3_bind_text(insertStatement, 1, actualWord.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, nsSectet.utf8String, -1, nil)
            if (sqlite3_step(insertStatement) != SQLITE_DONE) {
                print("Error inserting word: \(String(describing: (sqlite3_errmsg(db))))")
                return
            }
        }
        count += 1
        sqlite3_finalize(insertStatement)
    }
    
    /// Retourne un mot selon son id
    /// - Parameter id: id du mot
    /// - Returns: Mot
    func getWord(id: Int) -> (word: Word?, id: Int) {
        var selectStatement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, WordRequest.SELECT_WORD, -1, &selectStatement, nil) == SQLITE_OK) {
            sqlite3_bind_int(selectStatement, 1, Int32(id))
            var newWord : Word?
            var wordId : Int = -1
            while (sqlite3_step(selectStatement) == SQLITE_ROW) {
                wordId = Int(sqlite3_column_int(selectStatement, 0))
                let word = String(cString: sqlite3_column_text(selectStatement, 1))
                let secret = String(cString: sqlite3_column_text(selectStatement, 2))
                
                newWord = Word(Word: word, Secret: secret, Error: "")
            }
            sqlite3_finalize(selectStatement)
            return (newWord, wordId)
        }
        return (Word(Word: "", Secret: "", Error: ""), id: -1)
    }
    
    /// Supprime un mot selon son id
    /// - Parameter id: Id du mot
    func deleteWord(id: Int) {
        var deleteStatement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, WordRequest.DELETE_WORD, -1, &deleteStatement, nil) == SQLITE_OK) {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            count -= 1
            sqlite3_step(deleteStatement)
        }
        sqlite3_finalize(deleteStatement)
    }
    
    /// Retourne le plus petit id qu'il y a
    /// - Returns: Int contenant l'id
    func getLowestId() -> Int {
        var selectStatement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, WordRequest.GET_LOWEST_ID, -1, &selectStatement, nil) == SQLITE_OK) {
            var id = -1
            while (sqlite3_step(selectStatement) == SQLITE_ROW) {
                id = Int(sqlite3_column_int64(selectStatement, 0))
            }
            sqlite3_finalize(selectStatement)
            return id
        }
        sqlite3_finalize(selectStatement)
        return -1
    }
    
    /// Retourne le plus gros id
    /// - Returns: Int contenant l'id
    func getHighestId() -> Int {
        var selectStatement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, WordRequest.SELECT_WORD, -1, &selectStatement, nil) == SQLITE_OK) {
            var id = -1
            while (sqlite3_step(selectStatement) == SQLITE_ROW) {
                id = Int(sqlite3_column_int64(selectStatement, 0))
                
            }
            sqlite3_finalize(selectStatement)
            return id
        }
        sqlite3_finalize(selectStatement)
        return -1
    }
    
    /// Compte le nombre d'enregistrement dans la bd
    /// - Returns: Int contenant le nombre totale d'enregistrement
    func getCount() -> Int {
        var selectStatement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, WordRequest.COUNT_WORDS, -1, &selectStatement, nil) == SQLITE_OK) {
            var count: Int = 0
            while (sqlite3_step(selectStatement) == SQLITE_ROW) {
                count = Int(sqlite3_column_int64(selectStatement, 0))
                //count += 1
            }
            self.count = count
            sqlite3_finalize(selectStatement)
            return count
        }
        sqlite3_finalize(selectStatement)
        return -1
    }
    
    // MARK: Score table
    
    /// Ajoute un score à la tables des Scores
    /// - Parameter game: Score à rajouter
    func insertScore(game: Game) {
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
        sqlite3_finalize(insertStatement)
    }
    
    /// Retourne tout les scores
    /// - Returns: Tableau de game représentant tout les scores
    func getAllScore() -> [Game] {
        var statement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, ScoreRequest.SELECT_SCORE, -1, &statement, nil) == SQLITE_OK) {
            var games: [Game] = []
            while (sqlite3_step(statement) == SQLITE_ROW) {
                let id = Int(sqlite3_column_int64(statement, 0))
                let word = Word(Word: String(cString: sqlite3_column_text(statement, 1)!), Secret: String(cString: sqlite3_column_text(statement, 2)), Error: "")
                let time = Double(sqlite3_column_int64(statement, 3))
                let username = String(cString: sqlite3_column_text(statement, 4))
                let game = Game(id: id, username: username, word: word, time: time, isFound: false)
                games.append(game)
            }
            sqlite3_finalize(statement)
            return games
        }
        sqlite3_finalize(statement)
        return []
    }
    
    /// Supprime un score selon son id
    /// - Parameter id: Id du score
    func deleteScore(id: Int) {
        var deleteStatement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, ScoreRequest.DELETE_SCORE, -1, &deleteStatement, nil) == SQLITE_OK) {
            sqlite3_bind_int64(deleteStatement, 1, Int64(id))
            sqlite3_step(deleteStatement)
            sqlite3_finalize(deleteStatement)
            count -= 1
        }
    }
    
    // MARK: DEBUG
    
    /// DEBUG SEULEMENT supprime tout les scores
    func deleteAllScore() {
        var deleteStatement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, ScoreRequest.DEBUG_DELETE_ALL_SCORES, -1, &deleteStatement, nil) == SQLITE_OK) {
            sqlite3_step(deleteStatement)
            sqlite3_finalize(deleteStatement)
        }
    }
    
    /// DEBUG SEULEMENT supprime tout les mots
    func deleteAllWord() {
        var deleteStatement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, WordRequest.DEBUG_DELETE_ALL_WORDS, -1, &deleteStatement, nil) == SQLITE_OK) {
            sqlite3_step(deleteStatement)
            sqlite3_finalize(deleteStatement)
        }
    }
    
    /// DEBUG SEULEMENT affiche tout les scores
    func printAllScore() {
        var statement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, ScoreRequest.DEBUG_SELECT_ALL_SCORES, -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                let id = Int(sqlite3_column_int64(statement, 0))
                let username = String(cString: sqlite3_column_text(statement, 1))
                let word = String(cString: sqlite3_column_text(statement, 2))
                let time = Double(sqlite3_column_double(statement, 3))
                print("id: \(id), username: \(username), word: \(word), time: \(time)")
            }
        }
    }
    
    /// DEBUG SEULEMENT affiche tout les mots
    func printAllWord() {
        var statement: OpaquePointer?
        
        if (sqlite3_prepare_v2(db, WordRequest.DEBUG_SELECT_ALL_WORDS, -1, &statement, nil) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                let id = Int(sqlite3_column_int64(statement, 0))
                let word = String(cString: sqlite3_column_text(statement, 1))
                let secret = String(cString: sqlite3_column_text(statement, 2))
                print("id: \(id), word: \(word), secret: \(secret)")
            }
        }
    }
}
