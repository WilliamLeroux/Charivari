//
//  GameManager.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-28.
//

import SwiftUI

class GameManager : ObservableObject{
    private var timer = TimerManager.shared
    private var fetchWord = FetchWord()
    private var game: Game
    private var hasGame = false
    @Published var placedLetters = Array<Character>()
    var orderedLetters: [Letter] = []
    @Published var word: Word?
    
    init(username: String) {
        let userGame = UserDefaults.standard.object(forKey: "game") as? Game
        if (userGame != nil) {
            if (userGame!.isFound) {
                game = Game(username: username, time: 0.0, isFound: false)
                UserDefaults.standard.set(game, forKey: "game")
            } else {
                hasGame = true
                game = userGame!
                timer.setTime(time: game.time)
            }
        } else {
                game = Game(username: username, time: 0.0, isFound: false)
        }
        //setWord(word: Word(Word: "abc", Secret: "", Error: "")) // À retirer, seulement pour la preview
    }
    
    
    
    func setWord(word: Word) {
        self.game.word = word
        updateOrderedLetters()
        placedLetters.removeAll()
        placedLetters = Array(repeating: " ", count: orderedLetters.count)
    }
    
    private func updateOrderedLetters() {
        var word = game.word?.Word ?? "nil"
        word = word.uppercased()
        
        var tempArray: [Character] = Array(word)
        for i in 0..<tempArray.count {
            for j in 0..<tempArray.count {
                if (tempArray[i].unicodeScalars.first!.value < tempArray[j].unicodeScalars.first!.value) {
                    tempArray.swapAt(i, j)
                }
            }
        }
        for i in 0..<tempArray.count {
            orderedLetters.append(Letter(id: i, text: tempArray[i], offset: .zero))
        }
    }
    
    func getOrderedLetters() -> [Letter] {
        var word = game.word?.Word ?? "nil"
        word = word.uppercased()
        
        var tempArray: [Character] = Array(word)
        for i in 0..<tempArray.count {
            for j in 0..<tempArray.count {
                if (tempArray[i].unicodeScalars.first!.value < tempArray[j].unicodeScalars.first!.value) {
                    tempArray.swapAt(i, j)
                }
            }
        }
        
        var letterArray: [Letter] = []
        var i = 0
        for char in tempArray {
            let letter = Letter(id: i, text: char, offset: .zero)
            letterArray.append(letter)
            i+=1
        }
        
        self.orderedLetters = letterArray
        return letterArray
    }
    
    func updateOffset(id: Int, offset: CGSize) {
        orderedLetters[id].offset = offset
    }
    
    func getLetterOffset(id: Int) -> CGSize {
        return orderedLetters[id].offset
    }
    
    func getLetterCount() -> Int {
        return game.word?.Word.count ?? 0
    }
    
    func getPickNewWord() {
        let waiter = DispatchSemaphore(value: 0)
        Task {
            await fetchWord.getWord(difficulty: "1")
            game.word = fetchWord.word
            print(game.word?.Word)
            waiter.signal()
        }
        
        waiter.wait()
        orderedLetters.removeAll()
        updateOrderedLetters()
        placedLetters.removeAll()
        placedLetters = Array(repeating: " ", count: orderedLetters.count)
        saveWord()
    }
    
    func getWord() -> String {
        return game.word?.Word ?? "nil"
    }
    
    func checkWord(letterArray: [Letter]) -> Bool{
        reloadWord()
        var tempWord : String = ""
        let tempSecretWord = game.word!.Word.uppercased()
        for letter in letterArray {
            tempWord.append(letter.text)
        }
        if (tempWord == tempSecretWord) {
            timer.stop()
            game.time = timer.time
            Task {
                await fetchWord.sendScore(game: game)
            }
            return true
        }
        return false
    }
    
    func reloadWord() {
        if (UserDefaults.standard.object(forKey: "game") != nil) {
            if let gameEncode = UserDefaults.standard.data(forKey: "game"),
               let gameDecode = try? JSONDecoder().decode(Game.self, from: gameEncode) {
                game = gameDecode
                timer.setTime(time: game.time)
            }
        }
    }
    
    func saveWord() {
        game.time = timer.time
        UserDefaults.standard.set(try? JSONEncoder().encode(self.game), forKey: "game")
    }
    
    func setUsername(username: String) {
        game.username = username
    }
}
