//
//  GameManager.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-28.
//

import SwiftUI

class GameManager : ObservableObject, NetworkDelegate{
    static var shared = GameManager()
    private var timer = TimerManager.shared
    private var fetchWord = FetchWord()
    private var game: Game
    private var hasGame = false
    private let wordDatabase = WordDatabaseManager.shared
    private var network = NetworkMonitor.shared
    @Published var placedLetters = Array<Character>()
    @Published var word: Word?
    var orderedLetters: [Letter] = []
    var difficulty = "0"
    
    
    init() {
        game = Game(username: "", time: 0.0, isFound: false)
        if let username = UserDefaults.standard.string(forKey: "username") {
            game.username = username
        }
        if let difficulty = UserDefaults.standard.string(forKey: "difficulty") {
            self.difficulty = difficulty
        }
    }
    
    func checkDatabase() {
        if (network.connected){
            if (wordDatabase.getCount() < 100) {
                print(wordDatabase.getCount())
                DispatchQueue.global().async {
                    self.pickManyWords()
                }
            }
        }
    }
    
    func setDifficulty(difficulty: String) {
        self.difficulty = difficulty
        UserDefaults.standard.set(difficulty, forKey: "difficulty")
    }
    
    func setName(name: String) {
        game.username = name
        UserDefaults.standard.set(name, forKey: "username")
    }
    
    func getName() -> String {
        return game.username
    }
    
    func hasName() -> Bool {
        return !game.username.isEmpty
    }
    
    func hasConnection() {
        print("has connection")
        let scores = wordDatabase.getAllScore()
        if (!scores.isEmpty) {
            DispatchQueue.global().async {
                let waiter = DispatchSemaphore(value: 0)
                for score in scores {
                    Task{
                        await self.fetchWord.sendScore(game: score)
                        waiter.signal()
                    }
                    waiter.wait()
                    self.wordDatabase.deleteScore(id: score.id)
                }
            }
        }
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
    
    func pickNewWord() {
        if (network.connected) {
            game.id = -1
            let waiter = DispatchSemaphore(value: 0)
            var wordIsOk: Bool = false
            Task {
                while(!wordIsOk){
                    await fetchWord.getWord(difficulty: self.difficulty)
                    
                    if (fetchWord.word?.Word != nil) {
                        if (fetchWord.word!.Word != "") {
                            game.word = fetchWord.word
                            wordIsOk = true
                        }
                    }
                }
                print(game.word?.Word)
                waiter.signal()
            }
            
            waiter.wait()
        } else {
            let lowestId = wordDatabase.getLowestId()
            let requestResponse = wordDatabase.getWord(id: lowestId)
            game.id = lowestId
            game.word = requestResponse.word
            print(game.word?.Word)
        }
        orderedLetters.removeAll()
        updateOrderedLetters()
        placedLetters.removeAll()
        placedLetters = Array(repeating: " ", count: orderedLetters.count)
        saveWord()
    }
    
    func pickManyWords() {
        
            let count = wordDatabase.getCount()
            let waiter = DispatchSemaphore(value: 0)
            var newWordsTable: [Word?] = []
            Task {
                await newWordsTable = fetchWord.getWords(amount: 100 - count)
                waiter.signal()
            }
            waiter.wait()
            
            for word in newWordsTable {
                if (word != nil) {
                    wordDatabase.insertWord(word: word!)
                }
            }
    }
    
    func getWord() -> String {
        return game.word?.Word ?? "nil"
    }
    
    func checkWord(letterArray: [Letter]) -> Bool{
        if (game.word != nil) {
            if (getWordFromUserDefaults() != game.word!.Word) {
                reloadWord()
            }
        }
        
        var tempWord : String = ""
        let tempSecretWord = game.word!.Word.uppercased()
        for letter in letterArray {
            tempWord.append(letter.text)
        }
        if (tempWord == tempSecretWord) {
            timer.stop()
            game.time = timer.time
            if (network.connected) {
                Task {
                    await fetchWord.sendScore(game: game)
                }
            } else {
                updateScore()
            }
            
            return true
        }
        return false
    }
    
    func updateScore() {
        wordDatabase.insertScore(game: game)
        if (game.id != -1) {
            wordDatabase.deleteWord(id: game.id)
        }
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
    
    func getWordFromUserDefaults() -> String {
        if (UserDefaults.standard.object(forKey: "game") != nil) {
            if let gameEncode = UserDefaults.standard.data(forKey: "game"),
               let gameDecode = try? JSONDecoder().decode(Game.self, from: gameEncode) {
                return gameDecode.word!.Word
            }
        }
        return ""
    }
    
    func saveWord() {
        game.time = timer.time
        UserDefaults.standard.set(try? JSONEncoder().encode(self.game), forKey: "game")
    }
    
    func setUsername(username: String) {
        game.username = username
    }
}
