//
//  GameManager.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-28.
//

import SwiftUI

class GameManager : ObservableObject{
    private var timer = TimerManager.shared
    private var game: Game
    private var hasGame = false
    var placedLetters = Array<Character>()
    var orderedLetters: [Letter] = []

    
    init(username: String) {
        timer = TimerManager()
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
                if (tempArray[i].asciiValue! < tempArray[j].asciiValue!) {
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
                if (tempArray[i].asciiValue! < tempArray[j].asciiValue!) {
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
    
    func startTimer() {
        
    }
    
    func checkLetterDrag(letter: Letter, placedLetters: [Letter]){
        var tempPoint = CGPoint(x: letter.offset.width, y: letter.offset.height)
        var index = 0
        var letterHover: Bool = false
        for tempLetter in placedLetters {
            if (tempLetter.lastOffset.contains(tempPoint)) {
                letterHover = true
                break
            }
            index += 1
        }
        if (letterHover) {
            
        }
        
    }
    
    private func saveWord() {
        UserDefaults.standard.set(game, forKey: "game")
    }
}
