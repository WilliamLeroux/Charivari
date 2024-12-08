//
//  ContentView.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-26.
//

import SwiftUI
import UIKit

/// Structure représentant la vue du menu
struct MenuView: View {
    @ObservedObject var bgManager = BackgroundManager.shared /// Gestionnaire du background
    @ObservedObject var network : NetworkMonitor /// Gestionnaire du réseau
    @State private var name: String = "" /// Nom du joueur
    @State private var noName: Bool = true /// Booléen indiquant si le joueur a du réseau
    private var timer = TimerManager.shared /// Gestionnaire du timer
    private var game = GameManager.shared /// Gestionnaire du jeu
    
    init(network: NetworkMonitor) {
        self.network = network
        network.delegate = game
        game.checkDatabase()
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
                        GameView().navigationBarBackButtonHidden(true)
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
            }.onAppear{
                self.$noName.wrappedValue = !game.hasName()
            }
        }
    }
    
    /// Envoie le nom de l'utilisateur
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
    var backgroundVw: some View { /// Background
        Image(bgManager.getBackgroundImage(id: self.bgManager.backgroundId))
            .resizable()
            .scaledToFill()
            .ignoresSafeArea(.all)
    }
}
