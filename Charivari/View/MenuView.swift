//
//  ContentView.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-26.
//

import SwiftUI

struct MenuView: View {
    @State var isPlaying = false
    @State var inRanking = false
    @State private var path: [String] = []
    @StateObject private var fetchWord = FetchWord()
    
    let network: NetworkMonitor
    
    init(network: NetworkMonitor) {
        self.network = network
        
    }
    
    var body: some View {
        NavigationStack(path: $path){
            ZStack{
                backgroundVw
                    .toolbar {
                        if (!network.getNetworkState()){
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 25))
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
                    Spacer()
                        .frame(height: 40)
                    Button(action: play) {
                        Text("Play")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Rectangle())
                            .buttonBorderShape(.circle)
                    }
                    
                    NavigationLink(destination: GameView(fetchWord: fetchWord).navigationBarBackButtonHidden(true), isActive: $isPlaying) {
                        EmptyView()
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    Button(action: ranking) {
                        Text("Ranking")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Rectangle())
                            .buttonBorderShape(.circle)
                    }
                    NavigationLink(destination: RankingView().navigationBarBackButtonHidden(true), isActive: $inRanking) {
                        EmptyView()
                    }
                }
            }
        }
        .environmentObject(fetchWord)
    }
    private func play() {
        self.isPlaying = true
    }
    
    private func ranking() {
        self.inRanking = true
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
        Image(.background)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea(.all)
    }
}


