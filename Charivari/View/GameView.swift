//
//  GameView.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-26.
//
import SwiftUI

struct GameView: View {
    var game: GameManager
    @State var orderedLetters: [Letter]
    @ObservedObject var timer = TimerManager.shared
    @State var placedLetters: [Letter]
    @State var buttonFrame: [CGRect]
    
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
                    //emptyBoxes
                    letterBoxes
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    GameView(game: GameManager(username: "abc"), orderedLetters: ([Letter(id: 0, text: "a", offset: .zero), Letter(id: 1, text: "b", offset: .zero), Letter(id: 2, text: "c", offset: .zero)]), placedLetters: ([Letter(id: 0, text: " ", offset: .zero), Letter(id: 1, text: " ", offset: .zero), Letter(id: 2, text: " ", offset: .zero)]), buttonFrame: ([CGRect](repeating: .zero, count: 3)))
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
        VStack {
            Grid {
                GridRow {
                    ForEach($placedLetters, id: \.id) { $letter in
                        Text("\(letter.text)")
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
                                }
                            )
                            .onTapGesture {
                                
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
        }
    }
    
    func letterMoved(location: CGPoint, letter: Letter, dropped: Bool = false) -> DragState {
        if let match = buttonFrame.firstIndex(where: {
            $0.contains(location) }) {
            if (dropped) {
                placedLetters[match].text = letter.text
                placedLetters[match].dragState = .unknown
                orderedLetters[letter.id].isShown = false
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

