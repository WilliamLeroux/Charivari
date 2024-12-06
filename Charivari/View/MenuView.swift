//
//  ContentView.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-26.
//

import SwiftUI

struct MenuView: View {
    private var timer = TimerManager.shared
    @State var isPlaying = false
    @State var inRanking = false
    private var game = GameManager.shared
    @State private var orderedLetters: [Letter] = []
    @State private var placedLetters: [Letter] = []
    @State private var buttonFrame: [CGRect] = []
    @State private var name: String = ""
    @ObservedObject var network : NetworkMonitor
    @State private var noName: Bool = false
    
    init(network: NetworkMonitor) {
        self.network = network
        network.delegate = game
        game.pickNewWord()
        orderedLetters = game.orderedLetters
        game.checkDatabase()
        for letter in orderedLetters{
            placedLetters.append(Letter(id: letter.id, text: " ", offset: .zero))
            buttonFrame.append(.zero)
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                backgroundVw
                    .toolbar {
                        if (!network.connected){
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 25))
                                .foregroundStyle(.red)
                        }
                        Button(action: {}) {
                            Image(systemName: "person.crop.circle.fill")
                                .frame(width: 50, height: 50)
                                .font(.system(size: 25))
                                .foregroundStyle(.black)
                        }
                    }
                VStack{
                    Text("Charivari")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                        .frame(height: 40)
                    
                    
                    NavigationLink("Play") {
                        GameView(game: game, orderedLetters: orderedLetters, placedLetters: placedLetters, buttonFrame: buttonFrame).navigationBarBackButtonHidden(true)
                    }
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 100, height: 60)
                    .background(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                    .fill(Color.blue)
                    )
                    
                    Spacer()
                        .frame(height: 20)
                    
                    NavigationLink("Ranking") {
                        RankingView()
                    }
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 175, height: 60)
                    .background(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                    .fill(Color.blue)
                    )
                }
                .navigationDestination(for: String.self) { string in
                    GameView(game: game, orderedLetters: orderedLetters, placedLetters: placedLetters, buttonFrame: buttonFrame).navigationBarBackButtonHidden(true)
                }
            }
        }
    }
    
    private func checkNetwork() {
        if (!network.getNetworkState()) {
            
        }
    }
}

#Preview {
    MenuView(network: NetworkMonitor.shared)
}

private extension MenuView {
    var backgroundVw: some View {
        Image(.background4)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea(.all)
    }
}
