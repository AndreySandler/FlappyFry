//
//  HeadView.swift
//  FlappyFry
//
//  Created by Andrey Sandler on 23.09.2024.
//

import SwiftUI

struct HeadView: View {
    let headSize: Double
    
    var body: some View {
        Image(.head)
            .resizable()
            .scaledToFit()
            .frame(width: headSize, height: headSize)
        
            .border(Color.red, width: 2)
    }
}

#Preview {
    HeadView(headSize: 100)
}
