//
//  RankingView.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-26.
//

import SwiftUI

struct RankingView: View {
    var body: some View {
        NavigationStack {
            ZStack{
                backgroundVw
                VStack{
                    Text("Ranking")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 28.0)
                        .padding(.leading, 15)
                }
                
            }
        }
    }
}

#Preview {
    RankingView()
}

private extension RankingView {
    var backgroundVw: some View {
        Image(.rankingBackground)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea(.all)
    }
}
