//
//  GameView.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-26.
//

import SwiftUI


/// Structure représentant la vue du jeu
struct GameView: View {
    @Environment(\.dismiss) private var dismiss /// Variable d'environnement pour retourner à la vue précédente
    @Environment(\.scenePhase) private var scenePhase /// Variable d'environnement indiquant l'état de la vue
    @ObservedObject private var bgManager = BackgroundManager.shared /// Gestionnaire du background
    @ObservedObject private var timer = TimerManager.shared /// Timer
    @State private var orderedLetters: [Letter] = [] /// Tableau contenant toute les lettres en ordre
    @State private var placedLetters: [Letter] = [] /// Tableau contenant toute les lettres placées
    @State private var buttonFrame: [CGRect] = [] /// Tableau contenant toute les positions des cases à remplir
    @State private var gameFinished: Bool = false /// Booléen indiquant si la partie est terminée
    @State private var showWord: Bool = false /// Booléen indiquant s'il faut afficher le mot
    @State private var noHintLeft: Bool = false /// Booléen indiquant si le joueur peut encore avoir des indices
    private var game = GameManager.shared /// gestionnaire du jeu
    
    var body: some View {
        ZStack{
            backgroundVw
            VStack{
                HStack (spacing: -20){
                    Text("Time")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .padding()
                    Text(" \(timer.formattedTime())")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .padding()
                }
                
                if (buttonFrame.count > 0){
                    letterBoxes
                }
                HStack{
                    Button("Give up", action: {
                        self.$showWord.wrappedValue = true
                        timer.stop()
                        
                    })
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 130, height: 50)
                    .background(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                        .fill(Color.red))
                    .alert("Give up", isPresented: $showWord) {
                        Button("Ok", role: .cancel) {
                            self.$showWord.wrappedValue = false
                            timer.stop()
                            timer.reset()
                            game.pickNewWord()
                            dismiss()
                        }
                    } message: {
                        Text("Word was: \(game.getWord())")
                    }
                    HStack{
                        Button("Hint", action: {
                            if (game.hintAmount != 3) {
                                let hint = game.hint(gameOrderedLetters: orderedLetters, gamePlacedLetters: placedLetters)
                                orderedLetters = hint.0
                                placedLetters = hint.1
                                gameFinished = hint.2
                            } else {
                                $noHintLeft.wrappedValue = true
                            }
                            
                        })
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(.blue)
                        .cornerRadius(15)
                        .alert("Hint", isPresented: $noHintLeft) {
                            Button("Ok", role: .cancel) {
                                
                            }
                        } message: {
                            Text("No more hints left")
                        }
                        
                        Text("Hint: \(game.hintAmount)/3")
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                    }
                    
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if (gameFinished) {
                endGameComponnent
            }
        }
        .onAppear {
            if (game.hasWord()) {
                game.pickNewWord()
            } else {
                game.reloadWord()
            }
            orderedLetters = game.orderedLetters
            placedLetters.removeAll()
            buttonFrame.removeAll()
            for letter in orderedLetters{
                placedLetters.append(Letter(id: letter.id, text: " ", offset: .zero))
                buttonFrame.append(.zero)
            }
            timer.start()
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                if (game.hasWord()) {
                    game.reloadWord()
                    
                }else {
                    game.pickNewWord()
                    timer.start()
                }
                break
            case .background:
                break
            case .inactive:
                timer.stop()
                game.saveWord()
                break
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    GameView()
}

private extension GameView {
    var backgroundVw: some View { /// Background
        Image(bgManager.getBackgroundImage(id: self.bgManager.backgroundId))
            .resizable()
            .scaledToFill()
            .ignoresSafeArea(.all)
    }
    var endGameComponnent: some View { /// Éléments de fin de partie
        VStack{
            Text("Congratulations!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Spacer()
                .frame(height: 20)
            
            HStack(spacing: 0.0){
                Text("the_word_was")
                Text(" \(game.getWord())")
            }
            HStack(spacing: 0.0){
                Text("time_spent")
                Text(" \(timer.formattedTime()) sec")
            }
            
            Spacer()
                .frame(height: 40)
            
            HStack {
                Button("Back", action: {
                    timer.reset()
                    game.pickNewWord()
                    dismiss()
                })
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 75, height: 50)
                .background(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                .fill(Color.blue)
                )
                
                Button("Replay", action: {
                    placedLetters = []
                    orderedLetters.removeAll()
                    game.pickNewWord()
                    orderedLetters = game.orderedLetters
                    
                    var tempArray: [Letter] = []
                    var tempFrameArray: [CGRect] = buttonFrame
                    for letter in orderedLetters{
                        tempArray.append(Letter(id: letter.id, text: " ", offset: .zero))
                        if (tempFrameArray.count < orderedLetters.count) {
                            tempFrameArray.insert(.zero, at: tempFrameArray.endIndex)
                        } else if (tempFrameArray.count > orderedLetters.count) {
                            tempFrameArray.removeLast()
                        }
                    }
                    placedLetters = tempArray
                    buttonFrame = tempFrameArray
                    gameFinished = false
                    timer.reset()
                    timer.start()
                })
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 75, height: 50)
                    .background(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                        .fill(Color.blue)
                    )
            }
        }
        .foregroundStyle(.black)
        .frame(width: 350, height: 300)
        .background(RoundedRectangle(cornerSize: CGSize(width: 50, height: 50))
                        .fill(Color.white)
                        .opacity(0.9)
                        .frame(width: 350, height: 300)
        )
    }
    var letterBoxes: some View { /// Cases des lettres placées et à placer
        VStack {
            // Lettres placées ou vide
            Grid(alignment: .center, horizontalSpacing: placedLetters.count >= 10 ? 0.5 : 10) {
                GridRow {
                    ForEach($placedLetters, id: \.id) { $letter in
                        Text("\(letter.text)")
                            .font(Font.system(size: placedLetters.count >= 10 ? 12 : 20))
                            .foregroundStyle(.black)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(width: placedLetters.count >= 10 ? 40 : 50, height: placedLetters.count >= 10 ? 40 : 50)
                            .background(letterRec(letter: $letter, fix: true))
                            .overlay(GeometryReader { geo in
                                    Color.clear
                                    .onAppear {
                                        DispatchQueue.main.async {
                                            self.buttonFrame[letter.id] = geo.frame(in: .global)
                                        }
                                    }
                                    .onChange(of: buttonFrame.count, {
                                        DispatchQueue.main.async {
                                            self.buttonFrame[letter.id] = geo.frame(in: .global)
                                        }
                                    })
                                }
                            )
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    letterTapped(letter: letter)
                                }
                            }
                    }
                }
                .frame(width: placedLetters.count >= 10 ? 55 : 75, height: 75)
                .gridCellUnsizedAxes([.horizontal, .vertical])
            }
            // Lettres à placer
            Grid(alignment: .center, horizontalSpacing: orderedLetters.count >= 10 ? 0.1 : 10) {
                GridRow {
                    ForEach($orderedLetters, id: \.id) { $letter in
                        if (letter.isShown) {
                            Text("\(letter.text)")
                                .font(Font.system(size: placedLetters.count >= 10 ? 12 : 20))
                                .foregroundStyle(.black)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .padding()
                                .zIndex(letter.offset == .zero ? 0 : 1)
                                .frame(width: orderedLetters.count >= 10 ? 40 : 50, height: orderedLetters.count >= 10 ? 40 : 50)
                                .background(letterRec(letter: $letter))
                                .offset(letter.offset)
                                .gesture(
                                    DragGesture(coordinateSpace: .global)
                                        .onChanged { drag in
                                            withAnimation(.bouncy(extraBounce: 0.3)) {
                                                letter.offset = CGSize(width: drag.translation.width, height: drag.translation.height)
                                                letter.dragState = letterMoved(location: CGPoint(x: drag.location.x, y: drag.location.y), letter: letter)
                                            }
                                        }
                                        .onEnded { drag in
                                            withAnimation(.bouncy(extraBounce: 0.3)){
                                                letter.dragState = letterMoved(location: CGPoint(x: drag.location.x, y: drag.location.y), letter: letter, dropped: true)
                                                letter.offset = .zero
                                            }
                                        }
                                )
                        }
                    }
                }
                .frame(width: orderedLetters.count >= 10 ? 55 : 75, height: 75)
                .gridCellUnsizedAxes([.horizontal, .vertical])
            }
            
        }
    }
    
    /// Met à jour la lettre qui a été taper
    /// - Parameter letter: Letter taper
    func letterTapped(letter: Letter) {
        if (letter.text != " ") {
            let match = orderedLetters.firstIndex(where: { $0.text == letter.text && !$0.isShown})
            orderedLetters[match!].isShown = true
            placedLetters[letter.id].text = " "
        }
    }
    
    /// Vérification lorsqu'un lettre est bougé
    /// - Parameters:
    ///   - location: Location de la lettre
    ///   - letter: Lettre qui est bougé
    ///   - dropped: Booléen indiquant si la lettre est drop ou non
    /// - Returns: Retourne l'état du drag
    func letterMoved(location: CGPoint, letter: Letter, dropped: Bool = false) -> DragState {
        if let match = buttonFrame.firstIndex(where: {
            $0.contains(location) }) {
            if (dropped) {
                if (placedLetters.count >= match) {
                    if (placedLetters[match].text != " ") {
                        for i in 0..<orderedLetters.count {
                            if (orderedLetters[i].text == placedLetters[match].text && !orderedLetters[i].isShown) {
                                orderedLetters[i].isShown = true
                                break
                            }
                        }
                    }
                    
                    placedLetters[match].text = letter.text
                    
                    orderedLetters[letter.id].isShown = false
                    gameFinished = game.checkWord(letterArray: placedLetters)
                    if (gameFinished) {
                        timer.stop()
                    }
                }
            }
            return .good
        } else {
            return .unknown
        }
    }
    
    /// Fond des lettres
    /// - Parameters:
    ///   - letter: Lettres
    ///   - fix: Booléen indiquant si la lettre peut bouger
    /// - Returns: Un carré
    func letterRec(letter: Binding<Letter>, fix: Bool = false) -> some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .fill(Color.white)
                .shadow(radius: 3)
                .shadow(color: getDragColor(state: letter.wrappedValue.dragState, fix: fix)
                        , radius: letter.wrappedValue.offset == .zero ? 0 : 10)
        }
    }
    
    /// Retourne la couleur selon le dragState
    /// - Parameters:
    ///   - state: État du drag
    ///   - fix: Booléen indiquant si la lettre peut bouger
    /// - Returns: Color selon son état
    func getDragColor(state: DragState, fix: Bool) -> Color {
        if fix { return .clear }
        switch state {
            case .good: return .green
            case .unknown: return .black
            case .bad: return .red
        }
    }
}
