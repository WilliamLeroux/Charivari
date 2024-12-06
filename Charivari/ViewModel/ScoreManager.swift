//
//  ScoreManager.swift
//  Charivari
//
//  Created by William Leroux on 2024-12-06.
//

import SwiftUI

class ScoreManager : ObservableObject{
    private var fetchWord = FetchWord()
    @Published var score: Score? = nil
    var word = ""
    
    @MainActor func getScore(word: String) {
        self.word = word
        Task {
             score = await fetchWord.getScore(word: word) ?? nil
        }
    }
}
