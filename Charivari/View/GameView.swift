//
//  GameView.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-26.
//
import SwiftUI

struct GameView: View {
    @ObservedObject var word: FetchWord
    @ObservedObject var game: GameManager
    @ObservedObject var timer = TimerManager()
    @State var letters: Array<Letter>
    @State var letOffset: CGSize = .zero
    
    init(fetchWord: FetchWord) {
        self.word = fetchWord
        game = GameManager(username: "abc")
        letters = []
        timer.start()
        getNewWord()
    }
    var body: some View {
        NavigationStack {
            ZStack{
                backgroundVw
                VStack{
                    Text("Time:" + " \(String(format: "%.2f", timer.time))")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .padding()
                    emptyBoxes
                    letterBoxes
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    func getNewWord() {
        Task {
            //let tempWord =  await word.getWord(difficulty: "1")
            //sleep(5)
            let tempWord = Word(Word: "mi", Secret: "123", Error: "")
            game.setWord(word: tempWord)
            letters = game.orderedLetters
        }
    }
}

#Preview {
    GameView(fetchWord: FetchWord())
}

private extension GameView {
    var backgroundVw: some View {
        Image(.background)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea(.all)
    }
}

private extension GameView {
    var letterBoxes: some View {
        Grid {
            GridRow {
                
                ForEach(game.getOrderedLetters(), id: \.id) { letter in
                    
                    
                    Text("\(letter.text)")
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(width: 50, height: 50)
                        .background(letterRec)
                        .offset(letOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { drag in
                                    game.updateOffset(id: letter.id, offset: drag.translation)
                                    letOffset = drag.translation
                                }
                                .onEnded { drag in
                                    game.updateOffset(id: letter.id, offset: .zero)
                                    letOffset = .zero
                                }
                        )
                        
                }
            }
            .frame(width: 75, height: 75)
            .gridCellUnsizedAxes([.horizontal, .vertical])
        }
    }
    var emptyBoxes: some View {
        Grid {
            GridRow {
                ForEach(game.placedLetters, id: \.self) { letter in
                    Text("")
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(width: 50, height: 50)
                        .background(letterRec)
                }
            }
            .frame(width: 75, height: 75)
            .gridCellUnsizedAxes([.horizontal, .vertical])
        }
    }
    
    var letterRec: some View {
        RoundedRectangle(cornerSize: CGSize(width: 10, height: 10))
            .fill(Color.white)
            .shadow(radius: 3)
    }
}

