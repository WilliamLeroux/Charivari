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
    @Published var word: Word?
    
    init() {
        
    }
    
    func getWord(difficulty: String) async -> Word?{
        do {
            let word = try await fetchWord(difficulty: difficulty)
            DispatchQueue.main.async {
                self.word = word
            }
        }catch let jsonError as NSError {
            print("JSON decode failed: \(jsonError.localizedDescription)")
        }
        return self.word ?? nil
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
        
        return try JSONDecoder().decode(Word.self, from: data)
    }
    
    func saveWords() {
        
    }
}
