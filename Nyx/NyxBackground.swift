//
//  NyxBackground.swift
//  Nyx
//
//  Created by BitDegree on 31/05/25.
//

import SwiftUI

struct NyxBackground: View {
    @State private var starOpacity: Double = 0
    let nyxColors = NyxColors()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        nyxColors.backgroundStart,
                        nyxColors.backgroundMid,
                        nyxColors.backgroundEnd
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Cosmic dust effect
                ForEach(0..<100) { _ in
                    NyxStar()
                }
                
                // Mystical fog effect
                NyxFogEffect()
            }
        }
        .ignoresSafeArea()
    }
}

struct NyxStar: View {
    @State private var twinkling = false
    @State private var position = CGPoint.zero
    
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: CGFloat.random(in: 1...3))
            .opacity(twinkling ? 0.2 : 0.7)
            .position(position)
            .onAppear {
                position = CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                )
                withAnimation(Animation.easeInOut(duration: Double.random(in: 0.5...2.0)).repeatForever()) {
                    twinkling.toggle()
                }
            }
    }
}
