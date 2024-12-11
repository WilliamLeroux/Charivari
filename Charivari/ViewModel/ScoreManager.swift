//
//  ScoreManager.swift
//  Charivari
//
//  Created by William Leroux on 2024-12-06.
//

import SwiftUI

/// Gestionnaire du score
class ScoreManager : ObservableObject{
    private var fetchWord = FetchWord() /// Gestionnaire du serveur
    @Published var score: Score? = nil /// Score
    var word = "" /// Mot
    
    /// Trouve le score selon le mot
    /// - Parameter word: Mot rechercher
    @MainActor func getScore(word: String) {
        self.word = word
        Task {
            score = await fetchWord.getScore(word: word) ?? nil
            if (score != nil) {
                if (!(score!.List?.isEmpty ?? false)) {
                    for i in 0..<score!.List!.count {
                        for j in 0..<score!.List!.count {
                            if ((score?.List![i].Score)! < (score?.List![j].Score)!) {
                                score!.List!.swapAt(i, j)
                            }
                        }
                    }
                }
            }
        }
    }
}
