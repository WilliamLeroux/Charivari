//
//  FetchWord.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-28.
//

import SwiftUI

class FetchWord: ObservableObject {
    var word: Word?
    private var network = NetworkMonitor.shared
    
    init() {
        
    }
    
    func getWord(difficulty: String) async {
        do {
            let word = try await fetchWord(difficulty: difficulty)
            self.word = word
        }catch let jsonError as NSError {
            print("JSON decode failed: \(jsonError.localizedDescription)")
        }
    }
    
    func getWords(amount: Int) async -> [Word?] {
        var wordTab: [Word?] = []
        var requestWorked = false
        do {
            for _ in 0..<amount {
                while (!requestWorked) {
                    if (!network.connected) {
                        break
                    }
                    let word = try await fetchWord()
                    if (word.Word != "") {
                        wordTab.append(word)
                        requestWorked = true
                    }
                }
                if (!network.connected) {
                    break
                }
                requestWorked = false
            }
        }catch let jsonError as NSError {
            print("JSON decode failed: \(jsonError.localizedDescription)")
        }
        return wordTab
    }
    
    private func fetchWord(difficulty: String = "") async throws -> Word {
        var endpoint: String = ""
        if (difficulty == "" || difficulty == "0") {
            endpoint = "https://420c56.drynish.synology.me/new"
        } else {
            endpoint = "https://420c56.drynish.synology.me/new/\(difficulty)"
        }
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
    
        return try JSONDecoder().decode(Word.self, from: data)
    }
    
    func sendScore(game: Game) async {
        do {
            _ = try await postResult(game: game)
        } catch let jsonError as NSError {
            print("JSON decode failed: \(jsonError.localizedDescription)")
        }
    }
    
    private func postResult(game: Game) async throws -> PostScore {
        let endpoint = "https://420c56.drynish.synology.me/solve/\(String(describing: game.word.unsafelyUnwrapped.Word))/\(String(describing: game.word.unsafelyUnwrapped.Secret))/\(game.username)/\(Int(game.time))"
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(PostScore.self, from: data)
    }
        
    
    func getScore(word: String) async -> Score? {
        var score: Score? = nil
        do {
            score = try await fetchScore(word: word)
        } catch let jsonError as NSError {
            print("JSON decode failed: \(jsonError.localizedDescription)")
        }
        
        return score
    }
    
    private func fetchScore(word: String) async throws -> Score {
        let endpoint = "https://420c56.drynish.synology.me/score/\(word)"
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Score.self, from: data)
    }
}
