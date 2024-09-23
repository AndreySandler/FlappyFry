//
//  PipesView.swift
//  FlappyFry
//
//  Created by Andrey Sandler on 23.09.2024.
//

import SwiftUI

struct PipesView: View {
    let topPipeHeight: Double
    let pipeWidth: Double
    let pipeSpacing: Double
    
    var body: some View {
        
        // MARK: - Upper Pipe
        GeometryReader { geometry in
            VStack {
                Image(.pipe)
                    .resizable()
                    .rotationEffect(.degrees(180))
                    .frame(width: pipeWidth, height: topPipeHeight)
                
                // MARK: - Spacer
                Spacer(minLength: pipeSpacing)
                
                // MARK: - Down Pipe
                Image(.pipe)
                    .resizable()
                    .frame(
                        width: pipeWidth,
                        height: geometry.size.height - topPipeHeight - pipeSpacing
                    )
                
                    .border(Color.red, width: 2)
            }
        }
    }
}

#Preview {
    PipesView(topPipeHeight: 300, pipeWidth: 100, pipeSpacing: 100)
}
