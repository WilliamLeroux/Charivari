//
//  ProfilePreferenceView.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-27.
//

import SwiftUI

/// Structure représentant la vue des réglages
struct ProfilePreferenceView: View {
    @Environment(\.dismiss) private var dismiss /// Variable d'environnement pour retourner à la vue précédente
    @ObservedObject var bgManager = BackgroundManager.shared /// Gestionnaire du background
    @State private var name: String = "" /// Nom du joueur
    @State private var nameChange: Bool = false /// booléen indiquant si le nom est changé
    @State private var newBackground: String = "Background 1" /// Nouveau background
    @State private var newDifficulty: String = "\(String(localized: "Easy"))" /// Nouvelle difficulté
    private let game = GameManager.shared /// Gestionnaire de jeu
    private let backgrounds: [String] = ["Background 1", "Background 2", "Background 3", "Background 4", "Background 5"] /// Tableau contenant les background
    private let difficulties: [String] = ["\(String(localized: "Random"))", "\(String(localized: "Easy"))", "\(String(localized: "Medium"))", "\(String(localized: "Hard"))"] /// Tableau contenant les difficultés
    
    public var body: some View {
        ZStack {
            backgroundVw
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                    .frame(height: 20)
                
                Text("Your name:")
                    .font(.title)
                    .fontWeight(.bold)
                HStack{
                    Text(name)
                    
                    Button("Change", action: {
                        nameChange = true
                    })
                    .foregroundStyle(.white)
                    .frame(width: 75, height: 30)
                    .background(Color.blue)
                    .cornerRadius(16)
                    .alert("Enter a name", isPresented: $nameChange) {
                        TextField("Name", text: $name)
                            .autocorrectionDisabled()
                            .foregroundStyle(.black)
                        
                        Button("OK", action: {
                            submit()
                        })
                        .foregroundStyle(.blue)
                    }
                }
                
                Text("Difficulty:")
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack{
                    Picker("Difficulty", selection: $newDifficulty) {
                        ForEach(difficulties, id: \.self) { difficulty in
                            Text(difficulty)
                            
                        }
                    }
                    .onChange(of: newDifficulty) {
                        updateDifficulty(difficulty: newDifficulty)
                    }
                }
                
                Text("Background:")
                    .font(.title)
                    .fontWeight(.bold)
                    
                HStack{
                    Picker("Background", selection: $newBackground) {
                        ForEach(backgrounds, id: \.self) { background in
                            Text(background)
                        }
                    }
                    .onChange(of: newBackground) {
                        var id = 0
                        switch(newBackground) {
                            case "Background 1": id = 0
                                break
                            case "Background 2": id = 1
                                break
                            case "Background 3": id = 2
                                break
                            case "Background 4": id = 3
                                break
                            case "Background 5": id = 4
                                break
                        default: break
                        }
                        changeBackground(id: id)
                    }
                }
                
                Button("Back") {
                    dismiss()
                }
                .frame(width: 75, height: 30)
                .background(Color.blue)
                .cornerRadius(16)
            }
            .scrollDisabled(false)
            .foregroundStyle(.white)
            .frame(width: 500, height: 450)
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
        }
        .onAppear {
            switch(bgManager.backgroundId){
                case 0: newBackground = "Background 1"
                break
            case 1: newBackground = "Background 2"
                break
            case 2: newBackground = "Background 3"
                break
            case 3: newBackground = "Background 4"
                break
            case 4: newBackground = "Background 5"
                break
            default: self.newBackground = "Background 1"
                break
            }
            self.$name.wrappedValue = game.getName()
            
            switch(game.difficulty) {
            case "1": newDifficulty = "\(String(localized: "Easy"))"
                break
            case "2": newDifficulty = "\(String(localized: "Medium"))"
                break
            case "3": newDifficulty = "\(String(localized: "Hard"))"
                break
            default: newDifficulty = "\(String(localized: "Random"))"
            }
        }
    }
    
    /// Met à jour le nom du joueur
    private func submit() {
        if (name.isEmpty) {
            nameChange.toggle()
        } else {
            game.setName(name: name)
            nameChange = false
        }
    }
    
    /// Met à jour le background
    /// - Parameter id: <#id description#>
    private func changeBackground(id: Int) {
        bgManager.setBackgroundId(id: id)
    }
    
    /// Met à jour la difficulté choisi par le joueur
    /// - Parameter difficulty: Difficulté
    private func updateDifficulty(difficulty: String) {
        switch difficulty {
        case "\(String(localized: "Easy"))": game.setDifficulty(difficulty: "1")
            break
        case "\(String(localized: "Medium"))": game.setDifficulty(difficulty: "2")
            break
        case "\(String(localized: "Hard"))": game.setDifficulty(difficulty: "3")
            break
        default: game.setDifficulty(difficulty: "0")
            break
        }
    }
}

#Preview {
    ProfilePreferenceView()
}

private extension ProfilePreferenceView {
    var backgroundVw: some View { /// Background
        Image(bgManager.getBackgroundImage(id: self.bgManager.backgroundId))
            .resizable()
            .scaledToFill()
            .ignoresSafeArea(.all)
    }
}


