//
//  RankingView.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-26.
//

import SwiftUI

/// Structure représentant la vue du classement
struct RankingView: View {
    @Environment(\.dismiss) private var dismiss /// Variable d'environnement pour retourner a la vue précédente
    @State private var searchText: String = "" /// Recherche
    @StateObject private var scoreManager = ScoreManager() /// Gestionnaire du score
    
    var body: some View {
        ZStack{
            backgroundVw
            Group{
                VStack{
                    HStack{
                        TextField("Search", text: $searchText, prompt: Text("Search")
                                .foregroundStyle(.black.opacity(0.7))
                        )
                            .padding()
                            .foregroundStyle(.black)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(16)
                            .frame(width: 385, height: 55)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Button(action: search) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 35))
                                .fontWeight(.bold)
                                .foregroundStyle(.black.opacity(0.7))
                                .padding()
                        }
                        .frame(width: 55, height: 55)
                        .background(searchText.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(15)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(width: 450)
                    
                    List{
                        if let scores = scoreManager.score?.List {
                            ForEach(scores, id: \.Player) { score in
                                scoreRow(score: score, word: scoreManager.word)
                            }
                        } else {
                            GeometryReader { geometry in
                                VStack {
                                    Label("", systemImage: "magnifyingglass")
                                        .font(.system(size: 35))
                                        .fontWeight(.bold)
                                        .foregroundStyle(.black.opacity(0.7))
                                    Text("La recherche de score est vide")
                                        .font(.system(size: 25))
                                }
                                .position(x: geometry.size.width/2, y: geometry.size.height+30)
                            }
                            .listRowBackground(Color.clear)
                            .scrollDisabled(true)
                            .frame(width: 450, height: 55)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(15)
                    .scrollDisabled(scoreManager.score == nil || scoreManager.score!.List == nil)
                }
                .padding(.top, 100)
                .frame(width: 450, height: 400)
                
                VStack{
                    Text("Ranking")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 32.0)
                        .padding(.leading, 15)
                }
            }
        }
        .toolbar {
            Button("Back") {
                dismiss()
            }
            .fontWeight(.bold)
            .frame(width: 100, height: 44)
            .background(Color.green.secondary)
            .cornerRadius(16)
            .foregroundStyle(.white)
        }
    }
    
    /// Affiche une ligne de score
    /// - Parameters:
    ///   - score: Score
    ///   - word: Mot
    /// - Returns: View
    private func scoreRow(score: ScoreList, word: String) -> some View {
        HStack{
            Text(word)
            Text("\(score.Player)")
                .fixedSize()
            Spacer()
            Text("\(score.Score)")
                .fixedSize()
        }
    }
    
    /// Recherche le mot
    private func search() {
        scoreManager.getScore(word: searchText)
    }
}

#Preview {
    RankingView()
}

private extension RankingView {
    var backgroundVw: some View { /// Background
        Image(.rankingBackground)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea(.all)
    }
}
