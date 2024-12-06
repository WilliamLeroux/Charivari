//
//  GameView.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-26.
//
import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    var game: GameManager
    @State var orderedLetters: [Letter]
    @ObservedObject var timer = TimerManager.shared
    @State var placedLetters: [Letter]
    @State var buttonFrame: [CGRect]
    @State var gameFinished: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
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
                
                Button("Give up", action: {
                    dismiss()
                })
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 75, height: 50)
                .background(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                    .fill(Color.blue)
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            if (gameFinished) {
                endGameComponnent
            }
        }
        .onAppear {
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
                print("coucou")
                game.reloadWord()
                timer.start()
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
    GameView(game: GameManager(), orderedLetters: ([Letter(id: 0, text: "a", offset: .zero), Letter(id: 1, text: "b", offset: .zero), Letter(id: 2, text: "c", offset: .zero)]), placedLetters: ([Letter(id: 0, text: " ", offset: .zero), Letter(id: 1, text: " ", offset: .zero), Letter(id: 2, text: " ", offset: .zero)]), buttonFrame: ([CGRect](repeating: .zero, count: 3)))
}

private extension GameView {
    var backgroundVw: some View {
        Image(.background4)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea(.all)
    }
}

private extension GameView {
    var endGameComponnent: some View {
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
                    //game.setWord(word: Word(Word: "abcde", Secret: "", Error: ""))
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
        .frame(width: 350, height: 300)
        .background(RoundedRectangle(cornerSize: CGSize(width: 50, height: 50))
                        .fill(Color.white)
                        .opacity(0.9)
                        .frame(width: 350, height: 300)
        )
    }
}

private extension GameView {
    var letterBoxes: some View {
        VStack {
            Grid {
                GridRow {
                    ForEach($placedLetters, id: \.id) { $letter in
                        Text("\(letter.text)")
                            .foregroundStyle(.black)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(width: 50, height: 50)
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
                                withAnimation(.easeInOut) {
                                    letterTapped(letter: letter)
                                }
                            }
                    }
                }
                .frame(width: 75, height: 75)
                .gridCellUnsizedAxes([.horizontal, .vertical])
            }
            Grid {
                GridRow {
                    ForEach($orderedLetters, id: \.id) { $letter in
                        if (letter.isShown) {
                            Text("\(letter.text)")
                                .foregroundStyle(.black)
                                .fixedSize(horizontal: false, vertical: true)
                                .multilineTextAlignment(.center)
                                .padding()
                                .zIndex(letter.offset == .zero ? 0 : 1)
                                .frame(width: 50, height: 50)
                                .background(letterRec(letter: $letter))
                                .offset(letter.offset)
                                .gesture(
                                    DragGesture(coordinateSpace: .global)
                                        .onChanged { drag in
                                            withAnimation(.easeIn) {
                                                letter.offset = CGSize(width: drag.translation.width, height: drag.translation.height)
                                                letter.dragState = letterMoved(location: CGPoint(x: drag.location.x, y: drag.location.y), letter: letter)
                                            }
                                        }
                                        .onEnded { drag in
                                            withAnimation(.easeInOut){
                                                letter.dragState = letterMoved(location: CGPoint(x: drag.location.x, y: drag.location.y), letter: letter, dropped: true)
                                                letter.offset = .zero
                                            }
                                        }
                                )
                        }
                    }
                }
                .frame(width: 75, height: 75)
                .gridCellUnsizedAxes([.horizontal, .vertical])
            }
        }
    }
    
    func letterTapped(letter: Letter) {
        if (letter.text != " ") {
            let match = orderedLetters.firstIndex(where: { $0.text == letter.text && !$0.isShown})
            orderedLetters[match!].isShown = true
            placedLetters[letter.id].text = " "
        }
    }
    
    func letterMoved(location: CGPoint, letter: Letter, dropped: Bool = false) -> DragState {
        if let match = buttonFrame.firstIndex(where: {
            $0.contains(location) }) {
            if (dropped) {
                if (placedLetters[match].text != " ") {
                    for i in 0..<orderedLetters.count {
                        if (orderedLetters[i].text == placedLetters[match].text && !orderedLetters[i].isShown) {
                            orderedLetters[i].isShown = true
                        }
                    }
                }
                placedLetters[match].text = letter.text
                orderedLetters[letter.id].isShown = false
                gameFinished = game.checkWord(letterArray: placedLetters)
                if (gameFinished) {
                    print("coucou2")
                    timer.stop()
                }
            }
            return .good
        } else {
            return .unknown
        }
    }
    
    func letterRec(letter: Binding<Letter>, fix: Bool = false) -> some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
                .fill(Color.white)
                .shadow(radius: 3)
                .shadow(color: getDragColor(state: letter.wrappedValue.dragState, fix: fix)
                        , radius: letter.wrappedValue.offset == .zero ? 0 : 10)
                .onAppear {
                    letter.lastOffset.wrappedValue = geometry.frame(in: .local)
                }
        }
    }
    
    func getDragColor(state: DragState, fix: Bool) -> Color {
        if fix { return .clear }
        switch state {
            case .good: return .green
            case .unknown: return .black
            case .bad: return .red
        }
    }
}
