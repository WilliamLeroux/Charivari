//
//  GameManager.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-28.
//

import SwiftUI

/// Gestionnaire de partie
class GameManager : ObservableObject, NetworkDelegate{
    static var shared = GameManager() /// Singleton
    private var timer = TimerManager.shared /// Gestionnaire du timer
    private var fetchWord = FetchWord() /// Gestionnaires du serveur
    private var game: Game /// Partie en cours
    private let wordDatabase = WordDatabaseManager.shared /// Gestionnaire de la base de données
    private var network = NetworkMonitor.shared /// Gestionnaire du réseau
    @Published var placedLetters = Array<Character>() /// Tableau des lettres placées
    @Published var word: Word? /// Mot
    @Published var hintAmount = 0 /// Nombre d'indice totale
    var orderedLetters: [Letter] = [] /// Tableau des lettres en ordre alphabétique
    var difficulty = "0" /// Difficulté
    
    init() {
        game = Game(username: "", time: 0.0, isFound: false)
        if let username = UserDefaults.standard.string(forKey: "username") {
            game.username = username
        }
        if let difficulty = UserDefaults.standard.string(forKey: "difficulty") {
            self.difficulty = difficulty
        }
        reloadWord()
    }
    
    /// Vérifie si la base de données contient 100 mots
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
    
    /// Met à jour la difficutlé
    /// - Parameter difficulty: Nouvelle diffculté
    func setDifficulty(difficulty: String) {
        self.difficulty = difficulty
        UserDefaults.standard.set(difficulty, forKey: "difficulty")
    }
    
    /// Met à jour le nom du joueur
    /// - Parameter name: Nouveau nom
    func setName(name: String) {
        game.username = name
        UserDefaults.standard.set(name, forKey: "username")
    }
    
    /// Retounre le nom du joueur
    /// - Returns: Nom du joueur
    func getName() -> String {
        return game.username
    }
    
    /// Vérifie que le joueur possède un nom
    /// - Returns: True si le joueur possède un nom, false s'il n'en possède pas
    func hasName() -> Bool {
        return !game.username.isEmpty
    }
    
    /// Est appelé lorsque l'utilisateur a du réseau
    func hasConnection() {
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
    
    /// Met à jour le mot
    /// - Parameter word: Mot
    func setWord(word: Word) {
        self.game.word = word
        updateOrderedLetters()
        placedLetters.removeAll()
        placedLetters = Array(repeating: " ", count: orderedLetters.count)
    }
    
    /// Met à jour le tableau des lettres en ordre alphabétique
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
    
    /// Prend un nouveau mot
    func pickNewWord() {
        hintAmount = 0
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
                waiter.signal()
            }
            waiter.wait()
        } else {
            let lowestId = wordDatabase.getLowestId()
            let requestResponse = wordDatabase.getWord(id: lowestId)
            game.id = lowestId
            game.word = requestResponse.word
        }
        orderedLetters.removeAll()
        updateOrderedLetters()
        placedLetters.removeAll()
        placedLetters = Array(repeating: " ", count: orderedLetters.count)
        saveWord()
    }
    
    /// Priend plusieurs mots
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
    
    /// Retourne le mot
    /// - Returns: Le mot à chercher
    func getWord() -> String {
        return game.word?.Word ?? "nil"
    }
    
    /// Vérifie si le joueur a trouvé le mot
    /// - Parameter letterArray: Tableau des lettres
    /// - Returns: Booléen indiquant si le joueur a terminé la partie
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
            game.isFound = true
            saveWord()
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
    
    /// Donne un indice au jouer
    /// - Parameters:
    ///   - gameOrderedLetters: tableau des lettres en ordres alphabétiques de la vue
    ///   - gamePlacedLetters: tableau des lettres placées de la vue
    /// - Returns: Les deux tableaux envoyées mis à jour
    func hint(gameOrderedLetters: [Letter], gamePlacedLetters: [Letter]) -> (newOrder: [Letter], newPlaced: [Letter], gameFinished: Bool) {
        let tempArray = Array(game.word!.Word.uppercased())
        var tempLetter : Character = " "
        var letterAvailable : Bool = false
        var newOrder : [Letter] = gameOrderedLetters
        var newPlaced : [Letter] = gamePlacedLetters
        
        hintAmount += 1
        
        for i in 0..<gamePlacedLetters.count {
            if (gamePlacedLetters[i].text != tempArray[i]) {
                tempLetter = tempArray[i]
                for j in 0..<gameOrderedLetters.count {
                    if (gameOrderedLetters[j].text == tempLetter && gameOrderedLetters[j].isShown) {
                        if (gamePlacedLetters[i].text != " ") {
                            if let match = gameOrderedLetters.firstIndex(where: { $0.text == gamePlacedLetters[i].text && !$0.isShown}) {
                                newOrder[match].isShown = true
                            }
                        }
                        newPlaced[i].text = tempLetter
                        newOrder[j].isShown = false
                        letterAvailable = true
                        break
                    }
                }
                
                if (!letterAvailable) {
                    for j in 0..<gameOrderedLetters.count {
                        if (gamePlacedLetters[j].text == tempLetter) {
                            newPlaced[j].text = " "
                            newPlaced[i].text = tempLetter
                            break
                        }
                    }
                } else {
                    break
                }
            } else if (i == gamePlacedLetters.count - 1) {
                tempLetter = tempArray[0]
                let match = gamePlacedLetters.firstIndex(where: { $0.text == tempLetter})
                
                if (match == 0) {
                    return (newOrder: newOrder, newPlaced: newPlaced, gameFinished: checkWord(letterArray: newPlaced))
                }
                newPlaced.swapAt(match!, 0)
            }
        }
        return (newOrder: newOrder, newPlaced: newPlaced, gameFinished: checkWord(letterArray: newPlaced))
    }
    
    /// Met à jour le score
    func updateScore() {
        wordDatabase.insertScore(game: game)
        if (game.id != -1) {
            wordDatabase.deleteWord(id: game.id)
        }
    }
    
    /// Recharge le mot
    func reloadWord() {
        hintAmount = 0
        if (UserDefaults.standard.object(forKey: "game") != nil) {
            if let gameEncode = UserDefaults.standard.data(forKey: "game"),
               let gameDecode = try? JSONDecoder().decode(Game.self, from: gameEncode) {
                game = gameDecode
                timer.setTime(time: game.time)
                orderedLetters.removeAll()
                updateOrderedLetters()
                placedLetters.removeAll()
                placedLetters = Array(repeating: " ", count: orderedLetters.count)
            }
        }
    }
    
    /// Prend le mot qui est stocké dans le userDefault
    /// - Returns: Mot
    func getWordFromUserDefaults() -> String {
        if (UserDefaults.standard.object(forKey: "game") != nil) {
            if let gameEncode = UserDefaults.standard.data(forKey: "game"),
               let gameDecode = try? JSONDecoder().decode(Game.self, from: gameEncode) {
                return gameDecode.word!.Word
            }
        }
        return ""
    }
    
    /// Sauvegarde le mot dans le userDefault
    func saveWord() {
        game.time = timer.time
        UserDefaults.standard.set(try? JSONEncoder().encode(self.game), forKey: "game")
    }
    
    /// Vérifie si le joueur a fini le mot qu'il cherchait
    func hasWord() -> Bool {
        if let _ = UserDefaults.standard.data(forKey: "game") {
            reloadWord()
            return !game.isFound
        }
        return false
    }
}
