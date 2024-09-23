//
//  GameView.swift
//  FlappyFry
//
//  Created by Andrey Sandler on 23.09.2024.
//

import SwiftUI

enum GameState {
    case ready, active, stopped
}

struct GameView: View {
    @State private var gameState: GameState = .ready
    
    @State private var headPosition = CGPoint(x: 100, y: 300)
    @State private var headVelocity = CGVector(dx: 0, dy: 0)
    
    @State private var topPipeHeight = Double.random(in: 100...500)
    @State private var pipeOffset = 0.0
    @State private var passedPipe = false
    
    @State private var score = 0
    @AppStorage(wrappedValue: 0, "highScore") private var highScore: Int
    
    @State private var lastUpdateTime = Date()
    
    private let defaultSettings = GameSettings.defaultSettings
    
    private let timer = Timer.publish(
        every: 0.01,
        on: .main,
        in: .common
    ).autoconnect()
    
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
                        .position(headPosition)
                    
                    PipesView(
                        topPipeHeight: topPipeHeight,
                        pipeWidth: defaultSettings.pipeWidth,
                        pipeSpacing: defaultSettings.pipeSpacing
                    )
                    .offset(x: geometry.size.width + pipeOffset)
                    
                    if gameState == .ready {
                        Button(action: playButtonAction) {
                            Image(systemName: "play.fill")
                                .scaleEffect(x: 3.5, y: 3.5)
                        }
                        .foregroundColor(.white)
                    }
                    
                    if gameState == .stopped {
                        ResultView(score: score, highScore: highScore) {
                            resetGame()
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Text(score.formatted())
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
                .onTapGesture {
                    if gameState == .active {
                        // MARK: - Vertical speed up
                        headVelocity = CGVector(dx: 0, dy: defaultSettings.jumpVelocity)
                    }
                }
                .onReceive(timer) { currentTime in
                    guard gameState == .active else { return }
                    let deltaTime = currentTime.timeIntervalSince(lastUpdateTime)
                    
                    applyGravity(deltaTime: deltaTime)
                    updateHeadPosition(deltaTime: deltaTime)
                    checkBounds(geometry: geometry)
                    updatePipePosition(deltaTime: deltaTime)
                    resetPipePositionIfNeeded(geometry: geometry)
                    
                    if checkCollision(with: geometry) {
                        gameState = .stopped
                    }
                    
                    lastUpdateTime = currentTime
                }
            }
        }
    }
    // MARK: - Play Tapped
    private func playButtonAction() {
        gameState = .active
        lastUpdateTime = Date()
    }
    
    // MARK: - Reset Tapped
    private func resetGame() {
        headPosition = CGPoint(x: 100, y: 300)
        headVelocity = CGVector(dx: 0, dy: 0)
        pipeOffset = 0
        topPipeHeight = Double.random(
            in: defaultSettings.minPipeHeight...defaultSettings.maxPipeHeight
        )
        score = 0
        gameState = .ready
    }
    
    // MARK: - Gravity
    private func applyGravity(deltaTime: TimeInterval) {
        headVelocity.dy += Double(defaultSettings.gravity * deltaTime)
    }
    
    // MARK: - Update current position
    private func updateHeadPosition(deltaTime: TimeInterval) {
        headPosition.y += headVelocity.dy * deltaTime
    }
    
    // MARK: - Check Bounds
    private func checkBounds(geometry: GeometryProxy) {
        // MARK: - Check upper bounds
        if headPosition.y <= 0 {
            headPosition.y = 0
        }
        // MARK: - Check low bounds
        if headPosition.y > geometry.size.height - defaultSettings.groundHeight - defaultSettings.headSize / 2 {
            headPosition.y = geometry.size.height - defaultSettings.groundHeight - defaultSettings.headSize / 2
            headVelocity.dy = 0
        }
    }
    // MARK: - Update Pipe Position
    private func updatePipePosition(deltaTime: TimeInterval) {
        pipeOffset -= Double(defaultSettings.pipeSpeed * deltaTime)
    }
    
    // MARK: - Reset Pipe Position
    private func resetPipePositionIfNeeded(geometry: GeometryProxy) {
        if pipeOffset <= -geometry.size.width - defaultSettings.pipeWidth {
            pipeOffset = 0
            topPipeHeight = Double.random(in: defaultSettings.minPipeHeight...defaultSettings.maxPipeHeight)
        }
    }
    private func checkCollision(with geometry: GeometryProxy) -> Bool {
        
        // MARK: - Head Collision
        let birdFrame = CGRect(
            x: headPosition.x - defaultSettings.headRadius / 2,
            y: headPosition.y - defaultSettings.headRadius / 2,
            width: defaultSettings.headRadius,
            height: defaultSettings.headRadius
        )
        
        // MARK: - Collision upper pipe
        let topPipeFrame = CGRect(
            x: geometry.size.width + pipeOffset,
            y: 0,
            width: defaultSettings.pipeWidth,
            height: topPipeHeight
        )
        
        // MARK: - Collision down pipe
        let bottomPipeFrame = CGRect(
            x: geometry.size.width + pipeOffset,
            y: topPipeHeight + defaultSettings.pipeSpacing,
            width: defaultSettings.pipeWidth,
            height: topPipeHeight
        )
        
        // MARK: - Check colision if it crashed
        return birdFrame.intersects(topPipeFrame) || birdFrame.intersects(bottomPipeFrame)
    }
    
    // MARK: - Update score and high score
    private func updateScoresAndHighScore(geometry: GeometryProxy) {
        if pipeOffset + defaultSettings.pipeWidth + geometry.size.width < headPosition.x && !passedPipe {
            score += 1
            // MARK: - Update high score
            if score > highScore {
                highScore = score
            }
            // MARK: - Fixed score
            passedPipe = true
        } else if pipeOffset + geometry.size.width > headPosition.x {
            // MARK: - Reset pipe
            passedPipe = false
        }
    }
}

#Preview {
    GameView()
}
