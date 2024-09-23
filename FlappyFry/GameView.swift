//
//  GameView.swift
//  FlappyFry
//
//  Created by Andrey Sandler on 23.09.2024.
//

import SwiftUI

struct GameView: View {
    @State private var birdPosition = CGPoint(x: 100, y: 300)
    
    @State private var topPipeHeight = Double.random(in: 100...500)
    @State private var pipeOffset = 0.0
    
    @State private var score = 0
    
    private let defaultSettings = GameSettings.defaultSettings
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    Image(.background)
                        .resizable()
                        .scaleEffect(CGSize(
                            width: geometry.size.width * 0.003, height: geometry.size.height * 0.0017
                        )
                        )
                    
                    HeadView(headSize: defaultSettings.headSize)
                        .position(birdPosition)
                    
                    PipesView(
                        topPipeHeight: topPipeHeight,
                        pipeWidth: defaultSettings.pipeWidth,
                        pipeSpacing: defaultSettings.pipeSpacing
                    )
                    .offset(x: geometry.size.width + pipeOffset)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Text(score.formatted())
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
            }
        }
    }
}

#Preview {
    GameView()
}
