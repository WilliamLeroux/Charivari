//
//  FetchWord.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-28.
//

import SwiftUI

actor WordActor {
    var wordTab =  [Word?](repeating: nil, count: 100)
    func setWord(_ word: Word) {
        wordTab.append(word)
    }
}

class FetchWord: ObservableObject {
    var word: Word?
    
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
    
    func get100Words(difficulty: String) async {
        let wordActor = WordActor()
        do {
            for _ in 0..<100 {
                let word = try await fetchWord(difficulty: difficulty)
                Task {
                    await wordActor.setWord(word)
                }
            }
            for i in 0..<100 {
                
            }
        }catch let jsonError as NSError {
            print("JSON decode failed: \(jsonError.localizedDescription)")
        }
    }
    
    private func fetchWord(difficulty: String) async throws -> Word {
        let endpoint = "https://420c56.drynish.synology.me/new/\(difficulty)"
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        print(try JSONDecoder().decode(Word.self, from: data))
        return try JSONDecoder().decode(Word.self, from: data)
    }
    
    func sendScore(game: Game) async {
        do {
            let postScore = try await postResult(game: game)
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
        
    
    func saveWords() {
        
    }
}
