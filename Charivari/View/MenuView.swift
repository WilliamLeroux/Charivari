//
//  ContentView.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-26.
//

import SwiftUI
import UIKit

struct MenuView: View {
    @ObservedObject var bgManager = BackgroundManager.shared
    private var timer = TimerManager.shared
    @State var isPlaying = false
    @State var inRanking = false
    private var game = GameManager.shared
    @State private var orderedLetters: [Letter] = []
    @State private var placedLetters: [Letter] = []
    @State private var buttonFrame: [CGRect] = []
    @State private var name: String = ""
    @ObservedObject var network : NetworkMonitor
    @State private var noName: Bool = true
    
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
                        NavigationLink("Profil") {
                            ProfilePreferenceView().navigationBarBackButtonHidden(true)
                        }
                        .font(.system(size: 15))
                        .padding(.leading, -5.807)
                        .foregroundStyle(.white)
                        .frame(width: 55, height: 30)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                            .fill(Color.blue)
                        )
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
                        RankingView().navigationBarBackButtonHidden(true)
                    }
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 175, height: 60)
                    .background(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15))
                                    .fill(Color.blue)
                    )
                }
                .alert("Enter a name", isPresented: $noName) {
                    TextField("Name", text: $name)
                        .autocorrectionDisabled()
                    
                    Button("OK", action: {
                        submit()
                    })
                }
                .navigationDestination(for: String.self) { string in
                    GameView(game: game, orderedLetters: orderedLetters, placedLetters: placedLetters, buttonFrame: buttonFrame).navigationBarBackButtonHidden(true)
                }
            }.onAppear{
                self.$noName.wrappedValue = !game.hasName()
            }
        }
    }
    func submit() {
        if (name.isEmpty) {
            noName.toggle()
        } else {
            game.setName(name: name)
            noName = false
        }
    }
}

#Preview {
    MenuView(network: NetworkMonitor.shared)
}

private extension MenuView {
    var backgroundVw: some View {
        Image(bgManager.getBackgroundImage(id: self.bgManager.backgroundId))
            .resizable()
            .scaledToFill()
            .ignoresSafeArea(.all)
    }
}
